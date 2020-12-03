# TCC Permitter

Allow services that are denied in the TCC database.

## Background

For devices under management, there are some User Consent items that cannot be allowed even with PPPC.

If you have not granted administrators, the end user cannot change the access rights of some applications in the [System Preferences] > [Security & Privacy] > [Privacy] UI.

Therefore, I have created a script to force the User Consent item to be allowed.

## Requirements

* Full disk access
   * This script reads TCC database
* macOS 10.14 Mojave or later

## How to use

### With command line

The script will require two arguments.

```sh
./TCC-Permitter.sh <bundle-id or binary path> <TCC service name>
```

If you want to allow camera of zoom app, you should run the following command:

```sh
./TCC-Permitter.sh "us.zoom.xos" "Camera"
```

### With Jamf Pro

1. Upload this script to Jamf Pro.
1. Create new policy with the script.
1. Set arguments for the script.
    1. Bundle ID or Binary path
    1. TCC service name

If you want to allow camera of zoom app, the setting will look like the image below.

![Jamf Pro policy example](images/jamf-pro-policy-example.png?raw=true)

### Parameters

#### Bundle ID or Binary path

If you want to get the bundle ID of the target application, the following command may be of help.

```sh
mdls -name kMDItemCFBundleIdentifier -r /Applications/zoom.us.app
```

And if you want to check the current status of the TCC database, the following command may be of help.

```sh
sqlite3 -header "$HOME/Library/Application Support/com.apple.TCC/TCC.db" "SELECT service, client, allowed FROM access"
```

#### TCC service name

You can specify one of the following list
It is case-insensitive.

If you want to specify more than one, you can use comma-separated values like:

```sh
./TCC-Permitter.sh "us.zoom.xos" "Camera,Microphone,ScreenCapture"
```

* Accessibility
* AddressBook
* All
* AppleEvents
* Calendar
* Camera
* ContactsFull
* ContactsLimited
* DeveloperTool
* Facebook
* FileProviderDomain
* FileProviderPresence
* LinkedIn
* ListenEvent
* Liverpool
* Location
* MediaLibrary
* Microphone
* Motion
* Photos
* PhotosAdd
* PostEvent
* Reminders
* ScreenCapture
* ShareKit
* SinaWeibo
* Siri
* SpeechRecognition
* SystemPolicyAllFiles
* SystemPolicyDesktopFolder
* SystemPolicyDeveloperFiles
* SystemPolicyDocumentsFolder
* SystemPolicyDownloadsFolder
* SystemPolicyNetworkVolumes
* SystemPolicyRemovableVolumes
* SystemPolicySysAdminFiles
* TencentWeibo
* Twitter
* Ubiquity
* Willow
