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

function Normalize-CopyCheck {
    param([string]$Content)
    return (($Content -replace '\s+', ' ').Trim())
}

$packetDir = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis'
$draftPacketFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_TRANSLATION_DRAFT_PACKET_V1.md'
$spanishDraftFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_V1.md'
$draftNotesFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_NOTES_V1.md'
$reviewQueueFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_QUEUE_V1.md'
$qaPrecheckFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_QA_PRECHECK_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_TRANSLATION_DRAFT_PACKET_RECEIPT_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$syncLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHANGE_SYNC_LOG_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$draftReadinessGateFile = Join-Path $packetDir 'BOOK_1_SPANISH_TRANSLATION_DRAFT_READINESS_GATE_V1.md'
$intakeDecisionFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_INTAKE_DECISION_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

$requiredFiles = @(
    @{ Path = $draftPacketFile; Label = 'Book 1 Chapter 1 Spanish translation draft packet' },
    @{ Path = $spanishDraftFile; Label = 'Book 1 Chapter 1 Spanish draft' },
    @{ Path = $draftNotesFile; Label = 'Book 1 Chapter 1 Spanish draft notes' },
    @{ Path = $reviewQueueFile; Label = 'Book 1 Chapter 1 Spanish review queue' },
    @{ Path = $qaPrecheckFile; Label = 'Book 1 Chapter 1 Spanish draft QA precheck' },
    @{ Path = $receiptFile; Label = 'Book 1 Spanish translation draft packet receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$lockVersion = 'BOOK1-CH01-EN-LOCK-V1'
$lockedSourceCommit = 'bd0441d4a5cf8e5862a61421b3d515eb079afee4'
$reviewerCoverage = 'PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY'
$nextCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_DRAFT_REVIEW_AND_TERMINOLOGY_PASS_V1'

foreach ($file in @($draftPacketFile, $spanishDraftFile, $draftNotesFile, $reviewQueueFile, $qaPrecheckFile, $receiptFile, $trackerFile, $syncLogFile, $pilotGapLogFile, $draftReadinessGateFile, $intakeDecisionFile, $handoffFile)) {
    Assert-FileContains -File $file -Needle $lockVersion -Label 'English lock version check'
    Assert-FileContains -File $file -Needle $lockedSourceCommit -Label 'Locked source commit check'
}

Assert-FileContains -File $spanishDraftFile -Needle 'PROVISIONAL DRAFT ONLY' -Label 'Draft warning check'
Assert-FileContains -File $spanishDraftFile -Needle 'NOT HUMAN REVIEWED' -Label 'Draft human review warning check'
Assert-FileContains -File $spanishDraftFile -Needle 'NOT NATIVE REVIEWED' -Label 'Draft native review warning check'
Assert-FileContains -File $spanishDraftFile -Needle 'NOT FINAL' -Label 'Draft final warning check'
Assert-FileContains -File $spanishDraftFile -Needle 'NOT PUBLICATION READY' -Label 'Draft publication warning check'
Assert-FileContains -File $spanishDraftFile -Needle $reviewerCoverage -Label 'Draft reviewer coverage check'

foreach ($file in @($draftPacketFile, $spanishDraftFile, $draftNotesFile, $reviewQueueFile, $qaPrecheckFile, $receiptFile, $trackerFile, $draftReadinessGateFile, $handoffFile)) {
    Assert-FileContains -File $file -Needle $reviewerCoverage -Label 'Reviewer coverage decision check'
}

$reviewRoles = @(
    'terminology review',
    'native-language review',
    'technical review',
    'final sync/proof review'
)

foreach ($role in $reviewRoles) {
    Assert-FileContains -File $reviewQueueFile -Needle $role -Label "Review queue role check: $role"
}

foreach ($file in @($draftPacketFile, $draftReadinessGateFile, $handoffFile)) {
    Assert-FileContains -File $file -Needle 'Book 1 remains' -Label 'Authority boundary check'
    Assert-FileContains -File $file -Needle 'canonical' -Label 'Authority boundary canonical check'
}

$corridorFound = $false
foreach ($file in @($draftPacketFile, $draftNotesFile, $reviewQueueFile, $receiptFile, $nextCorridorFile, $handoffFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($nextCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure 'Expected next corridor is not present.'
}

$filesToScan = @(
    $draftPacketFile,
    $spanishDraftFile,
    $draftNotesFile,
    $reviewQueueFile,
    $qaPrecheckFile,
    $receiptFile,
    $trackerFile,
    $syncLogFile,
    $pilotGapLogFile,
    $draftReadinessGateFile,
    $intakeDecisionFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|publication readiness\s*[:=]\s*(approved|complete|passed|ready)|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|passed|ready))'
$releaseApprovalRegex = '(?i)(final release approval granted|release approval\s*[:=]\s*(approved|complete|passed|ready)|upload-ready|upload readiness\s*[:=]\s*(approved|complete|passed|ready))'

foreach ($file in $filesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match $publicationReadyRegex) {
        Add-Failure "File appears to claim Spanish publication readiness: $file"
    }
    if ($content -match $releaseApprovalRegex) {
        Add-Failure "File appears to claim final release/upload approval: $file"
    }
}

$book1Repo = 'D:\Dev\CGPT\Projects\Veristio\Book 1 Human Creativity + AI'
$sourcePath = 'manuscript/chapters/chapter_01_work_changed_before_most_people_noticed.md'
if (-not (Test-Path -LiteralPath $book1Repo)) {
    Add-Failure "Book 1 repo path missing for full-source copy check: $book1Repo"
} else {
    $sourceContent = git -C $book1Repo show "$lockedSourceCommit`:$sourcePath"
    if ($LASTEXITCODE -ne 0) {
        Add-Failure 'Locked Book 1 source could not be read for full-source copy check.'
    } else {
        $normalizedSource = Normalize-CopyCheck -Content ($sourceContent -join "`n")
        if ($normalizedSource.Length -gt 1000) {
            foreach ($file in $filesToScan) {
                if (-not (Test-Path -LiteralPath $file)) {
                    continue
                }
                $content = Get-Content -LiteralPath $file -Raw
                $normalizedContent = Normalize-CopyCheck -Content $content
                if ($normalizedContent.Contains($normalizedSource)) {
                    Add-Failure "File appears to contain the full locked English source text: $file"
                }
            }
        }
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
