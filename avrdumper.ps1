
param(
    # processor to use, eg. atmega328p
    $processor = $null,

    # programmer to use, eg. usbasp
    $programmer = $null,

    # output directory (when dumping) or input directory (when flashing), with files for each memory segment of the chip
    $dumpDir = $null,

    # should we dump (true) OR flash (false) the chip?
    $dump = $true,

    # use raw (true) or intel hex (false) format for dumping?
    $dumpRaw = $true
)


## Init ##
$avrdude = "./bin/avrdude.exe"
$memSegments = @("flash", "eeprom", "lfuse", "hfuse", "efuse", "lock", "calibration", "signature")


## Functions ##
function Is-NullOrWhitespace([string]$s)
{
    [String]::IsNullOrWhiteSpace($s)
}

function Get-FirstExisting([string]$fileA, [string]$fileB)
{
    if (Test-Path $fileA -PathType Leaf)
    {
        # file a exists
        $fileA
    }
    else 
    {
        if (Test-Path $fileB -PathType Leaf)
        {
            # file b exists
            $fileB
        }
        else
        {
            # no file exists
            $null
        }
    }
}

function Combine-Path([string]$a, [string]$b)
{
    [System.IO.Path]::Combine($a, $b)
}

function Resolve-FullPath([string]$path)
{
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function Create-Directory([string]$filePath)
{
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($filePath))
}

function Dump-AvrMemorySegment([string]$processor, [string]$programmer, [string]$segmentName, [string]$outputFile, [bool]$raw)
{
    # create output directory
    Create-Directory $outputFile

    # get descriptor for file type, default ihex
    $typeStr = "i"
    if($raw)
    {
        # bin/raw
        $typeStr = "r"
    }

    # dump using avrdude
    Write-Host "dumping $($segmentName) memory of $($processor) to $($outputFile) using $($programmer)..."
    & $avrdude -p "$processor" -c "$programmer" -U "$($segmentName):r:$($outputFile):$($typeStr)"
}

function Flash-AvrMemorySegment([string]$processor, [string]$programmer, [string]$segmentName, [string]$inputFile)
{
    # check file exists
    if (!(Test-Path $inputFile -PathType Leaf))
    {
        Write-Host "Failed to flash file $($inputFile): not found"
        return
    }

    # flash using avrdude
    Write-Host "flashing $($segmentName) memory of $($processor) with $($inputFile) using $($programmer)..."
    & $avrdude -p "$processor" -c "$programmer" -U "$($segmentName):w:$($inputFile):a"
}


## Read Parameters from user ##
Clear-Host
while (Is-NullOrWhitespace $processor) { $processor = Read-Host -Prompt "Enter Processor name (eg. atmega328p)" }
while (Is-NullOrWhitespace $programmer) { $programmer = Read-Host -Prompt "Enter Programmer name (eg. usbasp)" }
if (Is-NullOrWhitespace $dumpDir) {$dumpDir = "./dumps/$processor" }

if ($dump)
{
    ## dump the chip ##
    foreach($mem in $memSegments)
    {
        # build output file name
        $out = Combine-Path -a $dumpDir -b "$($mem).$(if ($dumpRaw) {"bin"} else {"hex"})"

        # dump to file
        Dump-AvrMemorySegment `
            -processor $processor `
            -programmer $programmer `
            -segmentName $mem `
            -outputFile $(Resolve-FullPath $out) `
            -raw $dumpRaw
    }
    
    Write-Host "Finished dumping"
}
else
{
    ## flash the chip ##
    foreach($mem in $memSegments)
    {
        # build output file name
        $in = Combine-Path -a $dumpDir -b $mem
        $in = Get-FirstExisting -fileA "$($in).bin" -fileB "$($in).hex"
        
        # flash with file
        Flash-AvrMemorySegment `
            -processor $processor `
            -programmer $programmer `
            -segmentName $mem `
            -inputFile $(Resolve-FullPath $in)
    }
    
    Write-Host "Finished flashing"
}