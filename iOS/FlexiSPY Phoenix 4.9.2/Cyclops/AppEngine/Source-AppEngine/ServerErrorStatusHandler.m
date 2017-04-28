//
//  ServerErrorStatusHandler.m
//  AppEngine
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerErrorStatusHandler.h"

#import "ComponentHeaders.h"

@implementation ServerErrorStatusHandler

@synthesize mLicenseManager;
@synthesize mAppEngine;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) serverStatusErrorRecieved: (DDMServerStatus) aServerStatus {
	LicenseInfo *licInfo = [mLicenseManager mCurrentLicenseInfo];
	if (aServerStatus == kDDMServerStatusLicenseExpired) {
		[licInfo setLicenseStatus:EXPIRED];
		[mLicenseManager commitLicense:licInfo];
	} else if (aServerStatus == kDDMServerStatusLicenseDisabled) {
		[licInfo setLicenseStatus:DISABLE];
		[mLicenseManager commitLicense:licInfo];
	}
}

- (void) dealloc {
	[mAppEngine release];
	[mLicenseManager release];
	[super dealloc];
}

@end
