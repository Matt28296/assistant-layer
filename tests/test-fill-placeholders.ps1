<#
test-fill-placeholders.ps1 -- offline checks for tools/fill-placeholders.ps1 and for the templates it
fills. Needs nothing but Windows PowerShell 5.1 or PowerShell 7: no modules, no network, no sign-in.
Every fill happens in a temporary folder that is removed at the end; the repository is only read.

Run it on the UNFILLED template. A deployed copy has no placeholders left, so it has nothing to test.
  powershell -ExecutionPolicy Bypass -File tests\test-fill-placeholders.ps1
  pwsh -File tests/test-fill-placeholders.ps1 -Companion ../assistant-layer

-Companion (optional) is a checkout of the other repository of the pair. When it is given, the files
the two repositories share must be identical in both (line endings aside).

This file is identical in both repositories, and it stays ASCII: Windows PowerShell 5.1 reads a
script saved without a byte-order mark in the ANSI code page. Non-ASCII test values are built from
character codes for that reason.

Exit code: the number of failed checks. 0 = every check passed.
#>
param([string]$Companion = '')
$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).ProviderPath
$filler = Join-Path (Join-Path $repo 'tools') 'fill-placeholders.ps1'
$ps = (Get-Process -Id $PID).Path
$utf8 = New-Object System.Text.UTF8Encoding($false)
$tokenPattern = '\{\{[A-Z_]+\}\}'
$scannedExts = @('.md', '.json', '.cmd', '.sh', '.txt')
$sharedFiles = @(
    'docs/AUTHORITY.md', 'docs/BUS-PROTOCOL.md', 'docs/CONTINUITY.md', 'docs/LAWS.md', 'docs/RESTART.md',
    'docs/brains/LIBRARIAN.md', 'docs/brains/README.md', 'docs/tools/README.md',
    'tools/fill-placeholders.ps1', 'values.example.json', 'tests/test-fill-placeholders.ps1'
)

$script:passed = 0
$script:failed = 0
function Check([string]$Name, [bool]$Ok, [string]$Detail = '') {
    if ($Ok) { $script:passed++; Write-Output "PASS  $Name"; return }
    $script:failed++
    Write-Output "FAIL  $Name"
    if ($Detail) { $Detail.Trim() -split "`r?`n" | ForEach-Object { Write-Output ('        ' + $_) } }
}

function Invoke-Filler([string]$ValuesPath, [string]$RootPath) {
    $ErrorActionPreference = 'Continue'
    $out = & $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $filler -Values $ValuesPath -Root $RootPath 2>&1 |
        ForEach-Object { "$_" } | Out-String
    [pscustomobject]@{ Code = $LASTEXITCODE; Out = $out }
}

function Get-Scanned([string]$Dir) {
    Get-ChildItem -Path $Dir -Recurse -File -Force | Where-Object {
        $_.FullName -notmatch '[\\/]\.git[\\/]' -and ($scannedExts -contains $_.Extension) -and ($_.Name -notlike 'values*.json')
    }
}

# Every file under a folder, as relative path -> text, so "nothing was written" can be compared.
function Get-Snapshot([string]$Dir) {
    $snap = @{}
    Get-ChildItem -Path $Dir -Recurse -File -Force | ForEach-Object {
        $snap[$_.FullName.Substring($Dir.Length)] = [IO.File]::ReadAllText($_.FullName)
    }
    $snap
}
function Test-SameSnapshot($A, $B) {
    if ($A.Count -ne $B.Count) { return $false }
    foreach ($k in $A.Keys) { if (-not $B.ContainsKey($k) -or $A[$k] -cne $B[$k]) { return $false } }
    $true
}

