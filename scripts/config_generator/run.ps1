# Define paths
$templateFile = "..\..\config_template.cfg"
$levelsInputFolder = "..\..\src\tiled_levels"
$levelsOutputFolder = "..\..\src\tiled_levels\generated"
$outputFile = "..\..\generated.cfg"

# Function to convert a CSV string into a byte array
function Convert-CSVToByteArray {
    param (
        [string]$csvData
    )

    # Split the CSV string into individual values
    $tileData = $csvData -split ','
    
    # Convert each tile value to a byte
    $byteArray = @()
    foreach ($tile in $tileData) {
        [byte]$byte = [convert]::ToByte($tile)
        $byteArray += $byte
    }

    return $byteArray
}

# Function to parse the TMX file and extract the tile layer data
function ExtractTileLayerData {
    param (
        [string]$tmxFilePath
    )

    # Load the XML content of the TMX file
    $xmlContent = [xml](Get-Content -Path $tmxFilePath)

    # Find the <data> element under the tile layer
    $tileLayerData = $xmlContent.map.layer.data

    # Extract the CSV data
    $csvData = $tileLayerData.InnerText.Trim()

    return $csvData
}

# Compress .tmx files using huffmunch.exe and save the output as .hfm files
$tmxFiles = Get-ChildItem -Path $levelsInputFolder -Filter *.tmx
# Initialize a hashtable to track filename occurrences
$filenameTracker = @{}

Get-ChildItem -Path $levelsOutputFolder -Include *.hfm -File -Recurse | foreach { $_.Delete()}
foreach ($tmxFile in $tmxFiles) {
    $originalName = [System.IO.Path]::GetFileNameWithoutExtension($tmxFile)

    # Replace spaces with underscores and remove unsupported characters
    $newName = $originalName -replace '\s', '_' -replace '[^a-zA-Z0-9_]', ''

    # Ensure the filename does not start with a number
    if ($newName -match '^\d') {
        $newName = "_" + $newName
    }

    # Track duplicates by checking if the name already exists in the tracker
    $counter = 1
    $baseName = $newName
    while ($filenameTracker.ContainsKey($newName)) {
        $newName = "$baseName" + "_$counter"
        $counter++
    }

    # Store the final unique filename in the tracker
    $filenameTracker[$newName] = $true

    # Extract the CSV tile data from the TMX file
    $csvData = ExtractTileLayerData -tmxFilePath $tmxFile.FullName

    # Convert the CSV tile data to a byte array
    $byteArray = Convert-CSVToByteArray -csvData $csvData

    # Generate a temporary binary file path
    $tempFilePath = [System.IO.Path]::ChangeExtension($tmxFile.FullName, ".temp")

    # Write the byte array to the binary file
    [System.IO.File]::WriteAllBytes($tempFilePath, $byteArray)

    $inputFilePath = $tmxFile.FullName
    $outputFileName = $newName + ".hfm"
    $outputFilePath = Join-Path -Path $levelsOutputFolder -ChildPath $outputFileName
    & "../../tools/huffmunch" "-B" $tempFilePath $outputFilePath

    # Delete the temporary binary file
    Remove-Item -Path $tempFilePath
}

# Set the maximum size for each bank in bytes
$bankMaxSize = 0x2000  # 8192 bytes

# Initialize variables to track current bank and its size
$currentBank = 0
$currentBankSize = 0
$bankAssignments = @{}
$segmentsIncContent = ""
$totalSize = 0  # To track total size of .hfm files

# Function to create a new bank segment
function Create-NewBankSegment {
    param (
        [int]$bankNumber
    )
    return ".segment LBNK_{0:00}`n" -f $bankNumber
}

# Iterate over .hfm files and assign them to banks
$hfmFiles = Get-ChildItem -Path $levelsOutputFolder -Filter *.hfm
foreach ($hfmFile in $hfmFiles) {
    $fileSize = (Get-Item $hfmFile.FullName).Length
    $totalSize += $fileSize  # Add to the total size

    # Check if adding this file exceeds the current bank's size limit
    if ($currentBankSize + $fileSize -gt $bankMaxSize) {
        # Output the current bank's details
        Write-Host ("Bank {0:00} filled with {1} bytes." -f $currentBank, $currentBankSize)

        # Move to the next bank
        $currentBank++
        $currentBankSize = 0
    }

    # If it's the first file in the bank, create the bank segment
    if (-not $bankAssignments[$currentBank]) {
        $bankAssignments[$currentBank] = @()
        $segmentsIncContent += Create-NewBankSegment -bankNumber $currentBank
    }

    # Assign the file to the current bank and update the bank size
    $bankAssignments[$currentBank] += $hfmFile.Name
    $currentBankSize += $fileSize

    # Add the file include line to the segments content
    $segmentsIncContent += [System.IO.Path]::GetFileNameWithoutExtension($hfmFile) + ":`n    .include `"{0}`"`n" -f $hfmFile.Name
}

# Output the final bank's details
Write-Host ("Bank {0:00} filled with {1} bytes." -f $currentBank, $currentBankSize)

# Save the segments.inc file
$segmentsIncFilePath = Join-Path -Path $levelsOutputFolder -ChildPath "segments.inc"
$segmentsIncContent | Set-Content -Path $segmentsIncFilePath

# Output the total size of all .hfm files
Write-Host "Total bytes of .hfm files: $totalSize"

Write-Host "Segments file 'segments.inc' created successfully."

# Read the template content
$templateContent = Get-Content -Path $templateFile

# Extract the MEMORY and SEGMENTS sections
$memorySection = $templateContent -join "`n" -replace '(?s).*MEMORY\s*{(.*?)\}.*', '$1'
$segmentSection = $templateContent -join "`n" -replace '(?s).*SEGMENTS\s*{(.*?)\}.*', '$1'

# Get all PRGA segments from the MEMORY section
$prgaInMemory = ($memorySection -split "`n" | Where-Object { $_ -match 'PRGA_(\w+):' }) -replace '.*PRGA_(\w+):.*', '$1'

# Get all PRGA segments used in the SEGMENTS section
$prgaInSegments = ($segmentSection -split "`n" | Where-Object { $_ -match 'load\s*=\s*PRGA_(\w+)' }) -replace '.*PRGA_(\w+).*', '$1'

# Find unused PRGA segments (in MEMORY but not in SEGMENTS)
$unusedPrgaSegments = $prgaInMemory | Where-Object { $_ -notin $prgaInSegments }

if (-not $unusedPrgaSegments) {
    Write-Host "No unused PRGA segments available."
    exit
}

# Get the .hfm files from the current script directory (levels output folder)
$hfmFiles = Get-ChildItem -Path $levelsOutputFolder -Filter *.hfm

$newSegments = foreach ($bank in $bankAssignments.Keys) {
    if ($unusedPrgaSegments.Count -eq 0) {
        Write-Host "Not enough unused PRGA segments for the bank files."
        exit
    }

    $prga = $unusedPrgaSegments[0] # Get the next available PRGA segment
    $unusedPrgaSegments = $unusedPrgaSegments[1..$unusedPrgaSegments.Count] # Remove it from the list

    # Create a segment for the entire bank
    $segmentName = "LBNK_{0:00}" -f $bank
    $segmentEntry = "${segmentName}:     load = PRGA_${prga}, type = ro;"

    # Return the segment entry
    $segmentEntry
}

# Replace the placeholder with the new segments
$templateContent = $templateContent -replace '\[LEVEL SEGMENTS\]', ($newSegments -join "`r`n")

# Write the updated content to the output file
$templateContent | Set-Content -Path $outputFile

Write-Host "Template updated with segments from assigned banks."

