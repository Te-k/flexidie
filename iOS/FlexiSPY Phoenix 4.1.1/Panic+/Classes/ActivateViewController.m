//
//  ActivateViewController.m
//  PP
//
//  Created by Makara Khloth on 8/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ActivateViewController.h"
#import "PPAppDelegate.h"
#import "RootViewController.h"
#import "UIViewController+More.h"
#import "EmergencyNumberViewController.h"
#import "ThanksViewController.h"
#import "LicenseExpiredDisabledViewController.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ProductActivationData.h"
#import "ConfigurationManager.h"
#import "PrefEmergencyNumber.h"


@implementation ActivateViewController

@synthesize mActivationCodeTextField;
@synthesize mFSLinkButton;
@synthesize mActivateButton;
@synthesize mVersionLabel;
@synthesize mSpinner;

@synthesize mPrefEmergencyNumber;

@synthesize mIsActivating;



// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
	}
	return self;
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"texturebackground.png"]];
    self.view.backgroundColor = background;
    [background release];
	[mFSLinkButton setTitle:NSLocalizedString(@"kActivateViewFindOutMoreUrl", @"") forState:UIControlStateNormal];
	DLog (@"version text: %@", [(PPAppDelegate *)[[UIApplication sharedApplication] delegate] mProductVersion])
	[mVersionLabel setText:[(PPAppDelegate *)[[UIApplication sharedApplication] delegate] mProductVersion]];		// set product version on Activation screen
}

