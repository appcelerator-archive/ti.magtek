//
//  MagTekDemoViewController.m
//  MagTekDemo
//
//  Created by MagTek on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//

#import "MTSCRA.h"
#import "MagTekDemoViewController.h"
#import "MediaPlayer/MPMusicPlayerController.h"

@interface MagTekDemoViewController () <UITextFieldDelegate, UIApplicationDelegate, NSStreamDelegate>

#pragma mark -
#pragma mark MTSCRA Property
#pragma mark -

@property (nonatomic, strong) MTSCRA *mtSCRALib;

#pragma mark -
#pragma mark UILabel Properties
#pragma mark -

@property (nonatomic, strong) IBOutlet UILabel *revVersion;
@property (nonatomic, strong) IBOutlet UILabel *transStatus;
@property (nonatomic, strong) IBOutlet UILabel *deviceStatus;

#pragma mark -
#pragma mark UISwitch Properties
#pragma mark -

@property (nonatomic, strong) IBOutlet UISwitch *switchAudio;
@property (nonatomic, strong) IBOutlet UISwitch *switchIDynamo;

#pragma mark -
#pragma mark UITextField Property
#pragma mark -

@property (nonatomic, strong) IBOutlet UITextField *command;

#pragma mark -
#pragma mark UITextView Properties
#pragma mark -

@property (nonatomic, strong) IBOutlet UITextView *responseData;
@property (nonatomic, strong) IBOutlet UITextView *rawResponseData;

#pragma mark -
#pragma mark UIScrollView Property
#pragma mark -

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

#pragma mark -
#pragma mark MPVolumeView Property
#pragma mark -

@property (nonatomic, strong)  MPVolumeView *myVolumeView;

#pragma mark -
#pragma mark UISlider Property
#pragma mark -

@property (nonatomic, strong) UISlider *volumeSlider;

#pragma mark -
#pragma mark IBAction Methods
#pragma mark -

- (IBAction)onClearScreen:(id)sender;
- (IBAction)setAudioSwitch:(id)sender;
- (IBAction)setIDynamoSwitch:(id)sender;
- (IBAction)onSendMessageToDevice:(id)sender;

#pragma mark -
#pragma mark UITextField Delegate Method
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField;

#pragma mark -
#pragma mark Helper Methods
#pragma mark -

- (void)clearLabels;
- (void)displayData;
- (void)devConnStatusChange;

@end

@implementation MagTekDemoViewController

#define PROTOCOLSTRING @"com.magtek.idynamo"

#pragma mark -
#pragma mark View Lifecycle
#pragma mark -

- (void)viewDidLoad
{
    MagTekDemoAppDelegate *delegate = (MagTekDemoAppDelegate *)([[UIApplication sharedApplication] delegate]);
    self.mtSCRALib                  = (MTSCRA *)([delegate getSCRALib]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackDataReady:)
                                                 name:@"trackDataReadyNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devConnStatusChange)
                                                 name:@"devConnectionNotification"
                                               object:nil];
    
    
    [self.scrollView setContentSize:CGSizeMake(320, 680)];
    
    [self updateConnStatus];
    
	[self clearLabels];
    
	NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *revDisplay       = [NSString stringWithFormat:@"App.Ver=%@,"
                                                             "SDK.Ver=%@",
                                                              appVersionString,
                                                              [self.mtSCRALib getSDKVersion]];
    
    [self.revVersion setText:revDisplay];
    
    [self.command setDelegate:self];
    
    [[self command] setText:@"C10206C20503840900"];
    
	[super viewDidLoad];
}

- (void)viewDidUnload
{
#ifdef _DGBPRNT
	NSLog(@"viewDidUnload");
#endif
    
    [self setCommand:nil];
    [self setMtSCRALib:nil];
    [self setScrollView:nil];
    [self setRevVersion:nil];
    [self setTransStatus:nil];
    [self setSwitchAudio:nil];
    [self setDeviceStatus:nil];
    [self setResponseData:nil];
    [self setResponseData:nil];
    [self setSwitchIDynamo:nil];
    [self setRawResponseData:nil];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationPortrait)||
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark -
#pragma mark IBAction Methods
#pragma mark -

