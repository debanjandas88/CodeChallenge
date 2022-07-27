
#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '2.8.0'}
#requires -module @{ModuleName = 'Az.Compute'; ModuleVersion = '4.27.0'}
#requires -module @{ModuleName = 'Az.Network'; ModuleVersion = '4.17.0'}
#requires -module @{ModuleName = 'Az.OperationalInsights'; ModuleVersion = '3.1.0'}
#requires -module @{ModuleName = 'Az.Keyvault'; ModuleVersion = '4.5.0'}
#requires -module @{ModuleName = 'Az.Sql'; ModuleVersion = '3.9.0'}
#requires -version 5.1

<#
.SYNOPSIS
  Creates Resource group

.DESCRIPTION
 Creates Resource group

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER TaggingData
  Specifies the tagging data

#>
function New-ResourceGroup {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$TaggingData

  )
  try {
    Write-Host "Creating resource group of name: $resourceGroupName" 
    New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $taggingData
    Write-Host "Resource group has been created of name: $resourceGroupName"
  }
  catch {
    Write-Error "Error while creating resource group. Error Message: '$($_.Exception.Message)'"
  }
}



<#
.SYNOPSIS
  Creates Application gateway

.DESCRIPTION
 Creates  Creates Application gateway

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER AppgatewayName
  Specifies the application gateway name

