#
# This script is used to udpate my data management gateway when I don't want my gateway auto updated, but I want to automate it myself.
# And the steps are like this:
# 1. check my current gateway version
# 2. check latest gateway version
# 3. if there is no gateway
#    3.1 download gateway msi
#    3.2 upgrade it
#
#

function Get-CurrentGatewayVersion()
{
    $registryKeyValue = Get-RegistryKeyValue "Software\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager"

    $baseFolderPath = [System.IO.Path]::GetDirectoryName($registryKeyValue.GetValue("DiacmdPath"))
    $filePath = [System.IO.Path]::Combine($baseFolderPath, "Microsoft.DataTransfer.GatewayManagement.dll")
    $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filePath)
    #$gatewayVersion = [System.Version]::new($version.FileMajorPart, $version.FileMinorPart, $version.FileBuildPart, $version.FilePrivatePart)

    $msg = "Current gateway: " + $version.FileVersion
    Write-Host $msg
    return $version.FileVersion
}

function Get-LatestGatewayVersion()
{
    $latestGateway = Get-RedirectedUrl "https://go.microsoft.com/fwlink/?linkid=839822"
    $item = $latestGateway.split("/") | Select-Object -Last 1
    if ($item -eq $null -or $item -notlike "DataManagementGateway*")
    {
        throw new Exception("Can't get latest gateway info")
    }

    $regexp = '^DataManagementGateway_(\d+\.\d+\.\d+\.\d+) \(64-bit\)\.msi$'

    $version = [regex]::Match($item, $regexp).Groups[1].Value
    if ($version -eq $null)
    {
        throw new Exception("Can't get version from gateway download uri")
    }

    $msg = "Latest gateway: " + $version
    Write-Host $msg
    return $version
}

function Get-RegistryKeyValue
{
	param($registryPath)

    $is64Bits = Is-64BitSystem
	if($is64Bits)
	{
		$baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
		return $baseKey.OpenSubKey($registryPath)
	}
	else
	{
		$baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
		return $baseKey.OpenSubKey($registryPath)
	}
}


function Get-RedirectedUrl 
{
    $URL = "https://go.microsoft.com/fwlink/?linkid=839822"
 
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$false
    $response=$request.GetResponse()
 
    If ($response.StatusCode -eq "Found")
    {
        $response.GetResponseHeader("Location")
    }
}

function Download-GatewayInstaller
{
    Write-Host "Start to download MSI"
    $is64Bits = Is-64BitSystem
    $uri = Get-RedirectedUrl
    if ($is64Bits -ne $true)
    {
        $uri = $uri.Replace("64-bit", "32-bit")
    }

    $folder = New-TempDirectory
    $output = Join-Path $folder "DataManagementGateway.msi"
    (New-Object System.Net.WebClient).DownloadFile($uri, $output)

    $msg = "New gateway MSI has been downloaded to " + $output
    Write-Host $msg
    return $output
}

function Install-Gateway
{
    Param (
        [Parameter(Mandatory=$true)]
        [String]$msi
    )

    Write-Host "Start to install gateway ..."


    $arg = "/i " + $msi + " /quiet /norestart"
    Start-Process -FilePath "msiexec.exe" -ArgumentList $arg -Wait -Passthru -NoNewWindow
    
    Write-Host "Gateway has been successfully updated!"
}

function New-TempDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}


function Is-64BitSystem
{
	$computerName= $env:COMPUTERNAME
	$osBit = (get-wmiobject win32_processor -computername $computerName).AddressWidth
	return $osBit -eq '64'
}

$currentVersion = Get-CurrentGatewayVersion
$latestGatewayVersion = Get-LatestGatewayVersion

if ($currentVersion -eq $latestGatewayVersion)
{
    Write-Host "Your gateway is latest, no update need..."
}
else
{
    $msi = Download-GatewayInstaller
    Install-Gateway $msi
    Remove-Item -Path $msi -Force
}