- (IBAction)onClearScreen:(id)sender
{
    [self clearLabels];
    
    [self.mtSCRALib clearBuffers];
}

- (IBAction)setAudioSwitch:(id)sender
{
    if(self.switchAudio.on)
    {
#ifdef _DGBPRNT
        NSLog(@"setAudioSwitch:ON");
#endif
        
        [self.mtSCRALib setDeviceType:MAGTEKAUDIOREADER];
        [self openDevice];
    }
    else
    {
#ifdef _DGBPRNT
        NSLog(@"setAudioSwitch:OFF");
#endif
        
        [self closeDevice];
        self.myVolumeView = nil;
    }
}

- (IBAction)setIDynamoSwitch:(id)sender
{
    if(self.switchIDynamo.on)
    {
#ifdef _DGBPRNT
        NSLog(@"setIDynamoSwitch:ON");
#endif
        
        [self.mtSCRALib setDeviceType:MAGTEKIDYNAMO];
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

- (IBAction)onSendMessageToDevice:(id)sender
{
	[self.mtSCRALib sendCommandToDevice:self.command.text];
}

#pragma mark -
#pragma mark UITextField Delegate Method
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark Helper Methods
#pragma mark -

- (void)openDevice
{
    if([self.mtSCRALib getDeviceType] == MAGTEKIDYNAMO)
    {
        [self.mtSCRALib setDeviceProtocolString:(PROTOCOLSTRING)];
        
        if(![self.mtSCRALib isDeviceOpened])
        {
            [self.mtSCRALib openDevice];
        }
    }
    else if([self.mtSCRALib getDeviceType] == MAGTEKAUDIOREADER)
    {
        if(![self.mtSCRALib isDeviceOpened])
        {
            [self.mtSCRALib openDevice];
        }
    }
    
    [self updateConnStatus];
}

- (void)closeDevice
{
    if([self.mtSCRALib isDeviceOpened])
    {
        [self.mtSCRALib closeDevice];
    }
    
    [self.mtSCRALib clearBuffers];
    
    [self updateConnStatus];
}

- (void)clearLabels
{
    [self.command         setText:@""];
    [self.transStatus     setText:@""];
    [self.responseData    setText:@""];
    [self.rawResponseData setText:@""];
}

- (void)displayData
{
    if(self.self.mtSCRALib != NULL)
    {
        if([self.mtSCRALib getDeviceType] == MAGTEKAUDIOREADER)
        {
            NSString *pResponse = [NSString stringWithFormat:@"Response.Type: %@\n"
                                                               "Track.Status: %@\n"
                                                               "Card.Status: %@\n"
                                                               "Encryption.Status: %@\n"
                                                               "Battery.Level: %ld\n"
                                                               "Swipe.Count: %ld\n"
                                                               "Track.Masked: %@\n"
                                                               "Track1.Masked: %@\n"
                                                               "Track2.Masked: %@\n"
                                                               "Track3.Masked: %@\n"
                                                               "Track1.Encrypted: %@\n"
                                                               "Track2.Encrypted: %@\n"
                                                               "Track3.Encrypted: %@\n"
                                                               "MagnePrint.Encrypted: %@\n"
                                                               "MagnePrint.Status: %@\n"
                                                               "SessionID: %@\n"
                                                               "Card.IIN: %@\n"
                                                               "Card.Name: %@\n"
                                                               "Card.Last4: %@\n"
                                                               "Card.ExpDate: %@\n"
                                                               "Card.SvcCode: %@\n"
                                                               "Card.PANLength: %d\n"
                                                               "KSN: %@\n"
                                                               "Device.SerialNumber: %@\n"
                                                               "TLV.CARDIIN: %@\n"
                                                               "MagTek SN: %@\n"
                                                               "Firmware Part Number: %@\n"
                                                               "TLV Version: %@\n"
                                                               "Device Model Name: %@\n"
                                                               "Capability MSR: %@\n"
                                                               "Capability Tracks: %@\n"
                                                               "Capability Encryption: %@\n",
                                                               [self.mtSCRALib getResponseType],
                                                               [self.mtSCRALib getTrackDecodeStatus],
                                                               [self.mtSCRALib getCardStatus],
                                                               [self.mtSCRALib getEncryptionStatus],
                                                               [self.mtSCRALib getBatteryLevel],
                                                               [self.mtSCRALib getSwipeCount],
                                                               [self.mtSCRALib getMaskedTracks],
                                                               [self.mtSCRALib getTrack1Masked],
                                                               [self.mtSCRALib getTrack2Masked],
                                                               [self.mtSCRALib getTrack3Masked],
                                                               [self.mtSCRALib getTrack1],
                                                               [self.mtSCRALib getTrack2],
                                                               [self.mtSCRALib getTrack3],
                                                               [self.mtSCRALib getMagnePrint],
                                                               [self.mtSCRALib getMagnePrintStatus],
                                                               [self.mtSCRALib getSessionID],
                                                               [self.mtSCRALib getCardIIN],
                                                               [self.mtSCRALib getCardName],
                                                               [self.mtSCRALib getCardLast4],
                                                               [self.mtSCRALib getCardExpDate],
                                                               [self.mtSCRALib getCardServiceCode],
                                                               [self.mtSCRALib getCardPANLength],
                                                               [self.mtSCRALib getKSN],
                                                               [self.mtSCRALib getDeviceSerial],
                                                               [self.mtSCRALib getTagValue:TLV_CARDIIN],
                                                               [self.mtSCRALib getMagTekDeviceSerial],
                                                               [self.mtSCRALib getFirmware],
                                                               [self.mtSCRALib getTLVVersion],
                                                               [self.mtSCRALib getDeviceName],
                                                               [self.mtSCRALib getCapMSR],
                                                               [self.mtSCRALib getCapTracks],
                                                               [self.mtSCRALib getCapMagStripeEncryption]];
            
            [self.responseData    setText:pResponse];
            [self.rawResponseData setText:[self.mtSCRALib getResponseData]];
        }
        else
        {
            NSString * pResponse = [NSString stringWithFormat:@"Track.Status: %@\n"
                                                                "Encryption.Status: %@\n"
                                                                "Track.Masked: %@\n"
                                                                "Track1.Masked: %@\n"
                                                                "Track2.Masked: %@\n"
                                                                "Track3.Masked: %@\n"
                                                                "Track1.Encrypted: %@\n"
                                                                "Track2.Encrypted: %@\n"
                                                                "Track3.Encrypted: %@\n"
                                                                "Card.IIN: %@\n"
                                                                "Card.Name: %@\n"
                                                                "Card.Last4: %@\n"
                                                                "Card.ExpDate: %@\n"
                                                                "Card.SvcCode: %@\n"
                                                                "Card.PANLength: %d\n"
                                                                "KSN: %@\n"
                                                                "Device.SerialNumber: %@\n"
                                                                "MagnePrint: %@\n"
                                                                "MagnePrintStatus: %@\n"
                                                                "SessionID: %@\n"
                                                                "Device Model Name: %@\n",
                                                                [self.mtSCRALib getTrackDecodeStatus],
                                                                [self.mtSCRALib getEncryptionStatus],
                                                                [self.mtSCRALib getMaskedTracks],
                                                                [self.mtSCRALib getTrack1Masked],
                                                                [self.mtSCRALib getTrack2Masked],
                                                                [self.mtSCRALib getTrack3Masked],
                                                                [self.mtSCRALib getTrack1],
                                                                [self.mtSCRALib getTrack2],
                                                                [self.mtSCRALib getTrack3],
                                                                [self.mtSCRALib getCardIIN],
                                                                [self.mtSCRALib getCardName],
                                                                [self.mtSCRALib getCardLast4],
                                                                [self.mtSCRALib getCardExpDate],
                                                                [self.mtSCRALib getCardServiceCode],
                                                                [self.mtSCRALib getCardPANLength],
                                                                [self.mtSCRALib getKSN],
                                                                [self.mtSCRALib getDeviceSerial],
                                                                [self.mtSCRALib getMagnePrint],
                                                                [self.mtSCRALib getMagnePrintStatus],
                                                                [self.mtSCRALib getSessionID],
                                                                [self.mtSCRALib getDeviceName]];
            
            [self.responseData    setText:pResponse];
            [self.rawResponseData setText:[self.mtSCRALib getResponseData]];
        }
        
        [self.mtSCRALib clearBuffers];
    }
}

#pragma mark -
#pragma mark Post Notification Selector Methods
#pragma mark -

- (void)trackDataReady:(NSNotification *)notification
{
    NSNumber *status = [[notification userInfo] valueForKey:@"status"];
    
    [self performSelectorOnMainThread:@selector(onDataEvent:)
                           withObject:status
                        waitUntilDone:NO];
}

- (void)devConnStatusChange
{
#ifdef _DGBPRNT
    NSLog(@"******* devConnStatusChange *******");
#endif
  
    // Ensure that updateConnStatus is performed on the Main Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self updateConnStatus];
        
    });
}

