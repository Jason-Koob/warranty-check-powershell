# warranty-check-powershell script
# Made by Jason/Koob

param(
    [string]$source,
    [string]$maker,
    [string]$serial,
    [string]$output = "warranty_results.csv",
    [switch]$h
)

if ($h) {
    Write-Host "Usage: .\script.ps1 -source <path_to_csv> -maker <column_name> -serial <column_name> -output <output_csv>"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -source    Path to the input CSV file"
    Write-Host "  -maker     Manufacturer column name"
    Write-Host "  -serial    Serial number column name"
    Write-Host "  -output    Output CSV path (default: warranty_results.csv)"
    Write-Host "  -h         Display help"
    return
}

if (-not $source -or -not $maker -or -not $serial) {
    Write-Host "Error: Missing required parameters" -ForegroundColor Red
    return
}

if (-not (Test-Path $source)) {
    Write-Host "Error: Source file not found" -ForegroundColor Red
    return
}

if ([System.IO.Path]::GetExtension($source) -ne ".csv") {
    Write-Host "Error: Source must be a CSV file" -ForegroundColor Red
    return
}

$Results = @()

function callLenovoWarrantyCheck {
    param (
        [Parameter(Mandatory=1, Position=0)]
        [String]$SerialNumber,
        [String]$Manufacturer
    )

    $data = @{
        "serialNumber" = $SerialNumber
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
        $WarrantyEnd   = $ResponseData.Data.baseWarranties[0].endDate
        $Status = if ([datetime]::Parse($WarrantyEnd) -lt (Get-Date)) {"Expired"} else {"Active"}

        return [pscustomobject]@{
            SerialNumber  = $SerialNumber
            Manufacturer  = $Manufacturer
            WarrantyStart = $WarrantyStart
            WarrantyEnd   = $WarrantyEnd
            Status        = $Status
        }

    } catch {
        return [pscustomobject]@{
            SerialNumber  = $SerialNumber
            Manufacturer  = $Manufacturer
            WarrantyStart = "N/A"
            WarrantyEnd   = "N/A"
            Status        = "Error"
        }
    }
}

try {
    $csvContent = Import-Csv -Path $source

    foreach ($row in $csvContent) {
        $serialValue = $row.$serial
        $makerValue = $row.$maker

        if (-not $serialValue) {
            Write-Host "Error: Missing serial in row" -ForegroundColor Yellow
            continue
        }
        if (-not $makerValue) {
            Write-Host "Error: Missing manufacturer in row" -ForegroundColor Yellow
            continue
        }

        $makerValue = $makerValue.Substring(0, 1).ToUpper() + $makerValue.Substring(1).ToLower()
        $serialValue = $serialValue.ToUpper()

        if ($makerValue -eq "Lenovo") {
            $result = callLenovoWarrantyCheck -SerialNumber $serialValue -Manufacturer $makerValue
        } else {
            $result = [pscustomobject]@{
                SerialNumber  = $serialValue
                Manufacturer  = $makerValue
                WarrantyStart = ""
                WarrantyEnd   = ""
                Status        = ""
            }
        }

        $Results += $result
        Write-Host "Processed $serialValue ($makerValue) - Status: $($result.Status)"
    }

    # Export with columns in the specified order
    $Results | Select-Object SerialNumber,Manufacturer,WarrantyStart,WarrantyEnd,Status |
        Export-Csv -Path $output -NoTypeInformation

    Write-Host "`nResults exported to $output" -ForegroundColor Green

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
