# Claude Code: бэкап и восстановление

Claude Code хранит почти всё локально, а не в аккаунте. Бан не стирает эти файлы, но при смене компьютера их легко потерять.

## Что бэкапим

| Путь | Что там | Нужно? |
|---|---|---|
| ~/.claude/CLAUDE.md | Глобальные инструкции | Да |
| ~/.claude/settings.json | Разрешения, хуки, модель | Да |
| ~/.claude/commands/, agents/, skills/, plugins/ | Команды, сабагенты, скиллы, плагины | Да |
| ~/.claude.json | Глобальные MCP-серверы | Да (внутри могут быть токены MCP) |
| ~/.claude/projects/ | История сессий и авто-память | По желанию |
| ~/.claude/.credentials.json | Токен входа | Нет |

В репозиториях: CLAUDE.md, .claude/, .mcp.json — сохраняются через Git. CLAUDE.local.md и .claude/settings.local.json обычно в .gitignore — их собирает скрипт.

## Как запускать

Скрипты лежат в этой папке отдельными файлами: backup-claude-code.sh (macOS/Linux) и backup-claude-code.ps1 (Windows). Копируйте файлы, а не текст из этого документа.

macOS/Linux: bash backup-claude-code.sh ~/projects

Windows: powershell -ExecutionPolicy Bypass -File backup-claude-code.ps1 -CodeDir C:\code

Автозапуск по пятницам (macOS, crontab -e): 0 18 * * 5 bash ~/backup-claude-code.sh ~/projects

Автозапуск (Windows, cmd от админа): schtasks /create /sc weekly /d FRI /st 18:00 /tn ClaudeBackup /tr "powershell -ExecutionPolicy Bypass -File %USERPROFILE%\backup-claude-code.ps1"

Если стоит Google Drive for Desktop, скрипт сам положит архивы в папку Claude Backup.

## Восстановление

1. Установить Claude Code.
2. Распаковать claude-code-backup-*.zip в домашнюю папку с заменой.
3. Распаковать claude-code-projects-*.zip в папку с кодом поверх клонированных репозиториев.
4. claude → /login новым аккаунтом.
5. /mcp — переавторизовать серверы с OAuth. /plugin — проверить плагины.
