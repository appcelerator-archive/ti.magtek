//
//  MagTekDemoViewController.m
//  MagTekDemo
//
//  Created by MagTek  on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//

#import "MagTekDemoViewController.h"




@implementation MagTekDemoViewController



@synthesize revVersion, deviceStatus, mtSCRALib;
@synthesize scrollView,switchIDynamo,switchAudio;
@synthesize transStatus,responseData,rawResponseData;
@synthesize command;


#define PROTOCOLSTRING @"com.magtek.idynamo"
#define _DGBPRNT



- (IBAction) setIDynamoSwitch:(id)sender
{
    if(switchIDynamo.on)
    {
#ifdef _DGBPRNT        
        NSLog(@"setIDynamoSwitch:ON");
#endif        
        [mtSCRALib setDeviceType:MAGTEKIDYNAMO];
        [self openDevice];
        
    }
    else 
    {
#ifdef _DGBPRNT        
        NSLog(@"setIDynamoSwitch:OFF");
#endif        
        [self closeDevice];
    }
}
- (IBAction) setAudioSwitch:(id)sender
{
    if(switchAudio.on)
    {
#ifdef _DGBPRNT        
        NSLog(@"setAudioSwitch:ON");
#endif        
        [mtSCRALib setDeviceType:MAGTEKAUDIOREADER];
        [self openDevice];
        
    }
    else 
    {
#ifdef _DGBPRNT        
        NSLog(@"setAudioSwitch:OFF");
#endif        
        [self closeDevice];

    }
    
    
}

- (IBAction) onSendMessageToDevice:(id)sender
{
	[mtSCRALib sendCommandToDevice: self.command.text];
}


- (IBAction) onClearScreen:(id)sender
{
    [self clearLabels];
    [mtSCRALib clearBuffers];
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}
- (void)displayData
{
    if(mtSCRALib !=NULL)
    {
        if([mtSCRALib getDeviceType]==MAGTEKAUDIOREADER)
        {
            NSString * pResponse = [NSString stringWithFormat:@"Response.Type=%@\nTrack.Status=%@\nCard.Status=%@\nOperation.Status=%@\nBattery.Level=%d\nSwipe.Count=%d\nTrack.Masked: %@\nTrack1.Masked: %@\nTrack2.Masked: %@\nTrack1.Encrypted: %@\nTrack2.Encrypted: %@\nTrack3.Encrypted: %@\nMagnePrint.Encrypted: %@\nMagnePrint.Status: %@\nSessionID: %@\nCard.IIN: %@\nCard.Name: %@\nCard.Last4: %@\nCard.ExpDate: %@\nCard.SvcCode: %@\nCard.PANLength: %d\nKSN: %@\nDevice.SerialNumber: %@\nTLV.CARDIIN: %@\nMagTek SN: %@\nFirmware Part Number: %@\nTLV Version: %@\nDevice Model Name: %@\nCapability MSR: %@\nCapability Tracks: %@\nCapability Encryption: %@\n",
                                    
                                    [mtSCRALib getResponseType],
                                    [mtSCRALib getTrackDecodeStatus],
                                    [mtSCRALib getCardStatus],
                                    [mtSCRALib getOperationStatus],
                                    [mtSCRALib getBatteryLevel],
                                    [mtSCRALib getSwipeCount],
                                    [mtSCRALib getMaskedTracks],
                                    [mtSCRALib getTrack1Masked],
                                    [mtSCRALib getTrack2Masked],
                                    [mtSCRALib getTrack1],
                                    [mtSCRALib getTrack2],
                                    [mtSCRALib getTrack3],
                                    [mtSCRALib getMagnePrint],
                                    [mtSCRALib getMagnePrintStatus],
                                    [mtSCRALib getSessionID],
                                    [mtSCRALib getCardIIN],
                                    [mtSCRALib getCardName],
                                    [mtSCRALib getCardLast4],
                                    [mtSCRALib getCardExpDate],
                                    [mtSCRALib getCardServiceCode],
                                    [mtSCRALib getCardPANLength],
                                    [mtSCRALib getKSN],
                                    [mtSCRALib getDeviceSerial],
                                    [mtSCRALib getTagValue:TLV_CARDIIN],
                                    [mtSCRALib getMagTekDeviceSerial],
                                    [mtSCRALib getFirmware],
                                    [mtSCRALib getTLVVersion],
                                    [mtSCRALib getDeviceName],
                                    [mtSCRALib getCapMSR],
                                    [mtSCRALib getCapTracks],
                                    [mtSCRALib getCapMagStripeEncryption]];
            self.responseData.text =pResponse;
            self.rawResponseData.text = [mtSCRALib getResponseData];
        }
        else
        {
            NSString * pResponse = [NSString stringWithFormat:@"Track.Status=%@\nTrack.Masked: %@\nTrack1.Masked: %@\nTrack2.Masked: %@\nTrack1.Encrypted: %@\nTrack2.Encrypted: %@\nTrack3.Encrypted: %@\nCard.IIN: %@\nCard.Name: %@\nCard.Last4: %@\nCard.ExpDate: %@\nCard.SvcCode: %@\nCard.PANLength: %d\nKSN: %@\nDevice.SerialNumber: %@\nMagnePrint: %@\nMagnePrintStatus: %@\nSessionID: %@\nDevice Model Name: %@\n",
                                    [mtSCRALib getTrackDecodeStatus],
                                    [mtSCRALib getMaskedTracks],
                                    [mtSCRALib getTrack1Masked],
                                    [mtSCRALib getTrack2Masked],
                                    [mtSCRALib getTrack1],
                                    [mtSCRALib getTrack2],
                                    [mtSCRALib getTrack3],
                                    [mtSCRALib getCardIIN],
                                    [mtSCRALib getCardName],
                                    [mtSCRALib getCardLast4],
                                    [mtSCRALib getCardExpDate],
                                    [mtSCRALib getCardServiceCode],
                                    [mtSCRALib getCardPANLength],
                                    [mtSCRALib getKSN],
                                    [mtSCRALib getDeviceSerial],
                                    [mtSCRALib getMagnePrint],
                                    [mtSCRALib getMagnePrintStatus],
                                    [mtSCRALib getSessionID],
                                    [mtSCRALib getDeviceName]];
            self.responseData.text =pResponse;
            self.rawResponseData.text = [mtSCRALib getResponseData];
            
        }
        [mtSCRALib clearBuffers];

        
    }
    
}
#pragma mark  -
#pragma mark MSRAccessory

