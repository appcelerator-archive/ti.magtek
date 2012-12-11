//
//  MagTekDemoViewController.h
//  MagTekDemo
//
//  Created by MagTek  on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "MagTekDemoAppDelegate.h"


@interface MagTekDemoViewController : UIViewController <UITextFieldDelegate, UIApplicationDelegate, NSStreamDelegate> 
{	
	UILabel *deviceStatus;
	EAAccessory *acc;
	UIScrollView *scrollView;
    UILabel *revVersion;
    UILabel *transStatus;
    IBOutlet UISwitch *switchIDynamo;
    IBOutlet UISwitch *switchAudio;
	UITextField *command;
    IBOutlet UITextView *responseData;
    IBOutlet UITextView *rawResponseData;
    IBOutlet UIButton *displayResponse;
	MTSCRA *mtSCRALib;
}

@property (nonatomic, retain) IBOutlet UITextField *command;
@property (nonatomic, retain) IBOutlet UILabel *deviceStatus;
@property (nonatomic, retain) IBOutlet UILabel *transStatus;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextView *responseData;
@property (nonatomic, retain) IBOutlet UITextView *rawResponseData;
@property (nonatomic, retain) IBOutlet UISwitch *switchIDynamo;
@property (nonatomic, retain) IBOutlet UISwitch *switchAudio;

@property (nonatomic, retain) MTSCRA *mtSCRALib;


@property (nonatomic, retain) IBOutlet UILabel *revVersion;


- (IBAction) onSendMessageToDevice:(id)sender;
- (IBAction) onClearScreen:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)aTextField;
- (IBAction) setIDynamoSwitch:(id)sender;
- (IBAction) setAudioSwitch:(id)sender;

- (void) clearLabels;
- (void) openDevice;
- (void) closeDevice;
- (void) displayData;
- (void) devConnStatusChange;


@end

