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

function Get-DocxText {
    param([string]$Path)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("review_copy_docx_" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $tempDir)
        $documentXml = Join-Path $tempDir 'word/document.xml'
        if (-not (Test-Path -LiteralPath $documentXml)) {
            Add-Failure "DOCX document.xml missing: $Path"
            return ''
        }

        $raw = Get-Content -LiteralPath $documentXml -Raw
        $text = $raw -replace '<[^>]+>', ' '
        return [System.Net.WebUtility]::HtmlDecode($text)
    } finally {
        if (Test-Path -LiteralPath $tempDir) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }
}

$sourceDraft = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis/BOOK_1_CHAPTER_1_SPANISH_DRAFT_V2.md'
$exportFolder = Join-Path $repoRoot 'exports/review_copies'
$docxPath = Join-Path $exportFolder 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_V2_REVIEW_COPY.docx'
$pdfPath = Join-Path $exportFolder 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_V2_REVIEW_COPY.pdf'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

Assert-Exists -Path $sourceDraft -Label 'Source draft'
Assert-Exists -Path $exportFolder -Label 'Export folder'
Assert-Exists -Path $docxPath -Label 'Review copy DOCX'

if (Test-Path -LiteralPath $docxPath) {
    $docxSize = (Get-Item -LiteralPath $docxPath).Length
    if ($docxSize -le 0) {
        Add-Failure "Review copy DOCX is empty: $docxPath"
    }

    $docxText = Get-DocxText -Path $docxPath
    foreach ($requiredLabel in @(
        'PROVISIONAL DRAFT ONLY',
        'NOT HUMAN REVIEWED',
        'NOT NATIVE REVIEWED',
        'NOT FINAL',
        'NOT PUBLICATION READY'
    )) {
        if ($docxText -notmatch [regex]::Escape($requiredLabel)) {
            Add-Failure "Review copy DOCX missing required draft label: $requiredLabel"
        }
    }

    $publicationReadyClaimRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|publication readiness\s*[:=]\s*(ready|complete|completed|passed|approved)|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|completed|passed|ready|approved))'
    if ($docxText -match $publicationReadyClaimRegex) {
        Add-Failure 'Review copy DOCX appears to introduce a positive Spanish publication-ready claim.'
    }
}

if (Test-Path -LiteralPath $pdfPath) {
    $pdfSize = (Get-Item -LiteralPath $pdfPath).Length
    if ($pdfSize -le 0) {
        Add-Failure "Review copy PDF exists but is empty: $pdfPath"
    }
}

$nextCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1'
$corridorFound = $false
foreach ($file in @($nextCorridorFile, $handoffFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($nextCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure "Expected next corridor is not present: $nextCorridor"
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
Write-Host "DOCX: $docxPath"
if (Test-Path -LiteralPath $pdfPath) {
    Write-Host "PDF: $pdfPath"
}
exit 0