- (void)onDataEvent:(id)status
{
	switch ([status intValue]) {
        case TRANS_STATUS_OK:
            
#ifdef _DGBPRNT        
            NSLog(@"TRANS_STATUS_OK");
#endif            
            self.transStatus.text = @"Transfer Completed";
            [self displayData];
            [self closeDevice];
                 
            break;
        case TRANS_STATUS_START:
            // This should be used with caution. CPU intensive
            // tasks done after this events and before TRANS_STATUS_OK
            // may interfere with reader communication
#ifdef _DGBPRNT        
            NSLog(@"TRANS_STATUS_START");
#endif            
            self.transStatus.text = @"Transfer Started";
            break;
            
        case TRANS_STATUS_ERROR:
            
            if(mtSCRALib !=NULL)
            {
#ifdef _DGBPRNT        
                NSLog(@"TRANS_STATUS_ERROR");
#endif                
                self.transStatus.text = @"Transfer Error";
                self.deviceStatus.backgroundColor = [UIColor redColor];
                [self devConnStatusChange];        
            }
            
            
            break;
                    
        default:
            break;
    }
    
		
}

- (void) clearLabels
{
    self.command.text = @"";
    self.transStatus.text = @"";
    self.responseData.text= @"";
    self.rawResponseData.text= @"";
}

