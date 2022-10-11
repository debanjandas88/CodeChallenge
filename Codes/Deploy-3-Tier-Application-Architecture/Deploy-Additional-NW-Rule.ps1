<#
.SYNOPSIS
  Creates network security group and network rules

.DESCRIPTION
 Creates network security group and network rules

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

.PARAMETER SubscriptionID
  Specifies the SubscriptionID

.PARAMETER Action
  Specifies the action whether to add, modify or delete NSG or its rule names

.PARAMETER SubscriptionID
  Specifies the SubscriptionID

.PARAMETER NsgRemoval
  Specifies the flag which determines whether to remove NSG or not

.PARAMETER Protocol
  Specifies the Protocol 

.PARAMETER SubnetAssociationFlag
  A flag which specifies whether a subnet needs to be associated or not. 


.PARAMETER AssociatedSNName
  Specifies the subnet name which is to be associated to the route table if SubnetAssociationFlag  is true

.PARAMETER SubnetRemovalFlag
  A Flag which Determines whether the existing subnet shall be removed from the NSG or not
 
.PARAMETER VnetName
  Specifies the VNET name. If the previous parameter "SubnetAssociationFlag" is true it is being used to fetch
  the vnet details to associate a subnet to the route table. 

.PARAMETER VnetRGName
  Specifies the VNET resource group name. If the previous parameter "SubnetAssociationFlag" is true it is being used to fetch
  the vnet details to associate a subnet to the NSG. 
#>


param(
  [Parameter(Mandatory = $true)]
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]
  [string]$NSGName,
  [Parameter(Mandatory = $true)]
  [string]$SubscriptionID,
  [Parameter(Mandatory = $true)]
  [ValidateSet("Add", "Remove", "Modify")]
  [string]$Action,
  [Parameter(Mandatory = $false)]
  [ValidateSet($true, $false)]
  [bool]$NsgRemoval,
  [Parameter(Mandatory = $false)]
  [string]$Location,
  [Parameter(Mandatory = $false)]
  [string]$RuleName,
  [Parameter(Mandatory = $false)]
  [string]$RuleDescription,
  [Parameter(Mandatory = $false)]
  [string]$Protocol,
  [Parameter(Mandatory = $false)]
  [string]$SourcePortRange,
  [Parameter(Mandatory = $false)]
  [string]$DestinationPortRange,
  [Parameter(Mandatory = $false)]
  [string]$SourceAddressPrefix,
  [Parameter(Mandatory = $false)]
  [string]$DestinationAddressPrefix,
  [Parameter(Mandatory = $false)]
  [ValidateSet("Allow", "Deny")]
  [string]$Access,
  [Parameter(Mandatory = $false)]
  [string]$Priority,
  [Parameter(Mandatory = $false)]
  [ValidateSet("Inbound", "Outbound")]
  [string]$Direction,
  [Parameter(Mandatory = $false)]
  [ValidateSet($true, $false)]
  [bool]$SubnetAssociationFlag,
  [Parameter(Mandatory = $false)]
  [ValidateSet($true, $false)]
  [bool]$SubnetRemovalFlag,
  [Parameter(Mandatory = $false)]
  [string]$VnetName,
  [Parameter(Mandatory = $false)]
  [string]$VnetRGName,
  [Parameter(Mandatory = $false)]
  [string]$AssociatedSNName,
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

       ## importing the required modules
       $commonModulePath = Join-Path $PSScriptRoot -ChildPath 'Modules\CommonModules'

       Import-Module -name $commonModulePath -Verbose
       Write-Host "Imported required modules"

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
        SubscriptionID           = $SubscriptionID
        Action                   = $Action
        Location                 = $Location
        NsgRemoval               = $NsgRemoval
        SubnetAssociationFlag    = $SubnetAssociationFlag
        SubnetRemovalFlag        = $SubnetRemovalFlag      
        VnetName                 = $VnetName
        VnetRGName               = $VnetRGName
        AssociatedSNName         = $AssociatedSNName
        TaggingData              = $TaggingData
    }


    New-OrModifyNetworkSecurityGrp @nsgCreateParams

    Write-Host "Created N/W rule and added to NSG"

    #endRegion
}catch{
    Write-Error "Error while creating n/w rule  $NWRuleName and attaching to NSG $NSGName. Error Message: '$($_.Exception.Message)'"
}