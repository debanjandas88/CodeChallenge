<#PSScriptInfo


.SYNOPSIS
This Script is used to fetch the metadata of an azure resources across subscriptions 
by providing the name of the resource

.DESCRIPTION
This Script is used to fetch the metadata of an azure resources across subscriptions 
by providing the name of the resource

.PARAMETER ResourceName
Specifies the name of the resource

.EXAMPLE

.\ScriptToFetchMetadataOfAzureResources.ps1 -ResourceName 'myVM'

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceName
)

try {

    #region current user token

    $currentAzureContext = Get-AzContext
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azureRmProfile)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)

    #endRegion

    ##Fetching the subsription in Scope

    Write-Host "Fetching the subscription in scope"
    $subscriptionIds = (Get-AzSubscription).Id

    $resourceGraphUri = "https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2021-03-01"

    foreach ($subscriptionId in $subscriptionIds) {
        $subs = @()
        #region Firing resource graph API to query the resource under subscription

        $SubscriptionName = (Get-AzSubscription -SubscriptionId $subscriptionId).Name
        Write-Host "Querying all the resources under subscription $subscriptionName"

        $filterResource = "Resources | where name =~ '$resourceName'"
        $subs += $subscriptionId
  
        $invokeResourceGraphQueryArgs = @{
            Uri     = $resourceGraphUri
            Method  = 'Post'
            Headers = @{
                Authorization = 'Bearer {0}' -f $token.AccessToken            
            }
            Body    = @{
                subscriptions = $subs
                query         = $filterResource
                options       = @{
                    "`$top"  = 500
                    "`$skip" = 0
                }
            } | ConvertTo-Json -Depth 5
        }
        try {
            $fetchResource = Invoke-RestMethod @invokeResourceGraphQueryArgs -ContentType 'application/json' -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "Error while accessing the metadata for $resourceName. Error Message: '$($_.Exception.Message)'" -ErrorAction SilentlyContinue  
        }
        #endRegion

        #region check whether resource exists or not

        if ($fetchResource.count -gt 0) {
            $resourceData = $fetchResource.data
            foreach ($resource in $resourceData) {
                $resourceType = $resource.type
                Switch ($resourceType) {
                    'microsoft.compute/virtualmachines' {
                        #region to fetch metadata of VM

                        #region check the power state of the VM
                        if ($resource.properties.extended.instanceView.powerState.displayStatus -ne 'VM Running') {
                            Write-Host "Instance metadata service API cannot be fired as the VM is in powered off state. Starting the VM" 
                            Start-AzVM -Name $vmName -ResourceGroupName $checkVMExistence.ResourceGroupName
                            $vmstarted = $true
                        }
                        else {
                            Write-Host "The VM is up and running and hence the Instance metadata service API can be fired"
                        }
                        #endRegion

                        #region fetch the metadata
                      
                        $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'Scripts/retrieveMetaData.ps1'
                        $retrieveMetaData = Invoke-AzVMRunCommand -ResourceGroupName $resource.resourceGroup -Name $resource.name -CommandId 'RunPowerShellScript' -ScriptPath $scriptPath
                        $scriptMessage = $retrieveMetaData.Value[0].Message 
                        if ( $scriptMessage -match 'Error') {
                            Write-Error "Error message: $scriptMessage" -ErrorAction Stop
                        }
                        else {
                            Write-Host "Please find below the metadata for VM $resourceName"
                            $scriptMessage
                        }

                        #endRegion

                        #region stop the VM is it was started

                        if ($vmstarted) {
                            Write-Host "Stopping the VM as it was started to fetch the metadata"
                            Stop-AzVM -Name $vmName -ResourceGroupName $checkVMExistence.ResourceGroupName
                            Write-Host "VM has been stopped"
                        }

                        #endRegion

                        #endRegion
                    }
               
                    'microsoft.keyvault/vaults' {
                        #region fetch metadata of disk

                        $kvRGName = $resource.ResourceGroup
                        $kvName = $resource.Name

                        $fetchKVUri = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.KeyVault/vaults/{2}?api-version=2021-10-01" -f @($subscriptionId, $kvRGName, $kvName)
                   
                        $irmKVArgs = @{
                            Headers     = @{
                                Authorization = 'Bearer {0}' -f $token.AccessToken
                            }
                            ErrorAction = 'Continue'
                            Method      = 'GET'
                            Uri         = $fetchKVUri
                        }
 
                        $metadata = Invoke-RestMethod @irmKVArgs
                        Write-Host "Please find below key vault metadata of name $resourceName :"
                        $metadata | ConvertTo-Json -Depth 20
 
                        #endRegion
                    }
                    'microsoft.compute/disks' {
                        #region fetch metadata of disk

                        $diskRGName = $resource.ResourceGroup
                        $diskName = $resource.Name
                        $fetchdiskUri = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Compute/disks/{2}?api-version=2021-12-01" -f @($subscriptionId, $diskRGName, $diskName)
                  
                        $irmDiskArgs = @{
                            Headers     = @{
                                Authorization = 'Bearer {0}' -f $token.AccessToken
                            }
                            ErrorAction = 'Continue'
                            Method      = 'GET'
                            Uri         = $fetchdiskUri
                        }

                        $metadata = Invoke-RestMethod @irmDiskArgs
                        Write-Host "Please find below VM disk metadata of name $resourceName :"
                        $metadata | ConvertTo-Json -Depth 20

                        #endRegion
                    }
                    'microsoft.storage/storageaccounts' {
                        #region Fetch MetaData of Storage Account

                        $saRGName = $resource.ResourceGroup
                        $saName = $resource.Name
                        $fetchSAUri = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Storage/storageAccounts/{2}?api-version=2021-09-01" -f @($subscriptionId, $saRGName, $saName)
                  
                        $irmSAArgs = @{
                            Headers     = @{
                                Authorization = 'Bearer {0}' -f $token.AccessToken
                            }
                            ErrorAction = 'Continue'
                            Method      = 'GET'
                            Uri         = $fetchSAUri
                        }

                        $metadata = Invoke-RestMethod @irmSAArgs
                        Write-Host "Please find below storage account metadata of name $resourceName : "
                        $metadata | ConvertTo-Json -Depth 20

                        #endRegion

                    }

                    #'Other resource' {                    }

                }
            }
        }
        else {
            Write-Host "No resource exists with the name $resourceName under subscription: $subscriptionName" -ErrorAction SilentlyContinue
        }

        #endRegion
    }

}
catch {
    Write-Error "Error while accessing the metadata for $resourceName. Error Message: '$($_.Exception.Message)'" -ErrorAction Stop
}
