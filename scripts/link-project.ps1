#Requires -Version 5.1
<#
.SYNOPSIS
Prepares a project for the harness: AGENTS.md, CLAUDE.md, .agents/skills and the .claude/skills link.
Never overwrites a file that already exists.

.DESCRIPTION
.claude/skills is a relative symbolic link committed to the project. On Windows, creating it needs
Developer Mode (or an elevated shell), and the repo needs `git config core.symlinks true`.

.EXAMPLE
./scripts/link-project.ps1 -Project C:\dev\myapp -Name myapp -Stack flutter
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)][string]$Project,
  [string]$Name,
  [string[]]$Stack = @('common'),
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Templates = Join-Path $Root 'harness/templates'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

if (-not (Test-Path -LiteralPath $Project -PathType Container)) { throw "Not a directory: $Project" }
$Project = (Resolve-Path -LiteralPath $Project).Path
if (-not $Name) { $Name = Split-Path -Leaf $Project }

$stacks = ($Stack -join ',') -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
foreach ($s in $stacks) {
  if (-not (Test-Path -LiteralPath (Join-Path (Join-Path $Root 'skills') $s))) { throw "Unknown stack '$s'" }
}

function Invoke-Step([string]$Description, [scriptblock]$Action) {
  if ($DryRun) { Write-Host "    [dry-run] $Description" } else { & $Action | Out-Null }
}

function Test-Exists([string]$Path) {
  (Test-Path -LiteralPath $Path) -or (Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue)
}

function Skip([string]$Label) { Write-Host "  = $Label (already exists, left as is)" }

$agentsMd = Join-Path $Project 'AGENTS.md'
if (Test-Exists $agentsMd) { Skip 'AGENTS.md' } else {
  Write-Host '  + AGENTS.md'
  $text = [System.IO.File]::ReadAllText((Join-Path $Templates 'AGENTS.md'))
  $text = $text.Replace('{{PROJECT_NAME}}', $Name).Replace('{{STACKS}}', ($stacks -join ', '))
  Invoke-Step "write $agentsMd" { [System.IO.File]::WriteAllText($agentsMd, $text, $Utf8NoBom) }
}

$claudeMd = Join-Path $Project 'CLAUDE.md'
if (Test-Exists $claudeMd) { Skip 'CLAUDE.md' } else {
  Write-Host '  + CLAUDE.md'
  Invoke-Step "copy CLAUDE.md" { Copy-Item -LiteralPath (Join-Path $Templates 'CLAUDE.md') -Destination $claudeMd }
}

foreach ($dir in '.agents/skills', '.agents/rules') {
  $path = Join-Path $Project $dir
  if (Test-Exists $path) { Skip "$dir/" } else {
    Write-Host "  + $dir/"
    Invoke-Step "mkdir $path" { New-Item -ItemType Directory -Path $path -Force }
  }
}

foreach ($rule in Get-ChildItem -LiteralPath (Join-Path $Templates 'rules') -Filter '*.md') {
  $target = Join-Path (Join-Path $Project '.agents/rules') $rule.Name
  if (Test-Exists $target) { Skip ".agents/rules/$($rule.Name)" } else {
    Write-Host "  + .agents/rules/$($rule.Name)"
    Invoke-Step "copy $($rule.Name)" { Copy-Item -LiteralPath $rule.FullName -Destination $target }
  }
}

$claudeDir = Join-Path $Project '.claude'
$claudeSkills = Join-Path $claudeDir 'skills'
if (Test-Exists $claudeSkills) { Skip '.claude/skills' } else {
  Write-Host '  + .claude/skills -> ../.agents/skills'
  Invoke-Step "mkdir $claudeDir" { New-Item -ItemType Directory -Path $claudeDir -Force }
  Invoke-Step "symlink $claudeSkills -> ../.agents/skills" {
    Push-Location $claudeDir
    try {
      if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
        cmd /c mklink /D skills '..\.agents\skills' | Out-Null
      } else {
        ln -s ../.agents/skills skills
      }
    } finally {
      Pop-Location
    }
  }
  if (-not $DryRun -and -not (Get-Item -LiteralPath $claudeSkills -Force -ErrorAction SilentlyContinue)) {
    Write-Warning 'Could not create .claude/skills. On Windows, turn on Developer Mode (Settings > System > For developers) and run again.'
  }
}

if ($DryRun) { Write-Host 'Dry run: nothing changed.' } else { Write-Host 'Done. Fill the TODO markers in AGENTS.md.' }
