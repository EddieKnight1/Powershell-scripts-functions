<#
.SYNOPSIS
    Creates a PowerShell script to recreate folder structure.
.DESCRIPTION
    This function takes a source folder path and generates a PowerShell script 
    that recreates the folder structure including subfolders.
.PARAMETER sourceFolder
    Specifies the path of the source folder to analyze.
.PARAMETER outputScriptPath
    Specifies the path where the generated PowerShell script will be saved.
.EXAMPLE
    Create-RecreateFolderStructureScript -sourceFolder "C:\Path\To\Source\Folder" -outputScriptPath "C:\Path\To\Output\Script.ps1"
#>

# Function to create PowerShell script to recreate folder structure
function Create-RecreateFolderStructureScript {
    param (
        [Parameter(Mandatory=$true)]
        [string]$sourceFolder,

        [Parameter(Mandatory=$true)]
        [string]$outputScriptPath
    )

    # Get all subdirectories recursively
    $directories = Get-ChildItem -Path $sourceFolder -Directory -Recurse

    # Create the script content
    $scriptContent = @"
# Script to recreate folder structure

# Define the root folder
`$rootFolder = "$sourceFolder"

# Create the root folder if it doesn't exist
if (-not (Test-Path -Path `$rootFolder)) {
    New-Item -ItemType Directory -Path `$rootFolder | Out-Null
}

"@

    # Iterate over each directory and add script commands
    foreach ($directory in $directories) {
        $relativePath = $directory.FullName.Substring($sourceFolder.Length + 1)
        $scriptContent += "New-Item -ItemType Directory -Path (Join-Path `$rootFolder '$relativePath') -Force | Out-Null`n"
    }

    # Write script content to file
    $scriptContent | Out-File -FilePath $outputScriptPath -Encoding UTF8
}

# Example usage
$sourceFolder = "C:\Path\To\Your\Folder"
$outputScriptPath = "C:\Path\To\Your\OutputScript.ps1"

Create-RecreateFolderStructureScript -sourceFolder $sourceFolder -outputScriptPath $outputScriptPath

Write-Host "Script to recreate folder structure has been created at: $outputScriptPath"
