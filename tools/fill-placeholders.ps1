<#
fill-placeholders.ps1 -- fills every {{TOKEN}} in this repository from a values file, then REFUSES to
report success while any {{TOKEN}} is left anywhere.

Why it refuses: a half-filled charter looks finished. A seat reading an unfilled working-directory
placeholder cannot match its own identity and stops -- which then looks like a broken install rather
than a missed value. The leftover scan runs after every fill, so "OK" is a measurement, not a hope.

JSON files get JSON-escaped values. A Windows path such as C:\Users\name written raw into a .json
file is invalid JSON (\U is not a legal escape), and a state file that no longer parses fails every
reader that opens it.

Nothing is written until everything checks out. Every file is filled in memory first; if a
placeholder would be left, or a JSON file would stop parsing, no file is touched.

The machine values are checked against this machine before anything is written: HOSTNAME must be
exactly what `hostname` prints here, ASSISTANT_DIR and HEAD_DIR must be two different folders
directly inside AGENTS_ROOT, and this repository must be one of them. A wrong value there would
otherwise show up only later, as a seat that fails its identity check.

A repository with no placeholders left was filled already. Running again does NOT apply a corrected
value, so the filler says so (exit 3) instead of printing OK. To change a value after a fill: put the
unfilled templates back (before the fill is committed: git checkout -- .), fix the values file, and
run it again.

Usage (once per repository, with the SAME values file):
  powershell -ExecutionPolicy Bypass -File tools\fill-placeholders.ps1 -Values ..\values.json

Exit codes: 0 = filled, nothing left, all JSON parses.
            1 = placeholders would remain or JSON would break. Nothing was written.
            2 = values file unreadable, a value still unset, or a machine value that does not match
                this machine. Nothing was written.
            3 = nothing to fill: this repository was filled already. Nothing was written.
Tests: tests/test-fill-placeholders.ps1
#>
param(
    [Parameter(Mandatory = $true)][string]$Values,
    [string]$Root = ''
)
$ErrorActionPreference = 'Stop'
# Resolve the repo root in the BODY, not as a param default: under Windows PowerShell 5.1 run with
# -File, $PSScriptRoot is EMPTY while parameter defaults are evaluated, so a default built from it
# throws before the script starts. Found by the test suite on 2026-09-12, before anyone installed it.
if (-not $Root) { $Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path) }
$Root = (Resolve-Path $Root).ProviderPath

# -Encoding UTF8: without it, Windows PowerShell 5.1 decodes a values file saved without a byte-order
# mark in the ANSI code page, and a name with an accent is written garbled into every file.
try { $vals = Get-Content -Raw -Encoding UTF8 -Path $Values | ConvertFrom-Json }
catch { Write-Output "Could not read values file '$Values': $($_.Exception.Message)"; exit 2 }
if ($null -eq $vals) { Write-Output "Could not read values file '$Values': it is empty."; exit 2 }

