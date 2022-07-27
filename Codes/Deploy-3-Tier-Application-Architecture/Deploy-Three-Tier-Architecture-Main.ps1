<#
.SYNOPSIS 
This Script is used to Deploy 3-Tier architecture in a modularized fasion

.DESCRIPTION
This Script is used to Deploy 3-Tier architecture in a modularized fasion

.EXAMPLE

.\ScriptToFetchMetadataOfAzureResources.ps1 -ResourceName 'myVM'

.Notes
The resource creation is performed by module function so as to make the structure modularized.
Module function can be accessed in the following path
 <<RootPath>>\Modules\CommonModules.psm1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]$ApplicationID,
    [Parameter(Mandatory = $true)]
    [string]$ApplicationName,
    [Parameter(Mandatory = $true)]
    [string]$AppGatewayName,
    [Parameter(Mandatory = $true)]
    [string]$AppGatewaySkuName,
    [Parameter(Mandatory = $true)]
    [string]$AppGatewayTier,
    [Parameter(Mandatory = $true)]
    [string]$AGSubnetName,
    [Parameter(Mandatory = $true)]
    [string]$AGAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$BackEndsubnetName,
    [Parameter(Mandatory = $true)]
    [string]$BackEndAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$VnetName,
    [Parameter(Mandatory = $true)]
    [string]$VnetAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$PIPName,
    [Parameter(Mandatory = $true)]
    [string]$AppGatewayIPName,
    [Parameter(Mandatory = $true)]
    [string]$AGFrontendIPConfigName,
    [Parameter(Mandatory = $true)]
    [string]$AGFrontEndPortName,
    [Parameter(Mandatory = $true)]
    [string]$AGBackEndPoolName,
    [Parameter(Mandatory = $true)]
    [string]$AGBackEndPoolSettingName,
    [Parameter(Mandatory = $true)]
    [string]$ListenerName,
    [Parameter(Mandatory = $true)]
    [string]$FrontEndRuleName,
    [Parameter(Mandatory = $true)]
    [string]$KeyVaultName,
    [Parameter(Mandatory = $true)]
    [string]$LAWorkSpaceName,
    [Parameter(Mandatory = $true)]
    [string]$LASku,
    [Parameter(Mandatory = $true)]
    [string]$VMName1,
    [Parameter(Mandatory = $false)]
    [string]$VMName2,
    [Parameter(Mandatory = $false)]
    [string]$VMName3,
    [Parameter(Mandatory = $false)]
    [string]$VMName4,
    [Parameter(Mandatory = $true)]
    [string]$NicName1,
    [Parameter(Mandatory = $false)]
    [string]$NicName2,
    [Parameter(Mandatory = $false)]
    [string]$NicName3,
    [Parameter(Mandatory = $false)]
    [string]$NicName4,
    [Parameter(Mandatory = $true)]
    [string]$VMSize,
    [Parameter(Mandatory = $true)]
    [string]$VMSku,
    [Parameter(Mandatory = $true)]
    [string]$SQLServerName,
    [Parameter(Mandatory = $true)]
    [string]$SQLDatabaseName,
    [Parameter(Mandatory = $true)]
    [string]$RequestedServiceObjectiveName,
    [Parameter(Mandatory = $true)]
    [string]$ILBName,
    [Parameter(Mandatory = $false)]
    [string]$Sku,
    [Parameter(Mandatory = $false)]
    [string]$NatGatewayIPName,
    [Parameter(Mandatory = $false)]
    [string]$NATGatewayName,
    [Parameter(Mandatory = $true)]
    [string]$IdleTimeOutMin,
    [Parameter(Mandatory = $true)]
    [string]$LBBackendSubnet,
    [Parameter(Mandatory = $true)]
    [string]$LBBackendSubnetAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$LBBastionSubName,
    [Parameter(Mandatory = $true)]
    [string]$LBBastionSubAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$LBVnetName,
    [Parameter(Mandatory = $true)]
    [string]$LBVnetAddressPrefix,
    [Parameter(Mandatory = $false)]
    [string]$LBbastionhostname,
    [Parameter(Mandatory = $false)]
    [string]$LBbastionPIP,
    [Parameter(Mandatory = $false)]
    [string]$LBRuleName,
    [Parameter(Mandatory = $true)]
    [string]$LBRuleDescription,
    [Parameter(Mandatory = $true)]
    [string]$LBProtocol,
    [Parameter(Mandatory = $true)]
    [string]$LBSourcePortRange,
    [Parameter(Mandatory = $true)]
    [string]$LBDestinationPortRange,
    [Parameter(Mandatory = $true)]
    [string]$LBSourceAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$LBDestinationAddressPrefix,
    [Parameter(Mandatory = $false)]
    [string]$LBAccess,
    [Parameter(Mandatory = $false)]
    [string]$LBPriority,
    [Parameter(Mandatory = $false)]
    [string]$LBDirection,
    [Parameter(Mandatory = $true)]
    [string]$FrontEndName,
    [Parameter(Mandatory = $true)]
    [string]$PrivateIPAddress,
    [Parameter(Mandatory = $true)]
    [string]$LBBackEndPoolName,
    [Parameter(Mandatory = $true)]
    [string]$LBHeathProbeName,
    [Parameter(Mandatory = $true)]
    [string]$LBHealthProbeProtocol,
    [Parameter(Mandatory = $true)]
    [string]$LBHealthProbePort,
    [Parameter(Mandatory = $true)]
    [string]$LBRuleName2,
    [Parameter(Mandatory = $true)]
    [string]$LBProtocol2,
    [Parameter(Mandatory = $true)]
    [string]$LBFrontEndPort,
    [Parameter(Mandatory = $true)]
    [string]$LBBackEndPort,
    [Parameter(Mandatory = $false)]
    [string]$NSGName,
    [Parameter(Mandatory = $true)]
    [string]$NWRuleName,
    [Parameter(Mandatory = $true)]
    [string]$NWRuleDescription,
    [Parameter(Mandatory = $true)]
    [string]$NWProtocol,
    [Parameter(Mandatory = $true)]
    [string]$RSVName,
    [Parameter(Mandatory = $false)]
    [string]$SourcePortRange,
    [Parameter(Mandatory = $false)]
    [string]$DestinationPortRange
)

