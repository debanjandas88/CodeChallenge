<#PSScriptInfo


.SYNOPSIS
This Function is used to fetch the value of the last element in a nested JSON object based on a given key 

.DESCRIPTION
This Function is used to fetch the value of the last element in a nested JSON object based on a given key 
.PARAMETER InputJsonObject
Specifies the Input Json Object

.PARAMETER Key
Specifies the key

.ASSUMPTION

The key passed in the format 'a/b/c'

.EXAMPLE

TraverseNestedJson -InputJsonObject 'InputJsonObject' -Key 'a/b/c'

#>


Function TraverseNestedJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputJsonObject,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    try {
 
        #region splitting the key into array object

        $keyArray = @()
        $keyArray += $key.Split('/')
        $lastKeyElement = $keyArray[-1]

        #endRegion

        #region traversing through the json object

        $inputObject = $InputJsonObject | ConvertFrom-Json
        $rootProperties = @()
        $childProperties = @()
        $rootProperties += ($inputObject.psobject.properties | where-object { $_.MemberType -eq "NoteProperty" })
   
        foreach ($rootProperty in $rootProperties) {
            $childProperties += $rootProperty.Value.psobject.Properties | where-object { $_.MemberType -eq "NoteProperty" -and $_.Value -match $lastKeyElement }
       
            foreach ($childProperty in $childProperties) {
                $value = ($childProperty | Where-Object { $_.value -match $lastKeyElement }).Value
                Write-Host "value: $($value.$lastKeyElement)"
            }
        }

        #endRegion

    }
    catch {
        Write-Error "Error while parsing the JSON object. Error Message: '$($_.Exception.Message)'"
    }
}

