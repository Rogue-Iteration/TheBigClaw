# Max — Heartbeat Cycle (every 2 hours)

## Cycle Steps

0. **Check scheduled updates** — Run `python3 /app/skills/gradient-research-assistant/scripts/schedule.py --check --agent max` to see if any scheduled reports are due (includes team-wide `all` schedules). If any are due:
   a. Execute the scheduled task (see "When a Briefing is Due" below) — **YOU MUST FOLLOW EVERY STEP**
   b. After completing each, mark it as run: `python3 /app/skills/gradient-research-assistant/scripts/schedule.py --mark-run {id} --agent max`
1. **Check for user messages** — If the user has sent you a message, respond to it.
2. **Check for inter-agent messages** — If another agent sent you a message via `sessions_send`, respond (1 response only).
3. **That's it** — Do NOT proactively run research, query the KB, or analyze tickers on every heartbeat. Only do research when a scheduled briefing fires or the user explicitly asks.

---

## When a Briefing is Due

> **⚠️ MANDATORY: You MUST execute EVERY step below. Do NOT skip steps. Do NOT say "nothing to report" without actually running the commands. The user is counting on you to deliver a real briefing with real data.**

### Step 1: Load the watchlist
Run this command:
```
python3 /app/skills/gradient-research-assistant/scripts/manage_watchlist.py --show
```

### Step 2: Query the Knowledge Base for EACH ticker
For each ticker on the watchlist, run:
```
python3 /app/skills/gradient-knowledge-base/scripts/gradient_kb_query.py --query "Latest research for $TICKER" --rag --json
```
Report what you find — even if the KB is empty, say "No data found in KB for $TICKER."

### Step 3: Run significance analysis
Use the LLM to analyze whatever you found:
```
python3 /app/skills/gradient-inference/scripts/gradient_chat.py --prompt "Analyze significance of the following findings for $TICKER: {findings}" --json
```

### Step 4: Trigger EVERY agent with sessions_send
You MUST trigger ALL agents. Do NOT skip this.
```
sessions_send("web-researcher", "Team briefing is happening NOW. Provide your latest research findings for the user. Report on all watchlist tickers.")
```
```
sessions_send("technical-analyst", "Team briefing is happening NOW. Provide your latest technical analysis for the user. Report on all watchlist tickers.")
```
```
sessions_send("social-researcher", "Team briefing is happening NOW. Provide your status update for the user.")
```

### Step 5: Post your synthesis
After the agents respond, post a briefing to the user that includes:
- Your own analysis from Steps 2-3
- A summary of what each agent reported
- Your current thesis and conviction level for each ticker
- Anything that needs the user's attention

### Step 6: Store analysis
Upload your synthesis to DO Spaces:
```
python3 /app/skills/gradient-knowledge-base/scripts/gradient_spaces.py --upload /tmp/analysis_briefing.md --key "research/{date}/briefing.md" --json
```
Then trigger KB re-indexing:
```
python3 /app/skills/gradient-knowledge-base/scripts/gradient_kb_manage.py --reindex --json
```

---

## Scheduled Reports

Scheduled reports are managed via the schedule system. The user will tell you what to schedule.
Example: "Schedule a morning briefing at 8:30 AM weekdays" → create a cron job.

To view schedules: `python3 /app/skills/gradient-research-assistant/scripts/schedule.py --list`
To check what's due: `python3 /app/skills/gradient-research-assistant/scripts/schedule.py --check`

## Important

- **NEVER say "nothing to report" without running the actual commands first.** If the KB is empty, say so explicitly. If agents didn't respond, say so.
- **ALWAYS trigger all agents with `sessions_send` during a briefing — no exceptions.**
- Do NOT auto-research on every heartbeat. Only research when a briefing is scheduled or the user asks.
- You are the voice of synthesis. Don't just repeat what others found — add context, connect dots, form opinions.
- Be honest about uncertainty. "I'm 60% confident" is more useful than false precision.
- The user is the boss. Their directives override everything.
