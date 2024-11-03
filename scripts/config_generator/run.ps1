# Define paths
$templateFile = "config_template.cfg"
$levelsInputFolder = "src\tiled_levels"
$levelsOutputFolder = "src\tiled_levels\generated"
$outputFile = "generated.cfg"

# Function to convert a hashtable of CSV strings into a hashtable of byte arrays
function Convert-CSVToByteArray {
    param (
        [hashtable]$tileLayerData
    )

    # Initialize a hashtable to store byte arrays for each layer
    $byteArrayData = @{}

    # Process each layer's CSV data in the hashtable
    foreach ($layerName in $tileLayerData.Keys) {
        if(($layerName -ne "foreground") -and ($layerName -ne "background")){continue}

        $csvData = $tileLayerData[$layerName]

        # Split the CSV string into individual values
        $tileData = $csvData -split ','

        # Convert each tile value to a byte and store in an array
        $byteArray = @()
        foreach ($tile in $tileData) {
            $tile = $tile - 1
            if($tile -eq -1) { 
                $tile = 0
            }
            [byte]$byte = [convert]::ToByte($tile)
            $byteArray += $byte
        }

        # Add the byte array to the output hashtable, keyed by layer name
        $byteArrayData[$layerName] = $byteArray
    }

    return $byteArrayData
}

# Function to parse the TMX file and extract tile layer data for background and foreground
function ExtractTileLayerData {
    param (
        [string]$tmxFilePath
    )

    # Load the XML content of the TMX file
    $xmlContent = [xml](Get-Content -Path $tmxFilePath)

    # Initialize a hashtable to store data for each layer
    $tileLayerData = @{}

    # Loop through each layer and check for background and foreground names
    foreach ($layer in $xmlContent.map.layer) {
        $layerName = $layer.name
        if ($layerName -eq "background" -or $layerName -eq "foreground") {
            # Extract the CSV data for the layer
            $csvData = $layer.data.InnerText.Trim()
            # Store it in the hashtable with the layer name as the key
            $tileLayerData[$layerName] = $csvData
        }
    }

    $tileLayerData["width"] = $xmlContent.map.width
    $tileLayerData["timer"] = $xmlContent.map.properties.property | Where-Object { $_.name -eq "timer" } | Select-Object -ExpandProperty value

    return $tileLayerData
}

# Function to compress each layer's byte array and save to separate files
function CompressTileLayerData {
    param (
        [string]$levelName,            # Base name for the output files
        [string]$levelsOutputFolder,   # Output folder path
        [hashtable]$byteArrayData,     # Hashtable containing byte arrays for each layer
        [Int16]$levelLength,
        [Int16]$levelTimer
    )

    # Iterate through each layer in the byteArrayData hashtable
    foreach ($layerName in $byteArrayData.Keys) {
        # Determine the file suffix based on the layer name
        $suffix = if ($layerName -eq "background") { "_bg" } else { "_fg" }
        $outputFileName = "${levelName}${suffix}.hfm"

        # Generate a temporary binary file path for the layer data
        $tempFilePath = [System.IO.Path]::Combine($levelsOutputFolder, "${levelName}${suffix}.temp")

        # Write the byte array for the current layer to the temporary binary file
        [System.IO.File]::WriteAllBytes($tempFilePath, $byteArrayData[$layerName])

        # Generate the compressed file path
        $outputFilePath = Join-Path -Path $levelsOutputFolder -ChildPath $outputFileName

        # Run huffmunch to compress the binary data to the output file
        & "../../tools/huffmunch" "-B" $tempFilePath $outputFilePath

        if($suffix -eq "_fg") {
            $hfmForegroundFinalData = @()
            $hfmForegroundFinalData += [System.BitConverter]::GetBytes($levelTimer)
            $hfmForegroundFinalData += [System.BitConverter]::GetBytes($levelLength)
            $hfmForegroundFinalData += [System.IO.File]::ReadAllBytes($outputFilePath)
            [io.file]::WriteAllBytes($outputFilePath,$hfmForegroundFinalData)
        }

        # Delete the temporary binary file
        Remove-Item -Path $tempFilePath
    }
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

    $tileLayerData = ExtractTileLayerData -tmxFilePath $tmxFile.FullName
    $length = $tileLayerData["width"]
    $timer = $tileLayerData["timer"]
    $byteArrayData = Convert-CSVToByteArray -tileLayerData $tileLayerData
    CompressTileLayerData -levelName $newName -levelsOutputFolder $levelsOutputFolder -byteArrayData $byteArrayData -levelLength $length -levelTimer $timer
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
    return ".segment `"LBNK_{0:00}`"`n" -f $bankNumber
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

    # Add the file incbin line to the segments content
    $segmentsIncContent += [System.IO.Path]::GetFileNameWithoutExtension($hfmFile) + ":`n    .incbin `"{0}`"`n" -f $hfmFile.Name
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

