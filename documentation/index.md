# Ti.Magtek Module

## Description

The Ti.Magtek module allows for developing applications for the iDynamo and audio jack readers under iOS. The software must be used on an iOS device and are not supported in a simulated environment.

## Getting Started

View the [Using Titanium Modules](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_Titanium_Modules) document for instructions on getting
started with using this module in your application.

## Using the MagTek module with iOS5+ devices

A change in the handling of external accessories with iOS beginning with version 5 requires that the supported external protocols be defined in the 'Info.plist' file for the application. In order for your application to access the MagTek scanner on iOS5 devices, you need to follow these steps to update your Info.plist file:

### Step 1: Generate Info.plist file

* Build the application once
* Navigate to the 'build/iphone' folder and locate the 'Info.plist' file
* Copy the 'Info.plist' file to the application's project root folder

### Step 2: Edit the Info.plist file

* Open the copied Info.plist file by double-clicking on the file in Finder
* Right-click in the list of entries and select 'Add Row'
* Select the entry titled 'Supported external accessory protocols' -- the entry should be added to the Info.plist as an 'Array' type
* Expand the 'Supported external accessory protocols' entry and select the value for 'Item 0' so that it can be edited
* Enter the unique protocol identifier for the MagTek device (e.g. 'com.yourcompany.magtek')
* Save and close the file

### Step 3: Rebuild your application

* Clean the application project
* Build the application -- the Info.plist file will be copied into the 'build/iphone' folder for you each time that the application is built

## Accessing the Module

Use `require` to access this module from JavaScript:

	var Magtek = require('ti.magtek');
	
The Magtek variable is a reference to the Module object.
 
## Methods

### void Magtek.registerDevice(options)

This function registers the protocol identifier for the MagTek device and optionally, sets the deviceType.

#### Arguments

* options[object]	
	* __protocol__ [string] (required): The unique protocol identifier for the MagTek device (e.g. 'com.yourcompany.magtek')
	* __deviceType__ [int] (optional): can be set to
		* DEVICE_TYPE_IDYNAMO (default if deviceType not specified)
		* DEVICE_TYPE_AUDIO_READER
		
	
#### Example
	// Set the protocol for your device. For example, 'com.yourcompany.magtek'
	Magtek.registerDevice({
		protocol: '<<--- YOUR DEVICE PROTOCOL --->>',
		deviceType: Magtek.DEVICE_TYPE_IDYNAMO
	});

## Constants
### Magtek.DEVICE_TYPE_IDYNAMO [int] (read-only)

Used to set the deviceType to iDynamo when calling registerDevice()

### Magtek.DEVICE_TYPE_AUDIO_READER [int] (read-only)
	
Used to set the deviceType to audio jack reader when calling registerDevice()

## Events 

### "connected"

Fired when a scanning device is connected.  Event dictionary is:

* deviceName[string]: The name of the accessory  

#### Example
	Magtek.addEventListener('connected', function(e) {
	   Ti.API.info('Connected: '+JSON.stringify(e));
	});

### "disconnected"

Fired when a scanning device is disconnected.  Event dictionary is:

* deviceName[string]: The name of the accessory  

#### Example
	Magtek.addEventListener('disconnected', function(e) {
	   Ti.API.info('Disconnected: '+JSON.stringify(e));
	});

### "swipe"

Fired when a card is swiped through the scanning device. Properties in the event dictionary may contain an empty string if the value is not available. Event dictionary is:

* __maskedTracks__ [string]: Masked data, only supported for iDynamo, it will return a empty string in audio reader
* __track1__ [string]: Encrypted Track1 if any
* __track2__ [string]: Encrypted Track2 if any
* __track3__ [string]: Encrypted Track3 if any
* __track1Masked__ [string]: Masked Track1 if any
* __track2Masked__ [string]: Masked Track2 if any
* __track3Masked__ [string]: Masked Track3 if any
* __magnePrint__ [string]: Encrypted MagnePrint, only supported for iDynamo, it will return a empty string in audio reader
* __magnePrintStatus__ [string]: MagnePrint Status, only supported for iDynamo, it will return a empty string in audio reader
* __deviceSerial__ [string]: Device serial number
* __sessionID__ [string]: Session ID, only supported for iDynamo, it will return a empty string in audio reader
* __KSN__ [string]: Key serial number
* __magTekDeviceSerial__ [string]: Device Serial Number created by MagTek
* __deviceName__ [string]: Device model name
* __deviceCaps__ [string]: Device capabilities
* __TLVVersion__ [string]: TLV Version of firmware
* __devicePartNumber__ [string]: Device part number
* __capMSR__ [string]: MSR Capability
* __capTracks__ [string]: Tracks Capability
* __capMagStripeEncryption__ [string]: MagStripe Encryption Capability
* __cardPANLength__ [number]: Length of the PAN
* __responseData__ [string]: The whole Response from the reader
* __cardName__ [string]: The Name in the Card
* __cardIIN__ [string]: The IIN in the Card
* __cardLast4__ [string]: The last 4 of the PAN
* __cardExpDate__ [string]: The Expiration Date
* __cardServiceCode__ [string]: The Service Code
* __cardStatus__ [string]: The Card Status
* __trackDecodeStatus__ [string]: The Track Decode Status
* __responseType__ [string]: The Response Type
* __operationStatus__ [string]: The Operation Status
* __batteryLevel__ [string]: The Device Battery Level
* __firmware__ [string]: Firmware version number

#### Example
	Magtek.addEventListener('swipe', function(e) {
		Ti.API.info('Swipe: '+JSON.stringify(e));
	});

### "swipeError"

Fired when a card error is detected during the swipe. This event is triggered when errors are detected composing the data for the swipe event. Typically caused by a read error on one of the tracks, and indicates that the card needs to be swiped again.

#### Example
	Magtek.addEventListener('swipeError',function(e){
		Ti.API.info('Swipe Error: Please re-swipe the card');
	});

## Usage

See the example application in the `example` folder of the module.

## Author

Jeff Haynie, Jeff English, and Jon Alter

## Module History

View the [change log](changelog.html) for this module.

## Feedback and Support

Please direct all questions, feedback, and concerns to [info@appcelerator.com](mailto:info@appcelerator.com?subject=iOS%20Magtek%20Module).

## License

Copyright(c) 2010-2012 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.