- (void)handleVolumeChanged:(id)sender
{
    self.volumeSlider.value = 1.0f;
}

#pragma mark -
#pragma mark Post Notification Selector Helper Methods
#pragma mark -

- (void)onDataEvent:(id)status
{
#ifdef _DGBPRNT
    NSLog(@"onDataEvent: %i", [status intValue]);
#endif
    
	switch ([status intValue])
    {
        case TRANS_STATUS_OK:
        {
            BOOL bTrackError = NO;
            
            [self.transStatus setText:@"Transfer Completed"];
            
            NSString *pstrTrackDecodeStatus = [self.mtSCRALib getTrackDecodeStatus];
            
            [self displayData];
            
            @try
            {
                if(pstrTrackDecodeStatus)
                {
                    if(pstrTrackDecodeStatus.length >= 6)
                    {
#ifdef _DGBPRNT
                        NSString *pStrTrack1Status = [pstrTrackDecodeStatus substringWithRange:NSMakeRange(0, 2)];
                        NSString *pStrTrack2Status = [pstrTrackDecodeStatus substringWithRange:NSMakeRange(2, 2)];
                        NSString *pStrTrack3Status = [pstrTrackDecodeStatus substringWithRange:NSMakeRange(4, 2)];
                        
                        if(pStrTrack1Status && pStrTrack2Status && pStrTrack3Status)
                        {
                            if([pStrTrack1Status compare:@"01"] == NSOrderedSame)
                            {
                                bTrackError=YES;
                            }
                            
                            if([pStrTrack2Status compare:@"01"] == NSOrderedSame)
                            {
                                bTrackError=YES;
                                
                            }
                            
                            if([pStrTrack3Status compare:@"01"] == NSOrderedSame)
                            {
                                bTrackError=YES;
                                
                            }
                            
                            NSLog(@"Track1.Status=%@",pStrTrack1Status);
                            NSLog(@"Track2.Status=%@",pStrTrack2Status);
                            NSLog(@"Track3.Status=%@",pStrTrack3Status);
                        }
#endif
                    }
                }
                
            }
            @catch(NSException *e)
            {
            }
            
            if(bTrackError == NO)
            {
                //[self closeDevice];
            }
            
            break;
            
        }
        case TRANS_STATUS_START:
            
            /*
             *
             *  NOTE: TRANS_STATUS_START should be used with caution. CPU intensive tasks done after this events and before
             *        TRANS_STATUS_OK may interfere with reader communication.
             *
             */
            
#ifdef _DGBPRNT
            NSLog(@"TRANS_STATUS_START");
#endif
            
            [self.transStatus setText:@"Transfer Started"];
            
            break;
            
        case TRANS_STATUS_ERROR:
            
            if(self.mtSCRALib != NULL)
            {
#ifdef _DGBPRNT
                NSLog(@"TRANS_STATUS_ERROR");
#endif
                
                [self.transStatus setText:@"Transfer Error"];
                
                [self.deviceStatus setBackgroundColor:[UIColor redColor]];
                
                [self updateConnStatus];
            }
            
            break;
            
        default:
            
            break;
    }
}