#>
function New-AzureAppGateway {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionID,
    [Parameter(Mandatory = $true)]
    [string]$AppGatewayName,
    [Parameter(Mandatory = $true)]
    [string]$SkuName,
    [Parameter(Mandatory = $true)]
    [string]$Tier,
    [Parameter(Mandatory = $true)]
    [string]$Location,
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
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
   
  )
  try {
    ##Seting context to the subscription

    $null = Set-AzContext -SubscriptionId $SubscriptionID -Scope Process -ErrorAction Stop

    $checkVnet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

    if ($null -eq $checkVnet) {
      #region Create subnet configuration

      Write-Host "Creating the configuration of app gateway subnet" 
      $agSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $aGSubnetName -AddressPrefix $agAddressPrefix 
      Write-Host "App gateway subnet created of name $aGSubnetName" 

      Write-Host "Creating the configuration of app gateway backend subnet" 
      $backendSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $backEndsubnetName -AddressPrefix $backEndAddressPrefix
      Write-Host "App gateway backend subnet created of name $backEndsubnetName" 
       
      #endRegion

      #region Create Virtual Network

      Write-Host "Create the virtual network"

      New-AzVirtualNetwork  -ResourceGroupName $ResourceGroupName -Location $Location -Name $VnetName -AddressPrefix $VnetAddressPrefix -Subnet $agSubnetConfig, $backendSubnetConfig
      Write-Host "The virtual network of name $vnetName has been created successfully"  

    }
    else {
      Write-Host "The virtual network of name $vnetName already exists"
    }

    #region Create Public IP address

    $checkPIP = Get-AzPublicIpAddress -Name $PIPName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

    if ($null -eq $checkPIP) {
      Write-Host "Creating public IP address of name $pipName"    
      New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location -Name $PIPName -AllocationMethod Static -Sku Standard
      Write-Host "Created public IP address of name $pipName"   
    }
    else {
      Write-Host "The public IP address already exists of name $pIPName"  
    }

    #endRegion

    #region Create IP configuration and front end port

    Write-Host "Creating the IP configuration and fromt end port"

    $vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName
    $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $AGSubnetName
    $publicIP = Get-AzPublicIpAddress -Name $PIPName -ResourceGroupName $ResourceGroupName 

    $gwIPconfig = New-AzApplicationGatewayIPConfiguration -Name $AppGatewayIPName -Subnet $subnet 
    $frontEndIPconfig = New-AzApplicationGatewayFrontendIPConfig -Name $AGFrontendIPConfigName -PublicIPAddress $publicIP 
    $frontendport = New-AzApplicationGatewayFrontendPort -Name $AGFrontEndPortName -Port 80

    Write-Host "Created the IP configuration and fromt end port"

    #endRegion

    #region Create backend pool and configure backend pool settings

    Write-Host "Creating backend pool and configure backend pool settings"
    $backendPool = New-AzApplicationGatewayBackendAddressPool -Name $AGBackEndPoolName
    $poolSettings = New-AzApplicationGatewayBackendHttpSetting -Name $AGBackEndPoolSettingName -Port 80 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30
    Write-Host "Created backend pool and configure backend pool settings"

    #endRegion

    #region create listener and rule addition

    Write-Host "Creating listener and rule addition"

    $listener = New-AzApplicationGatewayHttpListener -Name $ListenerName -Protocol Http -FrontendIPConfiguration $frontEndIPconfig -FrontendPort $frontendport
    $frontendRule = New-AzApplicationGatewayRequestRoutingRule -Name $FrontEndRuleName -RuleType Basic -HttpListener $listener -BackendAddressPool $backendPool -BackendHttpSettings $poolSettings -Priority 120
    Write-Host "Created listener and rule addition"

    #endRegion

    #region Create Keyvault for certificate management
    $checkKV = Get-AzKeyVault -ResourceGroupName $ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
    if ($null -eq $checkKV) {
      Write-Host "The keyvault of name $KeyVaultName does not exists. Hence creating the same"
      $createKVParams = @{
        ResourceGroupName = $ResourceGroupName
        KeyVaultName      = $KeyVaultName
        Location          = $Location
        TaggingData       = $TaggingData
      }

      New-AzureKeyVault @createKVParams
    }
    else {
      Write-Host "The keyvault of name $KeyVaultName already exists"
    }
    #endRegion

    #region Create Application Gateway

    Write-Host "Creating the sku and the tier"
    $sku = New-AzApplicationGatewaySku  -Name $SkuName -Tier $Tier -Capacity 2
    Write-Host "Created the sku and the tier"

    Write-Host "Creating application gateway v2"
    New-AzApplicationGateway -Name $AppGatewayName `
      -ResourceGroupName $ResourceGroupName `
      -Location $Location `
      -BackendAddressPools $backendPool `
      -BackendHttpSettingsCollection $poolSettings `
      -FrontendIpConfigurations $frontEndIPconfig `
      -GatewayIpConfigurations $gwIPconfig `
      -FrontendPorts $frontendport `
      -HttpListeners $listener `
      -RequestRoutingRules $frontendRule `
      -Sku $sku
    Write-Host "Created application gateway v2"

    #EndRegion 

    #region enabling monitoring for App gateway
    $checkLAworkspace = Get-AzOperationalInsightsWorkspace -Name $LAWorkSpaceName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $checkLAworkspace) {
      #region create LA workspace
      Write-Host "Log analytics workspace does not exists of name $LAWorkSpaceName. Hence creating the same"

      $createLAParams = @{
        ResourceGroupName = $ResourceGroupName
        LAWorkSpaceName   = $LAWorkSpaceName
        Location          = $Location
        LASku             = $LASku
        TaggingData       = $TaggingData
      }
      New-LAWorkSpace @createLAParams 
      Write-Host "Log analytics workspace  of name $LAWorkSpaceName has been created"
      #endRegion
    }
    else {
      Write-Host "Log analytics workspace  of name $LAWorkSpaceName already exists" 
    }


    #region enable log analytics diagnostics settings
    Write-Host "Enabling monitoring for App gateway"
    $getAppGateway = Get-AzApplicationGateway -Name $AppGatewayName -ResourceGroupName $ResourceGroupName
    $getLAWorkSpace = Get-AzOperationalInsightsWorkspace -Name $LAWorkSpaceName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($getLAWorkSpace) {
      Set-AzDiagnosticSetting -ResourceId $getAppGateway.Id -WorkspaceId $getLAWorkSpace.ResourceId -Enabled $True `
        -Category ApplicationGatewayAccessLog, ApplicationGatewayPerformanceLog, ApplicationGatewayFirewallLog -Name "$($AppGatewayName)-$($LAWorkSpaceName)"
    }
    Write-Host "Enabled monitoring for App gateway"
    #endRegion


    #endRegion
       
  }
  catch {
    Write-Error "Error while creating Application gateway of name $AppGatewayName. Error Message: '$($_.Exception.Message)'"
  }
}
   
<#
.SYNOPSIS
  Creates Azure KEyvault

.DESCRIPTION
 Creates Azure KEyvault


.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER KeyVaultName
  Specifies the KeyVaultName

#>
function New-AzureKeyVault {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$KeyVaultName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
   
  )
  try {

    #region Create Keyvault

    Write-Host "Creating Keyvault of name: $KeyVaultName" 
    New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $Location
    Write-Host "KeyVault been created of name: $KeyVaultName"

    #EndRegion

    #region Add Keyvault Access Policy

    Write-Host "Adding access policy to the current user to the Keyvault"
    $currentAzureContext = Get-AzContext
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azureRmProfile)
    $userInformation = ($profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)).HomeAccountId
    $objectId = $userInformation.Split('.')[0]
        
        
    Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName -ObjectId $objectId `
      -PermissionsToKeys get, list, update, create -PermissionsToSecrets get, list, set -PermissionsToCertificates get, create, import, list, update -BypassObjectIdValidation -ErrorAction Stop | Out-Null

    Write-Host "Added access policy to the current user to the Keyvault"         
    #endRegion
  }
  catch {
    Write-Error "Error while creating Keyvault. Error Message: '$($_.Exception.Message)'"
  }
}


