# Win 10 IoT Core BSP and Image Generation

## Quick Overview
The IoT ADK Addon Kit is a set of powershell applets for configuring and building IoT Core Images. This process points to input files, creates packages and “features” from these inputs, and then combines them all together at the end.

Because of this there are a variety of inputs that all need to be tracked but do not necessarily live within the workspace of the project.  They are merely inputs and could change. For example your application could be rebuilt into a new version. Or you may have external drivers which are provided by a vendor which you wish to include within your image.

For this reason we have worked on a useful structure for organizing your files related to a build. This structure is also recommended because absolute paths should always be used, additionally spaces should never be in a path or file name.

### Recommended Directory Structure
* C:\
    * <project_root>    _This is the root of your project, you should place this in source control_
        * apps
        * certificates
        * lib
            * bsps
            * config            _This is used for things like the Device Update Center Config_
            * drivers
            * files
            * scripts
        * prov
        * workspace             _This is the iot-adk workspace. You should absolutely track this independently as well_
            * Build
            * Common
            * Source-arm

_NOTE:_ Do not put spaces in the path for you project root.


## Toolchain Installation ([See here for more details](https://docs.microsoft.com/en-us/windows-hardware/manufacture/iot/set-up-your-pc-to-customize-iot-core))
Note: All packages/components must be based on same Win 10 Version. No Exceptions!
See this page for [links](https://docs.microsoft.com/en-us/windows-hardware/manufacture/iot/set-up-your-pc-to-customize-iot-core) to the current packages.
1.	Install [adksetup.exe](https://go.microsoft.com/fwlink/?LinkId=526803). Leave all options/paths to default.
2.	Install [wdksetup.exe](http://developer.microsoft.com/windows/hardware/windows-driver-kit). Leave all options/paths to default.
3.	Install the packages required for your architectures from [Windows10_IoTCore_Packages_ARM32_en-us_17763Oct.iso](https://www.microsoft.com/en-us/software-download/windows10iotcore)
    * Windows_10_IoT_Core_ARM_Packages.msi
    * Windows_10_IoT_Core_ARM64_Packages.msi
    * Windows_10_IoT_Core_x64_Packages.msi
    * Windows_10_IoT_Core_x86_Packages.msi from the 
4.	[Extract iot-adk-addonkit-master.zip]() to a known working directory. (Ex: “C:\\<something_without_spaces>”)
5.	Install the [Windows 10 IoT Core Dashboard](https://go.microsoft.com/fwlink/p/?LinkId=708576)
6.	Buy and obtain an EV Signing Certificate.
7.	Buy and obtain an EV Signing Certificate, Cross signature capable.
8.	Reboot after Installation.

## IoT Core Manufacturing Guide
### Default Image Generation
#### From “[Lab 2: Create/Load a BSP]()”

1.	Run as admin the "IoTCorePShell.cmd" script in the iot-adk-addonkit. SHOULD NOT have errors!
2.	> [new-ws](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTWorkspace.md) <target_folder> <oem_name> <proc_architecture>  
3.	Import the BSP into the workspace
    * Qualcomm:
        1. Place the db410c_bsp.zip in a convenient path without spaces. 
	    > [Import-QCBSP](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Import-QCBSP.md) “path_to_bsp.zip” C:\prebuilt\DB410c_BSP -ImportBSP  
        2. Build the packages for the BSP after imporation:
        > [buildpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTCabPackage.md) QCDB410C    
    * Raspberry Pi
        1. Place the RPi2_BSP.zip in a convenient path without spaces.
        > [importbsp](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Import-IoTBSP.md) RPi2 “path_to_bsp.zip” <path_to_bsp.zip>  
    * iMX
        1. Unknown

#### From “[Lab 1a: Create a basic image](https://docs.microsoft.com/en-us/windows-hardware/manufacture/iot/create-a-basic-image)”
1.	Import the packages for your project, either selectively or all in the sample workspace.
    * Import all packages: 
    > _[importpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Import-IoTOEMPackage.md) *_
	* Import selectively: 
    > _[importpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Import-IoTOEMPackage.md) <package_name>_
1.  Import the [Device Update Center](#device-update-center) configuration.
1.	Build the packages that you’ve imported.
	> [buildpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTCabPackage.md) All
1.	Create a new product. This is where BSP, Architecture, and Package selection combine.
	> [newproduct](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTProduct.md) <product_name> <bsp_name>  
	> bsp_name: DCDB410C Qualcom Dragonboard  
	> bsp_name: RPi2 Raspberry Pi  
    * The fields below all tie into the Device Update Center labeling  
    > OemName: <company name>   
	> FamilyName: <product family>   
	> SkuNumber: <sku number>   
	> Baseboard Mfr: <SOM manufacturer>   
	> BaseboardProduct: <SOM model>   
1.	Build the FFU image
	> [buildimage](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTFFUImage.md) <product_name> <Test|Retail>
1.	Load the image onto the device.

### Add an App Package to your image
#### From “[Lab 1b: Add an app to your image](https://docs.microsoft.com/en-us/windows-hardware/manufacture/iot/deploy-your-app-with-a-standard-board)”

Build a package for your application.

1.	Once you have built your APPX for your UWP app do the following.
    > [newappxpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTAppxPackage.md) _path_to_appx_ [fga|bgt] Appx.<application_name>
    
    > NOTE: Alphanumerics only for the application_name.  
    > bgt: Background Tasks, this will be set to start automatically  
    > fga: Foreground Applications  
1.	Now build your packages
    > [buildpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTCabPackage.md) Appx.*
1.	Now add the feature representing the application into your product
    > [addfid](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTProductFeature.md) <product_name> [Test|Retail] APPX_<APPNAME> -OEM
1.	Repeat the above for every application

### Add Custom Registry and Files
#### From "[Lab 1c: Add a file and registry setting to an image](https://docs.microsoft.com/en-us/windows-hardware/manufacture/iot/add-a-registry-setting-to-an-image)
#### Files
1.	Create an array with the listing of files you wish to include.
    ```Powershell
    $myfiles = @(  
    ("`$(runtime.system32)","C:\Temp\TestFile1.txt", ""),  
    ("`$(runtime.bootDrive)\OEMInstall","C:\Temp\TestFile2.txt", "TestFile2.txt")  
    )
    ```  
1. Add the IoT File Package to the workspace
    > [Add-IoTFilePackage](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTFilePackage.md) <package_name> $myfiles  
    > Recommended File._yournamehere_
1. Build the new package.
    > [buildpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTCabPackage.md) <package_name>
1. Add the package to your product
    > [addfid](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTProductFeature.md) <product_name> [Test|Retail] <PACKAGE_NAME> -OEM

#### Registry
1. Create an array with the listing of registry entries you wish to bundle in a package.
    ```Powershell
    $packagekeyarray = @(
    ("`$(hklm.software)\`$(OEMNAME)\Test","StringValue", "REG_SZ", "Test string"),
    ("`$(hklm.software)\`$(OEMNAME)\Test","DWordValue", "REG_DWORD", "0x12AB34CD")
    )
    ```
1. Add this registry collection as a package.
    > [Add-IoTRegistryPackage](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTRegistryPackage.md) <package_name> $packagekeyarray  
    > Recommend Registry._yournamehere_
1. Build the new package
    > [buildpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTCabPackage.md) <package_name>
1. Add the package name into your product
    > [addfid](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTProductFeature.md) <product_name> [Test|Retail] <PACKAGE_NAME> -OEM 

### Add a Driver to the image
#### From "[Lab 1e: Add a driver to an image](https://docs.microsoft.com/en-us/windows-hardware/manufacture/iot/add-a-driver-to-an-image)"

Build a package for your driver.
1. Create a package for the driver.
    > [newdrvpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTDriverPackage.md) <path_to_inf> <package_name>  
    Recommended: Drivers._yourname_
1. Build the package
    > [buildpkg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTCabPackage.md) <package_name>
1. Add the package to your product
    > [addfid](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTProductFeature.md) <product_name> [Test|Retail] <PACKAGE_NAME> -OEM

### Device Update Center
#### From "[Using Device Update Center](https://docs.microsoft.com/en-us/windows-hardware/service/iot/using-device-update-center)"

Setup your environment
1. Configure your workspace to use your EV Code Signing certificate and cross signing certificate. Use only one of the following formats for each tag.
    ```XML
    <!--Specify the retail signing certificate details, Format given below -->
    <RetailSignToolParam>/s my /i "Issuer" /n "Subject" /ac "C:\CrossCertRoot.cer" /fd SHA256</RetailSignToolParam>
    <RetailSignToolParam>/s my /sha1 "fingerprint for certificate here" /ac "C:\CrossCertRoot.cer" /fd SHA256</RetailSignToolParam>
    <RetailSignToolParam>/f "C:\CertificatePath\CertName.cer" /ac "C:\CrossCertRoot.cer" /fd SHA256</RetailSignToolParam>
    <!--Specify the ev signing certificate details, Format given below -->
    <EVSignToolParam>/s my /sha1 "fingerprint for certificate here" /fd SHA256</EVSignToolParam>
    <EVSignToolParam>/s my /i "Issuer" /n "Subject" /fd SHA256</EVSignToolParam>
    <EVSignToolParam>/f "C:\CertificatePath\CertName.cer" /fd SHA256</EVSignToolParam>
    ```
1. [Register your device](https://docs.microsoft.com/en-us/windows-hardware/service/iot/using-device-update-center#step-3-register-device-model-in-device-update-center) model in the [Device Update Center](https://partner.microsoft.com/en-us/dashboard/)

Now that you have the CUSConfig.zip, you need to bring that into your environment.

1. Import the CUSConfig.zip
    > [importcfg](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Import-IoTDUCConfig.md) <product_name> <CUSConfig.zip_path>
2. You need to sign all 

### Other Configuration Notes:

1.	For a headless device:
    > [addfid](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTProductFeature.md) <product_name> [Test|Retail] IOT_HEADLESS_CONFIGURATION

1. Validate the signatures on the CABs.
    > [Test-IoTSignature](https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Test-IoTSignature.md) <file> [Test|Retail]