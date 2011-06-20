<<<<<<< HEAD
=======
# magtek Module

## Description

The magtek module allows for 

## Accessing the magtek Module

To access this module from JavaScript, you would do the following:

	var magtek = require("ti.magtek");

The magtek variable is a reference to the Module object.	

## Reference

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

## Usage

See example.

## Author

Jeff Haynie <jhaynie@appcelerator.com>, Appcelerator Inc.

## License

Copyright(c) 2010-2011 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.
>>>>>>> b9a468610055bc3eb1c8a9011e53d65a12808b04
