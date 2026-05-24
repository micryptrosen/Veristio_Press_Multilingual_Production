param()

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ExportDir = Join-Path $RepoRoot "exports\review_copies\book_1_human_creativity_ai_synthesis"
$DocxPath = Join-Path $ExportDir "BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4_REVIEW_COPY.docx"
$PdfPath = Join-Path $ExportDir "BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4_REVIEW_COPY.pdf"
$SourceDraft = Join-Path $RepoRoot "docs\packets\book_1_human_creativity_ai_synthesis\BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4.md"
$Receipt = Join-Path $RepoRoot "docs\governance\receipts\BOOK_1_SPANISH_DRAFT_V4_REVIEW_COPY_EXPORT_RECEIPT_V1.md"
$NextCorridorFile = Join-Path $RepoRoot "controls\NEXT_IMPLEMENTATION_CORRIDOR.md"
$NextCorridor = "VERISTIO_PRESS_BOOK_1_SPANISH_NATIVE_REVIEWER_SELECTION_OR_EXECUTION_V1"

function Fail($Message) {
    Write-Error $Message
    exit 1
}

function Assert-PathExists($Path, $Label) {
    if (-not (Test-Path -LiteralPath $Path)) {
        Fail "$Label missing: $Path"
    }
}

function Assert-Contains($Content, $Needle, $Label) {
    if (-not $Content.Contains($Needle)) {
        Fail "$Label missing required text: $Needle"
    }
}

Assert-PathExists $ExportDir "Export folder"
Assert-PathExists $DocxPath "DOCX review copy"
Assert-PathExists $SourceDraft "Source Draft V4"
Assert-PathExists $Receipt "Receipt"
Assert-PathExists $NextCorridorFile "Next corridor file"

$DocxItem = Get-Item -LiteralPath $DocxPath
if ($DocxItem.Length -le 0) {
    Fail "DOCX review copy exists but has zero size."
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$fileStream = [System.IO.File]::Open($DocxPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
$memoryStream = New-Object System.IO.MemoryStream
try {
    $fileStream.CopyTo($memoryStream)
} finally {
    $fileStream.Dispose()
}
$memoryStream.Position = 0
$zip = New-Object System.IO.Compression.ZipArchive($memoryStream, [System.IO.Compression.ZipArchiveMode]::Read)
try {
    $entry = $zip.GetEntry("word/document.xml")
    if ($null -eq $entry) { Fail "DOCX has no word/document.xml entry." }
    $reader = New-Object System.IO.StreamReader($entry.Open())
    try { $xml = $reader.ReadToEnd() } finally { $reader.Close() }
} finally {
    $zip.Dispose()
    $memoryStream.Dispose()
}
$docxText = [regex]::Replace($xml, "<[^>]+>", " ")
$receiptText = Get-Content -LiteralPath $Receipt -Raw -Encoding UTF8
$nextText = Get-Content -LiteralPath $NextCorridorFile -Raw -Encoding UTF8
$all = @($docxText, $receiptText, $nextText) -join "`n---FILE---`n"

$RequiredDocxText = @(
    "Book 1 Chapter 1 Spanish Draft V4",
    "PROVISIONAL DRAFT ONLY",
    "NOT HUMAN REVIEWED",
    "NOT NATIVE REVIEWED",
    "NOT FINAL",
    "NOT PUBLICATION READY",
    "NO RELEASE APPROVAL",
    "BOOK1-CH01-EN-LOCK-V1",
    "bd0441d4a5cf8e5862a61421b3d515eb079afee4",
    "Review natural Spanish",
    "meaning preservation",
    "awkward phrasing",
    "terminology",
    "tone/register",
    "omissions",
    "additions",
    "cultural or technical ambiguity",
    "Reviewer Notes"
)
foreach ($needle in $RequiredDocxText) {
    Assert-Contains $docxText $needle "DOCX review copy"
}

Assert-Contains $all $NextCorridor "Next corridor"

$ForbiddenPositiveClaims = @(
    "PUBLICATION_READY_APPROVED",
    "PUBLICATION_READY_GRANTED",
    "publication readiness granted",
    "publication readiness approved",
    "publication-ready approval",
    "RELEASE_APPROVED",
    "RELEASE_READY",
    "release approval granted",
    "release approval approved",
    "final release approval"
)
foreach ($claim in $ForbiddenPositiveClaims) {
    if ($all.ToLowerInvariant().Contains($claim.ToLowerInvariant())) {
        Fail "Forbidden positive publication/release claim detected: $claim"
    }
}

if (Test-Path -LiteralPath $PdfPath) {
    $PdfItem = Get-Item -LiteralPath $PdfPath
    if ($PdfItem.Length -le 0) {
        Fail "PDF exists but has zero size: $PdfPath"
    }
    Write-Host "PDF present: $PdfPath"
} else {
    Write-Host "PDF not present; allowed because PDF creation depends on available tooling."
}

Write-Host "PASS: Book 1 Spanish Draft V4 review copy export verifier passed."
