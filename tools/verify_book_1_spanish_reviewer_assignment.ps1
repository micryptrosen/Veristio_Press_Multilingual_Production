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
$assignmentRegisterFile = Join-Path $packetDir 'BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_REGISTER_V1.md'
$coverageDecisionFile = Join-Path $packetDir 'BOOK_1_SPANISH_REVIEWER_COVERAGE_DECISION_V1.md'
$provisionalBoundaryFile = Join-Path $packetDir 'BOOK_1_SPANISH_PROVISIONAL_REVIEW_BOUNDARY_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_RECEIPT_V1.md'
$draftReadinessGateFile = Join-Path $packetDir 'BOOK_1_SPANISH_TRANSLATION_DRAFT_READINESS_GATE_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$intakeDecisionFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_INTAKE_DECISION_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

$requiredFiles = @(
    @{ Path = $assignmentRegisterFile; Label = 'Reviewer assignment register' },
    @{ Path = $coverageDecisionFile; Label = 'Reviewer coverage decision' },
    @{ Path = $provisionalBoundaryFile; Label = 'Provisional review boundary' },
    @{ Path = $receiptFile; Label = 'Reviewer assignment receipt' },
    @{ Path = $draftReadinessGateFile; Label = 'Draft readiness gate' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$roles = @(
    'terminology reviewer',
    'native-language reviewer',
    'technical reviewer',
    'final sync/proof reviewer'
)

foreach ($role in $roles) {
    foreach ($file in @($assignmentRegisterFile, $coverageDecisionFile, $provisionalBoundaryFile)) {
        Assert-FileContains -File $file -Needle $role -Label "Reviewer role check: $role"
    }
}

$allowedCoverageDecisions = @(
    'ASSIGNED',
    'PARTIALLY_ASSIGNED',
    'PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY',
    'HOLD_FOR_REVIEWER_ASSIGNMENT'
)

$coverageDecision = $null
if (Test-Path -LiteralPath $coverageDecisionFile) {
    $coverageContent = Get-Content -LiteralPath $coverageDecisionFile -Raw
    $match = [regex]::Match($coverageContent, '(?m)^## Coverage Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Coverage decision file does not declare a decision under ## Coverage Decision.'
    } else {
        $coverageDecision = $match.Groups[1].Value
        if ($allowedCoverageDecisions -notcontains $coverageDecision) {
            Add-Failure "Coverage decision is not allowed: $coverageDecision"
        }
    }
}

Assert-FileContains -File $assignmentRegisterFile -Needle 'NO_NAMED_REVIEWERS_ASSIGNED' -Label 'No named reviewer posture check'
Assert-FileContains -File $assignmentRegisterFile -Needle 'No named reviewer source in repo truth.' -Label 'Reviewer source boundary check'

if (Test-Path -LiteralPath $assignmentRegisterFile) {
    $assignmentContent = Get-Content -LiteralPath $assignmentRegisterFile -Raw
    foreach ($role in $roles) {
        $rolePattern = '(?im)^\|\s*' + [regex]::Escape($role) + '\s*\|\s*NOT_ASSIGNED\s*\|'
        if ($assignmentContent -notmatch $rolePattern) {
            Add-Failure "Reviewer role does not remain NOT_ASSIGNED in register: $role"
        }
    }
}

$allowedGateDecisions = @(
    'READY_FOR_TRANSLATION_DRAFT_PACKET',
    'READY_WITH_CONDITIONS',
    'HOLD_FOR_REVIEWER_AVAILABILITY',
    'HOLD_FOR_GLOSSARY_REVIEW',
    'HOLD_FOR_METADATA_ISBN_READINESS'
)

$gateDecision = $null
if (Test-Path -LiteralPath $draftReadinessGateFile) {
    $gateContent = Get-Content -LiteralPath $draftReadinessGateFile -Raw
    $match = [regex]::Match($gateContent, '(?m)^## Gate Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Draft readiness gate does not declare a decision under ## Gate Decision.'
    } else {
        $gateDecision = $match.Groups[1].Value
        if ($allowedGateDecisions -notcontains $gateDecision) {
            Add-Failure "Draft readiness gate uses an unsupported decision: $gateDecision"
        }
    }
}

if ($gateDecision -eq 'READY_FOR_TRANSLATION_DRAFT_PACKET' -or $gateDecision -eq 'READY_WITH_CONDITIONS') {
    foreach ($file in @($coverageDecisionFile, $provisionalBoundaryFile, $draftReadinessGateFile, $trackerFile, $receiptFile, $handoffFile)) {
        Assert-FileContains -File $file -Needle 'publication' -Label 'Publication boundary presence check'
        Assert-FileContains -File $file -Needle 'blocked' -Label 'Publication/release block check'
    }
    Assert-FileContains -File $draftReadinessGateFile -Needle 'human/native/final review' -Label 'Human/native/final review block check'
}

$draftCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_TRANSLATION_DRAFT_PACKET_V1'
$holdCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_GAP_REPAIR_V1'
$corridorFound = $false
foreach ($file in @($assignmentRegisterFile, $coverageDecisionFile, $provisionalBoundaryFile, $draftReadinessGateFile, $receiptFile, $nextCorridorFile, $handoffFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($draftCorridor) -or $content -match [regex]::Escape($holdCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure 'Neither draft-packet next corridor nor reviewer-assignment gap-repair hold corridor is present.'
}

$filesToScan = @(
    $assignmentRegisterFile,
    $coverageDecisionFile,
    $provisionalBoundaryFile,
    $receiptFile,
    $draftReadinessGateFile,
    $trackerFile,
    $pilotGapLogFile,
    $intakeDecisionFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$translationStartedRegex = '(?i)(Spanish translation has begun|Spanish translation began|translation execution started|Spanish draft created|ES_TRANSLATION_DRAFT\s*[:=]\s*(created|complete|started))'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|passed|ready))'

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
