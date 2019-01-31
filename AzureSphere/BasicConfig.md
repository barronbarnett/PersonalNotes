# Installation

This is the list of instructions necessary to configure an MT3620 for development.
1. Install [Visual Studio 2017](https://visualstudio.microsoft.com/vs/whatsnew/). 
1. Download the [Azure Sphere SDK](https://aka.ms/AzureSphereSDKDownload). 
1. Enable the [Developer Mode](https://docs.microsoft.com/en-us/windows/uwp/get-started/enable-your-device-for-development) for your development machine.
1. Restart the machine.
1. Open the Azure Sphere Developer Command Prompt. (Start->"Azure Sphere Developer Command Prompt" )
    1. First we need to associate the tools with our "tenant". We have created a tenant for the IoT Labs called 'iotinsiderlabs'
    1. ```azsphere tenant list```
        - You should see something like the following output:
        ``` 
        C:\Users\v-babarn\Documents>azsphere tenant list
        ID                                   Name
        --                                   ----
        12345678-1234-1234-1234-123456789abc iotinsiderlabs
        
        Command completed successfully in 00:00:02.3329163.
        ```
    1. Note, if you see the following error you need to update the device. See [here](./Update.md).
        ```
        error: The Azure Sphere OS on the attached device requires an update to be used with this version of the SDK.
        Diagnostic info: [1.2.0, 3]
        error: Failed to retrieve device ID from attached device: 'The Azure Sphere OS on the attached device requires an update to be used with this version of the SDK.
        Diagnostic info: [1.2.0, 3]'.
        error: Command failed in 00:00:00.9187758.
        ```
    1. Now we need to select which tenant we will be working with (note the GUID has been changed in this example.)
        - `azsphere tenant select -i 12345678-1234-1234-1234-123456789abc` 
        - where the last argument is the guid of the tenant we want to work with.
     
        ``` 
        azsphere tenant select -i 12345678-1234-1234-1234-123456789abc
        Default Azure Sphere tenant ID has been set to '12345678-1234-1234-1234-123456789abc'.
        Command completed successfully in 00:00:00.4419067.
        ```
    5. Now we need to claim the device in to the tenant.
        - `azsphere device claim`
        ```
        azsphere device claim
        Claiming device.
        Successfully claimed device ID 'DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEF' into tenant 'iotinsiderlabs' with ID '12345678-1234-1234-1234-123456789abc'.
        Command completed successfully in 00:00:02.4347242.
        ```
    6. Now we need to configure the device to allow debug and app side-loading.
        - `azsphere device prep-debug`
        ```
        Getting device capability configuration for application development.
        Downloading device capability configuration for device ID 'DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEF'.
        Successfully downloaded device capability configuration.
        Successfully wrote device capability configuration file 'C:\Users\v-babarn\AppData\Local\Temp\tmpD6EB.tmp'.
        Setting device group ID '63bbe6ea-14be-4d1a-a6e7-03591d882b42' for device with ID 'DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEF'.
        Successfully disabled over-the-air updates.
        Enabling application development capability on attached device.
        Applying device capability configuration to device.
        Successfully applied device capability configuration to device.
        The device is rebooting.
        Installing debugging server to device.
        Deploying 'C:\Program Files (x86)\Microsoft Azure Sphere SDK\DebugTools\gdbserver.imagepackage' to the attached device.
        Image package 'C:\Program Files (x86)\Microsoft Azure Sphere SDK\DebugTools\gdbserver.imagepackage' has been deployed to the attached device.
        Application development capability enabled.
        Successfully set up device 'DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEFBEEFCAFE00BEEF00ABCDEF0123456789DEADBEEF' for application development, and disabled over-the-air updates.
        Command completed successfully in 00:00:41.3508105.
        ```
1. Continue with [this example](https://docs.microsoft.com/en-us/azure-sphere/app-development/azure-iot-sample).  
