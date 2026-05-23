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

$candidateRegister = Join-Path $repoRoot 'docs/integration/PILOT_BOOK_CANDIDATE_REGISTER_V1.md'
$selectionAnalysis = Join-Path $repoRoot 'docs/integration/SPANISH_PILOT_BOOK_SELECTION_ANALYSIS_V1.md'
$receipt = Join-Path $repoRoot 'docs/governance/receipts/SPANISH_PILOT_BOOK_SELECTION_RECEIPT_V1.md'

Assert-Exists -Path $candidateRegister -Label 'Candidate register'
Assert-Exists -Path $selectionAnalysis -Label 'Selection analysis'
Assert-Exists -Path $receipt -Label 'Selection receipt'

$requiredRegisterFields = @(
    'candidate_id',
    'book_title',
    'book_repo_path',
    'current_book_stage',
    'english_maturity',
    'glossary_readiness',
    'source_claim_stability',
    'technical_complexity',
    'spanish_audience_value',
    'formatting_complexity',
    'metadata_isbn_readiness',
    'reviewer_availability',
    'risk_level',
    'recommendation',
    'notes'
)

foreach ($field in $requiredRegisterFields) {
    Assert-FileContains -File $candidateRegister -Needle $field -Label 'Candidate register field check'
}

if (Test-Path -LiteralPath $candidateRegister) {
    $registerLines = Get-Content -LiteralPath $candidateRegister
    $candidateRows = @($registerLines | Where-Object { $_ -match '^\|\s*CANDIDATE-\d+\s*\|' })

    $veristioRoot = Split-Path -Parent $repoRoot
    $candidateRepoCount = 0
    if (Test-Path -LiteralPath $veristioRoot -PathType Container) {
        $candidateRepoCount = @(
            Get-ChildItem -LiteralPath $veristioRoot -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like 'Book *' }
        ).Count
    }

    $minimumRows = if ($candidateRepoCount -lt 3) { $candidateRepoCount } else { 3 }
    if ($candidateRows.Count -lt $minimumRows) {
        Add-Failure "Candidate register has $($candidateRows.Count) candidate rows; expected at least $minimumRows based on discovered candidate repos."
    }
}

$requiredAnalysisPhrases = @(
    '## Selection Date',
    '## Repo Root',
    '## Selection Method',
    '## Candidate List',
    '## Evidence Read Per Candidate',
    '## Evaluation Matrix',
    '## Top Recommendation',
    '## Conditional Requirements Before Packet Preparation',
    '## Why Lower-Ranked Candidates Were Not First',
    '## Authority Boundary',
    'VERISTIO_PRESS_SPANISH_PILOT_TRANSLATION_PACKET_PREPARATION_V1'
)

foreach ($phrase in $requiredAnalysisPhrases) {
    Assert-FileContains -File $selectionAnalysis -Needle $phrase -Label 'Selection analysis structure check'
}

if (Test-Path -LiteralPath $selectionAnalysis) {
    $analysisContent = Get-Content -LiteralPath $selectionAnalysis -Raw
    $allowedRecommendationRegex = '(SELECT_FOR_PACKET_PREPARATION|SELECT_WITH_CONDITIONS|HOLD|REJECT_FOR_NOW)'

    if ($analysisContent -notmatch "(?m)^Final recommendation:\s*$allowedRecommendationRegex\s*$") {
        Add-Failure 'Selection analysis final recommendation is missing or not an allowed status.'
    }

    if ($analysisContent -notmatch 'No Book repo mutation') {
        Add-Failure 'Selection analysis does not include explicit no Book repo mutation authority boundary.'
    }

    if ($analysisContent -notmatch 'No manuscript authority transfer') {
        Add-Failure 'Selection analysis does not include explicit no manuscript authority transfer boundary.'
    }

    $translationStartRiskRegex = '(?i)(translation has begun|translation started|began translation|translation execution started|Spanish translation draft created|ES_TRANSLATION_DRAFT\s*[:=]\s*(created|complete|started))'
    if ($analysisContent -match $translationStartRiskRegex) {
        Add-Failure 'Selection analysis appears to claim translation execution has started.'
    }

    if (Test-Path -LiteralPath $candidateRegister) {
        $registerLines = Get-Content -LiteralPath $candidateRegister
        $candidateIds = @(
            $registerLines |
                Where-Object { $_ -match '^\|\s*(CANDIDATE-\d+)\s*\|' } |
                ForEach-Object { [regex]::Match($_, '^\|\s*(CANDIDATE-\d+)\s*\|').Groups[1].Value }
        )

        foreach ($candidateId in $candidateIds) {
            $statusLineRegex = "(?m)\|\s*(?:\d+\s*\|\s*)?$([regex]::Escape($candidateId))\s*\|.*\|\s*$allowedRecommendationRegex\s*\|"
            if ($analysisContent -notmatch $statusLineRegex) {
                Add-Failure "Selection analysis missing allowed recommendation status for reviewed candidate: $candidateId"
            }
        }
    }
}

Assert-FileContains -File $receipt -Needle 'Final recommendation: `SELECT_WITH_CONDITIONS`' -Label 'Receipt final recommendation check'
Assert-FileContains -File $receipt -Needle 'VERISTIO_PRESS_SPANISH_PILOT_TRANSLATION_PACKET_PREPARATION_V1' -Label 'Receipt next corridor check'

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