try {

    #region setting context to subscription

    $SubscriptionId = (Get-AzSubscription -SubscriptionName $SubscriptionName).Id
    Write-Host "Setting context to subscription"
    $null = Set-AzContext -Subscription $SubscriptionId -Scope Process -ErrorAction Stop
    Write-Host "subscription context set"

    #endRegion

    #region Create Resource Group if not existing

    Write-Host "Configuring Tagging Data"
    $taggingData = @{
        ApplicationID   = $ApplicationID
        ApplicationName = $ApplicationName
    }
    Write-Host "Configured Tagging Data"

    $checkRG = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

    if ($null -eq $checkRG) {
        $createResourceGroupParams = @{
            ResourceGroupName = $ResourceGroupName
            Location          = $Location
            TaggingData       = $taggingData
        }
        New-ResourceGroup @createResourceGroupParams
        Write-Host "New resource group created of name $resourceGroupName"
    }
    else {
        Write-Host "Resource already exists of name $resourceGroupName"
    }

    #endRegion

    #region Create App gateway

    $checkAppGateway = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName -ErrorAction SilentlyContinue
    if ($null -eq $checkAppGateway) {
        Write-Host "App gateway of name $AppGatewayName does not exists. Calling the function for creating the same."
        $createAppGatewayParams = @{
            ResourceGroupName        = $ResourceGroupName
            AppGatewayName           = $AppGatewayName
            SkuName                  = $AppGatewaySkuName
            Tier                     = $AppGatewayTier 
            Location                 = $Location
            AGSubnetName             = $AGSubnetName
            AGAddressPrefix          = $AGAddressPrefix 
            BackEndsubnetName        = $BackEndsubnetName
            BackEndAddressPrefix     = $BackEndAddressPrefix
            VnetName                 = $VnetName
            VnetAddressPrefix        = $VnetAddressPrefix
            PIPName                  = $PIPName
            AppGatewayIPName         = $AppGatewayIPName
            AGFrontendIPConfigName   = $AGFrontendIPConfigName
            AGFrontEndPortName       = $AGFrontEndPortName
            AGBackEndPoolName        = $AGBackEndPoolName
            AGBackEndPoolSettingName = $AGBackEndPoolSettingName
            ListenerName             = $ListenerName
            FrontEndRuleName         = $FrontEndRuleName
            KeyVaultName             = $KeyVaultName
            LAWorkSpaceName          = $LAWorkSpaceName
            LASku                    = $LASku
            TaggingData              = $TaggingData
            SubscriptionID           = $SubscriptionID
        }
    
        New-AzureAppGateway @createAppGatewayParams  
    }
    else {
        Write-Host "App gateway of name $AppGatewayName already exists."
    }
    #endRegion

    #region Create web tier virtual machines to be added as the backend og application gateway

    #region fetching the backend pool information

    Write-Host "Create web tier virtual machines to be added as the backend og application gateway"
    Write-Host "Fetching the backend pool informtion of app gateway"
    $appgw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $AppGatewayName
    $backendPool = Get-AzApplicationGatewayBackendAddressPool -Name $AGBackEndPoolName -ApplicationGateway $appgw
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnetName
    $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $BackEndsubnetName

    #endRegion

    #region confirguting the inputs

    $vmname = @()
    $vmname += ($vmName1, $vmname2)
    Write-Host "VM names are $vmName"
    $nicname = @()
    $nicname += ($nicName1, $nicName2)
    Write-Host "Nic Names names are $nicname"

    $adminUser = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'adminusername' -AsPlainText
    $adminPAss = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'adminpassword' -AsPlainText
    $secureString = ConvertTo-SecureString -String $adminPAss -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $adminUser, $secureString

    #endRegion

    #region Create VM for backendPool of App gateway
    for ($i = 1; $i -le 2; $i++) {

        Write-Host "Creating NIC $($nicName[$i-1]) for VM name  $($VMName[$i-1])"
        $nic = New-AzNetworkInterface -Name $nicName[$i - 1] -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $subnet -ApplicationGatewayBackendAddressPool $backendpool

        $checkVMExitence = Get-AzVM -Name $VMName[$i - 1] -ErrorAction SilentlyContinue
        if ($null -eq $checkVMExitence) {
            Write-Host "Calling function to create VM name  $($VMName[$i-1])"
            $createVMParams = @{
                ResourceGroupName = $ResourceGroupName
                SubscriptionId    = $SubscriptionId
                AVSetName         = $AVSetName
                VMName            = $VMName[$i - 1]
                VMSize            = $VMSize
                Location          = $Location
                NICId             = $nic.Id
                Credential        = $Credential
                VMSku             = $VMSku
                TaggingData       = $TaggingData
            }
    
            New-VMCreation @createVMParams
        }
        else {
            Write-Host "The VM of name $($VMName[$i-1]) already exists"
        }
    }
    #EndRegion   

    #endRegion

    #region Create Internal load balancer for the business tier

    Write-Host "Create Internal load balancer for the business tier"
    Write-Host "Checking the exietence of the load balancer"
    $checkILB = Get-AzLoadBalancer -Name $ILBName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $checkILB) {
        Write-Host "The load balancer of name $ILBName does not exist. Calling the function for creating the same."

        $createILBParams = @{
            ResourceGroupName            = $ResourceGroupName
            ILBName                      = $ILBName
            Location                     = $Location
            Sku                          = $Sku
            NatGatewayIPName             = $NatGatewayIPName
            NaTGatewayName               = $NaTGatewayName
            IdleTimeOutMin               = $IdleTimeOutMin
            LBBackendSubnet              = $LBBackendSubnet
            LBBackendSubnetAddressPrefix = $LBBackendSubnetAddressPrefix
            LBBastionSubName             = $LBBastionSubName
            LBBastionSubAddressPrefix    = $LBBastionSubAddressPrefix
            LBVnetName                   = $LBVnetName
            LBVnetAddressPrefix          = $LBVnetAddressPrefix
            LBbastionhostname            = $LBbastionhostname
            LBbastionPIP                 = $LBbastionPIP
            LBRuleName                   = $LBRuleName
            LBRuleDescription            = $LBRuleDescription
            LBProtocol                   = $LBProtocol
            LBSourcePortRange            = $LBSourcePortRange
            LBDestinationPortRange       = $LBDestinationPortRange
            LBSourceAddressPrefix        = $LBSourceAddressPrefix
            LBDestinationAddressPrefix   = $LBDestinationAddressPrefix
            LBAccess                     = $LBAccess
            LBPriority                   = $LBPriority
            LBDirection                  = $LBDirection
            FrontEndName                 = $FrontEndName
            PrivateIPAddress             = $PrivateIPAddress
            LBBackEndPoolName            = $LBBackEndPoolName
            LBHeathProbeName             = $LBHeathProbeName
            LBHealthProbeProtocol        = $LBHealthProbeProtocol
            LBHealthProbePort            = $LBHealthProbePort
            LBRuleName2                  = $LBRuleName2
            LBProtocol2                  = $LBProtocol2
            LBFrontEndPort               = $LBFrontEndPort
            NSGName                      = $NSGName
            SubscriptionId               = $subscriptionId
            LBBackEndPort                = $LBBackEndPort
            TaggingData                  = $TaggingData
        }
     
        New-LoadBalancerCreation @createILBParams
        Write-Host "Create load balancer of name $ilbName"
    }
    else {
        Write-Host "Load balancer of name $ilbName already exists"
    }

    #endRegion

    #region all VM under the backendpool of load balancer

    #region configuring input parameters
    Write-Host "Create web tier virtual machines to be added as the backend of ILB"
    Write-Host "Fetching the backend pool informtion of ILB"

    $getILB = Get-AzLoadBalancer -Name $ILBName -ResourceGroupName $ResourceGroupName
    $getILBbePool = Get-AzLoadBalancerBackendAddressPoolConfig -LoadBalancer $getILB
    $fetchNSG = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName

    $vmnameLB = @()
    $vmnameLB += ($vmName3, $vmName4)

    Write-Host "VM names are $vmnameLB"

    $nicnameLB = @()
    $nicnameLB += ($nicName3, $nicName4)

    Write-Host "Nic names are $nicnameLB"

    $adminUser2 = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'adminusername' -AsPlainText
    $adminPAss2 = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'adminpassword' -AsPlainText
    $secureString2 = ConvertTo-SecureString -String $adminPAss2 -AsPlainText -Force
    $Credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $adminUser2, $secureString2

    #endRegion

    #region create backedn VMS ILB

    for ($i = 1; $i -le 1; $i++) {

        Write-Host "Creating NIC $($nicNameLB[$i-1]) for VM name  $($VMNameLB[$i-1])"
        $nic = New-AzNetworkInterface -Name $nicNameLB[$i - 1] -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $vnet.Subnets[2] -NetworkSecurityGroup  $fetchNSG -LoadBalancerBackendAddressPool $getILBbePool
        $checkVMExitenceLB = Get-AzVM -Name $VMNameLB[$i - 1] -ErrorAction SilentlyContinue
        if ($null -eq $checkVMExitenceLB) {
            Write-Host "Calling function to create VM name  $($VMNameLB[$i-1])"
            $createVMParams = @{
                ResourceGroupName = $ResourceGroupName
                SubscriptionId    = $SubscriptionId
                AVSetName         = $AVSetName
                VMName            = $VMNameLB[$i - 1]
                VMSize            = $VMSize
                Location          = $Location
                NICId             = $nic.Id
                Credential        = $Credential2
                VMSku             = $VMSku
                TaggingData       = $TaggingData
            }
    
            New-VMCreation @createVMParams
        }
        else {
            Write-Host "VM name  $($VMNameLB[$i-1]) already exists"
        }
    }

    #endRegion

    #endRegion

    #region Create Azure SQL data base

    #region fetching the private IP address of the business tier VMs
    Write-Host "fetching the private IP address of the business tier VMs"

    $nicDetails01 = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nicName3
    $privateIPAddress01 = $nicDetails01.IpConfigurations[0].PrivateIpAddress

    $nicDetails02 = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nicName4
    $privateIPAddress02 = $nicDetails02.IpConfigurations[0].PrivateIpAddress

    $privateIPAddress = @()
    $privateIPAddress += ($privateIPAddress01, $privateIPAddress02)

    Write-Host "The private IP address of the business tier VMs are: $privateIPAddress"

    #endRegion

    #region sql server and data creation function

    $createSQLServerParams = @{

        ResourceGroupName             = $ResourceGroupName
        SQLServerName                 = $SQLServerName
        SQLDatabaseName               = $SQLDatabaseName
        SubscriptionId                = $SubscriptionId
        KeyVaultName                  = $KeyVaultName
        RequestedServiceObjectiveName = $RequestedServiceObjectiveName
        AllowedIPs                    = $privateIPAddress
        TaggingData                   = $taggingData
    }

    New-SQLDatabase @createSQLServerParams

    #endRegion

    #region create network rule from web to business tier


    Write-Host "Creating N/W rule from app to business tier"
    $subnetAddressPrefix = ((Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets | Where-Object { $_.Name -eq $BackEndsubnetName }).AddressPrefix
    $loadbalancerFEIP = (Get-AzLoadBalancer -Name $ILBName -ResourceGroupName $ResourceGroupName).FrontendIpConfigurations[0].PrivateIpAddress

    $nsgCreateParams = @{

        RuleName                 = $NWRuleName
        RuleDescription          = $NWRuleDescription
        Protocol                 = $NWProtocol
        SourcePortRange          = $SourcePortRange
        DestinationPortRange     = $DestinationPortRange
        SourceAddressPrefix      = $subnetAddressPrefix
        DestinationAddressPrefix = $loadbalancerFEIP
        Access                   = 'Allow'
        Priority                 = '120'
        Direction                = 'Inbound'
        ResourceGroupName        = $ResourceGroupName
        NSGName                  = $NSGName
        Location                 = $Location
        TaggingData              = $TaggingData
    }


    New-NetworkSecurityGrp @nsgCreateParams

    Write-Host "Created N/W rule from app to business tier"

    #endRegion

    #region backup configuration
    Write-Host "Enabling backup configuration for all the VMs deployed with this architecture and create RSV if required"

    $vmNames = @()
    $vmNames += @($VMName1, $VMName2, $VMName3, $VMName4)

    $createBackupConfigParams = @{
        ResourceGroupName = $ResourceGroupName
        RSVName           = $RSVName
        Location          = $Location
        SubscriptionID    = $SubscriptionId
        VMNames           = $vmnames
        Tagging           = $taggingData
    }
    New-BackupConfiguration @createBackupConfigParams
    Write-Host "Backup configuration completed"

    #endRegion
}
catch {
    Write-Error "Error while deploying three tier architecture. Error Message: '$($_.Exception.Message)'"
}