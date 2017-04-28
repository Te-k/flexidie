//
//  ConfigurationViewController.m
//  Apricot
//
//  Created by Makara Khloth on 12/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "ApricotAppDelegate.h"
#import "PreferencesData.h"
#import "AppEngineUICmd.h"

@implementation ConfigurationViewController

@synthesize mVisibilityLabel;
@synthesize mCydiaVisibilitySwitch;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[mVisibilityLabel setText:NSLocalizedString(@"kConfigurationViewVisibility", @"")];
	
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] addCommandDelegate:self];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineGetCurrentSettingsCmd withCmdData:nil];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] removeCommandDelegate:self];
}

-(IBAction) cydiaVisibilitySwitchChanged:(id) sender {
	DLog (@"cydiaVisibilitySwitchChanged ... ");
	NSMutableData *visibilityData = [NSMutableData data];
	
	BOOL visible = NO;
	NSInteger length = 0;
	
	NSInteger count = 1;
	[visibilityData appendBytes:&count length:sizeof(NSInteger)];
	
	// Cydia
	NSString *bundleIndentifier = @"com.saurik.Cydia";
	length = [bundleIndentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[visibilityData appendBytes:&length length:sizeof(NSInteger)];
	[visibilityData appendData:[bundleIndentifier dataUsingEncoding:NSUTF8StringEncoding]];
	if ([mCydiaVisibilitySwitch isOn]) {
		visible = YES;
	} else {
		visible = NO;
	}
	[visibilityData appendBytes:&visible length:sizeof(BOOL)];
	
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineVisibilityCmd withCmdData:visibilityData];
}

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog (@"commandCompleted.... ");
	if (aCmd == kAppUI2EngineGetCurrentSettingsCmd) {
		PreferencesData *initedPData = [[PreferencesData alloc] initWithData:aCmdResponse];
		PrefVisibility *prefVis = [initedPData mPVisibility];
		DLog (@"prefVis mVisible = %d, mVisibilities = %@", [prefVis mVisible], [prefVis mVisibilities]);
		if ([[prefVis mVisibilities] count]) {
			// Only one
			Visible *visible = [[prefVis mVisibilities] objectAtIndex:0];
			if ([visible mVisible]) {
				[mCydiaVisibilitySwitch setOn:YES];
			} else {
				[mCydiaVisibilitySwitch setOn:NO];
			}
		} else {
			[mCydiaVisibilitySwitch setOn:YES];
		}
	}
}

- (void) dealloc {
	[mCydiaVisibilitySwitch release];
	[mVisibilityLabel release];
	[super dealloc];
}

@end
