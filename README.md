# Self-hosted Integration Runtime (IR) Automation Scripts

1. **[InstallGatewayOnLocalMachine.ps1](./InstallGatewayOnLocalMachine.ps1)** -  The script can be used to install self-hosted integration runtime node and register it with an authentication key. The script accepts two arguments, **first** specifying the location of the [self-hosted integration runtime](https://www.microsoft.com/download/details.aspx?id=39717) on a local disk, **second** specifying the **authentication key** (for registering self-hosted IR node).
  *Example: PS D:\GitHub> .\InstallGatewayOnLocalMachine.ps1 E:\shared\IntegrationRuntime.msi <key>*

  <br />


2. **[script-update-gateway.ps1](./script-update-gateway.ps1)** - The script can be used to install the latest or update an existing self-hosted integration runtime to the latest version. It accepts an argument for specifying version number (example: *-version 3.13.6942.1*). When no version is specified, it always updates the self-hosted IR to the latest version found in the [downloads](https://www.microsoft.com/download/details.aspx?id=39717).
   
   *<u>Note</u>: Only last 3 versions can be specified. Ideally this is used only with the latest version to update an existing node to the latest version.*

   <u>Usage Examples:</u>

   - **Download and install latest self-hosted IR**
     PS > .\script-update-gateway.ps1

   - **Download and install the specified version of self-hosted IR**
     PS > .\script-update-gateway.ps1 -version 3.13.6942.1   


