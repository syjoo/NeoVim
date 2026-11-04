#Requires -Version 5.1
# Neovim 개발 환경 일괄 설치: Neovim, Git, ripgrep, fd, zig(C 컴파일러), Nerd Font, tree-sitter CLI
$ErrorActionPreference = 'Stop'

$pkgs = @(
    'Neovim.Neovim',
    'Git.Git',
    'BurntSushi.ripgrep.MSVC',
    'sharkdp.fd',
    'zig.zig',
    'DEVCOM.JetBrainsMonoNerdFont'
)

foreach ($id in $pkgs) {
    Write-Host "==> $id"
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
    # 이미 설치된 경우에도 0이 아닌 코드를 반환하므로 경고만 남기고 계속한다
    if ($LASTEXITCODE -ne 0) { Write-Warning "$id : exit code $LASTEXITCODE (이미 설치되었을 수 있음)" }
}

# tree-sitter CLI: npm 래퍼 대신 릴리스 exe를 직접 받는다 (postinstall 다운로드 실패 회피)
$dir = Join-Path $env:LOCALAPPDATA 'Programs\tree-sitter'
$exe = Join-Path $dir 'tree-sitter.exe'
if (-not (Test-Path $exe)) {
    Write-Host '==> tree-sitter CLI'
    New-Item -ItemType Directory -Force $dir | Out-Null
    $gz = Join-Path $env:TEMP 'tree-sitter-windows-x64.gz'
    Invoke-WebRequest 'https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-windows-x64.gz' -OutFile $gz

    $in  = [IO.File]::OpenRead($gz)
    $z   = New-Object IO.Compression.GZipStream($in, [IO.Compression.CompressionMode]::Decompress)
    $out = [IO.File]::Create($exe)
    try { $z.CopyTo($out) } finally { $out.Close(); $z.Close(); $in.Close() }
    Remove-Item $gz
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $dir) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$dir", 'User')
}

Write-Host "`n완료. 새 터미널을 열고 확인하세요: nvim --version / tree-sitter --version"
Write-Host 'Windows Terminal 폰트는 직접 "JetBrainsMono Nerd Font"로 바꿔야 합니다.'