<#
.SYNOPSIS
  Creates log analytics workspace

.DESCRIPTION
 Creates log analytics workspace

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER AVSetName
  Specifies the AVSetName

#>
function New-LAWorkSpace {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$LAWorkSpaceName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [string]$LASku,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
   
  )
  try {

                    
    #region Create the workspace
    Write-Host "Creating Log analytics workspace of name: $LAWorkSpaceName"
    New-AzOperationalInsightsWorkspace -Location $Location -Name $LAWorkSpaceName -Sku $LASku -ResourceGroupName $ResourceGroupName
    Write-Host "Created Log analytics workspace of name: $LAWorkSpaceName"
    #endRegion
  }
  catch {
    Write-Error "Error while creating log analytics workspace. Error Message: '$($_.Exception.Message)'"
  }
}

<#
.SYNOPSIS
  Creates a virtual machine resource

.DESCRIPTION
  Creates a virtual machine resource

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER VMName
  Specifies the VMName

.PARAMETER VMSize
  Specifies the VMSize

.PARAMETER NICId
 Specifies the NICId

.PARAMETER Credential
  Specifies the admin Credential

.PARAMETER VMSku
  Specifies the VMSku

.PARAMETER SubscriptionId
  Specifies the SubscriptionId


#>
function New-VMCreation {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [Parameter(Mandatory = $true)]
    [string]$VMSize,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [String]$NICId,
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Credential,
    [Parameter(Mandatory = $true)]
    [string]$VMSku,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
   
  )
  try {

    #Setting Subscription Context
    $null = Set-AzContext -SubscriptionId $subscriptionId -Scope Process -ErrorAction Stop

                       
    #region Create VM configuration

    Write-Host "Creating VM configuration"
    Write-Host "Configuring VM Size"
    $vmConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize 
        

    Write-Host "Configuring VM OS"
    Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $Credential

    Set-AzVMSourceImage -VM $vmConfig -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus $VMSku -Version latest

    Write-Host "Adding N/W interface"
    Add-AzVMNetworkInterface -VM $vmConfig -Id $NICId
    Write-Host "Configuring boot diagnostics"
    Set-AzVMBootDiagnostic -VM $vmConfig -Disable

    #endRegion  
         
    #region Create VM
    Write-Host "Creating VM of Name $VMName"
    New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig -Tag $TaggingData
    Write-Host "Created VM of Name $VMName"

    #endRegion

    #region Install IIS

    Set-AzVMExtension `
      -ResourceGroupName $resourceGroupName `
      -ExtensionName IIS `
      -VMName $vmName `
      -Publisher Microsoft.Compute `
      -ExtensionType CustomScriptExtension `
      -TypeHandlerVersion 1.4 `
      -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' `
      -Location $location

    #endRegion  


  }
  catch {
    Write-Error "Error while creating VM of name $vmName. Error Message: '$($_.Exception.Message)'"
  }
}


 

<#
.SYNOPSIS
  Creates load balancer

