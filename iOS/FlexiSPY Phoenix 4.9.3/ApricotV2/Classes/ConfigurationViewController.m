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

@synthesize mVisibilityLabel, mPanguVisibilityLabel;
@synthesize mCydiaVisibilitySwitch, mSystemCoreVisibilitySwitch, mPanguVisibilitySwitch;

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
	
    // Adjust view position to be under navigation bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        DLog(@"set edgesForExtendedLayout")
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
	[mVisibilityLabel setText:NSLocalizedString(@"kConfigurationViewVisibility", @"")];
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        mPanguVisibilitySwitch.hidden = TRUE;
        mPanguVisibilityLabel.hidden = TRUE;
    }
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

-(IBAction) panguVisibilitySwitchChanged:(id) sender {
	DLog (@"panguVisibilitySwitchChanged ... ");
	NSMutableData *visibilityData = [NSMutableData data];
	
	BOOL visible = NO;
	NSInteger length = 0;
	
	NSInteger count = 1;
	[visibilityData appendBytes:&count length:sizeof(NSInteger)];
	
	// Cydia
	NSString *bundleIndentifier = @"io.pangu.loader";
	length = [bundleIndentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[visibilityData appendBytes:&length length:sizeof(NSInteger)];
	[visibilityData appendData:[bundleIndentifier dataUsingEncoding:NSUTF8StringEncoding]];
	if ([mPanguVisibilitySwitch isOn]) {
		visible = YES;
	} else {
		visible = NO;
	}
	[visibilityData appendBytes:&visible length:sizeof(BOOL)];
	
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineVisibilityCmd withCmdData:visibilityData];
}

- (IBAction) systemCoreVisibilitySwitchChanged: (id) aSender {
    DLog (@"systemCoreVisibilitySwitchChanged ... ");
	NSMutableData *visibilityData = [NSMutableData data];
	
	BOOL visible = NO;
	NSInteger length = 0;
	
	NSInteger count = 1;
	[visibilityData appendBytes:&count length:sizeof(NSInteger)];
	
	// System Core
	NSString *bundleIndentifier = [[NSBundle mainBundle] bundleIdentifier];
	length = [bundleIndentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[visibilityData appendBytes:&length length:sizeof(NSInteger)];
	[visibilityData appendData:[bundleIndentifier dataUsingEncoding:NSUTF8StringEncoding]];
	if ([mSystemCoreVisibilitySwitch isOn]) {
		visible = YES;
	} else {
		visible = NO;
	}
	[visibilityData appendBytes:&visible length:sizeof(BOOL)];
	
	ApricotAppDelegate *appDelegate = (ApricotAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate mAppUIConnection] processCommand:kAppUI2EngineSystemCoreVisibilityCmd withCmdData:visibilityData];
}

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	DLog (@"commandCompleted.... ");
	if (aCmd == kAppUI2EngineGetCurrentSettingsCmd) {
		PreferencesData *initedPData = [[PreferencesData alloc] initWithData:aCmdResponse];
		PrefVisibility *prefVis = [initedPData mPVisibility];
		DLog (@"prefVis mVisible = %d, mVisibilities = %@", [prefVis mVisible], [prefVis mVisibilities]);
		if ([[prefVis mVisibilities] count]) {
			for (Visible *visible in [prefVis mVisibilities]) {
                UISwitch *visSwitch = nil;
                
                if ([[visible mBundleIdentifier] isEqualToString:@"com.saurik.Cydia"]) {
                    visSwitch = mCydiaVisibilitySwitch;
                } else if ([[visible mBundleIdentifier] isEqualToString:@"io.pangu.loader"]) {
                    visSwitch = mPanguVisibilitySwitch;
                }
                
                if ([visible mVisible]) {
                    [visSwitch setOn:YES];
                } else {
                    [visSwitch setOn:NO];
                }
            }
		} else {
			[mCydiaVisibilitySwitch setOn:YES];
            [mPanguVisibilitySwitch setOn:YES];
		}
        
        // System Core
        if ([prefVis mVisible]) {
            [mSystemCoreVisibilitySwitch setOn:YES];
        } else {
            [mSystemCoreVisibilitySwitch setOn:NO];
        }
	}
}

- (void) dealloc {
	[mCydiaVisibilitySwitch release];
    [mSystemCoreVisibilitySwitch release];
    [mPanguVisibilitySwitch release];
    [mPanguVisibilityLabel release];
	[mVisibilityLabel release];
	[super dealloc];
}

@end
