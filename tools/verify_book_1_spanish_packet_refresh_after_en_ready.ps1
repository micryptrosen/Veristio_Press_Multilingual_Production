[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
    param([string]$Message)
    $script:failures.Add($Message)
}

function Assert-Exists {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Failure "$Label missing: $Path"
    }
}

function Assert-FileContains {
    param(
        [string]$File,
        [string]$Needle,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $File)) {
        Add-Failure "$Label file missing: $File"
        return
    }

    $content = Get-Content -LiteralPath $File -Raw
    if ($content -notmatch [regex]::Escape($Needle)) {
        Add-Failure "$Label missing phrase: $Needle"
    }
}

$packetDir = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis'
$packetFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_PACKET_PREPARATION_V1.md'
$gapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$intakeDecisionFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_INTAKE_DECISION_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$syncLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHANGE_SYNC_LOG_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_PACKET_REFRESH_AFTER_EN_READY_RECEIPT_V1.md'

$requiredFiles = @(
    @{ Path = $packetFile; Label = 'Book 1 packet preparation file' },
    @{ Path = $gapLogFile; Label = 'Book 1 gap log file' },
    @{ Path = $intakeDecisionFile; Label = 'Book 1 intake decision file' },
    @{ Path = $trackerFile; Label = 'Book 1 tracker file' },
    @{ Path = $syncLogFile; Label = 'Book 1 change sync log' },
    @{ Path = $receiptFile; Label = 'Packet refresh receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$lockVersion = 'BOOK1-CH01-EN-LOCK-V1'
$lockedSourceCommit = 'bd0441d4a5cf8e5862a61421b3d515eb079afee4'
$book1CurrentHead = 'db3e5b92784ab6e01c4882b283aaa78d22399a44'
$readinessState = 'EN_TRANSLATION_READY_WITH_CONDITIONS'
$nextConditionCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_GLOSSARY_AND_REVIEWER_SETUP_V1'
$nextDraftCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_TRANSLATION_DRAFT_PACKET_V1'

Assert-FileContains -File $packetFile -Needle $readinessState -Label 'Packet readiness state check'
Assert-FileContains -File $packetFile -Needle $lockVersion -Label 'Packet English lock check'
Assert-FileContains -File $packetFile -Needle $lockedSourceCommit -Label 'Packet locked source commit check'
Assert-FileContains -File $packetFile -Needle $book1CurrentHead -Label 'Packet Book 1 current HEAD check'
Assert-FileContains -File $packetFile -Needle 'Book 1 repo remains canonical for English manuscript text' -Label 'Packet authority boundary check'

if (Test-Path -LiteralPath $intakeDecisionFile) {
    $intakeContent = Get-Content -LiteralPath $intakeDecisionFile -Raw
    $match = [regex]::Match($intakeContent, '(?m)^## Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Intake decision file does not declare a decision under ## Decision.'
    } else {
        $decision = $match.Groups[1].Value
        if ($decision -eq 'HOLD_FOR_EN_TRANSLATION_READY') {
            Add-Failure 'Intake decision must no longer be HOLD_FOR_EN_TRANSLATION_READY.'
        }
        $allowed = @(
            'READY_FOR_TRANSLATION_DRAFT_PACKET',
            'READY_WITH_CONDITIONS',
            'HOLD_FOR_GLOSSARY_REVIEW',
            'HOLD_FOR_REVIEWER_AVAILABILITY',
            'HOLD_FOR_METADATA_ISBN_READINESS'
        )
        if ($allowed -notcontains $decision) {
            Add-Failure "Intake decision is not allowed after EN ready refresh: $decision"
        }
    }
}

Assert-FileContains -File $trackerFile -Needle 'Chapter 1' -Label 'Tracker Chapter 1 check'
Assert-FileContains -File $trackerFile -Needle $readinessState -Label 'Tracker readiness state check'
Assert-FileContains -File $trackerFile -Needle 'READY_WITH_CONDITIONS' -Label 'Tracker translation state check'
Assert-FileContains -File $syncLogFile -Needle $lockVersion -Label 'Change-sync lock check'
Assert-FileContains -File $gapLogFile -Needle 'CLOSED' -Label 'Gap closure status check'
Assert-FileContains -File $gapLogFile -Needle 'Book 1 commit `db3e5b92784ab6e01c4882b283aaa78d22399a44` records Chapter 1 as `EN_TRANSLATION_READY_WITH_CONDITIONS`' -Label 'EN_TRANSLATION_READY gap closure check'

$corridorFound = $false
foreach ($file in @($packetFile, $gapLogFile, $intakeDecisionFile, $trackerFile, $syncLogFile, $receiptFile, (Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'), (Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'))) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($nextConditionCorridor) -or $content -match [regex]::Escape($nextDraftCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure 'Expected next corridor is not present.'
}

$filesToScan = @(
    $packetFile,
    $gapLogFile,
    $intakeDecisionFile,
    $trackerFile,
    $syncLogFile,
    $receiptFile,
    (Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'),
    (Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'),
    (Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'),
    (Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md')
)

$translationStartedRegex = '(?i)(Spanish translation has begun|Spanish translation began|translation execution started|Spanish draft created|ES_TRANSLATION_DRAFT\s*[:=]\s*(created|complete|started))'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|passed|ready))'
$authorityTransferRegex = '(?i)(Multilingual Production repo owns.*canonical English manuscript|this repo owns.*Book 1 canonical English manuscript)'

foreach ($file in $filesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match $translationStartedRegex) {
        Add-Failure "File appears to claim Spanish translation has begun: $file"
    }
    if ($content -match $publicationReadyRegex) {
        Add-Failure "File appears to claim Spanish publication readiness: $file"
    }
    if ($content -match $authorityTransferRegex) {
        Add-Failure "File appears to transfer Book 1 canonical English manuscript authority: $file"
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'VERIFICATION FAIL' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'VERIFICATION PASS' -ForegroundColor Green
Write-Host "Repo root: $repoRoot"
exit 0