.DESCRIPTION
 Creates load balancer

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER Location
 Specifies the location

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER ILBName
  Specifies the Load balancer name

#>
function New-LoadBalancerCreation {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ILBName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [string]$Sku,
    [Parameter(Mandatory = $true)]
    [string]$NatGatewayIPName,
    [Parameter(Mandatory = $true)]
    [string]$NATGatewayName,
    [Parameter(Mandatory = $true)]
    [String]$IdleTimeOutMin,
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
    [Parameter(Mandatory = $true)]
    [string]$LBbastionhostname,
    [Parameter(Mandatory = $true)]
    [string]$LBbastionPIP,
    [Parameter(Mandatory = $true)]
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
    [Parameter(Mandatory = $true)]
    [string]$LBAccess,
    [Parameter(Mandatory = $true)]
    [string]$LBPriority,
    [Parameter(Mandatory = $true)]
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
    [string]$NSGName,
    [Parameter(Mandatory = $true)]
    [string]$LBBackEndPort,
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
   
  )
  try {

    #Setting Subscription Context
    $null = Set-AzContext -SubscriptionId $subscriptionId -Scope Process -ErrorAction Stop

    #region Create NAT gateway

    $checkNatGW = Get-AzNatGateway -ResourceGroupName $ResourceGroupName -Name $NATGatewayName -ErrorAction SilentlyContinue
    if ($null -eq $checkNatGW) {
      Write-Host "Creating public IP address for NAT gateway"
       
      $publicIP = New-AzPublicIpAddress -Name $NatGatewayIPName -ResourceGroupName $ResourceGroupName -Location $Location -Sku $Sku -AllocationMethod 'Static'

      Write-Host "Created public IP address for NAT gateway"
        
      Write-Host "Creating NAT gateway"

   
      $natGateway = New-AzNatGateway -ResourceGroupName $ResourceGroupName -Name $NATGatewayName -IdleTimeoutInMinutes $IdleTimeOutMin `
        -Sku $Sku -Location $Location -PublicIpAddress $publicIP -Tag $TaggingData

      Write-Host "Created NAT gateway"
    }
    else {
      Write-Host "Nat Gateway already exists of name $NATGatewayName"
    }
    #endRegion 

    #region subnet configiration and virtual network

    $checkLBVnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $lbvnetName -ErrorAction SilentlyContinue
    if ($null -eq $checkLBVnet ) {

      Write-Host "Configuring backend subnet"
   
      $subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $LBBackendSubnet -AddressPrefix $LBBackendSubnetAddressPrefix -NatGateway $natGateway

      Write-Host "Configured backend subnet $LBBackendSubnet"
        
      Write-Host "Configuring bastion subnet"
      
      $bastsubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $LBBastionSubName -AddressPrefix $LBBastionSubAddressPrefix

      Write-Host "Configured bastion subnet $LBBastionSubName"
     
      Write-Host "Creating Vnet $LBVnetName"

      $vnetParams = @{
        Name              = $LBVnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $LBVnetAddressPrefix
        Subnet            = $subnetConfig, $bastsubnetConfig
      }
      $createvnet = New-AzVirtualNetwork @vnetParams
      Write-Host "Created Vnet $createvnet"

           

    }
    else {
      Write-Host "The vnet $LBVnetName already exists checking the subnet configuration"
      $checkSubnetConfig = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $checkLBVnet -Name $LBBackendSubnet -ErrorAction SilentlyContinue
      $checkBastionSNCFG = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $checkLBVnet -Name $LBBastionSubName -ErrorAction SilentlyContinue
      if ($null -eq $checkSubnetConfig -and $null -eq $checkBastionSNCFG) {
        Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $checkLBVnet -AddressPrefix $LBBackendSubnetAddressPrefix -Name $LBBackendSubnet 
        Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $checkLBVnet -AddressPrefix $LBBastionSubAddressPrefix -Name $LBBastionSubName
        $checkLBVnet | Set-AzVirtualNetwork
        Write-Host "Subnet configurations added to the vnet name $LBVnetName" 
            
      }
      else {
        Write-Host "Subnet configurations already exists to the vnet name $LBVnetName" 
      }
    }

    #region Create bastion host
        
    $checkLBVnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $lbvnetName -ErrorAction SilentlyContinue
        
    $checkBastionHost = Get-AzBastion -ResourceGroupName $ResourceGroupName -Name $LBbastionhostname -ErrorAction SilentlyContinue
    if ($null -eq $checkBastionHost) {
      Write-host "Creating public IP for bastion host $LBbastionhostname"
    
      $bastionPublicip = New-AzPublicIpAddress -Name $LBbastionPIP -ResourceGroupName $ResourceGroupName -Location $Location `
        -Sku $Sku -AllocationMethod Static


      Write-host "Creating Bastion host $LBbastionhostname"
     
      New-AzBastion -ResourceGroupName $ResourceGroupName -Name $LBbastionhostname -PublicIpAddress $bastionPublicip -VirtualNetwork $checkLBVnet -AsJob

      Write-host "Created Bastion host $LBbastionhostname"

    }
    else {
      Write-host "Bastion host $LBbastionhostname already exists"
    }

    #region create network security group with n/w rule

        

    $nsgCreateParams = @{

      RuleName                 = $LBRuleName
      RuleDescription          = $LBRuleDescription
      Protocol                 = $LBProtocol
      SourcePortRange          = $LBSourcePortRange
      DestinationPortRange     = $LBDestinationPortRange
      SourceAddressPrefix      = $LBSourceAddressPrefix
      DestinationAddressPrefix = $LBDestinationAddressPrefix
      Access                   = $LBAccess
      Priority                 = $LBPriority
      Direction                = $LBDirection
      ResourceGroupName        = $ResourceGroupName
      NSGName                  = $NSGName
      Location                 = $Location
      TaggingData              = $TaggingData
    }
   
    
    New-NetworkSecurityGrp @nsgCreateParams

    #endRegion 

    #region Create Load Balancer

        
    Write-Host "Get the virtual network config"
    $vnetConfig = Get-AzVirtualNetwork -Name $LBVnetName -ResourceGroupName $ResourceGroupName

    Write-Host "Configure front end IP address"
        
    $lbFrontEndIPParams = @{
      Name             = $frontEndName
      PrivateIpAddress = $privateIPAddress
      SubnetId         = $vnetConfig.subnets[2].Id
    }
    $lbFrontIPAddress = New-AzLoadBalancerFrontendIpConfig @lbFrontEndIPParams

    Write-Host "Configure back end IP address"
    $lbBackEndPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $lbBackEndPoolName

    Write-Host "Configure health probe"
    $probeParams = @{
      Name              = $LBHeathProbeName
      Protocol          = $LBHealthProbeProtocol
      Port              = $LBHealthProbePort
      IntervalInSeconds = '180'
      ProbeCount        = '2'
    }
    $healthprobeConfig = New-AzLoadBalancerProbeConfig @probeParams

    Write-Host "Create load balancer rule"
    $lbrule = @{
      Name                    = $LBRuleName2
      Protocol                = $LBProtocol2
      FrontendPort            = $LBFrontEndPort
      BackendPort             = $LBBackEndPort
      IdleTimeoutInMinutes    = $IdleTimeOutMin
      FrontendIpConfiguration = $lbFrontIPAddress
      BackendAddressPool      = $lbBackEndPool
    }
    $rule = New-AzLoadBalancerRuleConfig @lbrule -EnableTcpReset

    Write-Host "Create Load balancer of name $ILBName"
    $loadbalancer = @{
      ResourceGroupName       = $ResourceGroupName
      Name                    = $ILBName
      Location                = $Location
      Sku                     = $Sku
      FrontendIpConfiguration = $lbFrontIPAddress
      BackendAddressPool      = $lbBackEndPool
      LoadBalancingRule       = $rule
      Probe                   = $healthprobeConfig
    }
    New-AzLoadBalancer @loadbalancer
    Write-Host "Created Load balancer of name $ILBName"

    #endRegion
  }
  catch {
    Write-Error "Error while creating load balancer of name $ilbName. Error Message: '$($_.Exception.Message)'"
  }
}

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

