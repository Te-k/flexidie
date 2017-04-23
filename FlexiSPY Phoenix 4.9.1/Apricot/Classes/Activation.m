//
//  Activation.m
//  Apricot
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Activation.h"
#import "ApricotAppDelegate.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ProductActivationData.h"
#import "ConfigurationManager.h"

//static NSString *kDeactivateButtonText			= @"Deactivate";
//static NSString *kDeactivateLabelText			= @"Press Deactivate";
//static NSString *kActivateButtonText			= @"Activate";
//static NSString *kActivateLabelText				= @"Enter Activation Code then press Activate";
//
//static NSString *kActivationSuccessText			= @"Activation success!";
//static NSString *kDeactivationSuccessText		= @"Deactivation success!";
//static NSString *kActivationFailedText			= @"Activation failed!";
//static NSString *kDeactivationFailedText		= @"Deactivation failed!";

@implementation Activation

@synthesize mActivationCode,mActivationURL, mActivate,mDismiss;
@synthesize mActivateLabel;
@synthesize mSpinner;

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
- (IBAction) dismissKeyboard { 
	[mActivationCode resignFirstResponder];
	[mActivationURL resignFirstResponder];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"-->Enter<--")
	
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	
	//delegate method for url textfield
	self.mActivationURL.delegate = self;
	
	LicenseInfo *licInfo = [appDelegate mLicenseInfo];
	if ([licInfo licenseStatus] == DEACTIVATED) {
	} else {
		[mActivate setTitle:NSLocalizedString(@"kDeactivateButtonText", @"") forState:UIControlStateNormal];
		[mActivationCode setText:[licInfo activationCode]];
		[mActivationCode setUserInteractionEnabled:NO];
		[mActivationURL setUserInteractionEnabled:NO];
		[mActivationURL setHidden:YES];
		[mActivateLabel setText:NSLocalizedString(@"kDeactivateLabelText", @"")];
	}
}

//delegate method for url textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [mActivationURL resignFirstResponder];
    return NO;
}

- (void)viewWillDisappear: (BOOL) animated {
	DLog(@"----->Enter<-----")
	[super viewWillDisappear:animated];
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog(@"aCmd: %d", aCmd)
	if (aCmd == kAppUI2EngineDeactivateCmd || aCmd == kAppUI2EngineActivateCmd || aCmd == kAppUI2EngineActivateURLCmd) {
		[mActivate setEnabled:YES];
		[mActivate setAlpha:1];
		[mSpinner stopAnimating];
		
		NSData *data = aCmdResponse;
		ProductActivationData *pActivationData = [[ProductActivationData alloc] initWithData:data];
		ApricotAppDelegate *appDelegate = (ApricotAppDelegate *) [[UIApplication sharedApplication] delegate];
		[appDelegate setMLicenseInfo:[pActivationData mLicenseInfo]];
		[[appDelegate mConfigurationManager] updateConfigurationID:[[pActivationData mLicenseInfo] configID]];
		NSString* message = nil;
		NSString *title = nil;
		if ([pActivationData mIsSuccess]) {
			if (aCmd == kAppUI2EngineActivateCmd || aCmd == kAppUI2EngineActivateURLCmd) {
				title = [NSString stringWithString:NSLocalizedString(@"kActivationTitle", @"")];
				// Change UI texts
				[mActivate setTitle:NSLocalizedString(@"kDeactivateButtonText", @"") forState:UIControlStateNormal];
				[mActivationCode setUserInteractionEnabled:NO];
				[mActivationURL setUserInteractionEnabled:NO];
				[mActivationURL setHidden:YES];
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
				[mActivationURL setUserInteractionEnabled:YES];
				[mActivationURL setHidden:NO];
				[mActivateLabel setText:NSLocalizedString(@"kActivateLabelText", @"")];
				
				[[self navigationItem] setTitle:NSLocalizedString(@"kMainViewActivate", @"")];
				//self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"kUnknownTitle", @"");
				
				message = [NSString stringWithString:NSLocalizedString(@"kDeactivationSuccessText", @"")];
			}
		} else {
			if (aCmd == kAppUI2EngineActivateCmd || aCmd == kAppUI2EngineActivateURLCmd) {
				[mActivationCode setUserInteractionEnabled:YES];
				[mActivationURL setUserInteractionEnabled:YES];
				[mActivationURL setHidden:NO];
				message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"kActivationFailedText", @""), [pActivationData mErrorDescription]];
			} else {
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
	[mActivationURL release];
	[mDismiss release];
	[mActivate release];
    [super dealloc];
}

-(IBAction) activate:(id) sender {
	// If deactivate make sure to ask confirmation
	[mActivationCode resignFirstResponder];
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licInfo = [appDelegate mLicenseInfo];  
	
	if ([licInfo licenseStatus] == DEACTIVATED											&&
		([[mActivationCode text] length] == 0 || ![self verifyURL:[mActivationURL text]])) {
		if (![self verifyURL:[mActivationURL text]]) {
			UIAlertView *alert = [[UIAlertView alloc] init];
			[alert setTitle:NSLocalizedString(@"kActivationTitle", @"")];
			[alert setMessage:NSLocalizedString(@"kInvalidActivationURL", @"")];
			[alert setDelegate:self];
			[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
			[alert show];
			[alert release];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] init];
			[alert setTitle:NSLocalizedString(@"kActivationTitle", @"")];
			[alert setMessage:NSLocalizedString(@"kInvalidActivationCode", @"")];
			[alert setDelegate:self];
			[alert addButtonWithTitle:NSLocalizedString(@"kOkButtonTitle", @"")];
			[alert show];
			[alert release];
		}
	} else {
		[mActivate setEnabled:NO];
		[mActivate setAlpha:0.5];
		[mSpinner startAnimating];
		
		NSString *activationCode = [mActivationCode text];
		NSString *url = [mActivationURL text];
		
		NSArray *objects = [NSArray arrayWithObjects:activationCode, url, nil];
		NSArray *objectKeys = [NSArray arrayWithObjects:@"activationCode", @"url", nil];
		
		NSDictionary *activationInfo = [NSDictionary dictionaryWithObjects:objects forKeys:objectKeys];
		
		NSInteger command = kAppUI2EngineActivateURLCmd;
		if ([licInfo licenseStatus] == ACTIVATED ||
			[licInfo licenseStatus] == EXPIRED ||
			[licInfo licenseStatus] == DISABLE) {
			command = kAppUI2EngineDeactivateCmd;
		} else {
			[mActivationCode setUserInteractionEnabled:NO];
			[mActivationURL setUserInteractionEnabled:NO];
		}
		
		[[appDelegate mAppUIConnection] processCommand:command withCmdData:activationInfo];
	}
}

- (BOOL)verifyURL:(NSString *)aUrl{
	//NSString *urlRegEx =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
	NSString *urlRegEx =@"((mailto\\:|(news|(ht|f)tp(s?))\\://){1}\\S+)";
	NSPredicate *urlCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx]; 
	return [urlCheck evaluateWithObject:aUrl];
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//	DLog (@"Button index of clicked button of alert is = %d", buttonIndex);
//    if (buttonIndex == 0) {
//      FlexiSPYAppDelegate *appDelegate = (FlexiSPYAppDelegate *)[[UIApplication sharedApplication] delegate];
//		if ([[appDelegate mLicenseInfo] licenseStatus] == DEACTIVATED) {
//			[[self navigationController] popViewControllerAnimated:YES];
//		}
//	}
//}

@end
