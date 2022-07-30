<#
.SYNOPSIS 
This Script is used to Deploy 3-Tier architecture in a modularized fasion

.DESCRIPTION
This Script is used to Deploy 3-Tier architecture in a modularized fasion

.EXAMPLE

.\ScriptToFetchMetadataOfAzureResources.ps1 -ResourceName 'myVM'

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER SubscriptionName
 Specifies the Subscription name

.PARAMETER ApplicationID
 Specifies the ApplicationID for tagging purpose

.PARAMETER ApplicationName
 Specifies the Application name for tagging purpose

.PARAMETER AppgatewayName
  Specifies the application gateway name

.PARAMETER AppGatewaySkuName
  Specifies the application gateway SKU 

.PARAMETER AppGatewayTier
  Specifies the application gateway tier 

.PARAMETER AGSubnetName
  Specifies the application gateway subnet name

.PARAMETER AGAddressPrefix
  Specifies the application gateway subnet address prefix

.PARAMETER BackEndsubnetName
  Specifies the application gateway backend subnet name

.PARAMETER BackEndAddressPrefix
  Specifies the application gateway backend subnet address prefix

.PARAMETER VnetName
  Specifies the application gateway virtual network name

.PARAMETER VnetAddressPrefix
  Specifies the application gateway virtual network address prefix

.PARAMETER PIPName
  Specifies the application gateway public ip name

.PARAMETER Keyvault2
  Specifies the keyvault for storing windows and sql server admin credentials

.PARAMETER AppGatewayIPName
  Specifies the application gateway gateway IP name

.PARAMETER AGFrontendIPConfigName
  Specifies the application gateway frontend IP configuration name

.PARAMETER AGFrontEndPortName
  Specifies the application gateway frontend port name

.PARAMETER AGFrontendIPConfigName
  Specifies the application gateway frontend IP configuration name

.PARAMETER AGFrontEndPortName
  Specifies the application gateway frontend port name

.PARAMETER AGBackEndPoolName
  Specifies the application gateway backend pool name

.PARAMETER ListenerName
  Specifies the application gateway listener name

.PARAMETER KeyVaultName
  Specifies the keyvault name for certificate mgmt if any

 .PARAMETER FrontEndRuleName
 
.PARAMETER LAWorkSpaceName
  Specifies the log analytics workspace name for monitoring

.PARAMETER LASku
  Specifies the log analytics workspace sku

.PARAMETER DNSName
  Specifies the domain name server used for app gateway health probe

.PARAMETER HealthProbeName
  Specifies the health probe name of app gateway

.PARAMETER AGBackEndPoolSettingName
  Specifies the app gateway backend pool settings name

.PARAMETER FrontEndRuleName
  Specifies the app gateway front end rule name

.PARAMETER VMName1, VMName2, VMName3, VMName4
  Specifies the VM names to be deployed 

.PARAMETER Nicname1, Nicname2, Nicname3, Nicname14
  Specifies the netwrok interface card names to be used for the above VM deployments

.PARAMETER Location
 Specifies the location of the resources
 
.PARAMETER VMSize
  Specifies the VMSize

.PARAMETER VMSku
  Specifies the VMSku

.PARAMETER SQLServerName
 Specifies the SQLServerName

.PARAMETER SQLDatabaseName
  Specifies the SQLDatabaseName

.PARAMETER RequestedServiceObjectiveName
  Specifies the service tier of Azure SQL database

.PARAMETER ILBName
  Specifies the Load balancer name

.PARAMETER ILBName
  Specifies the load balancer SKU 

.PARAMETER NatGatewayIPName
  Specifies the NAT gateway IP name

.PARAMETER NATGatewayName
  Specifies the NAT gateway  name

.PARAMETER IdleTimeOutMin
  Specifies the idle timout of nat gateway and load balancer 

.PARAMETER LBBackendSubnet
  Specifies the ILB backend subnet name

.PARAMETER LBBackendSubnetAddressPrefix
  Specifies the ILB backend subnet address prefix

.PARAMETER LBBastionSubName
  Specifies the ILB bastion subnet name

