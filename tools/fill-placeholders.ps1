<#
fill-placeholders.ps1 -- fills every {{TOKEN}} in this repository from a values file, then REFUSES to
report success while any {{TOKEN}} is left anywhere.

Why it refuses: a half-filled charter looks finished. A seat reading an unfilled working-directory
placeholder cannot match its own identity and stops -- which then looks like a broken install rather
than a missed value. The leftover scan runs after every fill, so "OK" is a measurement, not a hope.

JSON files get JSON-escaped values. A Windows path such as C:\Users\name written raw into a .json
file is invalid JSON (\U is not a legal escape), and a state file that no longer parses fails every
reader that opens it.

Usage (once per repository, with the SAME values file):
  powershell -ExecutionPolicy Bypass -File tools\fill-placeholders.ps1 -Values ..\values.json

Exit codes: 0 = filled, nothing left, all JSON parses.  1 = placeholders remain or JSON broken.
            2 = values file unreadable or a value still unset.
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
$Root = (Resolve-Path $Root).Path

try { $vals = Get-Content -Raw -Path $Values | ConvertFrom-Json }
catch { Write-Output "Could not read values file '$Values': $($_.Exception.Message)"; exit 2 }

$mapText = @{}
$mapJson = @{}
$unset = @()
foreach ($p in $vals.PSObject.Properties) {
    if ($p.Name -like '_*') { continue }
    $v = [string]$p.Value
    if ([string]::IsNullOrWhiteSpace($v) -or $v -match 'CHANGE_ME|SET_ON_DEVICE') { $unset += $p.Name; continue }
    $key = '{{' + $p.Name + '}}'
    $mapText[$key] = $v
    $mapJson[$key] = $v.Replace('\', '\\').Replace('"', '\"')
}
if ($unset.Count -gt 0) {
    Write-Output ("NOT DONE - these values are still unset in {0}: {1}" -f $Values, ($unset -join ', '))
    exit 2
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$exts = @('.md', '.json', '.cmd', '.sh', '.txt')
$files = Get-ChildItem -Path $Root -Recurse -File | Where-Object {
    $_.FullName -notmatch '[\\/]\.git[\\/]' -and ($exts -contains $_.Extension) -and ($_.Name -notlike 'values*.json')
}

$changed = 0
foreach ($f in $files) {
    $map = if ($f.Extension -eq '.json') { $mapJson } else { $mapText }
    $text = [IO.File]::ReadAllText($f.FullName)
    $new = $text
    foreach ($k in $map.Keys) { $new = $new.Replace($k, $map[$k]) }
    if ($new -ne $text) { [IO.File]::WriteAllText($f.FullName, $new, $utf8); $changed++ }
}

$problems = @()
foreach ($f in $files) {
    $text = [IO.File]::ReadAllText($f.FullName)
    $found = [regex]::Matches($text, '\{\{[A-Z_]+\}\}') | ForEach-Object { $_.Value } | Sort-Object -Unique
    $rel = $f.FullName.Substring($Root.Length).TrimStart('\', '/')
    if ($found) { $problems += ('  {0}: placeholders left: {1}' -f $rel, ($found -join ', ')) }
    if ($f.Extension -eq '.json') {
        try { $null = $text | ConvertFrom-Json } catch { $problems += ('  {0}: NO LONGER VALID JSON' -f $rel) }
    }
}

Write-Output ("filled {0} file(s) under {1}" -f $changed, $Root)
if ($problems.Count -gt 0) {
    Write-Output 'NOT DONE:'
    $problems | ForEach-Object { Write-Output $_ }
    exit 1
}
Write-Output 'OK - no placeholders left in this repository, and every JSON file parses.'
exit 0
