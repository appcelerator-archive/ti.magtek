# Ti.Magtek Module

## Description

The Ti.Magtek module allows for

## Accessing the Ti.Magtek Module

To access this module from JavaScript, you would do the following:

	Titanium.Magtek = Ti.Magtek = require("ti.magtek");

## Events 

### connected

Fired when a scanning device is connected.  Event dictionary is:

connectionId[int]: The connection identifier  
name[string]: The name of the accessory  
manufacturer[string]: The manufacturer of the accessory  
modelNumber[string]: The model number for the accessory  
serialNumber[string]: The serial number for the accessory  
hardwareRevision[string]: The hardware revision of the accessory  
firmwareRevision[string]: The firmware revision of the accessory

### disconnected

Fired when a scanning device is disconnected.  Event dictionary is:

connectionId[int]: The connection identifier  
name[string]: The name of the accessory  
manufacturer[string]: The manufacturer of the accessory  
modelNumber[string]: The model number for the accessory  
serialNumber[string]: The serial number for the accessory  
hardwareRevision[string]: The hardware revision of the accessory  
firmwareRevision[string]: The firmware revision of the accessory

### swipe

Fired when a card is swiped through the scanning device.  Event dictionary is:

name[string]: The name of the card owner  
cardnumber[string]: The (masked) card number  
expiration[string]: The expiration date, in xx/xx format.  
data[object]: A blob representing the data on the magstripe of the card.  

### swipeError

Fired when a card error is detected during the swipe. This event is triggered when errors are detected composing the data for the swipe event. You will need to analyze the full data blob for all possible errors.   
 
## Methods
### resumeConnection()
call this in the applications resume event to reconnect the reader when the application goes into the background. 

## Usage

See example.

## Author

Jeff Haynie <jhaynie@appcelerator.com>, Appcelerator Inc.

## License

Copyright(c) 2010-2011 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