.PARAMETER LBbastionhostname
  Specifies the ILB bastion host name

.PARAMETER LBBastionSubAddressPrefix
  Specifies the ILB bastion subnet address prefix

.PARAMETER LBbastionPIP
  Specifies the ILB bastion public IP address

.PARAMETER FrontEndName
  Specifies the ILB front end name

.PARAMETER PrivateIPAddress
  Specifies the ILB front end private IP address

.PARAMETER LBBackEndPoolName
  Specifies the ILB backend pool name

.PARAMETER LBHeathProbeName
  Specifies the ILB health probe name

 .PARAMETER LBHealthProbeProtocol
  Specifies the ILB health probe protocol

.PARAMETER LBHealthProbePort
  Specifies the ILB health probe port

.PARAMETER LBRuleName
  Specifies the load balancer rule name

.PARAMETER LBProtocol
  Specifies the load balancer rule's protocol

.PARAMETER LBFrontEndPort
  Specifies the load balancer front end port

.PARAMETER LBBackEndPort
  Specifies the load balancer back end port

.PARAMETER NSGName
  Specifies the NSG name

.PARAMETER RSVName
 Specifies the recovery service vault name


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
    [string]$KeyVaultName2,
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
    [Parameter(Mandatory = $true)]
    [string]$LBSku,
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
    [Parameter(Mandatory = $false)]
    [string]$LBBastionSubName,
    [Parameter(Mandatory = $false)]
    [string]$LBBastionSubAddressPrefix,
    [Parameter(Mandatory = $false)]
    [string]$LBbastionhostname,
    [Parameter(Mandatory = $false)]
    [string]$LBbastionPIP,
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
    [string]$LBRuleName,
    [Parameter(Mandatory = $true)]
    [string]$LBProtocol,
    [Parameter(Mandatory = $true)]
    [string]$LBFrontEndPort,
    [Parameter(Mandatory = $true)]
    [string]$LBBackEndPort,
    [Parameter(Mandatory = $false)]
    [string]$NSGName,   
    [Parameter(Mandatory = $true)]
    [string]$RSVName,
    [Parameter(Mandatory = $true)]
    [string]$DNSName,
    [Parameter(Mandatory = $false)]
    [string]$HealthProbeName
)

