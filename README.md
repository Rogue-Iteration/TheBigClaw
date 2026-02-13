# OpenClaw + Gradient AI Research Assistant

A proactive investment research assistant running on a DigitalOcean Droplet, powered by [Gradient AI](https://www.digitalocean.com/products/ai-ml) models via [OpenClaw](https://openclaw.ai).

## What It Does

- 📊 Monitors a watchlist of stock tickers ($CAKE, $HOG, $BOOM, $LUV, $WOOF)
- 🔍 Gathers research from news, Reddit, SEC filings, and social media
- 🧠 Stores findings in a Gradient Knowledge Base for RAG queries
- 🚨 Proactively alerts you via Telegram when something significant happens
- 💬 Answers questions about your watchlist using accumulated knowledge

## Architecture

```
Telegram → OpenClaw Gateway → Gradient AI (GPT OSS 120B)
                ↓
         exec tool → Python skills
                ↓
         DO Spaces + Gradient KB
```

## Setup

### 1. Create a Droplet

```bash
doctl compute droplet create openclaw-research \
  --image ubuntu-24-04-x64 \
  --size s-1vcpu-2gb \
  --region nyc3 \
  --ssh-keys <your-ssh-key-id>
```

### 2. Create the environment file

SSH into the Droplet and create `/etc/openclaw.env`:

```bash
# Copy from .env.example and fill in your values
scp .env.example root@<droplet-ip>:/etc/openclaw.env
ssh root@<droplet-ip> nano /etc/openclaw.env
```

### 3. Run setup

```bash
ssh root@<droplet-ip>
git clone https://github.com/Rogue-Iteration/openclaw-do-gradient.git /home/openclaw/openclaw-do-gradient
cd /home/openclaw/openclaw-do-gradient
bash setup.sh
```

### 4. Deploy updates

After pushing changes to GitHub:

```bash
ssh openclaw@<droplet-ip>
cd ~/openclaw-do-gradient
bash deploy.sh
```

## Management

```bash
# Check status
systemctl status openclaw

# View logs
journalctl -u openclaw -f

# Restart
sudo systemctl restart openclaw
```

## Running Tests

```bash
cd tests
python3 -m pytest -v
```

## Project Structure

```
├── skills/gradient-research-assistant/   # Skill tools (Python scripts)
├── data/workspace/                       # Persona files (IDENTITY, AGENTS, HEARTBEAT)
├── tests/                                # Unit tests (121 tests)
├── setup.sh                              # One-time Droplet provisioning
├── deploy.sh                             # Git-pull update script
├── .env.example                          # Environment variable template
└── requirements.txt                      # Python dependencies
```
