﻿<###
# Overview:
    This script is used to get the Virtual Network of Load Balancer where DDOS is disabled in a Subscription.

# Control ID:
    Azure_LoadBalancer_NetSec_Enable_WAF_And_DDoS_Protection_Trial

# Display Name:
    Get the Data of Virtual Network where DDOS is disabled.

# Prerequisites:    
    Owner or higher priviliged role on the Load Balancer(s) is required.

# Steps performed by the script:
    To Retrieve the list of Virtual Network(s):
        1. Validating and installing the modules required to run the script and validating the user.
        2. Get the list of Load Balancer(s) in a Subscription that have Virtual Network where DDoS Protection Plan is not configured.
        3. Back up details of Load Balancer(s) that are to be remediated.
        4. Configure the DDoS Protection Plan on the Virtual Network of Load Balancer(s) in the Subscription.

# Instructions to execute the script:
    To remediate:
        1. Download the script.
        2. Load the script in a PowerShell session. Refer https://aka.ms/AzTS-docs/RemediationscriptExcSteps to know more about loading the script.
        3. Execute the script to get the list of Virtual Network of Load Balancer(s) in the Subscription. Refer `Examples`, below.

# Examples:
    To remediate:
        1. To review the list of Virtual Network of Load Balancer(s) in a Subscription:
    
           Retrieve-LoadBalancerVirtualNetworkDDoSNotConfigured -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -DryRun

        To know more about the options supported by the remediation command, execute:
        
        Get-Help Retrieve-LoadBalancerVirtualNetworkDDoSNotConfigured -Detailed
###>


function Setup-Prerequisites
{
    <#
        .SYNOPSIS
        Checks if the prerequisites are met, else, sets them up.

        .DESCRIPTION
        Checks if the prerequisites are met, else, sets them up.
        Includes installing any required Azure modules.

        .INPUTS
        None. You cannot pipe objects to Setup-Prerequisites.

        .OUTPUTS
        None. Setup-Prerequisites does not return anything that can be piped and used as an input to another command.

        .EXAMPLE
        PS> Setup-Prerequisites

        .LINK
        None
    #>

    # List of required modules
    $requiredModules = @("Az.Accounts", "Az.Network")

    Write-Host "Required modules: $($requiredModules -join ', ')"
    Write-Host $([Constants]::SingleDashLine)    
    Write-Host "Checking if the required modules are present..." -ForegroundColor $([Constants]::MessageType.Info)
    Write-Host $([Constants]::SingleDashLine)

    $availableModules = $(Get-Module -ListAvailable $requiredModules -ErrorAction Stop)

    # Check if the required modules are installed.
    $requiredModules | ForEach-Object {
        if ($availableModules.Name -notcontains $_)
        {
            Write-Host "$($_) module is not present." -ForegroundColor $([Constants]::MessageType.Warning)
            Write-Host "Installing [$($_)] module..." -ForegroundColor $([Constants]::MessageType.Info)
            Install-Module -Name $_ -Scope CurrentUser -Repository 'PSGallery' -ErrorAction Stop
            Write-Host "[$($_)] module installed." -ForegroundColor $([Constants]::MessageType.Update)
        }
        else
        {
            Write-Host "[$($_)] module is present." -ForegroundColor $([Constants]::MessageType.Update)
        }
    }
    Write-Host "$($_) module is not present." -ForegroundColor $([Constants]::MessageType.Warning)
}