.PARAMETER AVSetName
  Specifies the AVSetName

#>
function New-NetworkSecurityGrp {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$NSGName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [string]$RuleName,
    [Parameter(Mandatory = $true)]
    [string]$RuleDescription,
    [Parameter(Mandatory = $true)]
    [string]$Protocol,
    [Parameter(Mandatory = $true)]
    [string]$SourcePortRange,
    [Parameter(Mandatory = $true)]
    [string]$DestinationPortRange,
    [Parameter(Mandatory = $true)]
    [string]$SourceAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$DestinationAddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]$Access,
    [Parameter(Mandatory = $true)]
    [string]$Priority,
    [Parameter(Mandatory = $true)]
    [string]$Direction,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
   
  )
  try {
        
    #region create NSG
    $checkNSG = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName -ErrorAction SilentlyContinue
    if ($null -eq $checkNSG) {
      Write-Host "Creating NSG of $NSGName is not present"
      New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName -Tag $TaggingData -Location $Location
      Write-Host "Created NSG of $NSGName"
    }
    else {
      Write-Host "NSG of $NSGName already exists"
    }     
    #endRegion

    #region Add network rule
    Write-Host "Checking whether rule name $RuleName exists or not"
    $getNSG = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName
    $checkRule = Get-AzNetworkSecurityRuleConfig -Name $RuleName -NetworkSecurityGroup $getNSG -ErrorAction SilentlyContinue
    if ($null -eq $checkRule) {
      Write-Host "Creating rule name $RuleName as it is not present" 
      $nsgrule = @{
        Name                     = $RuleName
        Description              = $RuleDescription
        Protocol                 = $Protocol
        SourcePortRange          = $SourcePortRange
        DestinationPortRange     = $DestinationPortRange
        SourceAddressPrefix      = $SourceAddressPrefix
        DestinationAddressPrefix = $DestinationAddressPrefix
        Access                   = $Access
        Priority                 = $Priority
        Direction                = $Direction
             
      }
            
      New-AzNetworkSecurityRuleConfig @nsgrule
      $getNSG | Set-AzNetworkSecurityGroup 
      Write-Host "Created rule name $RuleName and added to the NSG $nsgName" 
    }
    else {
      Write-Host "Rule name $RuleName already exists" 
    }
    #endRegion
  }
  catch {
    Write-Error "Error while creating Network Security Group. Error Message: '$($_.Exception.Message)'"
  }
}


