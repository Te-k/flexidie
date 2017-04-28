//
//  AdvancedSettingsLockViewController.m
//  PP
//
//  Created by Makara Khloth on 9/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvancedSettingsLockViewController.h"
#import "PPAppDelegate.h"
#import "PanicViewController.h"
#import "LicenseExpiredDisabledViewController.h"
#import "ActivateViewController.h"
#import "RootViewController.h"

#import "LicenseInfo.h"
#import "UIViewController+More.h"

@interface AdvancedSettingsLockViewController (private)
- (void) applicationUIDidEnterBackground:(NSNotification *)aNotification;
@end

@implementation AdvancedSettingsLockViewController

@synthesize mACNotMatchLabel;
@synthesize mGoButton;
@synthesize mACTextField;

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
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(applicationUIDidEnterBackground:)
			   name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	DLog(@"----------------------- Advanced settings lock view controller's view did load -----------------------")
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	DLog(@"Advanced settings lock view controller will appear view = %@", [self view])
}

- (void)viewWillDisappear: (BOOL) animated {
	[super viewWillDisappear:animated];
	DLog(@"Advanced settings lock view controller will disappear.......")
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

- (IBAction) goButtonPressed: (id) aSender {
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licenseInfo = [appDelegate mLicenseInfo];
	
	NSString *text = [mACTextField text];
	if (text && [text isEqualToString:[licenseInfo activationCode]]) {
		UINavigationController *rootNaviController = [appDelegate navigationController];
		[rootNaviController dismissModalViewControllerAnimated:NO];
		
		RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
		UINavigationController *naviViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
		[rootViewController release];
		
		if ([rootNaviController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
			[rootNaviController presentViewController:naviViewController animated:YES completion:nil];
		} else {
			// Deprecated API in newer version
			[rootNaviController presentModalViewController:naviViewController animated:YES];
		}
		[naviViewController release];
		
	} else {
		NSString *notMatch = NSLocalizedString(@"kAdvancedSettingsLockViewACNotMatch", @"");
		[mACNotMatchLabel setText:notMatch];
	}
}

#pragma mark -
#pragma mark Application notifications
#pragma mark -

- (void) applicationUIDidEnterBackground:(NSNotification *)aNotification {
	DLog(@"Application did enter background get call in advanced settings lock view controller");
	PPAppDelegate *appDelegate = (PPAppDelegate *)[[UIApplication sharedApplication] delegate];
	LicenseInfo *licenseInfo = [appDelegate mLicenseInfo];
	
	UINavigationController *rootNaviController = [appDelegate navigationController];
	
	//[rootNaviController popViewControllerAnimated:NO];
	[rootNaviController dismissModalViewControllerAnimated:NO];
	
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

- (void) dealloc {
	DLog (@"Advanced settings lock view controller is dealloced--------------------------------");
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	[mACNotMatchLabel release];
	[mGoButton release];
	[mACTextField release];
	[super dealloc];
}

@end
