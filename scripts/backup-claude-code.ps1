# Бэкап Claude Code (Windows).
# Запуск: powershell -ExecutionPolicy Bypass -File backup-claude-code.ps1 [-CodeDir C:\path\to\code]
# Если стоит Google Drive for Desktop и есть папка "Claude Backup" — архивы копируются туда.
param([string]$CodeDir = "$env:USERPROFILE\projects")

$h = $env:USERPROFILE
$hostName = $env:COMPUTERNAME
$out1 = "$h\claude-code-backup-$hostName.zip"
$out2 = "$h\claude-code-projects-$hostName.zip"
$t = "$env:TEMP\cc-backup"

Remove-Item $t -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory $t | Out-Null
robocopy "$h\.claude" "$t\.claude" /E /XF .credentials.json /XD shell-snapshots statsig todos ide | Out-Null
Copy-Item "$h\.claude.json" $t -ErrorAction SilentlyContinue
Compress-Archive -Path "$t\*" -DestinationPath $out1 -Force

if (Test-Path $CodeDir) {
  $p = "$env:TEMP\cc-projects"
  Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
  Get-ChildItem $CodeDir -Recurse -Force -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(node_modules|\.git)\\' -and
      ($_.Name -like 'CLAUDE*.md' -or $_.Name -eq '.mcp.json' -or $_.FullName -match '\\\.claude\\') } |
    ForEach-Object {
      $rel = $_.FullName.Substring($CodeDir.Length).TrimStart('\')
      $dest = Join-Path $p $rel
      New-Item -ItemType Directory (Split-Path $dest) -Force | Out-Null
      Copy-Item $_.FullName $dest
    }
  if (Test-Path $p) { Compress-Archive -Path "$p\*" -DestinationPath $out2 -Force }
}

$drive = Get-ChildItem -Path "G:\", "$h\Google Drive" -Directory -Recurse -Depth 2 -Filter "Claude Backup" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($drive) {
  Copy-Item $out1 $drive.FullName -Force
  if (Test-Path $out2) { Copy-Item $out2 $drive.FullName -Force }
  Write-Host "Скопировано в Google Drive: $($drive.FullName)"
} else {
  Write-Host "Google Drive for Desktop не найден — загрузите архивы в папку Claude Backup вручную:"
}
Get-ChildItem "$h\claude-code-*-$hostName.zip"