- (void)updateConnStatus
{
#ifdef _DGBPRNT
    NSLog(@"updateConnStatus");
#endif
    
    BOOL isDeviceOpened    = [self.mtSCRALib isDeviceOpened];
    BOOL isDeviceConnected = [self.mtSCRALib isDeviceConnected];

    if(isDeviceConnected)
    {
        if(isDeviceOpened)
        {
            [self.responseData setText:@"Connected"];
            [self.rawResponseData setText:@""];
            
            [self.deviceStatus setText:@"Device Ready"];
            [self.deviceStatus setBackgroundColor:[UIColor greenColor]];
            
            if([self.mtSCRALib getDeviceType] == MAGTEKIDYNAMO)
            {
                [self.switchAudio setHidden:YES];
                
                [self.switchAudio setOn:NO
                               animated:YES];
                
                [self.switchIDynamo setOn:YES
                                 animated:YES];
            }
            else if([self.mtSCRALib getDeviceType] == MAGTEKAUDIOREADER)
            {
                [self.switchIDynamo setHidden:YES];
                
                [self.switchIDynamo setOn:NO
                                 animated:YES];
                
                [self.switchAudio setOn:YES
                               animated:YES];
                //depricated
               // MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
               // [musicPlayer setVolume:1];
                
                //new implementation - work around
                [self createAndDisplayMPVolumeView];
            }
        }
        else
        {
            [self.deviceStatus setText:@"Device Not Ready"];
            [self.deviceStatus setBackgroundColor:[UIColor redColor]];
            
            
            [self.switchAudio setOn:NO];
            [self.switchAudio setHidden:NO];
            
            [self.switchIDynamo setOn:NO];
            [self.switchIDynamo setHidden:NO];
        }
    }
    else
    {
        [self.responseData setText:@"Disconnected"];
        
        [self.deviceStatus setText:@"Device Not Ready"];
        [self.deviceStatus setBackgroundColor:[UIColor redColor]];
        
        [self.switchAudio setOn:NO];
        [self.switchAudio setHidden:NO];
        
        [self.switchIDynamo setOn:NO];
        [self.switchIDynamo setHidden:NO];
        
        [self.mtSCRALib closeDevice];
        
        self.volumeSlider.value = 0.5f;
    }
}

