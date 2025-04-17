# warranty-check-powershell script
# Made by Jason-Koob on GitHub

function __main__ {
    param(
        [string]$source,
        [string]$maker,
        [int32]$serial
    )

    if (-not $source) {
        Write-Host "Error: Please provide a source" -ForegroundColor Red
        return
    }
    if (-not $maker) {
        Write-Host "Error: Please provide a maker" -ForegroundColor Red
        return
    }
    if (-not $serial) {
        Write-Host "Error: Please provide a serial" -ForegroundColor Red
        return
    }

}

__main__