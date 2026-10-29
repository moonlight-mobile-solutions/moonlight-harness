#Requires -Version 5.1
<#
.SYNOPSIS
Links the harness skills into each agent's user-level skills directory (Windows, macOS, Linux).

.DESCRIPTION
On Windows the links are directory junctions, which need neither admin rights nor Developer Mode.
An existing skill with the same name is moved to ~/.moonlight-harness/backups/<timestamp>/<agent>/ before linking,
and -Uninstall moves the latest backup back.

.EXAMPLE
./scripts/install.ps1 -DryRun
./scripts/install.ps1 -Agent claude,agents -Stack common,flutter
./scripts/install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
  [string[]]$Agent = @('claude', 'agents'),
  [string[]]$Stack = @('all'),
  [switch]$DryRun,
  [switch]$Uninstall,
  [switch]$List
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$SkillsDir = Join-Path $Root 'skills'
$Conf = Join-Path $PSScriptRoot 'agents.conf'
$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$BackupRoot = if ($env:MOONLIGHT_HARNESS_BACKUP_DIR) { $env:MOONLIGHT_HARNESS_BACKUP_DIR } else { Join-Path (Join-Path $UserHome '.moonlight-harness') 'backups' }
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$IsWindowsHost = [System.Environment]::OSVersion.Platform -eq 'Win32NT'
$LinkType = if ($IsWindowsHost) { 'Junction' } else { 'SymbolicLink' }

function Invoke-Step([string]$Description, [scriptblock]$Action) {
  if ($DryRun) { Write-Host "    [dry-run] $Description" } else { & $Action | Out-Null }
}

function Split-List([string[]]$Value) {
  ($Value -join ',') -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

function Get-AgentDir([string]$Name) {
  $entries = Get-Content $Conf | Where-Object { $_.Trim() -and $_ -notmatch '^\s*#' }
  $line = $entries | Where-Object { ($_.Trim() -split '\s+')[0] -eq $Name } | Select-Object -First 1
  if (-not $line) {
    $known = ($entries | ForEach-Object { ($_.Trim() -split '\s+')[0] }) -join ' '
    throw "Unknown agent '$Name'. Known: $known"
  }
  $dir = ($line.Trim() -split '\s+', 2)[1].Replace('$HOME', $UserHome)
  [System.IO.Path]::GetFullPath($dir)
}

function Get-SelectedStacks {
  $available = Get-ChildItem -LiteralPath $SkillsDir -Directory | Sort-Object Name | ForEach-Object { $_.Name }
  if ((Split-List $Stack) -contains 'all') { return $available }
  foreach ($name in Split-List $Stack) {
    if ($available -notcontains $name) { throw "Unknown stack '$name'. Known: $($available -join ' ')" }
    $name
  }
}

function Get-SelectedSkills {
  foreach ($name in Get-SelectedStacks) {
    Get-ChildItem -LiteralPath (Join-Path $SkillsDir $name) -Directory |
      Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') } |
      Sort-Object Name
  }
}

function Get-LinkTarget([string]$Path) {
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType) { return [string]($item.Target | Select-Object -First 1) }
  $null
}

function Test-PointsIntoRepo([string]$Path) {
  $target = Get-LinkTarget $Path
  $prefix = $SkillsDir.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  $target -and $target.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
}

function Remove-Link([string]$Path) {
  Invoke-Step "remove link $Path" { [System.IO.Directory]::Delete($Path, $false) }
}

function Install-Into([string]$AgentName, [string]$Dest) {
  if (-not (Test-Path -LiteralPath $Dest)) {
    Invoke-Step "mkdir $Dest" { New-Item -ItemType Directory -Path $Dest -Force }
  }
  foreach ($skill in Get-SelectedSkills) {
    $target = Join-Path $Dest $skill.Name
    $current = Get-LinkTarget $target
    if ($current -and $current.TrimEnd('\', '/') -eq $skill.FullName) {
      Write-Host "  = $($skill.Name)"
      continue
    }
    if ($current -or (Test-Path -LiteralPath $target)) {
      $backup = Join-Path (Join-Path $BackupRoot $Stamp) $AgentName
      Write-Host "  ~ $($skill.Name) (backup of the existing one in $backup)"
      Invoke-Step "mkdir $backup" { New-Item -ItemType Directory -Path $backup -Force }
      Invoke-Step "move $target -> $backup" { Move-Item -LiteralPath $target -Destination $backup }
    } else {
      Write-Host "  + $($skill.Name)"
    }
    Invoke-Step "$LinkType $target -> $($skill.FullName)" { New-Item -ItemType $LinkType -Path $target -Target $skill.FullName }
  }
  if (Test-Path -LiteralPath $Dest) {
    foreach ($entry in Get-ChildItem -LiteralPath $Dest -Force) {
      if ((Test-PointsIntoRepo $entry.FullName) -and -not (Test-Path -LiteralPath (Get-LinkTarget $entry.FullName))) {
        Write-Host "  - $($entry.Name) (no longer in the harness)"
        Remove-Link $entry.FullName
      }
    }
  }
}

function Get-LatestBackup([string]$AgentName, [string]$SkillName) {
  if (-not (Test-Path -LiteralPath $BackupRoot)) { return $null }
  Get-ChildItem -LiteralPath $BackupRoot -Directory | Sort-Object Name -Descending |
    ForEach-Object { Join-Path (Join-Path $_.FullName $AgentName) $SkillName } |
    Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}

function Uninstall-From([string]$AgentName, [string]$Dest) {
  if (-not (Test-Path -LiteralPath $Dest)) { return }
  foreach ($entry in Get-ChildItem -LiteralPath $Dest -Force) {
    if (Test-PointsIntoRepo $entry.FullName) {
      Write-Host "  - $($entry.Name)"
      Remove-Link $entry.FullName
      $backup = Get-LatestBackup $AgentName $entry.Name
      if ($backup) {
        Write-Host "  < $($entry.Name) (restored from $backup)"
        Invoke-Step "move $backup -> $Dest" { Move-Item -LiteralPath $backup -Destination (Join-Path $Dest $entry.Name) }
      }
    }
  }
}

$skills = @(Get-SelectedSkills)

if ($List) {
  $skills | ForEach-Object { "$($_.Parent.Name)/$($_.Name)" }
  exit 0
}

$duplicates = $skills | Group-Object Name | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name }
if ($duplicates) { throw "Skill names must be unique across stacks: $($duplicates -join ' ')" }

foreach ($name in Split-List $Agent) {
  $dest = Get-AgentDir $name
  Write-Host "$name -> $dest"
  if ($Uninstall) { Uninstall-From $name $dest } else { Install-Into $name $dest }
}

if ($DryRun) { Write-Host 'Dry run: nothing changed.' }