<#
.SYNOPSIS
  Creates Azure SQL database resource

.DESCRIPTION
 Creates Azure SQL database resource

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER SQLServerName
 Specifies the SQLServerName

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER SQLDatabaseName
  Specifies the SQLDatabaseName

.PARAMETER SubscriptionId
 Specifies the SubscriptionId

.PARAMETER KeyVaultName
  Specifies the KeyVaultName

.PARAMETER RequestedServiceObjectiveName
  Specifies the service tier

.PARAMETER AllowedIPs
  Specifies the AllowedIPs

#>
function New-SQLDatabase {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$SQLServerName,
    [Parameter(Mandatory = $true)]
    [string]$SQLDatabaseName,
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$KeyVaultName,
    [Parameter(Mandatory = $true)]
    [string]$RequestedServiceObjectiveName,
    [Parameter(Mandatory = $true)]
    [array]$AllowedIPs,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
   
  )
  try {
    
    #SETTING SUBSCRIPTION CONTEXT
    Write-Host "Setting context to subscription"
    $null = Set-AzContext -Subscription $SubscriptionId -Scope Process -ErrorAction Stop
    Write-Host "subscription context set"

    #region fetching the credential from the keyvault

    Write-Host "fetching credential from the keyvault"
    $adminUser = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'adminusername' -AsPlainText
    $adminPAss = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name 'adminpassword' -AsPlainText
    $secureString = ConvertTo-SecureString -String $adminPAss -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $adminUser, $secureString

    #endRegion

    #region create SQL server and database

    $checkSQLserver = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -ErrorAction SilentlyContinue

    if ($null -eq $checkSQLserver) {
      Write-Host "Creating sql server"
      $sqlserver = New-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $SQLServerName -Location $location -SqlAdministratorCredentials $credential -Tags $taggingData
      Write-Host "Created sql server of name $SQLServerName"
      $sqlserver
        
      Write-Host "Creating SQL database of name $SQLDatabaseName"
      $sqlDatabase = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName -ServerName $SQLServerName -DatabaseName $SQLDatabaseName -RequestedServiceObjectiveName $RequestedServiceObjectiveName -Tags $taggingData
      Write-Host "Created SQL database of name $SQLDatabaseName"
      $sqlDatabase
    }
    else {
      Write-Host "SQL server name $SQLServerName and its database $SQLDatabaseName already exists"
    }
    #endRegion


    #region whitelisting IP addresses for sql database access

    Write-Host "whitelisting IP addresses for access"
        
    $j = 1

    foreach ($allowedIP in $AllowedIPs) {
      $fireWallRuleName = "Firewallrule-$j"
      $serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $SQLServerName -FirewallRuleName $fireWallRuleName -StartIpAddress $allowedIP -EndIpAddress $allowedIP
      Write-Host "Enabled IP whitelisting from IP: $allowedIP"
      $serverFirewallRule
      $j = $j + 1
    }
    #endRegion
       
  }
  catch {
    Write-Error "Error while creating azure sql database. Error Message: '$($_.Exception.Message)'"
  }
}