- (void) closeDevice
{
    if([mtSCRALib isDeviceOpened])
    {
        [mtSCRALib closeDevice];
    }
    [mtSCRALib clearBuffers];
    [switchIDynamo setHidden:NO];
    [switchIDynamo setOn:NO];
    [switchAudio setOn:NO];
    [switchAudio setHidden:NO];

    
    
    [self devConnStatusChange];   
    
}
- (void) openDevice
{
    if([mtSCRALib getDeviceType]==MAGTEKIDYNAMO)
    {
        [switchAudio setOn:NO  animated:YES];
        [switchAudio setHidden:YES];
        [switchIDynamo setOn:YES  animated:YES];
        
        [self.mtSCRALib setDeviceProtocolString:(PROTOCOLSTRING)]; 
        if(![mtSCRALib isDeviceOpened])
        {
            [mtSCRALib openDevice];
        }
        
    }
    else if([mtSCRALib getDeviceType]==MAGTEKAUDIOREADER)

    {
        [switchIDynamo setOn:NO animated:YES];
        [switchIDynamo setHidden:YES];
        [switchAudio setOn:YES  animated:YES];
        if(![mtSCRALib isDeviceOpened])
        {
            [mtSCRALib openDevice];
        }
        
    }
    
    [self devConnStatusChange];   
    
}
/*
- (void) stopTimer
{close
    if(gMainTimer!=NULL)
    {
        [gMainTimer invalidate];
        gMainTimer=NULL;
    }
}
- (void) startTimer
{
    gMainTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(mainTimerProc) userInfo:nil repeats:YES];
}
*/



#pragma mark -
#pragma mark ViewDidLoad, etc

- (void)trackDataReady:(NSNotification *)notification
{
    NSNumber *status = [[notification userInfo] valueForKey:@"status"];
    
    [self performSelectorOnMainThread:@selector(onDataEvent:) withObject:status waitUntilDone:NO];
}

- (void)devConnStatusChange
{
    BOOL isDeviceConnected = [self.mtSCRALib isDeviceConnected];
    BOOL isDeviceOpened = [self.mtSCRALib isDeviceOpened];
    if (isDeviceConnected)
    {
        if(isDeviceOpened)
        {
            self.deviceStatus.text = @"Device Ready";
            self.deviceStatus.backgroundColor = [UIColor greenColor];
        }
        else 
        {
            self.deviceStatus.text = @"Device Not Ready";
            self.deviceStatus.backgroundColor = [UIColor redColor];
            [switchIDynamo setHidden:NO];
            [switchIDynamo setOn:NO];
            [switchAudio setOn:NO];
            [switchAudio setHidden:NO];
        }
        
    }
    else
    {
        self.deviceStatus.text = @"Device Not Ready";
        self.deviceStatus.backgroundColor = [UIColor redColor];
        
    }
}

- (void)viewDidLoad 
{	
    MagTekDemoAppDelegate *delegate = (MagTekDemoAppDelegate *)([[UIApplication sharedApplication] delegate]);
    self.mtSCRALib = (MTSCRA *)([delegate getSCRALib]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackDataReady:) name:@"trackDataReadyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devConnStatusChange) name:@"devConnectionNotification" object:nil];
    
    
    [self devConnStatusChange];
	
	[scrollView setContentSize:CGSizeMake(320, 1000)];
	
	[self clearLabels];
	NSString * appVersionString = [[NSBundle mainBundle] 
                                   objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * revDisplay = [NSString stringWithFormat:@"App.Ver=%@,SDK.Ver=%@",appVersionString,[self.mtSCRALib getSDKVersion]];
	self.revVersion.text = revDisplay;
    
	self.command.delegate = self;
	
	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return ((interfaceOrientation == UIInterfaceOrientationPortrait)||(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [switchIDynamo release];
    switchIDynamo = nil;
    [switchAudio release];
    switchAudio = nil;
    [displayResponse release];
    displayResponse = nil;
#ifdef _DGBPRNT        
	NSLog(@"viewDidUnload");
#endif    
    rawResponseData = nil;
    self.responseData = nil;
    self.mtSCRALib = nil;
	self.deviceStatus = nil;
	self.scrollView = nil;
    self.transStatus = nil;
    self.revVersion=nil;
    
}


- (void)dealloc {
	[scrollView release];
	[deviceStatus release];
    [responseData release];
	[revVersion release];
    [mtSCRALib release];
    [transStatus release];
    [responseData release];
    [rawResponseData release];
    [displayResponse release];
    [switchAudio release];
    [switchIDynamo release];
    [super dealloc];
}

@end
