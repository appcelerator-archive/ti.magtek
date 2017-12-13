/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2012 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */

// See the book "Building IPhone OS Accessories: Use the IPhone Accessories API to Control"
// by Ken Maskrey for great coverage on developing Accessories. Chapter 2 is especiallyl
// relevant to this module.

// *******************************************************************************************
// NOTE: For the MagTek device that Appcelerator has for testing, the protocol
// is 'com.appcelerator.magtek'. Use that value in the sample app when calling registerDevice.
// *******************************************************************************************

// *******************************************************************************************
// NOTE: Due to some problems with the MagTek library, it is necessary to delay calling some
// methods for some seconds to avoid race conditions. The amount of delay is controlled by
// variables "openDelayAfterClose" and "openDelayAfterRemoveObserver" which are initialized in
// init where there is also an exaplanation of what they control. These variables are exposed
// as properties of the module and can be set in the case that the default values are not working.
// *******************************************************************************************

#import "TiMagtekModule.h"
#import "TiBase.h"
#import "TiBlob.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <ExternalAccessory/ExternalAccessory.h>

@implementation TiMagtekModule

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"57754725-fe67-4e3f-90c7-1137ad0a5b13";
}

// this is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"ti.magtek";
}

#pragma mark Public Constants

MAKE_SYSTEM_NUMBER(DEVICE_TYPE_AUDIO_READER, NUMINT(MAGTEKAUDIOREADER));
MAKE_SYSTEM_NUMBER(DEVICE_TYPE_IDYNAMO, NUMINT(MAGTEKIDYNAMO));

#pragma mark Lifecycle

- (void)startup
{
  // This method is called when the module is first loaded
  // you *must* call the superclass

  [super startup];

  NSLog(@"[INFO] Magtek iDynamo Reader Module loaded", self);
}

- (id)init
{
  if (self = [super init]) {
    mtSCRALib = [[MTSCRA alloc] init];
    //      mtSCRALib.delegate = self;

    // TRANS_STATUS_START should be used with caution. CPU intensive
    // tasks done after this events and before TRANS_STATUS_OK
    // may interfere with reader communication
    [mtSCRALib listenForEvents:(TRANS_EVENT_START | TRANS_EVENT_OK | TRANS_EVENT_ERROR)];

    // Register for device notifications
    [self turnDeviceNotificationsOn];

    // The time (in seconds) till openDevice is called after deviceClosed is called.
    // Calling open immediately after close will create a race condition causing
    // the open to not function correctly
    //
    // This happens when registerDevice is called more than 1x and with different parameters
    // If cards are not being read correctly after this case, try increasing the delay
    openDelayAfterClose = 2.0;

    // The time (in seconds) till openDevice is called after the device connection observer
    // is triggered and removed
    //
    // This happens when registerDevice is called before a device is connected.
    // If cards are not being read correctly after this case, try increasing the delay
    openDelayAfterRemoveObserver = 3.0;
  }

  return self;
}

- (void)_destroy
{
  // This method is called from the dealloc method and is good place to
  // release any objects and memory that have been allocated for the module.

  if ([mtSCRALib isDeviceOpened]) {
    [mtSCRALib closeDevice];
  }
  [mtSCRALib clearBuffers];

  [self turnDeviceNotificationsOff];

  RELEASE_TO_NIL(mtSCRALib);
  RELEASE_TO_NIL(protocol);

  [super _destroy];
}

#pragma mark Internal Memory Management

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
  // optionally release any resources that can be dynamically
  // reloaded once memory is available - such as caches
  [super didReceiveMemoryWarning:notification];
}

#pragma mark Device

- (void)turnDeviceNotificationsOn
{
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(trackDataReady:) name:@"trackDataReadyNotification" object:nil];
  [center addObserver:self selector:@selector(devConnStatusChange) name:@"devConnectionNotification" object:nil];

  [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
}

- (void)turnDeviceNotificationsOff
{
  [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];

  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center removeObserver:self name:@"trackDataReadyNotification" object:nil];
  [center removeObserver:self name:@"devConnectionNotification" object:nil];
  if (openDeviceOnConnect) {
    [center removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
  }
}

#pragma mark Notifications

