<#PSScriptInfo


.SYNOPSIS
This Script from within a VM to fetch its metadata.

.DESCRIPTION
This Script from within a VM to fetch its metadata.

#>

param()
try {
    Invoke-RestMethod -Headers @{"Metadata" = "true" } -Method GET  -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 50
}
catch {
    Write-Output "Error while capturing the meta data. Error Message: '$($_.Exception.Message)'"   
}
