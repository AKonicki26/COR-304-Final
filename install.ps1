# Ensure script runs from the repo root
$repoRoot = Get-Location

# Check if .NET SDK 8.0 is installed
$dotnetInstalled = & dotnet --list-runtimes | Select-String "Microsoft.NETCore.App 8.0"
if (-not $dotnetInstalled) {
    Write-Host ".NET 8.0 Runtime not found. Downloading and installing..."

    $runtimeUrl = "https://download.visualstudio.microsoft.com/download/pr/7f0f6dc7-6ee4-4cf5-94c1-b21a5bb650a3/1a0b8d99cc017e553ce9e7f48746a75d/dotnet-runtime-8.0.4-win-x64.exe"
    $installerPath = "$env:TEMP\dotnet-runtime-8.0.4-win-x64.exe"

    Invoke-WebRequest -Uri $runtimeUrl -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host ".NET 8.0 Runtime is already installed."
}

# Check for dotnet-tools.json (local tool manifest)
$toolManifestPath = "$repoRoot\.config\dotnet-tools.json"
if (-not (Test-Path $toolManifestPath)) {
    Write-Host "Initializing local dotnet tool manifest..."
    dotnet new tool-manifest
}

# Check if DocFX is already installed locally
$docfxInstalled = dotnet tool list --local | Select-String "docfx"
if (-not $docfxInstalled) {
    Write-Host "Installing DocFX as a local tool..."
    dotnet tool install docfx
} else {
    Write-Host "DocFX is already installed locally."
}

# Build and serve the documentation
Write-Host "Launching docfx server..."
dotnet tool run docfx --serve