- (void)devConnStatusChange
{
  BOOL isDeviceConnected = [mtSCRALib isDeviceConnected];
  if (isDeviceConnected) {
    if ([self _hasListeners:@"connected"]) {
      NSDictionary *event = [self accessoryToDictionary];
      [self fireEvent:@"connected" withObject:event];
    }
  } else {
    if ([self _hasListeners:@"disconnected"]) {
      NSDictionary *event = [self accessoryToDictionary];
      [self fireEvent:@"disconnected" withObject:event];
    }
  }
}

- (void)trackDataReady:(NSNotification *)notification
{
  NSNumber *status = [[notification userInfo] valueForKey:@"status"];
  [self onDataEvent:status];
}

- (void)onDataEvent:(id)status
{
  switch ([status intValue]) {
  case TRANS_STATUS_OK:

    [self fireSwipeEvent];

    break;
  case TRANS_STATUS_START:

    // This should be used with caution. CPU intensive
    // tasks done after this events and before TRANS_STATUS_OK
    // may interfere with reader communication

    break;
  case TRANS_STATUS_ERROR:

    if ([self _hasListeners:@"swipeError"]) {
      [self fireEvent:@"swipeError"];
    }
    [mtSCRALib clearBuffers];

    break;
  default:
    break;
  }
}

- (void)fireSwipeEvent
{
  if (mtSCRALib != NULL) {
    if (![self trackReadSuccessful]) {
      if ([self _hasListeners:@"swipeError"]) {
        [self fireEvent:@"swipeError"];
      }
    } else {
      if ([self _hasListeners:@"swipe"]) {
        NSDictionary *event = [self swipeToDictionary];
        [self fireEvent:@"swipe" withObject:event];
      }
    }

    [mtSCRALib clearBuffers];
  }
}

- (BOOL)trackReadSuccessful
{
  // Track Decode Status. Consists of three 2-byte hex values
  // representing the decode status for tracks 1, 2, and 3 (respectively from left to right).
  // Values are:
  // 00 = Track OK
  // 01 = Track read Error
  // 02 = Track is Blank
  NSString *trackDecodeStatus = [mtSCRALib getTrackDecodeStatus];
  NSRange range = [trackDecodeStatus rangeOfString:@"01"];
  return (range.location == NSNotFound);
}

- (NSDictionary *)accessoryToDictionary
{
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [mtSCRALib getDeviceName], @"deviceName",
                                     nil];

  return dict;
}

- (NSDictionary *)swipeToDictionary
{
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [mtSCRALib getMaskedTracks], @"maskedTracks",
                                     [mtSCRALib getTrack1], @"track1",
                                     [mtSCRALib getTrack2], @"track2",
                                     [mtSCRALib getTrack3], @"track3",
                                     [mtSCRALib getTrack1Masked], @"track1Masked",
                                     [mtSCRALib getTrack2Masked], @"track2Masked",
                                     [mtSCRALib getTrack3Masked], @"track3Masked",
                                     [mtSCRALib getMagnePrint], @"magnePrint",
                                     [mtSCRALib getMagnePrintStatus], @"magnePrintStatus",
                                     [mtSCRALib getDeviceSerial], @"deviceSerial",
                                     [mtSCRALib getSessionID], @"sessionID",
                                     [mtSCRALib getKSN], @"KSN",
                                     [mtSCRALib getMagTekDeviceSerial], @"magTekDeviceSerial",
                                     [mtSCRALib getDeviceName], @"deviceName",
                                     [mtSCRALib getDeviceCaps], @"deviceCaps",
                                     [mtSCRALib getTLVVersion], @"TLVVersion",
                                     [mtSCRALib getDevicePartNumber], @"devicePartNumber",
                                     [mtSCRALib getCapMSR], @"capMSR",
                                     [mtSCRALib getCapTracks], @"capTracks",
                                     [mtSCRALib getCapMagStripeEncryption], @"capMagStripeEncryption",
                                     NUMINT([mtSCRALib getCardPANLength]), @"cardPANLength",
                                     [mtSCRALib getResponseData], @"responseData",
                                     [mtSCRALib getCardName], @"cardName",
                                     [mtSCRALib getCardIIN], @"cardIIN",
                                     [mtSCRALib getCardLast4], @"cardLast4",
                                     [mtSCRALib getCardExpDate], @"cardExpDate",
                                     [mtSCRALib getCardServiceCode], @"cardServiceCode",
                                     [mtSCRALib getCardStatus], @"cardStatus",
                                     [mtSCRALib getTrackDecodeStatus], @"trackDecodeStatus",
                                     [mtSCRALib getResponseType], @"responseType",
                                     [mtSCRALib getOperationStatus], @"operationStatus",
                                     NUMINT([mtSCRALib getBatteryLevel]), @"batteryLevel",
                                     [mtSCRALib getFirmware], @"firmware",
                                     nil];

  return dict;
}

