# Self-hosted Integration Runtime Automation Scripts

1. **[InstallGatewayOnLocalMachine.ps1](./InstallGatewayOnLocalMachine.ps1)** -  The script can be used to install self-hosted integration runtime node and register it with an authentication key. The script accepts two arguments, **first** specifying the location of the [self-hosted integration runtime](https://www.microsoft.com/download/details.aspx?id=39717) on a local disk, **second** specifying the **authentication key** (for registering self-hosted IR node).
  *Example: PS D:\GitHub> .\InstallGatewayOnLocalMachine.ps1 E:\shared\IntegrationRuntime.msi <key>*

  

2. **[script-update-gateway.ps1](./script-update-gateway.ps1)** - The script can be used to update an existing self-hosted integration runtime. It accepts an argument for specifying version number (example: *-version 3.13.6942.1*). 
   *<u>Note</u>: Only last 3 versions can be specified. Ideally this is used only with the latest version to update an existing node to the latest version.*