#pragma mark -
#pragma mark MPVolume Helper Method
#pragma mark -

- (void)createAndDisplayMPVolumeView
{
    // Create a simple holding UIView and give it a frame
    UIView *volumeHolder = [[UIView alloc] initWithFrame: CGRectMake(30, 200, 260, 20)];
    
    // set the UIView backgroundColor to clear.
    [volumeHolder setBackgroundColor: [UIColor clearColor]];
    
    // add the holding view as a subView of the main view
    [self.view addSubview: volumeHolder];
    
    // Create an instance of MPVolumeView and give it a frame
    self.myVolumeView = [[MPVolumeView alloc] initWithFrame: volumeHolder.bounds];
    
    self.myVolumeView.showsRouteButton = NO; //no showing
    self.myVolumeView.showsVolumeSlider = NO;
    
    // Add volumeHolder as a subView of the volumeHolder
    [volumeHolder addSubview: self.myVolumeView];
    
    
    self.volumeSlider = [[UISlider alloc] init];
    
    [[self.myVolumeView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if([obj isKindOfClass:[UISlider class]])
         {
             self.volumeSlider = obj;
             
             *stop = YES;
         }
     }];
    
    [self.volumeSlider addTarget:self
                          action:@selector(handleVolumeChanged:)
                forControlEvents:UIControlEventValueChanged];
}

@end