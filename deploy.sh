#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# OpenClaw + Gradient AI — Deploy Updates (run from repo on Droplet)
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

WORKSPACE_DIR="$HOME/.openclaw/workspace"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Pulling latest changes..."
git -C "$SCRIPT_DIR" pull origin main

echo "Updating persona files..."
for f in IDENTITY.md AGENTS.md HEARTBEAT.md; do
  if [ -f "$SCRIPT_DIR/data/workspace/$f" ]; then
    cp "$SCRIPT_DIR/data/workspace/$f" "$WORKSPACE_DIR/$f"
  fi
done

echo "Updating Python dependencies..."
pip3 install --break-system-packages -q -r "$SCRIPT_DIR/requirements.txt"

echo "Restarting OpenClaw..."
sudo systemctl restart openclaw

sleep 3
if systemctl is-active --quiet openclaw; then
  echo "✅ OpenClaw restarted successfully"
else
  echo "⚠️  Check logs: journalctl -u openclaw -f"
fi
