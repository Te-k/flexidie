//
//  LicenseChangeDelegate.m
//  FeelSecure
//
//  Created by Makara Khloth on 8/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LicenseChangeDelegate.h"
#import "FeelSecureAppDelegate.h"

#import "AppEngineUICmd.h"
#import "LicenseInfo.h"
#import "ConfigurationManagerImpl.h"

@implementation LicenseChangeDelegate

@synthesize mAppDelegate;

- (id) initWithFeelSecureAppDelegate:(FeelSecureAppDelegate *)aAppDelegate {
	if ((self = [super init])) {
		[self setMAppDelegate:aAppDelegate];
	}
	return (self);
}

- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd {
	if (aCmd == kAppUI2EngineGetLicenseInfoCmd) {
		NSData *licenseData = aCmdResponse;
		
		LicenseInfo *licenseInfo = [[LicenseInfo alloc] initWithData:licenseData];
		DLog(@"License status: %d", [licenseInfo licenseStatus])
		DLog(@"License configuration id: %d", [licenseInfo configID])
		DLog(@"License activation code: %@", [licenseInfo activationCode])
		DLog(@"License MD5: %@", [licenseInfo md5])
		
		[[self mAppDelegate] setMLicenseInfo:licenseInfo];
		[[[self mAppDelegate] mConfigurationManager] updateConfigurationID:[licenseInfo configID]];
		
		// Post notification
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:aCmdResponse forKey:@"CmdResponse"];
		[userInfo setObject:[NSNumber numberWithInt:aCmd] forKey:@"Cmd"];
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:kFeelSecureLicenseChangeNotification object:self userInfo:userInfo];
		[licenseInfo release];
	}
}

- (void) dealloc {
	[super dealloc];
}

@end
