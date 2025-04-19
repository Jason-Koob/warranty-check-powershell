# warranty-check-powershell script
# Made by Jason-Koob on GitHub

param(
    [string]$source,
    [string]$maker,
    [string]$serial,
    [switch]$h
)

if ($h) {
    Write-Host "Usage: .\script.ps1 -source <path_to_csv> -maker <column_name_or_index> -serial <column_name_or_index>"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -source    Path to the CSV file containing the data."
    Write-Host "  -maker     Column name or index for the maker/manufacturer."
    Write-Host "  -serial    Column name or index for the serial number."
    Write-Host "  -h         Display this help message."
    return
}

if (-not $source) {
    Write-Host "Error: Please provide a source file path (Ex. -source 'configurations.csv')" -ForegroundColor Red
    return
}
if (-not $maker) {
    Write-Host "Error: Please provide a maker/manufacturer column index (Ex. -maker 3)" -ForegroundColor Red
    return
}
if (-not $serial) {
    Write-Host "Error: Please provide a serial column index (Ex. -serial 2)" -ForegroundColor Red
    return
}

if (-not (Test-Path $source)) {
    Write-Host "Error: Source file not found." -ForegroundColor Red
    return
}
if ([System.IO.Path]::GetExtension($source) -ne ".csv") {
    Write-Host "Error: Source file must be a CSV file." -ForegroundColor Red
    return
}
function callLenovoWarrantyCheck {
    param (
        [Parameter(Mandatory=1, Position=0)]
        [String]$SerialNumber
    )

    $data = @{
        "serialNumber" = $SerialValue
        "machineType"  = ""
        "country"      = "us"
        "language"     = "en"
    }
    $json = $data | ConvertTo-Json -Depth 10

    try {
        $Response = Invoke-WebRequest -Uri "https://pcsupport.lenovo.com/us/en/api/v4/upsell/redport/getIbaseInfo" `
            -Method Post `
            -Headers @{
                "User-Agent"    = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0"
                "Accept"        = "application/json, text/plain, */*"
                "Accept-Language" = "en-US,en;q=0.5"
                "Content-Type"  = "application/json"
            } `
            -Body $json

        $ResponseData = $Response.Content | ConvertFrom-Json

        $WarrantyStart = $ResponseData.Data.baseWarranties[0].startDate
        $WarrantyEnd = $ResponseData.Data.baseWarranties[0].endDate
        Write-Host ""
        Write-Host "Manufacturer: $makerValue"
        Write-Host "Serial Number: $serialValue"
        Write-Host "Warranty Start: $WarrantyStart"

        if ([datetime]::Parse($WarrantyEnd) -lt (Get-Date)) {
            Write-Host "Warranty End: $WarrantyEnd" -ForegroundColor Red
        } else {
            Write-Host "Warranty End: $WarrantyEnd" -ForegroundColor Green
        }
        # Write-Host "Product: $Product"
        # Write-Host "Model: $Model"
        # Write-Host "Type: $Brand"
        Write-Host "----------------------------------------"

    } catch {
        Write-Host "Error: Unable to retrieve warranty information for serial number $Serialvalue." -ForegroundColor Red
    }
}

try {
    $csvContent = Import-Csv -Path $source

    foreach ($row in $csvContent) {
        $serialValue = $row.serial
        $makerValue = $row.manufacturer

        if (-not $serialValue) {
            Write-Host "Error: Serial value is missing in one of the rows." -ForegroundColor Red
            continue
        }
        if (-not $makerValue) {
            Write-Host "Error: Manufacturer value is missing in one of the rows." -ForegroundColor Red
            continue
        }

        $makerValue = $makerValue.Substring(0, 1).ToUpper() + $makerValue.Substring(1).ToLower()
        $serialValue = $serialValue.ToUpper()

        if ($makerValue -eq "Lenovo") {
            callLenovoWarrantyCheck -SerialNumber $serialValue
        }
        
    }
} catch {
    Write-Host "Error: Unable to process the CSV file. Ensure it has the correct format." -ForegroundColor Red
    Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Red
    return
}

