param()

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$ReviewPath = Join-Path $RepoRoot "inputs\advisory_reviews\deepseek\BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_REAL_DEEPSEEK_REVIEW_V1.md"
$ComparisonPath = Join-Path $RepoRoot "docs\packets\book_1_human_creativity_ai_synthesis\BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_REAL_DEEPSEEK_COMPARISON_V1.md"
$ReceiptPath = Join-Path $RepoRoot "docs\governance\receipts\BOOK_1_SPANISH_DRAFT_V3_REAL_DEEPSEEK_REVIEW_RECEIPT_V1.md"
$DraftV4Path = Join-Path $RepoRoot "docs\packets\book_1_human_creativity_ai_synthesis\BOOK_1_CHAPTER_1_SPANISH_DRAFT_V4.md"
$NextCorridor = "APPLY_REAL_DEEPSEEK_AND_CLAUDE_ADVISORY_CORRECTIONS_TO_BOOK_1_SPANISH_DRAFT_V4"

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

Assert-PathExists $ReviewPath "Real DeepSeek review file"
Assert-PathExists $ComparisonPath "Real DeepSeek comparison file"
Assert-PathExists $ReceiptPath "Real DeepSeek receipt file"

$Review = Get-Content -LiteralPath $ReviewPath -Raw -Encoding UTF8
$Comparison = Get-Content -LiteralPath $ComparisonPath -Raw -Encoding UTF8
$Receipt = Get-Content -LiteralPath $ReceiptPath -Raw -Encoding UTF8
$AllNewContent = @($Review, $Comparison, $Receipt) -join "`n---FILE---`n"

Assert-Contains $Review "## Real API Response" "Review file"
Assert-Contains $Review "YES" "Review file"
Assert-Contains $Review '`deepseek-v4-flash`' "Review file"
Assert-Contains $Review "## Response Body" "Review file"
Assert-Contains $Review "advisory-only" "Review file"
Assert-Contains $Comparison "Prior Provenance-Only DeepSeek Slot Status" "Comparison file"
Assert-Contains $Comparison "Real DeepSeek Findings" "Comparison file"
Assert-Contains $Comparison "Claude Findings Already Applied" "Comparison file"
Assert-Contains $Comparison "Safe Corrections Recommended For Draft V4" "Comparison file"
Assert-Contains $Comparison "Items Deferred To Native/Human Reviewer" "Comparison file"
Assert-Contains $Receipt "PASS_REAL_DEEPSEEK_ADVISORY_REVIEW_RECORDED" "Receipt"
Assert-Contains $AllNewContent $NextCorridor "Next corridor"

if ($Review -like "*Connectivity Test*TRUE*") {
    Fail "Review output appears to be a connectivity-test artifact rather than the real Draft V3 review."
}

if ($Review -notmatch "(?is)## Response Body\s+.{200,}") {
    Fail "Review file does not contain enough response-body content to prove a substantive real API response."
}

$ForbiddenAffirmativeClaims = @(
    "(?i)\b(native-language review|native review)\s+(is\s+)?(complete|completed|performed|satisfied)\b",
    "(?i)\bhuman review\s+(is\s+)?(complete|completed|performed|satisfied)\b",
    "(?i)\btechnical review\s+(is\s+)?(complete|completed|performed|satisfied)\b",
    "(?i)\bfinal review\s+(is\s+)?(complete|completed|performed|satisfied)\b",
    "(?i)\bpublication readiness\s+(is\s+)?(complete|completed|granted|approved|satisfied)\b",
    "(?i)\brelease approval\s+(is\s+)?(complete|completed|granted|approved|satisfied)\b",
    "(?i)\bfinal release approval\b"
)
foreach ($Pattern in $ForbiddenAffirmativeClaims) {
    if ($AllNewContent -match $Pattern) {
        Fail "Forbidden completion/readiness claim detected by pattern: $Pattern"
    }
}

if (Test-Path -LiteralPath $DraftV4Path) {
    Fail "Draft V4 must not be created in this tranche: $DraftV4Path"
}

$UnexpectedDraftV4 = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "docs\packets\book_1_human_creativity_ai_synthesis") -File -Filter "*DRAFT_V4*.md" -ErrorAction SilentlyContinue
if ($UnexpectedDraftV4) {
    Fail "Draft V4-related markdown artifact exists before the Draft V4 corridor: $($UnexpectedDraftV4.FullName -join ', ')"
}

Write-Host "PASS: Book 1 Spanish Draft V3 real DeepSeek advisory review verifier passed."