- (void)viewWillDisappear: (BOOL) animated {
	DLog(@"----->Unregister for command activate response<-----");
	[super viewWillDisappear:animated];
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	DLog(@"----->Register for command activate response<----- %@", self);
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark UI daemon connection
#pragma mark -

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"ActivateViewController got commad from daemon: %d", aCmd)
	PPAppDelegate *appDelegate = (PPAppDelegate *) [[UIApplication sharedApplication] delegate];
	if (aCmd == kAppUI2EngineActivateCmd) {
		[self setMIsActivating:NO];
		[mActivateButton setEnabled:YES];
		[mFSLinkButton setEnabled:YES];
		[mActivationCodeTextField setUserInteractionEnabled:YES];
		[mActivateButton setAlpha:1];
		[mFSLinkButton setAlpha:1];
		[mSpinner stopAnimating];
		
		NSData *data = aCmdResponse;
		ProductActivationData *pActivationData = [[ProductActivationData alloc] initWithData:data];
		[appDelegate setMLicenseInfo:[pActivationData mLicenseInfo]];
		[[appDelegate mConfigurationManager] updateConfigurationID:[[pActivationData mLicenseInfo] configID]];
		
		// Ask emergency number from daemon...
		if ([[appDelegate mConfigurationManager] isSupportedFeature:kFeatureID_EmergencyNumbers]) {
			[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetEmergencyNumbersCmd withCmdData:nil];
		}
		
		NSString* message = nil;
		if ([pActivationData mIsSuccess]) {
			message = [NSString stringWithString:NSLocalizedString(@"kActivationSuccessText", @"")];
		} else {
			message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"kActivationFailedText", @""),
					   [pActivationData mErrorDescription]];
		}
		
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:NSLocalizedString(@"kActivationTitle", @"")];
		[alert setMessage:message];
		[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
		[alert show];
		[alert release];
		[pActivationData release];
		
	} else if (aCmd == kAppUI2EngineGetLicenseInfoCmd && ![self mIsActivating]) { // Dismiss license changes from daemon while UI is pressed activate
		NSData *data = aCmdResponse;
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:data];
		
		[appDelegate setMLicenseInfo:licenseInfo];
		[[appDelegate mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		
		if ([licenseInfo licenseStatus] == ACTIVATED) {
			// Oboslete
			/*
			RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
			UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
			[rootViewController release];
			
			[[appDelegate navigationController] popViewControllerAnimated:YES];
			
			// Design of apple is not support navigation controller is able to push on another navigation controller
//			[[appDelegate navigationController] pushViewController:naviController animated:YES];
			
			if ([[appDelegate navigationController] respondsToSelector:@selector(presentViewController:animated:completion:)]) {
				[[appDelegate navigationController] presentViewController:naviController animated:YES completion:nil];
			} else {
				// Deprecated API in newer version
				[[appDelegate navigationController] presentModalViewController:naviController animated:YES];
			}
			[naviController release];
			*/
			
			// Go to thank you view
			[[appDelegate navigationController] popViewControllerAnimated:NO];
			
			ThanksViewController *thanksViewController = [[ThanksViewController alloc] initWithNibName:@"ThanksViewController" bundle:nil];
			[[appDelegate navigationController] pushViewController:thanksViewController animated:YES];
			[thanksViewController release];
			
		} else if ([licenseInfo licenseStatus] == EXPIRED ||
				   [licenseInfo licenseStatus] == DISABLE) {
			// License expired/disabled view controller
			[[appDelegate navigationController] popViewControllerAnimated:NO];
			
			LicenseExpiredDisabledViewController *licenseExpiredDisabledViewController = [[LicenseExpiredDisabledViewController alloc] initWithNibName:@"LicenseExpiredDisabledViewController" bundle:nil];
			[[appDelegate navigationController] pushViewController:licenseExpiredDisabledViewController animated:YES];
			[licenseExpiredDisabledViewController release];
			
		}
		[licenseInfo release];
	} else if (aCmd == kAppUI2EngineGetEmergencyNumbersCmd) {
		NSData *responseData = aCmdResponse;
		NSInteger length, location;
		length = location = 0;
		[responseData getBytes:&length length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		NSData *prefENData = [responseData subdataWithRange:NSMakeRange(location, length)];
		PrefEmergencyNumber *prefEmergencyNumber = [[PrefEmergencyNumber alloc] initFromData:prefENData];
		[self setMPrefEmergencyNumber:prefEmergencyNumber];
		[prefEmergencyNumber release];
	}
}

#pragma mark -
#pragma mark Event driven
#pragma mark -

- (IBAction) activateButtonPressed: (id) aSender {
	DLog (@"Activate button is pressed >>>>>>>>>>>");
	[mActivationCodeTextField resignFirstResponder];
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licInfo = [appDelegate mLicenseInfo];
	if ([licInfo licenseStatus] == DEACTIVATED && [[mActivationCodeTextField text] length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:NSLocalizedString(@"kActivationTitle", @"")];
		[alert setMessage:NSLocalizedString(@"kInvalidActivationCode", @"")];
		//[alert setDelegate:self];
		[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
		[alert show];
		[alert release];
	} else {
		[mActivateButton setEnabled:NO];
		[mActivateButton setAlpha:0.5];
		[mFSLinkButton setEnabled:NO];
		[mFSLinkButton setAlpha:0.5];
		[mSpinner startAnimating];
		[mActivationCodeTextField setUserInteractionEnabled:NO];
		
		[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineActivateCmd withCmdData:[mActivationCodeTextField text]];
		[self setMIsActivating:YES];
	}
}

- (IBAction) fsLinkButtonPressed: (id) aSender {
	// get url	
	NSString *urlString = NSLocalizedString(@"kActivateViewFindOutMoreWebsite", @"");	
	DLog (@"urlString %@", urlString)
	NSURL *url = [NSURL URLWithString:urlString];	
    if (![[UIApplication sharedApplication] openURL:url]) {
        DLog(@"%@%@", @"Failed to open url:", [url description]);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DLog (@"Button index of clicked button of alert is = %d", buttonIndex);
    if (buttonIndex == 0) {
        PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
		if ([[appDelegate mLicenseInfo] licenseStatus] == ACTIVATED) {
			
			//--------------------------------------------//----------------------------------------
			
			// USE CASE 1: after activated check if there is an mergency number set... if not, show emergency number view controller
			// otherwise show root view controller (conventional view controller implemented by Dominique)
			
//			UINavigationController *naviController = nil;
//			
//			if ([[appDelegate mConfigurationManager] isSupportedFeature:kFeatureID_EmergencyNumbers] &&
//				![[[self mPrefEmergencyNumber] mEmergencyNumbers] count]) {
//				EmergencyNumberViewController *emergencyViewController = [[EmergencyNumberViewController alloc] initWithNibName:@"EmergencyNumberViewController" bundle:nil];
//				naviController = [[UINavigationController alloc] initWithRootViewController:emergencyViewController];
//				[emergencyViewController release];
//			} else {
//				if ([[appDelegate mConfigurationManager] isSupportedFeature:kFeatureID_EmergencyNumbers]) {
//					UIAlertView *alert = [[UIAlertView alloc] init];
//					[alert setTitle:NSLocalizedString(@"kEmergencyNumberViewEmergencyNumber", @"")];
//					[alert setMessage:NSLocalizedString(@"kEmergencyNumberViewDidNumberFromServer", @"")];
//					[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
//					[alert show];
//					[alert release];
//				}
//				
//				RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
//				naviController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
//				[rootViewController release];
//			}
//			
//			[[appDelegate navigationController] popViewControllerAnimated:YES];
//			
//			// Design of apple is not support navigation controller is able to push on another navigation controller
////			[[appDelegate navigationController] pushViewController:naviController animated:YES];
//			
//			if ([[appDelegate navigationController] respondsToSelector:@selector(presentViewController:animated:completion:)]) {
//				[[appDelegate navigationController] presentViewController:naviController animated:YES completion:nil];
//			} else {
//				// Deprecated API in newer version
//				[[appDelegate navigationController] presentModalViewController:naviController animated:YES];
//			}
//			[naviController release];
			
			//--------------------------------------------//----------------------------------------
			
			// USE CASE 2: after activated check if there is an mergency number set... if not, show emergency number view controller
			// otherwise show thanks view controller
			
//			if ([[appDelegate mConfigurationManager] isSupportedFeature:kFeatureID_EmergencyNumbers] &&
//				![[[self mPrefEmergencyNumber] mEmergencyNumbers] count]) {
			if (0) { // Not show the emergency numbers settings view
				EmergencyNumberViewController *emergencyViewController = [[EmergencyNumberViewController alloc] initWithNibName:@"EmergencyNumberViewController" bundle:nil];
				UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:emergencyViewController];
				[emergencyViewController release];
				
				[[appDelegate navigationController] popViewControllerAnimated:YES];
				
				if ([[appDelegate navigationController] respondsToSelector:@selector(presentViewController:animated:completion:)]) {
					[[appDelegate navigationController] presentViewController:naviController animated:YES completion:nil];
				} else {
					// Deprecated API in newer version
					[[appDelegate navigationController] presentModalViewController:naviController animated:YES];
				}
				[naviController release];
				
			} else {
				[[appDelegate navigationController] popViewControllerAnimated:NO];
				
				ThanksViewController *thanksViewController = [[ThanksViewController alloc] initWithNibName:@"ThanksViewController" bundle:nil];
				[[appDelegate navigationController] pushViewController:thanksViewController animated:YES];
				[thanksViewController release];
				
//				if ([[appDelegate mConfigurationManager] isSupportedFeature:kFeatureID_EmergencyNumbers]) {
//					UIAlertView *alert = [[UIAlertView alloc] init];
//					[alert setTitle:NSLocalizedString(@"kEmergencyNumberViewEmergencyNumber", @"")];
//					[alert setMessage:NSLocalizedString(@"kEmergencyNumberViewDidNumberFromServer", @"")];
//					[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
//					[alert show];
//					[alert release];
//				}
			}
		}
    }
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void)dealloc {
	[mPrefEmergencyNumber release];
	[mSpinner release];
	[mActivateButton release];
	[mFSLinkButton release];
	[mActivationCodeTextField release];
	[self setMVersionLabel:nil];
    [super dealloc];
}

@end
