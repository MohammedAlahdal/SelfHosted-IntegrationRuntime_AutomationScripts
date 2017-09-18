#### Here is the usage doc:
#### PS D:\GitHub> .\InstallGatewayOnLocalMachine.ps1 E:\shared\bugbash\IntegrationRuntime.msi
####

param([string]$path)
function Install-Gateway([string] $gwPath)
{
    if ([string]::IsNullOrEmpty($gwPath))
    {
        throw "Gateway path is not specified"
    }

    if (!(Test-Path -Path $gwPath))
    {
        throw "Invalid gateway path: $gwPath"
    }

    # uninstall any existing gateway
    UnInstall-Gateway

    Write-Host "Start Gateway installation"
    
    Start-Process "msiexec.exe" "/i $path /quiet /passive"
    Start-Sleep -Seconds 30	

    Write-Host "Installation of gateway is successful"
}

function Check-WhetherGatewayInstalled([string]$name)
{
    $installedSoftwares = Get-ChildItem "hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    foreach ($installedSoftware in $installedSoftwares)
    {
        $displayName = $installedSoftware.GetValue("DisplayName")
        if($DisplayName -eq "$name Preview" -or  $DisplayName -eq "$name")
        {
            return $true
        }
    }

    return $false
}


function UnInstall-Gateway()
{
    $installed = $false
    if (Check-WhetherGatewayInstalled("Microsoft Data Management Gateway"))
    {
        [void](Get-WmiObject -Class Win32_Product -Filter "Name='Microsoft Data Management Gateway Preview' or Name='Microsoft Data Management Gateway'" -ComputerName $env:COMPUTERNAME).Uninstall()
        $installed = $true
    }

    if (Check-WhetherGatewayInstalled("Microsoft Integration Runtime"))
    {
        [void](Get-WmiObject -Class Win32_Product -Filter "Name='Microsoft Integration Runtime Preview' or Name='Microsoft Integration Runtime'" -ComputerName $env:COMPUTERNAME).Uninstall()
        $installed = $true
    }

    if ($installed -eq $false)
    {
        Write-Host "Microsoft Data Management Gateway Preview is not installed."
        return
    }

    Write-Host "Microsoft Data Management Gateway Preview has been uninstalled from this machine."
    Start-Sleep -Seconds 30
}

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

Install-Gateway $path