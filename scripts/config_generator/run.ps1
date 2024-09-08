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
foreach ($tmxFile in $tmxFiles) {
    # Extract the CSV tile data from the TMX file
    $csvData = ExtractTileLayerData -tmxFilePath $tmxFile.FullName

    # Convert the CSV tile data to a byte array
    $byteArray = Convert-CSVToByteArray -csvData $csvData

    # Generate a temporary binary file path
    $tempFilePath = [System.IO.Path]::ChangeExtension($tmxFile.FullName, ".temp")

    # Write the byte array to the binary file
    [System.IO.File]::WriteAllBytes($tempFilePath, $byteArray)

    $inputFilePath = $tmxFile.FullName
    $outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($tmxFile) + ".hfm"
    $outputFilePath = Join-Path -Path $levelsOutputFolder -ChildPath $outputFileName
    & "../../tools/huffmunch" "-B" $tempFilePath $outputFilePath

    # Delete the temporary binary file
    Remove-Item -Path $tempFilePath
}

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

# Generate new segments based on .hfm files using unused PRGA segments
$newSegments = foreach ($file in $hfmFiles) {
    if ($unusedPrgaSegments.Count -eq 0) {
        Write-Host "Not enough unused PRGA segments for the bank files."
        exit
    }

    $segmentName = $file.BaseName  # Extract the file name without extension
    $prga = $unusedPrgaSegments[0] # Get the next available PRGA segment
    $unusedPrgaSegments = $unusedPrgaSegments[1..$unusedPrgaSegments.Count] # Remove it from the list

    "LBNK_${segmentName}:     load = PRGA_${prga}, type = ro;"
}

# Replace the placeholder with the new segments
$templateContent = $templateContent -replace '\[LEVEL SEGMENTS\]', ($newSegments -join "`r`n")

# Write the updated content to the output file
$templateContent | Set-Content -Path $outputFile

Write-Host "Template updated with segments from .hfm files."