- (void)openDeviceWithData
{
  if ((deviceType != MAGTEKAUDIOREADER) && (deviceType != MAGTEKIDYNAMO)) {
    NSLog(@"[ERROR] MagtekModule invalid 'deviceType' passed to registerDevice(), defaulting to iDynamo");
    deviceType = MAGTEKIDYNAMO;
  }

  if (!protocol && (deviceType == MAGTEKIDYNAMO)) {
    NSLog(@"[ERROR] MagtekModule 'protocol' is required when calling registerDevice()");
  }

  [mtSCRALib setDeviceType:deviceType];

  // Protocol does not need to be set if deviceType is MAGTEKAUDIOREADER
  if (deviceType == MAGTEKIDYNAMO) {
    [mtSCRALib setDeviceProtocolString:(protocol)];
  }

  if (![mtSCRALib isDeviceOpened]) {
    [self openDevice];
  }
}

- (void)openDevice
{
  EAAccessory *acc = [self accessoryForProtocol:protocol];

  // If [mtSCRALib openDevice] is called before a device is connected "trackDataReadyNotification"
  // events will not come through until the device is re-plugged in
  // Solution: wait for device to be plugged in before calling openDevice

  // Checking if device is connected
  if (acc) {
    [mtSCRALib openDevice];
    [self devConnStatusChange];

    // openDeviceCount is true if an observer is already set for EAAccessoryDidConnectNotification
    // We do not want to add more than one observer
  } else if (!openDeviceOnConnect) {

    openDeviceOnConnect = YES;
    // Listen for device connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnected:) name:EAAccessoryDidConnectNotification object:nil];
  }
}

- (void)deviceConnected:(NSNotification *)note
{
  EAAccessory *acc = [[note userInfo] objectForKey:EAAccessoryKey];

  if ([[acc protocolStrings] containsObject:protocol] && openDeviceOnConnect) {
    openDeviceOnConnect = NO;
    // Remove device connection observer (no need to call it again and it blocks the trackDataReadyNotification)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];

    // If openDevice is called directly here (without a delay) then "trackDataReadyNotification"
    // events do not alwasy come through, it works sporatically.
    [self performSelector:@selector(openDevice) withObject:nil afterDelay:openDelayAfterRemoveObserver];
  }
}

- (EAAccessory *)accessoryForProtocol:(NSString *)protocolString
{
  NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];

  for (EAAccessory *obj in accessories) {
    if ([[obj protocolStrings] containsObject:protocolString]) {
      return (obj);
    }
  }

  return nil;
}

#pragma mark Public APIs

- (void)registerDevice:(id)args
{
  ENSURE_UI_THREAD(registerDevice, args);
  ENSURE_SINGLE_ARG(args, NSDictionary);

  NSString *newProtocol = [TiUtils stringValue:@"protocol" properties:args def:nil];
  // Default to iDynamo if no deviceType set
  int newDeviceType = [TiUtils intValue:@"deviceType" properties:args def:MAGTEKIDYNAMO];

  // No need to re-open device if being called with the same params
  if (([newProtocol isEqualToString:protocol]) && (newDeviceType == deviceType)) {
    return;
  }

  // Release protocol in case app is calling this method multiple times
  RELEASE_TO_NIL(protocol);

  protocol = [newProtocol copy];
  deviceType = newDeviceType;

  if ([mtSCRALib isDeviceOpened]) {
    [mtSCRALib closeDevice];
    [mtSCRALib clearBuffers];
    // Delaying because [mtSCRALib openDevice] will fail to connect if called immediately after closeDevice
    [self performSelector:@selector(openDeviceWithData) withObject:args afterDelay:openDelayAfterClose];
  } else {
    [self openDeviceWithData];
  }
}

- (void)setOpenDelayAfterClose:(id)value
{
  openDelayAfterClose = [TiUtils floatValue:value];
}

- (void)setOpenDelayAfterRemoveObserver:(id)value
{
  openDelayAfterRemoveObserver = [TiUtils floatValue:value];
}

@end
