# CLAUDE.md — OpenClaw + Gradient AI Research Assistant

## Project Overview

A proactive investment research assistant running on a **DigitalOcean Droplet**, powered by Gradient AI models via OpenClaw. Four specialized agents (Max, Nova, Luna, Ace) monitor a stock watchlist, gather research from multiple sources, and alert the user via Telegram.

## Architecture

- **Runtime**: OpenClaw gateway running as a systemd service on an Ubuntu Droplet
- **AI Backend**: Gradient AI (GPT OSS 120B, Llama 3.3, DeepSeek R1, Qwen3) via DO Inference API
- **Agents**: Max (fundamental analyst, default), Nova (web researcher), Luna (social researcher), Ace (technical analyst)
- **Messaging**: Telegram bot integration
- **Storage**: DigitalOcean Spaces (S3-compatible) + Gradient Knowledge Base for RAG
- **Skills**: Python scripts in `skills/` — shared (`gradient-research-assistant/`) and agent-specific

## Tech Stack

| Layer         | Technology                                  |
|---------------|---------------------------------------------|
| Language      | Python 3, Bash                              |
| Testing       | pytest, responses (HTTP mocking), moto (S3) |
| Dependencies  | requests, beautifulsoup4, feedparser, boto3, yfinance |
| Infra         | DigitalOcean Droplet, Spaces, Gradient AI   |
| Gateway       | OpenClaw (Node.js / pnpm)                   |

## Key Directories

```
skills/gradient-research-assistant/  → Shared skill tools (gather, analyze, alert, store, etc.)
skills/{agent-name}/                 → Agent-specific skill tools
data/workspace/                      → Shared persona files (IDENTITY, AGENTS, HEARTBEAT)
data/workspaces/{agent-name}/        → Per-agent persona files
tests/                               → pytest unit tests
```

## Deployment

### Production Deployment

**You are expected to handle production deployments yourself.** The workflow is:

1. Commit and push changes to `main`
2. SSH into the Droplet: `ssh openclaw@<droplet-ip>`
3. Run: `cd ~/openclaw-do-gradient && bash deploy.sh`
4. Verify: `systemctl status openclaw`

`deploy.sh` pulls the latest code, updates persona files, syncs agent configs, installs Python deps, and restarts the OpenClaw systemd service.

### First-Time Setup

For provisioning a new Droplet from scratch, use `setup.sh` (run as root). See `README.md` for full instructions.

### Service Management

```bash
systemctl status openclaw       # Check status
journalctl -u openclaw -f       # Tail logs
sudo systemctl restart openclaw  # Restart
```

## Droplet Safety

> **⚠️ Always ask before performing destructive actions on the Droplet.**
>
> This includes but is not limited to:
> - Deleting or overwriting files on the Droplet
> - Stopping or disabling the `openclaw` systemd service
> - Modifying `/etc/openclaw.env` or `~/.openclaw/openclaw.json`
> - Removing packages or changing system configuration
> - Any `rm`, `apt remove`, or destructive SSH commands
>
> Non-destructive reads (checking logs, status, listing files) are fine without asking.

## Testing

### Approach

- **Use TDD where it makes sense** — particularly for new skill scripts and data-processing logic where inputs/outputs are well-defined.
- **Otherwise, write test cases afterwards** — especially for integration-style work, persona file changes, or deployment scripts.
- Tests live in `tests/` and follow the naming convention `test_<skill_name>.py`.

### Running Tests

```bash
cd /Users/simoneichenauer/Development/openclaw-do-gradient
python3 -m pytest tests/ -v
```

### Test Fixtures

Mock data and fixtures live in `tests/fixtures/`. Tests use `responses` for HTTP mocking and `moto` for S3/Spaces mocking.

## Code Style & Documentation

- **Document files inline** — every Python skill script should have:
  - A module-level docstring explaining what the skill does
  - Docstrings on all public functions describing purpose, parameters, and return values
  - Inline comments for non-obvious logic
- Bash scripts should have header comments and section markers (see `setup.sh` and `deploy.sh` for examples)
- Persona files (IDENTITY.md, AGENTS.md, HEARTBEAT.md) use Markdown

## Environment Variables

All secrets live in `/etc/openclaw.env` on the Droplet (see `.env.example` for the template). **Never commit real secrets.**

Required:
- `GRADIENT_API_KEY` — Gradient AI inference API key
- `TELEGRAM_BOT_TOKEN` — Telegram bot token
- `TELEGRAM_ALLOWED_IDS` — Comma-separated Telegram user IDs

DO Spaces / Knowledge Base:
- `DO_API_TOKEN`, `DO_SPACES_ACCESS_KEY`, `DO_SPACES_SECRET_KEY`
- `DO_SPACES_ENDPOINT`, `DO_SPACES_BUCKET`, `GRADIENT_KB_UUID`

## Common Workflows

### Adding a new skill script

1. Create `skills/gradient-research-assistant/<skill_name>.py` (or under an agent-specific dir)
2. Add inline documentation (module docstring + function docstrings)
3. Write tests in `tests/test_<skill_name>.py` (TDD preferred)
4. Run `python3 -m pytest tests/ -v` to verify
5. Deploy to Droplet via `deploy.sh`

### Updating agent personas

1. Edit the relevant files in `data/workspaces/<agent-name>/`
2. Run `deploy.sh` on the Droplet — it copies persona files to each agent's workspace
3. Verify with `journalctl -u openclaw -f` after restart
