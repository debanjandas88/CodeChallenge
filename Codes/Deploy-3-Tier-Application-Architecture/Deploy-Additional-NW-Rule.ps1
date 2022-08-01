<#
.SYNOPSIS
  Creates a network rule and attach to NSG

.DESCRIPTION
 Creates a network rule and attach to NSG

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER NSGName
  Specifies the NSG name

.PARAMETER RuleName
  Specifies the network rule name

.PARAMETER Action
  Specifies the Action

.PARAMETER RuleDescription
 Specifies the network rule description

.PARAMETER SourcePortRange
  Specifies the source port range

.PARAMETER DestinationPortRange
  Specifies the destination port range

.PARAMETER SourceAddressPrefix
  Specifies the Source Address Prefix

.PARAMETER DestinationAddressPrefix
  Specifies the Destination Address Prefix

.PARAMETER Access
  Specifies the access allow/deny

.PARAMETER Priority
  Specifies the priority of network rule

.PARAMETER Direction
  Specifies the direction of n/w rule inbound/outbound

#>


param(
    [Parameter(Mandatory = $false)]
    [string]$NWProtocol,
    [Parameter(Mandatory = $true)]
    [string]$NWRuleName,
    [Parameter(Mandatory = $true)]
    [ValidateSet("Add", "Remove")]
    [string]$Action,
    [Parameter(Mandatory = $false)]
    [string]$NWRuleDescription,
    [Parameter(Mandatory = $false)]
    [string]$SourcePortRange,
    [Parameter(Mandatory = $false)]
    [string]$DestinationPortRange,
    [Parameter(Mandatory = $false)]
    [string]$SourceAddressPrefix,
    [Parameter(Mandatory = $false)]
    [string]$DestinationAddressPrefix,
    [Parameter(Mandatory = $false)]
    [string]$Access,
    [Parameter(Mandatory = $false)]
    [string]$Priority,
    [Parameter(Mandatory = $false)]
    [string]$Direction,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$NSGName,
    [Parameter(Mandatory = $false)]
    [string]$Location,
    [Parameter(Mandatory = $false)]
    [string]$ApplicationID,
    [Parameter(Mandatory = $false)]
    [string]$ApplicationName
)


try{

    Write-Host "Configuring Tagging Data"
    $taggingData = @{
        ApplicationID   = $ApplicationID
        ApplicationName = $ApplicationName
    }
    Write-Host "Configured Tagging Data"
    #region create additional network rules 

    Write-Host "Creating Additional rule  $NWRuleName and attach to NSG $NSGName"
    $nsgCreateParams = @{

        RuleName                 = $NWRuleName
        RuleDescription          = $NWRuleDescription
        Protocol                 = $NWProtocol
        SourcePortRange          = $SourcePortRange
        DestinationPortRange     = $DestinationPortRange
        SourceAddressPrefix      = $SourceAddressPrefix
        DestinationAddressPrefix = $DestinationAddressPrefix
        Access                   = $Access
        Priority                 = $Priority
        Direction                = $Direction
        ResourceGroupName        = $ResourceGroupName
        NSGName                  = $NSGName
        Location                 = $Location
        TaggingData              = $TaggingData
        Action                   = $Action
    }


    New-NetworkSecurityGrp @nsgCreateParams

    Write-Host "Created N/W rule and added to NSG"

    #endRegion
}catch{
    Write-Error "Error while creating n/w rule  $NWRuleName and attaching to NSG $NSGName. Error Message: '$($_.Exception.Message)'"
}
