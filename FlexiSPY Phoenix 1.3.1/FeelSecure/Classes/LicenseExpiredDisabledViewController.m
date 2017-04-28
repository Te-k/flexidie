//
//  LicenseExpiredDisabledViewController.m
//  FeelSecure
//
//  Created by Makara Khloth on 8/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LicenseExpiredDisabledViewController.h"
#import "FeelSecureAppDelegate.h"
#import "RootViewController.h"
#import "UIViewController+More.h"
#import	"ActivateViewController.h"
#import "PanicViewController.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ProductActivationData.h"
#import "ConfigurationManager.h"


static NSString* const kLanguagePath			= @"/Applications/ssmp.app/Language-english.plist";
static NSString* const kWFURL					= @"wfurl";


@implementation LicenseExpiredDisabledViewController

@synthesize mLicenseExiredLabel;
@synthesize mFindoutFeaturesLabel;
@synthesize mFSLinkButton;
@synthesize mRenewLicenseLinkButton;

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
	
	FeelSecureAppDelegate *fsAppDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licInfo = [fsAppDelegate mLicenseInfo];
	NSString *text = nil;
	if ([licInfo licenseStatus] == EXPIRED) {
		text = NSLocalizedString(@"kLicenseExpiredDisabledViewLicenseExpired", @"");
		[mRenewLicenseLinkButton setEnabled:YES];
		[mRenewLicenseLinkButton setHidden:NO];
	} else if ([licInfo licenseStatus] == DISABLE) {
		text = NSLocalizedString(@"kLicenseExpiredDisabledViewLicenseDisabled", @"");
		[mRenewLicenseLinkButton setEnabled:NO];
		[mRenewLicenseLinkButton setHidden:YES];
	}
	[mLicenseExiredLabel setText:text];
	[mFSLinkButton setTitle:NSLocalizedString(@"kActivateViewFindOutMoreUrl", @"") forState:UIControlStateNormal];
}

- (void)viewWillDisappear: (BOOL) animated {
	DLog(@"----->Unregister for command activate response<-----");
	[super viewWillDisappear:animated];
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	DLog(@"----->Register for command activate response<----- %@", self);
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	DLog(@"---------- LicenseExpiredDisabledViewController got commad from daemon: %d", aCmd)
	FeelSecureAppDelegate *appDelegate = (FeelSecureAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	if (aCmd == kAppUI2EngineGetLicenseInfoCmd) {
		NSData *data = aCmdResponse;
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:data];
		
		[appDelegate setMLicenseInfo:licenseInfo];
		[[appDelegate mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		
		if ([licenseInfo licenseStatus] == ACTIVATED) {
			// USE CASE 1:
//			RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
//			UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
//			[rootViewController release];
//			
//			[[appDelegate navigationController] popViewControllerAnimated:YES];
//			
//			// Design of apple is not support navigation controller is able to push on another navigation controller
//			//			[[appDelegate navigationController] pushViewController:naviController animated:YES];
//			
//			if ([[appDelegate navigationController] respondsToSelector:@selector(presentViewController:animated:completion:)]) {
//				[[appDelegate navigationController] presentViewController:naviController animated:YES completion:nil];
//			} else {
//				// Deprecated API in newer version
//				[[appDelegate navigationController] presentModalViewController:naviController animated:YES];
//			}
//			[naviController release];
			
			// USE CASE 2:
			UINavigationController *navigationController = [appDelegate navigationController];
			PanicViewController *panicViewController = [[PanicViewController alloc] initWithNibName:@"PanicViewController" bundle:nil];
			[navigationController popViewControllerAnimated:NO];
			[navigationController pushViewController:panicViewController animated:YES];
			[panicViewController release];
			
		} else if ([licenseInfo licenseStatus] == DEACTIVATED) {
			UINavigationController *navigationController = [appDelegate navigationController];
			ActivateViewController *activateViewController = [[ActivateViewController alloc] initWithNibName:@"ActivateViewController" bundle:nil];
			[navigationController popViewControllerAnimated:NO];
			[navigationController pushViewController:activateViewController animated:YES];
			[activateViewController release];
		}
		[licenseInfo release];
	}
}

#pragma mark -
#pragma mark Event driven
#pragma mark -

- (IBAction) renewLicenseButtonPressed: (id) aSender {
	// get url
	NSDictionary *languageResources = [NSDictionary dictionaryWithContentsOfFile:kLanguagePath];	
	NSString *urlString = @"";
	urlString = [languageResources objectForKey:kWFURL];	
	DLog (@"urlString %@", urlString)
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] openURL:url]) {
        DLog(@"%@%@", @"Failed to open url:", [url description]);
    }
}

- (IBAction) fsLinkButtonPressed: (id) aSender {
	// get url
	NSDictionary *languageResources = [NSDictionary dictionaryWithContentsOfFile:kLanguagePath];	
	NSString *urlString = @"";
	urlString = [languageResources objectForKey:kWFURL];	
	DLog (@"urlString %@", urlString)
	NSURL *url = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] openURL:url]) {
        DLog(@"%@%@", @"Failed to open url:", [url description]);
    }
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void)dealloc {
	[mLicenseExiredLabel release];
	[mFindoutFeaturesLabel release];
	[mFSLinkButton release];
	[mRenewLicenseLinkButton release];
    [super dealloc];
}

@end
