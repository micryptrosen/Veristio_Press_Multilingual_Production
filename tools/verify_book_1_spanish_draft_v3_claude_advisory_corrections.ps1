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
$receiptDir = Join-Path $repoRoot 'docs/governance/receipts'

$draftV3File = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3.md'
$correctionPassFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_CLAUDE_ADVISORY_CORRECTION_PASS_V1.md'
$changeLogFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_CHANGE_LOG_V1.md'
$receiptFile = Join-Path $receiptDir 'BOOK_1_SPANISH_DRAFT_V3_CLAUDE_ADVISORY_CORRECTIONS_RECEIPT_V1.md'

$requiredFiles = @(
    @{ Path = $draftV3File; Label = 'Draft V3' },
    @{ Path = $correctionPassFile; Label = 'Claude advisory correction pass' },
    @{ Path = $changeLogFile; Label = 'Draft V3 change log' },
    @{ Path = $receiptFile; Label = 'Draft V3 receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$requiredDraftPhrases = @(
    'PROVISIONAL DRAFT ONLY',
    'NOT HUMAN REVIEWED',
    'NOT NATIVE REVIEWED',
    'NOT FINAL',
    'NOT PUBLICATION READY',
    'Source lock: `BOOK1-CH01-EN-LOCK-V1`',
    'Locked source commit: `bd0441d4a5cf8e5862a61421b3d515eb079afee4`'
)
foreach ($phrase in $requiredDraftPhrases) {
    Assert-FileContains -File $draftV3File -Needle $phrase -Label 'Draft V3 boundary/source check'
}

$draftContent = ''
if (Test-Path -LiteralPath $draftV3File) {
    $draftContent = Get-Content -LiteralPath $draftV3File -Raw
}

$forbiddenDraftTerms = @(
    'Dueno',
    'Aqui',
    'Contribucion',
    'útilidad',
    'lo cuál',
    'programadores de redes sociales',
    'mercadeo por correo electrónico',
    'nunca suben lo suficiente'
)
foreach ($term in $forbiddenDraftTerms) {
    if ($draftContent -match [regex]::Escape($term)) {
        Add-Failure "Draft V3 still contains forbidden advisory correction term: $term"
    }
}

$requiredCorrectionTerms = @(
    'están',
    'Dueño',
    'Aquí',
    'sitúa',
    'Contribución',
    'Más personas ahora están',
    'agregó IA',
    'producía con estilo',
    'imágenes generadas',
    'resúmenes generados',
    'además de los sistemas',
    'lo cual puede ser peor',
    'utilidad de la IA',
    'herramientas de programación de redes sociales',
    'marketing por correo electrónico',
    'nunca llegan a escalar hasta convertirse',
    'fuente única de verdad'
)
foreach ($term in $requiredCorrectionTerms) {
    if ($draftContent -notmatch [regex]::Escape($term)) {
        Add-Failure "Draft V3 missing expected correction term: $term"
    }
}

Assert-FileContains -File $correctionPassFile -Needle 'Claude advisory feedback' -Label 'Correction pass advisory source check'
Assert-FileContains -File $correctionPassFile -Needle 'advisory correction input only' -Label 'Correction pass boundary check'
Assert-FileContains -File $correctionPassFile -Needle 'contribuidor' -Label 'Terminology decision check'
Assert-FileContains -File $correctionPassFile -Needle 'fuente única de verdad' -Label 'Source truth terminology decision check'
Assert-FileContains -File $changeLogFile -Needle 'DRAFT_V3_ADVISORY_CHANGE_LOG_RECORDED' -Label 'Change log status check'
Assert-FileContains -File $receiptFile -Needle 'CLAUDE_ADVISORY_CORRECTIONS_APPLIED_TO_DRAFT_V3' -Label 'Receipt correction status check'

$scanFiles = @(
    $draftV3File,
    $correctionPassFile,
    $changeLogFile,
    $receiptFile,
    (Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_QUEUE_V1.md'),
    (Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVISION_QUEUE_V1.md'),
    (Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'),
    (Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'),
    (Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_STATUS_DECISION_V1.md'),
    (Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'),
    (Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'),
    (Join-Path $repoRoot 'controls/PHASE_LEDGER.md'),
    (Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'),
    (Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md')
)

$nativeReviewCompleteRegex = '(?i)(NATIVE_REVIEW_COMPLETE|native-language review\s*[:=]\s*(complete|completed|passed|approved)|native review\s*[:=]\s*(complete|completed|passed|approved)|native-language review is complete|native review is complete|native-language review completed|native review completed)'
$humanReviewCompleteRegex = '(?i)(HUMAN_REVIEW_COMPLETE|human review\s*[:=]\s*(complete|completed|passed|approved)|human review is complete|human review completed|human reviewer signoff granted)'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|publication readiness\s*[:=]\s*(ready|complete|completed|passed|approved)|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|completed|passed|ready|approved))'
$releaseApprovalRegex = '(?i)(final release approval granted|release approval\s*[:=]\s*(approved|complete|completed|passed|ready)|release gate\s*[:=]\s*(approved|complete|completed|passed|ready)|upload-ready files?\s*(prepared|created|approved))'

foreach ($file in $scanFiles) {
    if (-not (Test-Path -LiteralPath $file)) {
        Add-Failure "Expected updated scan file missing: $file"
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match $nativeReviewCompleteRegex) {
        Add-Failure "File appears to claim native review complete: $file"
    }
    if ($content -match $humanReviewCompleteRegex) {
        Add-Failure "File appears to claim human review complete: $file"
    }
    if ($content -match $publicationReadyRegex) {
        Add-Failure "File appears to claim publication readiness: $file"
    }
    if ($content -match $releaseApprovalRegex) {
        Add-Failure "File appears to claim release approval/upload readiness: $file"
    }
}

$allowedNextCorridors = @(
    'VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1',
    'VERISTIO_PRESS_BOOK_1_SPANISH_NATIVE_HUMAN_REVIEW_WITH_CONDITIONS_V1',
    'VERISTIO_PRESS_BOOK_1_SPANISH_TECHNICAL_REVIEW_PREP_WITH_CONDITIONS_V1',
    'APPLY_COMBINED_ADVISORY_CORRECTIONS_TO_BOOK_1_SPANISH_DRAFT_V4'
)
$nextContent = ''
foreach ($file in @((Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'), (Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'), $correctionPassFile, $receiptFile)) {
    if (Test-Path -LiteralPath $file) {
        $nextContent += "`n" + (Get-Content -LiteralPath $file -Raw)
    }
}
$nextFound = $false
foreach ($corridor in $allowedNextCorridors) {
    if ($nextContent -match [regex]::Escape($corridor)) {
        $nextFound = $true
    }
}
if (-not $nextFound) {
    Add-Failure 'Next corridor is not native human review or technical review prep with conditions.'
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
Write-Host "Draft V3: $draftV3File"
exit 0
