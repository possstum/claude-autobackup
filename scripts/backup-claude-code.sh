#!/usr/bin/env bash
# Бэкап Claude Code (macOS / Linux).
# Запуск: bash backup-claude-code.sh [папка_с_кодом]   (по умолчанию ~/projects)
# Если стоит Google Drive for Desktop и есть папка "Claude Backup" — архивы копируются туда.
set -euo pipefail
CODE_DIR="${1:-$HOME/projects}"
HOST="$(hostname -s 2>/dev/null || hostname)"
OUT1="$HOME/claude-code-backup-$HOST.zip"
OUT2="$HOME/claude-code-projects-$HOST.zip"
rm -f "$OUT1" "$OUT2"

cd "$HOME"
TARGETS=()
[ -d .claude ] && TARGETS+=(.claude)
[ -f .claude.json ] && TARGETS+=(.claude.json)
if [ ${#TARGETS[@]} -eq 0 ]; then echo "Claude Code не найден в $HOME"; exit 1; fi
zip -qr "$OUT1" "${TARGETS[@]}" \
  -x '.claude/.credentials.json' '.claude/shell-snapshots/*' \
     '.claude/statsig/*' '.claude/todos/*' '.claude/ide/*'

if [ -d "$CODE_DIR" ]; then
  cd "$CODE_DIR"
  find . \( -name 'CLAUDE*.md' -o -name '.mcp.json' -o -path '*/.claude/*' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -type f -print \
    | zip -q "$OUT2" -@ || true
fi

DRIVE="$(ls -d "$HOME"/Library/CloudStorage/GoogleDrive-*/*/"Claude Backup" 2>/dev/null | head -1 || true)"
if [ -n "$DRIVE" ]; then
  cp -f "$OUT1" "$DRIVE"/ ; [ -f "$OUT2" ] && cp -f "$OUT2" "$DRIVE"/
  echo "Скопировано в Google Drive: $DRIVE"
else
  echo "Google Drive for Desktop не найден — загрузите архивы в папку Claude Backup вручную:"
fi
ls -lh "$OUT1" "$OUT2" 2>/dev/null || true
