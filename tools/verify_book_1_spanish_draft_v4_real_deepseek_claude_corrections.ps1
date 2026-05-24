param()

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PacketDir = Join-Path $RepoRoot "docs\packets\book_1_human_creativity_ai_synthesis"

$DraftV4 = Join-Path $PacketDir "BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4.md"
$ChangeLog = Join-Path $PacketDir "BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4_CHANGE_LOG_V1.md"
$Disposition = Join-Path $PacketDir "BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4_ADVISORY_DISPOSITION_V1.md"
$Receipt = Join-Path $RepoRoot "docs\governance\receipts\BOOK_1_SPANISH_DRAFT_V4_REAL_DEEPSEEK_CLAUDE_CORRECTIONS_RECEIPT_V1.md"
$NextCorridorFile = Join-Path $RepoRoot "controls\NEXT_IMPLEMENTATION_CORRIDOR.md"
$NextCorridor = "VERISTIO_PRESS_BOOK_1_SPANISH_DRAFT_V4_REVIEW_COPY_EXPORT_V1"

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

Assert-PathExists $DraftV4 "Draft V4"
Assert-PathExists $ChangeLog "V4 change log"
Assert-PathExists $Disposition "V4 advisory disposition"
Assert-PathExists $Receipt "V4 receipt"
Assert-PathExists $NextCorridorFile "Next corridor file"

$Draft = Get-Content -LiteralPath $DraftV4 -Raw -Encoding UTF8
$Log = Get-Content -LiteralPath $ChangeLog -Raw -Encoding UTF8
$DispositionText = Get-Content -LiteralPath $Disposition -Raw -Encoding UTF8
$ReceiptText = Get-Content -LiteralPath $Receipt -Raw -Encoding UTF8
$NextText = Get-Content -LiteralPath $NextCorridorFile -Raw -Encoding UTF8
$All = @($Draft, $Log, $DispositionText, $ReceiptText, $NextText) -join "`n---FILE---`n"

$RequiredDraftBoundaries = @(
    "PROVISIONAL DRAFT ONLY",
    "NOT HUMAN REVIEWED",
    "NOT NATIVE REVIEWED",
    "NOT FINAL",
    "NOT PUBLICATION READY",
    "NO RELEASE APPROVAL",
    "Claude advisory only",
    "DeepSeek advisory only",
    'Source lock: `BOOK1-CH01-EN-LOCK-V1`',
    'Locked source commit: `bd0441d4a5cf8e5862a61421b3d515eb079afee4`'
)
foreach ($Boundary in $RequiredDraftBoundaries) {
    Assert-Contains $Draft $Boundary "Draft V4 boundary"
}

Assert-Contains $Log "Real DeepSeek" "V4 change log"
Assert-Contains $Log "Claude" "V4 change log"
Assert-Contains $DispositionText "Real DeepSeek" "V4 advisory disposition"
Assert-Contains $DispositionText "Claude advisory" "V4 advisory disposition"
Assert-Contains $ReceiptText "PASS_DRAFT_V4_ADVISORY_CORRECTIONS_APPLIED" "V4 receipt"
Assert-Contains $All $NextCorridor "Next corridor"

$ExpectedCorrections = @(
    "no se despertaron",
    "descubrieron",
    "conveniencia",
    "habilidad en el manejo de botones",
    "sistemas que funcionan",
    "lenguaje de pol",
    "reducir la velocidad",
    "de la verdad"
)
foreach ($Correction in $ExpectedCorrections) {
    Assert-Contains $Draft $Correction "Draft V4 correction"
}

$ForbiddenInDraft = @(
    "fluidez con botones",
    "sistemas que trabajan",
    "bajar la velocidad"
)
foreach ($Forbidden in $ForbiddenInDraft) {
    if ($Draft.Contains($Forbidden)) {
        Fail "Draft V4 still contains superseded text: $Forbidden"
    }
}

$ForbiddenPositiveClaims = @(
    "NATIVE_REVIEW_COMPLETE",
    "HUMAN_REVIEW_COMPLETE",
    "TECHNICAL_REVIEW_COMPLETE",
    "FINAL_REVIEW_COMPLETE",
    "PUBLICATION_READY_APPROVED",
    "PUBLICATION_READY_GRANTED",
    "RELEASE_APPROVED",
    "RELEASE_READY",
    "FINAL_RELEASE_APPROVAL_GRANTED",
    "native-language review complete",
    "native review complete",
    "human review complete",
    "final review complete",
    "publication readiness granted",
    "publication readiness approved",
    "release approval granted",
    "release approval approved"
)
foreach ($Forbidden in $ForbiddenPositiveClaims) {
    if ($All.ToLowerInvariant().Contains($Forbidden.ToLowerInvariant())) {
        Fail "Forbidden positive review/publication/release claim detected: $Forbidden"
    }
}

Write-Host "PASS: Book 1 Spanish Draft V4 real DeepSeek/Claude advisory correction verifier passed."