try {

    #region setting context to subscription

    $SubscriptionId = (Get-AzSubscription -SubscriptionName $SubscriptionName).Id
    Write-Host "Setting context to subscription"
    $null = Set-AzContext -Subscription $SubscriptionId -Scope Process -ErrorAction Stop
    Write-Host "subscription context set"

    #endRegion

    ## importing the required modules
    $commonModulePath = Join-Path $PSScriptRoot -ChildPath 'Modules\CommonModules'

    Import-Module -name $commonModulePath -Verbose
    Write-Host "Imported required modules"

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
            HealthProbeName          = $HealthProbeName
            DNSName                  = $DNSName
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

    $adminUser = Get-AzKeyVaultSecret -VaultName $KeyVaultName2 -Name 'adminusername' -AsPlainText
    $adminPAss = Get-AzKeyVaultSecret -VaultName $KeyVaultName2 -Name 'adminpassword' -AsPlainText
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

    #region restarting the application gateway
    Write-Host "Stopping App gateway"
    Stop-AzApplicationGateway -ApplicationGateway $appgw
 
    # Start the Azure Application Gateway
    Write-Host "Starting App gateway"
    Start-AzApplicationGateway -ApplicationGateway $appgw
    Write-Host "App gateway restarted"

    #endRegion

    #region Create Internal load balancer for the business tier

    Write-Host "Create Internal load balancer for the business tier"
    Write-Host "Checking the exietence of the load balancer"
    $checkILB = Get-AzLoadBalancer -Name $ILBName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $checkILB) {
        Write-Host "The load balancer of name $ILBName does not exist. Calling the function for creating the same."

        ##get the subnet  address prefix  of app gw backend

        $vnet   = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnetName
        $apgwbesubnet = $vnet.Subnets[1].AddressPrefix

        $LBRuleName = $AGBackEndPoolName + '-' + $ILBName + '-Connect'

        Write-Host "Front end subnet of app gw : $apgwfesubnet"

        $createILBParams = @{
            ResourceGroupName            = $ResourceGroupName
            ILBName                      = $ILBName
            Location                     = $Location
            Sku                          = $LBSku
            NatGatewayIPName             = $NatGatewayIPName
            NaTGatewayName               = $NaTGatewayName
            IdleTimeOutMin               = $IdleTimeOutMin
            LBBackendSubnet              = $LBBackendSubnet
            LBBackendSubnetAddressPrefix = $LBBackendSubnetAddressPrefix
            LBBastionSubName             = $LBBastionSubName
            LBBastionSubAddressPrefix    = $LBBastionSubAddressPrefix
            LBVnetName                   = $VnetName
            LBVnetAddressPrefix          = $VnetAddressPrefix
            LBbastionhostname            = $LBbastionhostname
            LBbastionPIP                 = $LBbastionPIP
            LBRuleName                   = $LBRuleName
            LBRuleDescription            = "Connect web tier to business tier"
            LBProtocol                   = "tcp"
            LBSourcePortRange            = "443"
            LBDestinationPortRange       = "443"
            LBSourceAddressPrefix        = $apgwbesubnet
            LBDestinationAddressPrefix   = $PrivateIPAddress
            LBAccess                     = "Allow"
            LBPriority                   = "125"
            LBDirection                  = "Inbound"
            FrontEndName                 = $FrontEndName
            PrivateIPAddress             = $PrivateIPAddress
            LBBackEndPoolName            = $LBBackEndPoolName
            LBHeathProbeName             = $LBHeathProbeName
            LBHealthProbeProtocol        = $LBHealthProbeProtocol
            LBHealthProbePort            = $LBHealthProbePort
            LBRuleName2                  = $LBRuleName
            LBProtocol2                  = $LBProtocol
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

    $adminUser2 = Get-AzKeyVaultSecret -VaultName $KeyVaultName2 -Name 'adminusername' -AsPlainText
    $adminPAss2 = Get-AzKeyVaultSecret -VaultName $KeyVaultName2 -Name 'adminpassword' -AsPlainText
    $secureString2 = ConvertTo-SecureString -String $adminPAss2 -AsPlainText -Force
    $Credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $adminUser2, $secureString2

    #endRegion

    #region create backend VMs of ILB
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnetName
    for ($i = 1; $i -le 2; $i++) {

        Write-Host "Creating NIC $($nicNameLB[$i-1]) for VM name  $($VMNameLB[$i-1])"
        $nic = New-AzNetworkInterface -Name $nicNameLB[$i - 1] -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $vnet.Subnets[2] -NetworkSecurityGroup  $fetchNSG -LoadBalancerBackendAddressPool $getILBbePool 
        $checkVMExitenceLB = Get-AzVM -Name $VMNameLB[$i - 1] -ErrorAction SilentlyContinue
        if ($null -eq $checkVMExitenceLB) {
            Write-Host "Calling function to create VM name  $($VMNameLB[$i-1])"
            $createVMParams = @{
                ResourceGroupName = $ResourceGroupName
                SubscriptionId    = $SubscriptionId
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

    $privateIPAddresses = @()
    $privateIPAddresses += ($privateIPAddress01, $privateIPAddress02)

    Write-Host "The private IP address of the business tier VMs are: $privateIPAddress"

    #endRegion

    #region sql server and data creation function

    $createSQLServerParams = @{

        ResourceGroupName             = $ResourceGroupName
        SQLServerName                 = $SQLServerName
        SQLDatabaseName               = $SQLDatabaseName
        SubscriptionId                = $SubscriptionId
        KeyVaultName                  = $KeyVaultName2
        RequestedServiceObjectiveName = $RequestedServiceObjectiveName
        AllowedIPs                    = $privateIPAddresses
        TaggingData                   = $taggingData
    }

    New-SQLDatabase @createSQLServerParams

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
