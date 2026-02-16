---
name: research-heartbeat
description: Run periodic research cycle for all tracked tickers
frequency: 30m
---

# Research Heartbeat

Run a full research cycle for every ticker in the watchlist.

## Steps

1. Load the watchlist:
```bash
python3 manage_watchlist.py --show
```

2. For **each ticker** in the watchlist, delegate to the specialist agents:

```bash
# Nova: gather news + SEC filings
python3 /app/skills/gradient-data-gathering/scripts/gather_web.py --ticker {{ticker}} --name "{{company_name}}" --output /tmp/web_{{ticker}}.md

# Luna: gather social sentiment
python3 /app/skills/gradient-data-gathering/scripts/gather_social.py --ticker {{ticker}} --company "{{company_name}}" --output /tmp/social_{{ticker}}.md

# Ace: gather technical data
python3 /app/skills/gradient-data-gathering/scripts/gather_technicals.py --ticker {{ticker}} --company "{{company_name}}" --output /tmp/technicals_{{ticker}}.md

# Store all reports to DO Spaces
python3 /app/skills/gradient-knowledge-base/scripts/gradient_spaces.py --upload /tmp/web_{{ticker}}.md --key "research/{date}/{{ticker}}_web.md" --json
python3 /app/skills/gradient-knowledge-base/scripts/gradient_spaces.py --upload /tmp/social_{{ticker}}.md --key "research/{date}/{{ticker}}_social.md" --json
python3 /app/skills/gradient-knowledge-base/scripts/gradient_spaces.py --upload /tmp/technicals_{{ticker}}.md --key "research/{date}/{{ticker}}_technicals.md" --json

# Trigger KB re-indexing
python3 /app/skills/gradient-knowledge-base/scripts/gradient_kb_manage.py --reindex --json

# Max: query KB and analyze significance
python3 /app/skills/gradient-knowledge-base/scripts/gradient_kb_query.py --query "Latest research findings for ${{ticker}}" --rag --json
python3 /app/skills/gradient-inference/scripts/gradient_chat.py --prompt "Analyze significance..." --json
```

3. **If any ticker's analysis reveals significant findings**, proactively send the user an alert message. Use the severity-appropriate emoji:
   - 🔴 Score 8-10 (critical)
   - 🟡 Score 6-7 (notable)
   - 🟢 Score 1-5 (low significance)

4. After processing all tickers, send a brief heartbeat summary:
   - How many tickers were checked
   - Any alerts triggered
   - Which tickers were quiet

## Notes

- Process tickers sequentially to respect rate limits on public APIs
- If a data source fails, continue with the remaining sources — partial data is better than none
- The Knowledge Base grows with each heartbeat, making future queries richer
- All research is stored as Markdown in DO Spaces at `research/{date}/{TICKER}_{source}.md`