function ConvertTo-JsonText([string]$S) { '"' + $S.Replace('\', '\\').Replace('"', '\"') + '"' }
# Written by hand, as UTF-8 WITHOUT a byte-order mark: that is how most editors save values.json, and
# it is the case Windows PowerShell 5.1 used to decode as ANSI.
function Write-Values([string]$Path, [hashtable]$V) {
    $lines = foreach ($k in $V.Keys) { '  {0}: {1}' -f (ConvertTo-JsonText $k), (ConvertTo-JsonText $V[$k]) }
    [IO.File]::WriteAllText($Path, "{`n" + ($lines -join ",`n") + "`n}`n", $utf8)
}

function Write-Text([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { $null = New-Item -ItemType Directory -Path $dir -Force }
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

$hostHere = ''
try { $hostHere = ((& hostname) | Out-String).Trim() } catch { $hostHere = '' }

# 'Zoe Lukas' with a diaeresis and a Polish L-stroke: non-ASCII, and not all of it in any ANSI code page.
$principal = 'Zo' + [char]0x00EB + ' ' + [char]0x0141 + 'ukas'
$business = 'Back\slash "Quoted" Co'

$tmp = Join-Path ([IO.Path]::GetTempPath()) ('fill-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$null = New-Item -ItemType Directory -Path $tmp
$tmp = (Resolve-Path $tmp).ProviderPath

$script:caseNo = 0
function New-Case {
    $script:caseNo++
    $agents = Join-Path $tmp ("case{0}" -f $script:caseNo)
    $c = [pscustomobject]@{
        Agents    = $agents
        Head      = Join-Path $agents 'head'
        Assistant = Join-Path $agents 'assistant'
        Values    = Join-Path $agents 'values.json'
    }
    $null = New-Item -ItemType Directory -Path $c.Head, $c.Assistant -Force
    $c
}
function Get-GoodValues($Case) {
    @{
        '_how'                 = 'test values'
        'PRINCIPAL_NAME'       = $principal
        'BUSINESS_NAME'        = $business
        'BUSINESS_DESCRIPTION' = 'a test business'
        'OPERATOR_NAME'        = 'Test Operator'
        'HOSTNAME'             = $hostHere
        'AGENTS_ROOT'          = $Case.Agents
        'ASSISTANT_DIR'        = $Case.Assistant
        'HEAD_DIR'             = $Case.Head
        'TIMEZONE'             = 'UTC'
        'SETUP_DATE'           = '2026-01-02'
    }
}
# A small repository with one of each thing the filler must handle.
function New-Fixture([string]$Dir) {
    Write-Text (Join-Path $Dir 'notes.md') "{{PRINCIPAL_NAME}} works at {{HEAD_DIR}} in {{TIMEZONE}}.`n"
    Write-Text (Join-Path $Dir 'state/x.json') "{`n  `"cwd`": `"{{HEAD_DIR}}`",`n  `"who`": `"{{BUSINESS_NAME}}`"`n}`n"
    Write-Text (Join-Path $Dir '.hidden-dir/inner.md') "{{PRINCIPAL_NAME}}`n"
    Write-Text (Join-Path $Dir '.git/ignored.md') "{{PRINCIPAL_NAME}}`n"
    Write-Text (Join-Path $Dir 'values.local.json') "{ `"x`": `"{{PRINCIPAL_NAME}}`" }`n"
    # A dot-folder is hidden to pwsh on macOS and Linux; mark it hidden on Windows too, so this case
    # checks the same thing everywhere.
    if ([IO.Path]::DirectorySeparatorChar -eq '\') {
        $hidden = Get-Item -LiteralPath (Join-Path $Dir '.hidden-dir') -Force
        $hidden.Attributes = $hidden.Attributes -bor [IO.FileAttributes]::Hidden
    }
}

try {
    Write-Output "Testing $filler"
    Write-Output "with $ps"
    Write-Output ''

    # --- The templates themselves -----------------------------------------------------------------
    $example = $null
    try { $example = [IO.File]::ReadAllText((Join-Path $repo 'values.example.json')) | ConvertFrom-Json } catch { }
    Check 'values.example.json parses' ($null -ne $example)
    $keys = @()
    $notPlaceholder = @()
    if ($example) {
        $props = @($example.PSObject.Properties | Where-Object { $_.Name -notlike '_*' })
        $keys = @($props | ForEach-Object { $_.Name })
        $notPlaceholder = @($props | Where-Object { $_.Value -notmatch '^(CHANGE_ME|SET_ON_DEVICE)$' } | ForEach-Object { $_.Name })
    }
    Check 'every value in values.example.json is CHANGE_ME or SET_ON_DEVICE, so an unedited copy is refused' `
        ($notPlaceholder.Count -eq 0) ('not a placeholder: ' + ($notPlaceholder -join ', '))

    $used = @{}
    foreach ($f in (Get-Scanned $repo)) {
        foreach ($m in [regex]::Matches([IO.File]::ReadAllText($f.FullName), $tokenPattern)) {
            $name = $m.Value.Trim('{', '}')
            if (-not $used.ContainsKey($name)) { $used[$name] = $f.FullName.Substring($repo.Length + 1) }
        }
    }
    Check 'the templates use at least one placeholder (this is an unfilled template)' ($used.Count -gt 0)
    $noKey = @($used.Keys | Where-Object { $keys -notcontains $_ } | ForEach-Object { '{0} (in {1})' -f $_, $used[$_] })
    Check 'every placeholder the templates use is a key in values.example.json' ($noKey.Count -eq 0) ($noKey -join "`n")

    $nonAscii = @()
    foreach ($rel in 'tools/fill-placeholders.ps1', 'tests/test-fill-placeholders.ps1') {
        $bytes = [IO.File]::ReadAllBytes((Join-Path $repo $rel))
        if (@($bytes | Where-Object { $_ -gt 127 }).Count -gt 0) { $nonAscii += $rel }
    }
    Check 'the PowerShell scripts are pure ASCII (Windows PowerShell 5.1 reads them as ANSI)' ($nonAscii.Count -eq 0) ($nonAscii -join ', ')

    if ($Companion) {
        $comp = (Resolve-Path $Companion).ProviderPath
        $diff = @()
        foreach ($rel in $sharedFiles) {
            $a = Join-Path $repo $rel
            $b = Join-Path $comp $rel
            if (-not (Test-Path -LiteralPath $a) -or -not (Test-Path -LiteralPath $b)) { $diff += "$rel (missing in one repository)"; continue }
            $ta = [IO.File]::ReadAllText($a).Replace("`r`n", "`n")
            $tb = [IO.File]::ReadAllText($b).Replace("`r`n", "`n")
            if ($ta -cne $tb) { $diff += $rel }
        }
        Check ("the {0} shared files are identical in the companion repository" -f $sharedFiles.Count) ($diff.Count -eq 0) ($diff -join "`n")
    }
    else {
        Write-Output 'SKIP  shared files vs the companion repository (no -Companion given)'
    }

    Check 'hostname prints something to test against' ($hostHere -ne '')

    # --- Filling this repository's real templates ---------------------------------------------------
    $c = New-Case
    Get-ChildItem -Path $repo -Force | Where-Object { $_.Name -ne '.git' } |
        ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $c.Head -Recurse -Force }
    $v = Get-GoodValues $c
    Write-Values $c.Values $v
    $r = Invoke-Filler $c.Values $c.Head
    Check 'real templates: fills them and reports OK (exit 0)' ($r.Code -eq 0 -and $r.Out -match 'OK - no placeholders left') $r.Out
    $left = @(Get-Scanned $c.Head | Where-Object { [regex]::IsMatch([IO.File]::ReadAllText($_.FullName), $tokenPattern) } |
        ForEach-Object { $_.FullName.Substring($c.Head.Length + 1) })
    Check 'real templates: no placeholder is left in any file' ($left.Count -eq 0) ($left -join "`n")
    $badJson = @(Get-Scanned $c.Head | Where-Object { $_.Extension -eq '.json' } | Where-Object {
        try { $null = [IO.File]::ReadAllText($_.FullName) | ConvertFrom-Json; $false } catch { $true } } |
        ForEach-Object { $_.FullName.Substring($c.Head.Length + 1) })
    Check 'real templates: every JSON file still parses' ($badJson.Count -eq 0) ($badJson -join "`n")
    $claude = [IO.File]::ReadAllText((Join-Path $c.Head 'CLAUDE.md'), [Text.Encoding]::UTF8)
    Check 'real templates: a non-ASCII name from a values file without a byte-order mark arrives intact' `
        ($claude.Contains($principal)) 'CLAUDE.md does not contain the name exactly as written in values.json'

    $snap = Get-Snapshot $c.Head
    $v['TIMEZONE'] = 'Europe/Corrected'
    Write-Values $c.Values $v
    $r = Invoke-Filler $c.Values $c.Head
    Check 'run again after correcting a value: refuses to say OK (exit 3), because the correction was not applied' `
        ($r.Code -eq 3 -and $r.Out -notmatch 'OK - no placeholders left' -and $r.Out -match 'nothing to fill') $r.Out
    Check 'run again after correcting a value: changes no file' (Test-SameSnapshot $snap (Get-Snapshot $c.Head))

    # --- JSON escaping, hidden folders, and what must never be touched ----------------------------
    $c = New-Case
    New-Fixture $c.Head
    $v = Get-GoodValues $c
    Write-Values $c.Values $v
    $r = Invoke-Filler $c.Values $c.Head
    Check 'fixture: fills and reports OK (exit 0)' ($r.Code -eq 0) $r.Out
    $x = $null
    try { $x = [IO.File]::ReadAllText((Join-Path $c.Head 'state/x.json')) | ConvertFrom-Json } catch { }
    Check 'JSON: a path, a backslash and a quote are escaped, and read back exactly' `
        ($null -ne $x -and $x.cwd -ceq $c.Head -and $x.who -ceq $business) ([IO.File]::ReadAllText((Join-Path $c.Head 'state/x.json')))
    Check 'text files get the raw value' `
        ([IO.File]::ReadAllText((Join-Path $c.Head 'notes.md'), [Text.Encoding]::UTF8) -ceq "$principal works at $($c.Head) in UTC.`n")
    Check 'a file inside a hidden dot-folder is filled' `
        ([IO.File]::ReadAllText((Join-Path $c.Head '.hidden-dir/inner.md'), [Text.Encoding]::UTF8) -ceq "$principal`n")
    Check 'nothing under .git is touched' ([IO.File]::ReadAllText((Join-Path $c.Head '.git/ignored.md')) -ceq "{{PRINCIPAL_NAME}}`n")
    Check 'values*.json files are not touched' `
        ([IO.File]::ReadAllText((Join-Path $c.Head 'values.local.json')) -ceq "{ `"x`": `"{{PRINCIPAL_NAME}}`" }`n")

    # --- Refusals: each must exit with its code and write nothing ----------------------------------
    function Test-Refusal([string]$Name, [scriptblock]$Change, [int]$Code, [string]$Says, [string]$RootOverride = '') {
        $c = New-Case
        New-Fixture $c.Head
        $v = Get-GoodValues $c
        & $Change $v $c
        Write-Values $c.Values $v
        $root = if ($RootOverride) { Join-Path $c.Agents $RootOverride } else { $c.Head }
        if ($RootOverride) { New-Fixture $root }
        $snap = Get-Snapshot $c.Agents
        $r = Invoke-Filler $c.Values $root
        Check "$Name (exit $Code)" ($r.Code -eq $Code -and $r.Out -match $Says) $r.Out
        Check "$Name - writes nothing" (Test-SameSnapshot $snap (Get-Snapshot $c.Agents))
    }

    Test-Refusal 'a value left as CHANGE_ME is refused' { param($v, $c) $v['TIMEZONE'] = 'CHANGE_ME' } 2 'still unset'
    Test-Refusal 'a missing key leaves a placeholder, so nothing is filled' { param($v, $c) $v.Remove('TIMEZONE') } 1 '\{\{TIMEZONE\}\}'
    Test-Refusal 'HOSTNAME that is not what hostname prints is refused' { param($v, $c) $v['HOSTNAME'] = 'NOT-' + $hostHere } 2 'HOSTNAME'
    Test-Refusal 'HEAD_DIR outside AGENTS_ROOT is refused' { param($v, $c) $v['AGENTS_ROOT'] = Join-Path $c.Agents 'elsewhere' } 2 'HEAD_DIR'
    Test-Refusal 'ASSISTANT_DIR equal to HEAD_DIR is refused' { param($v, $c) $v['ASSISTANT_DIR'] = $c.Head } 2 'two different folders'
    Test-Refusal 'a relative path is refused' { param($v, $c) $v['ASSISTANT_DIR'] = 'assistant' } 2 'full path'
    Test-Refusal 'a repository that is neither seat folder is refused' { param($v, $c) } 2 'neither' 'other'

    $c = New-Case
    New-Fixture $c.Head
    $snap = Get-Snapshot $c.Agents
    $r = Invoke-Filler (Join-Path $c.Agents 'no-such-values.json') $c.Head
    Check 'a values file that does not exist is refused (exit 2)' ($r.Code -eq 2 -and $r.Out -match 'Could not read') $r.Out
    Write-Text $c.Values '{ "PRINCIPAL_NAME": '
    $r = Invoke-Filler $c.Values $c.Head
    Check 'a values file that is not valid JSON is refused (exit 2)' ($r.Code -eq 2 -and $r.Out -match 'Could not read') $r.Out
    Remove-Item -LiteralPath $c.Values
    Check 'an unreadable values file writes nothing' (Test-SameSnapshot $snap (Get-Snapshot $c.Agents))
}
finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ''
Write-Output ("{0} passed, {1} failed" -f $script:passed, $script:failed)
exit $script:failed