<#
.SYNOPSIS
  Creates Resovery Services Vault and configures backup for deployed VMs 
  with this architecture

.DESCRIPTION
 Creates Resovery Services Vault and configures backup for deployed VMs 
  with this architecture

.PARAMETER ResourceGroupName
  Specifies the resource group name

.PARAMETER RSVName
 Specifies the recovery service vault name

.PARAMETER TaggingData
  Specifies the tagging data

.PARAMETER Location
  Specifies the Location

.PARAMETER SubscriptionId
 Specifies the SubscriptionId

.PARAMETER VMNames
  Specifies the VM names



#>
function New-BackupConfiguration {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$RSVName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [array]$VMNames,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$TaggingData
 
  )
  try {
  
    #SETTING SUBSCRIPTION CONTEXT
    Write-Host "Setting context to subscription"
    $null = Set-AzContext -Subscription $SubscriptionId -Scope Process -ErrorAction Stop
    Write-Host "subscription context set"

    #region Create receovery service vaults for backup configuration of VMs

    Write-Host "Check whether the subscription is registered to provider 'Microsoft.RecoveryServices' "
    
    $providerCheckRSV = Get-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices

    ####Registering the subscription to Microsoft.RecoveryServices provider if not registered
    if ([string]::IsNullOrEmpty($providerCheckRSV)) {
      Register-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices
      Write-Host "The subscription is registered with the provider Microsoft.RecoveryServices"
    }

    $checkRSV = Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $RSVName -ErrorAction SilentlyContinue
   
    if ($null -eq $checkRSV ) {
        
      Write-Host "Creating the recovery service vault of name $RSVName as it does not exists"
      New-AzRecoveryServicesVault -Name $RSVName -ResourceGroupName $ResourceGroupName -Location $Location -Tag $taggingData
      Write-Host "Created the recovery service vault of name $RSVName"    
    }
    else {
      Write-Host "Recovery service vault of name $RSVName already exists"
    }

    #region backup configuration with default backup policy

    Write-Host "Backup configuration of VM with default backup policy"

    Write-Host "Setting vault context"
    $vaultInfo = Get-AzRecoveryServicesVault -ResourceGroupName  $ResourceGroupName -Name $RSVName 
    $vaultContext = Set-AzRecoveryServicesAsrVaultContext -Vault $vaultInfo
    Write-Host "Vault context set"
    $vaultContext
    $policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy" -VaultId $vaultInfo.ID
    Write-Host "Default backup policy"
    $policy

    Write-Host "Enabling backup configuration for all the VMs deployed with this architecture"
  
    foreach ($vm in $vmNames) {
      $vm = $vm.Trim()
      Write-Host "Enabling backup configuration for $vm"
      Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $ResourceGroupName -Name $vm -Policy $policy -VaultId $vaultInfo.ID -ErrorAction SilentlyContinue
      Write-Host "Enabled backup configuration for $vm"
    }

    #endRegion

    #endRegion
     
  }
  catch {
    Write-Error "Error while backup configuration. Error Message: '$($_.Exception.Message)'"
  }
}