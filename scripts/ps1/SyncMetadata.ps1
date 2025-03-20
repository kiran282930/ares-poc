# Variables
$SourceOrg = "ares1Org"  # Alias for the source org
$TargetOrg = "ares2Org"  # Alias for the target org
$PackageXmlPath = "C:\Users\tpkkumar\OneDrive - Deloitte (O365D)\Documents\ARES_Poc\manifest\package.xml"  # Path to your package.xml file

# Step 1: Check for package.xml
Write-Host "Checking if package.xml exists..."
if (-Not (Test-Path $PackageXmlPath)) {
    Write-Host "Error: package.xml file not found at $PackageXmlPath." -ForegroundColor Red
    exit 1
}

# Step 2: Retrieve metadata from Source Org
Write-Host "Retrieving metadata from Source Org ($SourceOrg) using package.xml..."
sf project retrieve start --manifest $PackageXmlPath --target-org $SourceOrg
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to retrieve metadata from Source Org." -ForegroundColor Red
    exit 1
}

# Step 3: Add and commit changes to Git
Write-Host "Adding and committing changes to Git..."
git add .
git commit -m "Metadata sync from Source Org ($SourceOrg)"
git push
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to push changes to Git." -ForegroundColor Red
    exit 1
}

# Step 4: Pull the latest changes from Git for Target Org
Write-Host "Pulling changes for Target Org ($TargetOrg)..."
git pull
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to pull changes for Target Org." -ForegroundColor Red
    exit 1
}

# Step 5: Deploy metadata to Target Org
Write-Host "Deploying metadata to Target Org ($TargetOrg)..."
sf project deploy start --source-dir ./force-app --target-org $TargetOrg
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to deploy metadata to Target Org." -ForegroundColor Red
    exit 1
}

Write-Host "Metadata synchronization completed successfully!" -ForegroundColor Green
