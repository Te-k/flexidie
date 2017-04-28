//
//  DemoViewController.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandDelegate.h"


@class CommandServiceManager;

@interface DemoViewController : UIViewController <CommandDelegate> {
	CommandServiceManager *CSM;
	UIScrollView *scrollView;
}

@property (nonatomic, assign) CommandServiceManager *CSM;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;

-(IBAction)activateButtonTouched:(id)sender;
-(IBAction)deactivateButtonTouched:(id)sender;
-(IBAction)heartBeatButtonTouched:(id)sender;
-(IBAction)addressBookTouched:(id)sender;
-(IBAction)addressBookForApprovalTouched:(id)sender;

-(IBAction)callLogTouched:(id)sender;
-(IBAction)emailTouched:(id)sender;
-(IBAction)IMTouched:(id)sender;
-(IBAction)MMSLogTouched:(id)sender;
-(IBAction)SMSLogTouched:(id)sender;

-(IBAction)panicOnTouched:(id)sender;
-(IBAction)panicOffTouched:(id)sender;
-(IBAction)PanicImageTouched:(id)sender;
-(IBAction)PanicLocationTouched:(id)sender;
-(IBAction)AlertLocationTouched:(id)sender;

-(IBAction)WallpaperTouched:(id)sender;
-(IBAction)WallpaperTNTouched:(id)sender;
-(IBAction)CameraImageTouched:(id)sender;
-(IBAction)CameraImageTNTouched:(id)sender;
-(IBAction)AudioConversationTouched:(id)sender;
-(IBAction)AudioConversationTNTouched:(id)sender;
-(IBAction)AudioTouched:(id)sender;
-(IBAction)AudioTNTouched:(id)sender;
-(IBAction)VideoTouched:(id)sender;
-(IBAction)VideoTNTouched:(id)sender;

-(IBAction)debugEventTouched:(id)sender;
-(IBAction)locationTouched:(id)sender;
-(IBAction)settingTouched:(id)sender;
-(IBAction)systemTouched:(id)sender;

#pragma mark -
#pragma mark Get Command

-(IBAction)CSIDTouched:(id)sender;
-(IBAction)timeTouched:(id)sender;
-(IBAction)processProfileTouched:(id)sender;
-(IBAction)commuDirectiveTouched:(id)sender;
-(IBAction)configTouched:(id)sender;
-(IBAction)activationCodeTouched:(id)sender;
-(IBAction)getAddressBookTouched:(id)sender;
-(IBAction)incompatibleAppTouched:(id)sender;

#pragma mark -
#pragma mark ResumeRequest

- (IBAction) resumeTouched:(id)sender;
- (IBAction) cancelTouched:(id)sender;

@end
