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
    param([string]$File, [string]$Needle, [string]$Label)
    if (-not (Test-Path -LiteralPath $File)) {
        Add-Failure "$Label file missing: $File"
        return
    }
    $content = Get-Content -LiteralPath $File -Raw
    if ($content -notmatch [regex]::Escape($Needle)) {
        Add-Failure "$Label missing phrase: $Needle"
    }
}

$runner = Join-Path $repoRoot 'tools/deepseek_advisory_review.py'
Assert-Exists -Path $runner -Label 'DeepSeek advisory runner'

if (-not $env:DEEPSEEK_API_KEY) {
    Add-Failure 'DEEPSEEK_API_KEY is missing from the process environment.'
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'veristio_deepseek_api_connectivity'
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
$inputFile = Join-Path $tempRoot 'deepseek_connectivity_input.md'
$outputFile = Join-Path $tempRoot 'deepseek_connectivity_output.md'
Set-Content -LiteralPath $inputFile -Value 'DeepSeek connectivity test for Veristio advisory-only review integration.' -Encoding UTF8
if (Test-Path -LiteralPath $outputFile) {
    Remove-Item -LiteralPath $outputFile -Force
}

if ($failures.Count -eq 0) {
    & python $runner --input $inputFile --output $outputFile --prompt-purpose 'DeepSeek API connectivity test for advisory-only integration' --connectivity-test --max-tokens 80 --timeout 45
    if ($LASTEXITCODE -ne 0) {
        Add-Failure 'DeepSeek API live connectivity test failed. See runner output above; API key was not printed.'
    }
}

Assert-Exists -Path $outputFile -Label 'DeepSeek connectivity output'
if (Test-Path -LiteralPath $outputFile) {
    Assert-FileContains -File $outputFile -Needle 'YES' -Label 'Real API response marker check'
    Assert-FileContains -File $outputFile -Needle 'Model' -Label 'Model metadata check'
    Assert-FileContains -File $outputFile -Needle 'Prompt Purpose' -Label 'Prompt purpose metadata check'
    Assert-FileContains -File $outputFile -Needle 'Response Body' -Label 'Response body check'
    Assert-FileContains -File $outputFile -Needle 'DeepSeek output is advisory-only.' -Label 'Advisory-only boundary check'
    Assert-FileContains -File $outputFile -Needle 'REAL_DEEPSEEK_API_RESPONSE' -Label 'Real DeepSeek response phrase check'

    $outputContent = Get-Content -LiteralPath $outputFile -Raw
    if ($outputContent -match [regex]::Escape($env:DEEPSEEK_API_KEY)) {
        Add-Failure 'Connectivity output appears to contain the API key.'
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'VERIFICATION FAIL' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure" -ForegroundColor Red
    }
    Write-Host "Output test path: $outputFile"
    exit 1
}

Write-Host 'VERIFICATION PASS' -ForegroundColor Green
Write-Host "Repo root: $repoRoot"
Write-Host 'DeepSeek API key detected: yes'
Write-Host "Output test path: $outputFile"
exit 0
