# ============================================
# ASPM - Script de Varredura de Segurança
# ============================================

$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

$projectRoot = Split-Path $PSScriptRoot -Parent
$reportsDir  = "$PSScriptRoot\reports"

# Garante que a pasta de relatórios existe
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ASPM - Iniciando Sensores de Segurança   " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# ----------------------------------------
# 1. SCA - Trivy (dependências)
# ----------------------------------------
Write-Host ""
Write-Host "[1/3] SCA - Trivy: Analisando dependências..." -ForegroundColor Yellow

trivy fs $projectRoot `
  --format sarif `
  --output "$reportsDir\trivy-results.sarif" `
  --severity HIGH,CRITICAL

if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
    Write-Host "      ✅ Trivy concluído → trivy-results.sarif" -ForegroundColor Green
} else {
    Write-Host "      ❌ Trivy falhou (código $LASTEXITCODE)" -ForegroundColor Red
}

# ----------------------------------------
# 2. SAST - Semgrep (lógica do código)
# ----------------------------------------
Write-Host ""
Write-Host "[2/3] SAST - Semgrep: Varrendo código-fonte..." -ForegroundColor Yellow

semgrep scan $projectRoot `
  --config=auto `
  --sarif `
  --output="$reportsDir\semgrep-results.sarif"

if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
    Write-Host "      ✅ Semgrep concluído → semgrep-results.sarif" -ForegroundColor Green
} else {
    Write-Host "      ❌ Semgrep falhou (código $LASTEXITCODE)" -ForegroundColor Red
}

# ----------------------------------------
# 3. Secrets - Gitleaks (credenciais)
# ----------------------------------------
Write-Host ""
Write-Host "[3/3] Secrets - Gitleaks: Caçando credenciais expostas..." -ForegroundColor Yellow

gitleaks detect `
  --source $projectRoot `
  --report-format sarif `
  --report-path "$reportsDir\gitleaks-results.sarif" `
  --no-git

if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
    Write-Host "      ✅ Gitleaks concluído → gitleaks-results.sarif" -ForegroundColor Green
} else {
    Write-Host "      ❌ Gitleaks falhou (código $LASTEXITCODE)" -ForegroundColor Red
}

# ----------------------------------------
# Resumo final
# ----------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Relatórios gerados em: $reportsDir" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Lista os arquivos gerados
Get-ChildItem -Path $reportsDir -Filter "*.sarif" | ForEach-Object {
    $size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  📄 $($_.Name) ($size KB)" -ForegroundColor White
}
Write-Host ""