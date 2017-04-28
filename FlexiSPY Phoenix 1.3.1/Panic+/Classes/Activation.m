//
//  Activation.m
//  PP
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Activation.h"
#import "PPAppDelegate.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ProductActivationData.h"
#import "ConfigurationManager.h"

@implementation Activation

@synthesize mActivationCode, mActivate;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"-->Enter<--")
	
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	if (aCmd == kAppUI2EngineDeactivateCmd || aCmd == kAppUI2EngineActivateCmd) {
		[mActivate setEnabled:YES];
		[mActivate setAlpha:1];
		[mSpinner stopAnimating];
		
		NSData *data = aCmdResponse;
		ProductActivationData *pActivationData = [[ProductActivationData alloc] initWithData:data];
		PPAppDelegate *appDelegate = (PPAppDelegate *) [[UIApplication sharedApplication] delegate];
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
				
				message = [NSString stringWithString:NSLocalizedString(@"kActivationSuccessText", @"")];
			} else {
				title = [NSString stringWithString:NSLocalizedString(@"kDeactivationTitle", @"")];
				// Change UI texts
				[mActivate setTitle:NSLocalizedString(@"kActivateButtonText", @"") forState:UIControlStateNormal];
				[mActivationCode setUserInteractionEnabled:YES];
				[mActivateLabel setText:NSLocalizedString(@"kActivateLabelText", @"")];
				
				message = [NSString stringWithString:NSLocalizedString(@"kDeactivationSuccessText", @"")];
			}
		} else {
			if (aCmd == kAppUI2EngineActivateCmd) {
				[mActivationCode setUserInteractionEnabled:YES];
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
	[mActivate release];
    [super dealloc];
}

-(IBAction) activate:(id) sender {
	// If deactivate make sure to ask confirmation
	[mActivationCode resignFirstResponder];
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	DLog (@"Button index of clicked button of alert is = %d", buttonIndex);
    if (buttonIndex == 0) {
        PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
		if ([[appDelegate mLicenseInfo] licenseStatus] == DEACTIVATED) {
			[[self navigationController] popViewControllerAnimated:YES];
		}
	}
}

@end
