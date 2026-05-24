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

$deepseekReviewFile = Join-Path $repoRoot 'inputs/advisory_reviews/deepseek/BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_DEEPSEEK_REVIEW_V1.md'
$comparisonFile = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis/BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_DEEPSEEK_ADVISORY_COMPARISON_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_DRAFT_V3_DEEPSEEK_ADVISORY_REVIEW_RECEIPT_V1.md'
$claudeSourceFile = Join-Path $repoRoot 'inputs/advisory_reviews/claude/BOOK_1_CHAPTER_1_SPANISH_DRAFT_V2_CLAUDE_REVIEW_V1.txt'
$draftV3File = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis/BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3.md'
$draftV4File = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis/BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4.md'

Assert-Exists -Path $deepseekReviewFile -Label 'DeepSeek review file'
Assert-Exists -Path $comparisonFile -Label 'DeepSeek comparison file'
Assert-Exists -Path $receiptFile -Label 'DeepSeek review receipt'
Assert-Exists -Path $draftV3File -Label 'Draft V3 source draft'

$requiredReviewConcepts = @(
    'accent/orthographic errors',
    'grammar',
    'natural Spanish',
    'awkward literal phrasing',
    'terminology consistency',
    'regional neutrality',
    'meaning preservation',
    'omissions/additions',
    'title treatment',
    'Human Creativity + AI Synthesis',
    'IA / inteligencia artificial treatment',
    'source-of-truth edition',
    'canonical manuscript',
    'governed workflow',
    'translation-ready',
    'tone/register for educational/workforce readers',
    'Claude corrections applied safely'
)
foreach ($concept in $requiredReviewConcepts) {
    Assert-FileContains -File $deepseekReviewFile -Needle $concept -Label 'DeepSeek review coverage check'
}

$requiredComparisonPhrases = @(
    'Claude Corrections Already Applied In V3',
    'DeepSeek Findings Accepted For Repair',
    'DeepSeek Findings Deferred',
    'Conflicts Between Claude And DeepSeek',
    'Items Requiring Real Native Reviewer Decision',
    'Safe Corrections Recommended For Draft V4',
    'APPLY_COMBINED_ADVISORY_CORRECTIONS_TO_BOOK_1_SPANISH_DRAFT_V4'
)
foreach ($phrase in $requiredComparisonPhrases) {
    Assert-FileContains -File $comparisonFile -Needle $phrase -Label 'DeepSeek comparison section check'
}

$advisoryBoundaryPhrases = @(
    'DeepSeek is advisory only.',
    'Claude is advisory only.',
    'not human review',
    'not native-language review',
    'not final review',
    'not publication readiness',
    'not release approval'
)
foreach ($phrase in $advisoryBoundaryPhrases) {
    Assert-FileContains -File $deepseekReviewFile -Needle $phrase -Label 'DeepSeek review advisory boundary check'
    Assert-FileContains -File $comparisonFile -Needle $phrase -Label 'Comparison advisory boundary check'
}

Assert-FileContains -File $receiptFile -Needle 'DeepSeek is advisory only.' -Label 'Receipt DeepSeek boundary check'
Assert-FileContains -File $receiptFile -Needle 'Claude is advisory only.' -Label 'Receipt Claude boundary check'

if (Test-Path -LiteralPath $draftV4File) {
    Add-Failure "Draft V4 must not be created in this tranche: $draftV4File"
}

$unexpectedDraftV4Files = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis') -Filter '*DRAFT_V4*.md' -File -ErrorAction SilentlyContinue
foreach ($file in $unexpectedDraftV4Files) {
    Add-Failure "Draft V4-related file found before Draft V4 corridor: $($file.FullName)"
}

$filesToScan = @(
    $deepseekReviewFile,
    $comparisonFile,
    $receiptFile,
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

foreach ($file in $filesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        Add-Failure "Expected scan file missing: $file"
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match $nativeReviewCompleteRegex) {
        Add-Failure "File appears to claim native review completion: $file"
    }
    if ($content -match $humanReviewCompleteRegex) {
        Add-Failure "File appears to claim human review completion: $file"
    }
    if ($content -match $publicationReadyRegex) {
        Add-Failure "File appears to claim publication readiness: $file"
    }
    if ($content -match $releaseApprovalRegex) {
        Add-Failure "File appears to claim release approval/upload readiness: $file"
    }
}

if (Test-Path -LiteralPath $claudeSourceFile) {
    $claudeContent = Get-Content -LiteralPath $claudeSourceFile -Raw
    $expectedClaudePhrases = @(
        'Orthographic Errors',
        'programadores de redes sociales',
        'mercadeo por correo electrónico',
        'fuente de verdad',
        'lo cuál',
        'útilidad'
    )
    foreach ($phrase in $expectedClaudePhrases) {
        if ($claudeContent -notmatch [regex]::Escape($phrase)) {
            Add-Failure "Claude advisory source exists but does not match expected input phrase: $phrase"
        }
    }

    $relativeClaude = 'inputs/advisory_reviews/claude/BOOK_1_CHAPTER_1_SPANISH_DRAFT_V2_CLAUDE_REVIEW_V1.txt'
    $status = git -C $repoRoot status --short -- $relativeClaude
    if ($LASTEXITCODE -ne 0) {
        Add-Failure 'Unable to inspect Claude advisory source Git status.'
    } elseif ($status -match '^\?\?') {
        Add-Failure 'Claude advisory source file exists but is still untracked.'
    }
} else {
    Assert-FileContains -File (Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis/BOOK_1_CHAPTER_1_CLAUDE_ADVISORY_CORRECTION_PASS_V1.md') -Needle 'CLAUDE_ADVISORY_CORRECTIONS_APPLIED_TO_DRAFT_V3' -Label 'Claude correction pass fallback check'
}

$nextCorridorA = 'APPLY_COMBINED_ADVISORY_CORRECTIONS_TO_BOOK_1_SPANISH_DRAFT_V4'
$nextCorridorB = 'VERISTIO_PRESS_BOOK_1_SPANISH_NATIVE_REVIEWER_SELECTION_OR_EXECUTION_V1'
$nextContent = ''
foreach ($file in @((Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'), (Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'), $comparisonFile, $receiptFile)) {
    if (Test-Path -LiteralPath $file) {
        $nextContent += "`n" + (Get-Content -LiteralPath $file -Raw)
    }
}
if (($nextContent -notmatch [regex]::Escape($nextCorridorA)) -and ($nextContent -notmatch [regex]::Escape($nextCorridorB))) {
    Add-Failure 'Expected next corridor not present.'
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
Write-Host "DeepSeek review: $deepseekReviewFile"
exit 0
