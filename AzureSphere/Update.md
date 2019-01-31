# Updating Azure Sphere

You need to download the update package from the [Collaborate Portal](https://partner.microsoft.com/en-us/dashboard/collaborate/).
- If you're within the lab, check [here](https://microsoft.sharepoint.com/teams/RedmondIoTAICustomer371/Shared%20Documents/General/Sphere).
- Do NOT upload the files to a public access point. These are for distribution within the lab under NDA only!  

Unzip the files and know where the folder "images" is located.

Within the Azure Sphere shell cd to the directory where "images" is located.  For example 

```
azsphere device recover –images images
```