$raw = @{}
$mapText = @{}
$mapJson = @{}
$unset = @()
foreach ($p in $vals.PSObject.Properties) {
    if ($p.Name -like '_*') { continue }
    $v = [string]$p.Value
    if ([string]::IsNullOrWhiteSpace($v) -or $v -match 'CHANGE_ME|SET_ON_DEVICE') { $unset += $p.Name; continue }
    $raw[$p.Name] = $v
    $key = '{{' + $p.Name + '}}'
    $mapText[$key] = $v
    $mapJson[$key] = $v.Replace('\', '\\').Replace('"', '\"')
}
$machineKeys = @('HOSTNAME', 'AGENTS_ROOT', 'ASSISTANT_DIR', 'HEAD_DIR')
foreach ($k in $machineKeys) { if (-not $raw.ContainsKey($k) -and $unset -notcontains $k) { $unset += $k } }
if ($unset.Count -gt 0) {
    Write-Output ("NOT DONE - these values are still unset in {0}: {1}" -f $Values, ($unset -join ', '))
    exit 2
}

# The same instrument the seats use for their identity check: the `hostname` command.
$wrong = @()
$measured = ''
try { $measured = ((& hostname) | Out-String).Trim() } catch { $measured = '' }
if (-not $measured) { $wrong += '  HOSTNAME: could not run the hostname command to check it' }
elseif ($measured -cne $raw['HOSTNAME']) {
    $wrong += ("  HOSTNAME is '{0}', but hostname prints '{1}' on this machine" -f $raw['HOSTNAME'], $measured)
}

function Get-FullDir([string]$Path) { [IO.Path]::GetFullPath($Path).TrimEnd('\', '/') }
$dirs = @{}
foreach ($k in 'AGENTS_ROOT', 'ASSISTANT_DIR', 'HEAD_DIR') {
    $p = $raw[$k]
    try {
        if (-not [IO.Path]::IsPathRooted($p)) { throw 'relative' }
        $dirs[$k] = Get-FullDir $p
    }
    catch { $wrong += ("  {0} must be a full path, not '{1}'" -f $k, $p) }
}
if ($dirs.Count -eq 3) {
    $cmp = [StringComparison]::OrdinalIgnoreCase
    foreach ($k in 'ASSISTANT_DIR', 'HEAD_DIR') {
        $parent = ([string][IO.Path]::GetDirectoryName($dirs[$k])).TrimEnd('\', '/')
        if (-not [string]::Equals($parent, $dirs['AGENTS_ROOT'], $cmp)) {
            $wrong += ("  {0} ({1}) must be a folder directly inside AGENTS_ROOT ({2})" -f $k, $raw[$k], $raw['AGENTS_ROOT'])
        }
    }
    if ([string]::Equals($dirs['ASSISTANT_DIR'], $dirs['HEAD_DIR'], $cmp)) {
        $wrong += '  ASSISTANT_DIR and HEAD_DIR must be two different folders'
    }
    $here = Get-FullDir $Root
    if (-not ([string]::Equals($here, $dirs['ASSISTANT_DIR'], $cmp) -or [string]::Equals($here, $dirs['HEAD_DIR'], $cmp))) {
        $wrong += ("  this repository is at {0}, which is neither ASSISTANT_DIR nor HEAD_DIR" -f $Root)
    }
}
if ($wrong.Count -gt 0) {
    Write-Output ("NOT DONE - these values in {0} do not match this machine:" -f $Values)
    $wrong | ForEach-Object { Write-Output $_ }
    Write-Output 'Measure them here (SETUP.md step 4), fix the values file, and run this again. Nothing was written.'
    exit 2
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$exts = @('.md', '.json', '.cmd', '.sh', '.txt')
# -Force: without it, pwsh on macOS and Linux skips dot-folders, and their placeholders stay unfilled.
$files = Get-ChildItem -Path $Root -Recurse -File -Force | Where-Object {
    $_.FullName -notmatch '[\\/]\.git[\\/]' -and ($exts -contains $_.Extension) -and ($_.Name -notlike 'values*.json')
}
$tokenPattern = '\{\{[A-Z_]+\}\}'

function Find-Problems($File, [string]$Text) {
    $rel = $File.FullName.Substring($Root.Length).TrimStart('\', '/')
    $found = [regex]::Matches($Text, $tokenPattern) | ForEach-Object { $_.Value } | Sort-Object -Unique
    if ($found) { '  {0}: placeholders left: {1}' -f $rel, ($found -join ', ') }
    if ($File.Extension -eq '.json') {
        try { $null = $Text | ConvertFrom-Json } catch { '  {0}: NO LONGER VALID JSON' -f $rel }
    }
}

# Fill every file in memory first.
$plan = @()
$templates = 0
foreach ($f in $files) {
    $text = [IO.File]::ReadAllText($f.FullName)
    if ([regex]::IsMatch($text, $tokenPattern)) { $templates++ }
    $map = if ($f.Extension -eq '.json') { $mapJson } else { $mapText }
    $new = $text
    foreach ($k in $map.Keys) { $new = $new.Replace($k, $map[$k]) }
    $plan += [pscustomobject]@{ File = $f; Old = $text; New = $new }
}

if ($templates -eq 0) {
    Write-Output ("NOT DONE - nothing to fill: no placeholders are left under {0}, so it was filled already." -f $Root)
    Write-Output ("Nothing was changed, and the values in {0} were NOT applied." -f $Values)
    Write-Output 'To change a value: put the unfilled templates back (before the fill is committed: git checkout -- .),'
    Write-Output 'fix the values file, and run this again.'
    exit 3
}

$problems = @()
foreach ($item in $plan) { $problems += @(Find-Problems $item.File $item.New) }
if ($problems.Count -gt 0) {
    Write-Output ("NOT DONE - nothing was written. Filling with {0} would leave:" -f $Values)
    $problems | ForEach-Object { Write-Output $_ }
    exit 1
}

$changed = 0
foreach ($item in $plan) {
    if ($item.New -cne $item.Old) { [IO.File]::WriteAllText($item.File.FullName, $item.New, $utf8); $changed++ }
}

# Measure again from disk: what was written, not what was meant to be written.
$problems = @()
foreach ($f in $files) { $problems += @(Find-Problems $f ([IO.File]::ReadAllText($f.FullName))) }

Write-Output ("filled {0} file(s) under {1}" -f $changed, $Root)
if ($problems.Count -gt 0) {
    Write-Output 'NOT DONE:'
    $problems | ForEach-Object { Write-Output $_ }
    exit 1
}
Write-Output 'OK - no placeholders left in this repository, and every JSON file parses.'
exit 0
