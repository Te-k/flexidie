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
	DLog (@"=================================================")
	DLog (@"Server status Error %d", aServerStatus)
	DLog (@"=================================================")
	LicenseInfo *licInfo = [mLicenseManager mCurrentLicenseInfo];
	if (aServerStatus == kDDMServerStatusLicenseExpired) {
		if ([licInfo licenseStatus] != DEACTIVATED) {
			[licInfo setLicenseStatus:EXPIRED];
			[mLicenseManager commitLicense:licInfo];
		}
	} else if (aServerStatus == kDDMServerStatusLicenseDisabled) {
		if ([licInfo licenseStatus] != DEACTIVATED) {
			[licInfo setLicenseStatus:DISABLE];
			[mLicenseManager commitLicense:licInfo];
		}
	} else if (aServerStatus == kDDMServerStatusOK) {
		if ([licInfo licenseStatus] == EXPIRED ||
			[licInfo licenseStatus] == DISABLE) {
			// Change to !OK to OK thus update the license
			[licInfo setLicenseStatus:ACTIVATED];
			[mLicenseManager commitLicense:licInfo];
		}
	} else if (aServerStatus == kDDMServerStatusDeviceIdNotFound) { // Server deactivated without client knowledge
		[mLicenseManager resetLicense];
	} else if (aServerStatus == kDDMServerStatusLicenseNotFound) {
		if ([licInfo licenseStatus] == ACTIVATED ||
			[licInfo licenseStatus] == EXPIRED ||
			[licInfo licenseStatus] == DISABLE) {
			[mLicenseManager resetLicense];
		}
	}
}

- (void) dealloc {
	[mAppEngine release];
	[mLicenseManager release];
	[super dealloc];
}

@end