function Retrieve-LoadBalancerVirtualNetworkDDoSNotConfigured
{
    <#
        .SYNOPSIS
        Remediates 'Azure_LoadBalancer_NetSec_Enable_WAF_And_DDoS_Protection_Trial' Control.

        .DESCRIPTION
        Remediates 'Azure_LoadBalancer_NetSec_Enable_WAF_And_DDoS_Protection_Trial' Control.
        Get the list of Virtual Network of Load Balancer(s) in the Subscription. 
        
        .PARAMETER SubscriptionId
        Specifies the ID of the Subscription to be remediated.
        
        .Parameter PerformPreReqCheck
        Specifies validation of prerequisites for the command.
        
        .PARAMETER DryRun
        Specifies a dry run of the actual remediation.
        
        .INPUTS
        None. You cannot pipe objects to Retrieve-LoadBalancerVirtualNetworkDDoSNotConfigured.

        .OUTPUTS
        None. Retrieve-LoadBalancerVirtualNetworkDDoSNotConfigured does return the list of Virtual Network that can be piped and used as an input to another script where DDoS would be configured for these Virtual Network(s).

        .EXAMPLE
        PS> Retrieve-LoadBalancerVirtualNetworkDDoSNotConfigured -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck -DryRun

        .EXAMPLE
        PS> Retrieve-LoadBalancerVirtualNetworkDDoSNotConfigured -SubscriptionId 00000000-xxxx-0000-xxxx-000000000000 -PerformPreReqCheck

        .LINK
        None
    #>

    param (
        [String]
        [Parameter(ParameterSetName = "DryRun", Mandatory = $true, HelpMessage="Specifies the ID of the Subscription to be remediated")]
        [Parameter(ParameterSetName = "WetRun", Mandatory = $true, HelpMessage="Specifies the ID of the Subscription to be remediated")]
        $SubscriptionId,

        [Switch]
        [Parameter(ParameterSetName = "DryRun", HelpMessage="Specifies validation of prerequisites for the command")]
        [Parameter(ParameterSetName = "WetRun", HelpMessage="Specifies validation of prerequisites for the command")]
        $PerformPreReqCheck,

        [Switch]
        [Parameter(ParameterSetName = "DryRun", Mandatory = $true, HelpMessage="Specifies a dry run of the actual remediation")]
        $DryRun
    )

    Write-Host $([Constants]::DoubleDashLine)

    if ($PerformPreReqCheck)
    {
        try
        {
            Write-Host "[Step 1 of 4] Validate and install the modules required to run the script and validate the user..."
            Write-Host $([Constants]::SingleDashLine)
            Write-Host "Setting up prerequisites..." -ForegroundColor $([Constants]::MessageType.Info)	
            Write-Host $([Constants]::SingleDashLine)
            Setup-Prerequisites
            Write-Host "Completed setting up prerequisites." -ForegroundColor $([Constants]::MessageType.Update)	
            Write-Host $([Constants]::SingleDashLine)
        }
        catch
        {
            Write-Host "Error occurred while setting up prerequisites. Error: $($_)" -ForegroundColor $([Constants]::MessageType.Error)            
            Write-Host $([Constants]::DoubleDashLine)
            return
        }
    }
    else
    {
        Write-Host "[Step 1 of 4] Validate the user... "
        Write-Host $([Constants]::SingleDashLine)
    }

    # Connect to Azure account
    $context = Get-AzContext

    if ([String]::IsNullOrWhiteSpace($context))
    {
        Write-Host "Connecting to Azure account..." -ForegroundColor $([Constants]::MessageType.Info)
        Write-Host $([Constants]::SingleDashLine)
        Connect-AzAccount -Subscription $SubscriptionId -ErrorAction Stop | Out-Null
        Write-Host "Connected to Azure account." -ForegroundColor $([Constants]::MessageType.Update)        
        Write-Host $([Constants]::SingleDashLine)
    }
      # Setting up context for the current Subscription.
      $context = Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    

        Write-Host "Subscription Name: [$($context.Subscription.Name)]"
        Write-Host "Subscription ID: [$($context.Subscription.SubscriptionId)]"
        Write-Host "Account Name: [$($context.Account.Id)]"
        Write-Host "Account Type: [$($context.Account.Type)]"
        Write-Host $([Constants]::SingleDashLine)
    
    Write-Host " To get the data from Load Balancer(s) in a Subscription, Contributor or higher privileged role assignment on the Load Balancer(s) is required." -ForegroundColor $([Constants]::MessageType.Warning)
    Write-Host $([Constants]::SingleDashLine)  

    Write-Host "[Step 2 of 4] Fetch all Load Balancer(s)"
    Write-Host $([Constants]::SingleDashLine)
    
    # list to store Container details.
    $LoadBalancerDetails = @()

     # To keep track of remediated and skipped resources	
    $logRemediatedResources = @()	
    $logSkippedResources=@()	

    # Control Id	
    $controlIds = "Azure_LoadBalancer_NetSec_Enable_WAF_And_DDoS_Protection_Trial"


    # No file path provided as input to the script. Fetch all Load Balancer(s) in the Subscription.

   	
       
        Write-Host "Fetching all Load Balancer(s) in Subscription: [$($context.Subscription.SubscriptionId)]" -ForegroundColor $([Constants]::MessageType.Info)
        Write-Host $([Constants]::SingleDashLine)

        # Get all Load Balancer(s) in a Subscription
        $LoadBalancerDetails =  Get-AzLoadBalancer -ErrorAction Stop

        # Seperating required properties
        $LoadBalancerDetails = $LoadBalancerDetails | Select-Object @{N='ResourceId';E={$_.Id}},
                                                                          @{N='ResourceGroupName';E={$_.Id.Split("/")[4]}},
                                                                          @{N='ResourceName';E={$_.Name}},
                                                                          @{N='ResourceSubNetId';E={$_.FrontendIPConfigurations.SubnetText}},
                                                                          @{N='ResourceVNetName';E={$_.FrontendIPConfigurations.SubnetText.Split('/')[8]}},
                                                                          @{N='ResourceVNetRGName';E={$_.FrontendIPConfigurations.SubnetText.Split('/')[4]}},
                                                                          @{N='IsDDOSEnabled';E=
                                                                          {
                                                                            $VnetDetails =  Get-AzVirtualNetwork -Name $_.FrontendIPConfigurations.SubnetText.Split('/')[8] -ErrorAction Stop
                                                                            $VnetDetails.EnableDdosProtection                                   
                                                                          }}

    
    
    $totalLoadBalancers = ($LoadBalancerDetails| Measure-Object).Count

    if ($totalLoadBalancers -eq 0)
    {
        Write-Host "No Virtual Network of Load Balancer(s) found where DDoS Protection Plan is disabled. Exiting..." -ForegroundColor $([Constants]::MessageType.Update)
        Write-Host $([Constants]::DoubleDashLine)	
        return
    }
  
    Write-Host "Found [$($totalLoadBalancers)] Load Balancer(s)." -ForegroundColor $([Constants]::MessageType.Update)
                                                                          
    Write-Host $([Constants]::SingleDashLine)
    
    # list for storing Load Balancer(s) for which DDoS Protection Plan is not configured on associated Virtual Network.
    $LoadBalancerVNetWithoutDDoS = @()

    Write-Host "Separating Load Balancer(s) for which DDoS Protection Plan is already enabled on associated VNet..." -ForegroundColor $([Constants]::MessageType.Info)

    $LoadBalancerDetails | ForEach-Object {
        $LoadBalancer = $_        
            if($_.IsDDOSEnabled -eq $false)
            {
                $LoadBalancerVNetWithoutDDoS += $LoadBalancer
            }
    }
   
    $totalLoadBalancerVNetWithoutDDoS  = ($LoadBalancerVNetWithoutDDoS | Measure-Object).Count

    if ($totalLoadBalancerVNetWithoutDDoS  -eq 0)
    {
        Write-Host "No Load Balancer(s) found where DDoS Protection Plan is disabled on associated Virtual Network.. Exiting..." -ForegroundColor $([Constants]::MessageType.Warning)
        Write-Host $([Constants]::DoubleDashLine)	
        return
    }

    Write-Host "Found [$($totalLoadBalancerVNetWithoutDDoS)] Load Balancer(s) found where DDoS Protection Plan is disabled on associated Virtual Network." -ForegroundColor $([Constants]::MessageType.Update)
    Write-Host $([Constants]::SingleDashLine)	

    $colsProperty = @{Expression={$_.ResourceName};Label="ResourceName";Width=30;Alignment="left"},
                    @{Expression={$_.ResourceGroupName};Label="ResourceGroupName";Width=30;Alignment="left"},
                    @{Expression={$_.ResourceId};Label="ResourceId";Width=100;Alignment="left"},
                    @{Expression={$_.ResourceSubNetId};Label="ResourceSubNetId";Width=100;Alignment="left"},
                    @{Expression={$_.ResourceVNetName};Label="Resource Virtual Network Name";Width=100;Alignment="left"},
                    @{Expression={$_.ResourceVNetRGName};Label="Resource Virtual Network RG Name";Width=100;Alignment="left"},
                    @{Expression={$_.IsDDOSEnabled};Label="IsDDOSEnabled";Width=100;Alignment="left"}
                    @{Expression={$_.IsNSGConfigured};Label="IsNSGConfigured";Width=100;Alignment="left"}
                    
      if(-not $AutoRemediation)
      {
        Write-Host "Load Balancer(s) where DDoS Protection Plan is disabled on associated Virtual Network are as follows:"
        $LoadBalancerVNetWithoutDDoS | Format-Table -Property $colsProperty -Wrap
        Write-Host $([Constants]::SingleDashLine)
      }    
    

    # Back up snapshots to `%LocalApplicationData%'.
    $backupFolderPath = "$([Environment]::GetFolderPath('LocalApplicationData'))\AzTS\Remediation\Subscriptions\$($context.Subscription.SubscriptionId.replace('-','_'))\$($(Get-Date).ToString('yyyyMMddhhmm'))\VNetWithoutDDoSEnabled"

    if (-not (Test-Path -Path $backupFolderPath))
    {
        New-Item -ItemType Directory -Path $backupFolderPath | Out-Null
    }
 
    Write-Host "[Step 3 of 4] Back up Load Balancer(s) details..."
    Write-Host $([Constants]::SingleDashLine)

    if ([String]::IsNullOrWhiteSpace($FilePath))
    {
        # Backing up Load Balancer(s) details.
        $backupFile = "$($backupFolderPath)\LoadBalancerDetailsBackUp.csv"
        $LoadBalancerVNetWithoutDDoS | Export-CSV -Path $backupFile -NoTypeInformation
        Write-Host "Load Balancer(s) details have been backed up to [$($backupFile)]" -ForegroundColor $([Constants]::MessageType.Update)
        Write-Host $([Constants]::SingleDashLine)
    }
    

    Write-Host "Skipped as -DryRun switch is provided." -ForegroundColor $([Constants]::MessageType.Warning)
    Write-Host $([Constants]::SingleDashLine)
    Write-Host "Next steps:" -ForegroundColor $([Constants]::MessageType.Warning)
    Write-Host "Run the next command with -FilePath [$($backupFile)] and without -DryRun, Enable the DDOS on the Vnet of Load Balancer(s) listed in the file." -ForegroundColor $([Constants]::MessageType.Warning)
    Write-Host $([Constants]::DoubleDashLine)
    
}




# Defines commonly used constants.
class Constants
{
    # Defines commonly used colour codes, corresponding to the severity of the log...
    static [Hashtable] $MessageType = @{
        Error = [System.ConsoleColor]::Red
        Warning = [System.ConsoleColor]::Yellow
        Info = [System.ConsoleColor]::Cyan
        Update = [System.ConsoleColor]::Green
        Default = [System.ConsoleColor]::White
    }

    static [String] $DoubleDashLine = "========================================================================================================================"
    static [String] $SingleDashLine = "------------------------------------------------------------------------------------------------------------------------"
}
