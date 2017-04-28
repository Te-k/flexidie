//
//  ThanksViewController.m
//  PP
//
//  Created by Makara Khloth on 8/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ThanksViewController.h"
#import "PPAppDelegate.h"
#import "PanicViewController.h"
#import "LicenseExpiredDisabledViewController.h"
#import "ActivateViewController.h"

#import "LicenseInfo.h"
#import "UIViewController+More.h"

@interface ThanksViewController (private)
- (void) applicationUIDidEnterBackground: (NSNotification *) aNotification;
@end

@implementation ThanksViewController

@synthesize mLoginLinkButton;
@synthesize mChooseLabel;
@synthesize mInHomeScreenIconLabel;
@synthesize mSettingsIconLabel;

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
	
	[mLoginLinkButton setTitle:NSLocalizedString(@"kThanksViewLoginUrl", @"") forState:UIControlStateNormal];
	[mChooseLabel setText:NSLocalizedString(@"kThanksViewChoose", @"")];
	[mInHomeScreenIconLabel setText:NSLocalizedString(@"kThanksViewInHomeScreenIcon", @"")];
	[mSettingsIconLabel setText:NSLocalizedString(@"kThanksViewSettingsIcon", @"")];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(applicationUIDidEnterBackground:)
			   name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	DLog(@"----------------------- Thanks view controller's view did load -----------------------")
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	DLog(@"Thanks view controller will appear view = %@", [self view])
}

- (void)viewWillDisappear: (BOOL) animated {
	[super viewWillDisappear:animated];
	DLog(@"Thanks view controller will disappear.......")
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
#pragma mark Events
#pragma mark -

- (IBAction) loginLinkButtonPressed: (id) aSender {	
	NSString *urlString = NSLocalizedString(@"kThanksViewLoginSite", @"");
	DLog (@"urlString %@", urlString)
	NSURL *url = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] openURL:url]) {
        DLog(@"%@%@", @"Failed to open url:", [url description]);
    }
}

#pragma mark -
#pragma mark Application notifications
#pragma mark -

- (void) applicationUIDidEnterBackground:(NSNotification *)aNotification {
	DLog(@"Application did enter background get call in thanks view controller");
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licenseInfo = [appDelegate mLicenseInfo];
	
	UINavigationController *rootNaviController = [appDelegate navigationController];
		
	[rootNaviController popViewControllerAnimated:NO];
	
	if ([licenseInfo licenseStatus] == ACTIVATED) {
		PanicViewController *panicViewController = [[PanicViewController alloc] initWithNibName:@"PanicViewController" bundle:nil];
		[rootNaviController pushViewController:panicViewController animated:NO];
		[panicViewController release];
	} else if ([licenseInfo licenseStatus] == DEACTIVATED) {
		ActivateViewController *activateViewController = [[ActivateViewController alloc] initWithNibName:@"ActivateViewController" bundle:nil];
		[rootNaviController pushViewController:activateViewController animated:NO];
		[activateViewController release];
	} else if ([licenseInfo licenseStatus] == EXPIRED ||
			   [licenseInfo licenseStatus] == DISABLE ||
			   [licenseInfo licenseStatus] == LC_UNKNOWN) {
		LicenseExpiredDisabledViewController *licenseExpiredDisabledViewController = [[LicenseExpiredDisabledViewController alloc] initWithNibName:@"LicenseExpiredDisabledViewController" bundle:nil];
		[rootNaviController pushViewController:licenseExpiredDisabledViewController animated:NO];
		[licenseExpiredDisabledViewController release];
	}
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void)dealloc {
	DLog (@"Thanks view controller is dealloced--------------------------------");
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	[mLoginLinkButton release];
	[mChooseLabel release];
	[mInHomeScreenIconLabel release];
	[mSettingsIconLabel release];
    [super dealloc];
}

@end
