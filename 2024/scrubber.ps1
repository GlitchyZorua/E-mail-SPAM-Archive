# Function to remove personal information from an individual .eml file
function Remove-PersonalInformationFromEml {
    param (
        [string]$emlFilePath,
        [string]$outputFilePath
    )

    # Check if the file exists
    if (-Not (Test-Path -Path $emlFilePath)) {
        Write-Host "The specified file does not exist."
        return
    }

    # Read the content of the .eml file
    $content = Get-Content -Path $emlFilePath -Raw

    # Define a regex pattern to find email addresses
    $emailPattern = '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

    # Remove email addresses from the content (you can add other patterns for more personal info)
    $contentWithoutEmails = $content -replace $emailPattern, '[removed]'

    # Optionally, remove names or other identifiable information (add more patterns as needed)
    # Example: Removing names (naive approach)
    $namePattern = '(?<=From:|To:|Cc:)[^\n]+'
    $contentWithoutPersonalInfo = $contentWithoutEmails -replace $namePattern, '[removed]'

    # Save the modified content back to the file
    Set-Content -Path $outputFilePath -Value $contentWithoutPersonalInfo
    Write-Host "Personal information removed from: $emlFilePath and saved to $outputFilePath"
}

# Function to process all .eml files in the given directory and save redacted files in a separate folder
function Process-AllEmlFilesInDirectory {
    param (
        [string]$directoryPath
    )

    # Define the folder to store redacted emails
    $redactedFolderPath = "$directoryPath\RedactedEmails"

    # Create the RedactedEmails folder if it doesn't exist
    if (-Not (Test-Path -Path $redactedFolderPath)) {
        New-Item -Path $redactedFolderPath -ItemType Directory
        Write-Host "Created folder for redacted emails at: $redactedFolderPath"
    }

    # Get all .eml files in the directory
    $emlFiles = Get-ChildItem -Path $directoryPath -Filter "*.eml"

    # Check if there are no .eml files in the directory
    if ($emlFiles.Count -eq 0) {
        Write-Host "No .eml files found in the directory: $directoryPath"
        return
    }

    # Process each .eml file
    foreach ($file in $emlFiles) {
        $inputFilePath = $file.FullName
        $outputFilePath = "$redactedFolderPath\$($file.BaseName)_modified.eml"

        # Call the function to remove personal information from the current .eml file
        Remove-PersonalInformationFromEml -emlFilePath $inputFilePath -outputFilePath $outputFilePath
    }
}

# Example usage:
$directoryPath = "C:\Users\Jacob\Documents\GitHub\E-mail-SPAM-Archive\2024"
Process-AllEmlFilesInDirectory -directoryPath $directoryPath
