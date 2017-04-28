//
//  LibTest.m
//  LicenseManager3
//
//  Created by Pichaya Srifar on 10/5/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#define DEBUG_NO
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#import "GHTestCase.h"
#import "LicenseManager.h"
#import "LicenseInfo.h"
#import "LCListener.h"
#import <stdlib.h>
#import <time.h>
#import "Util.h"

@interface LibTest : GHTestCase { }
@end

@implementation LibTest

LicenseManager *lcMgr = nil;
LCListener *listener = nil;

- (void)setUp { 
}

- (void)tearDown {
}

- (void)setUpClass {
	lcMgr = [[LicenseManager alloc] init];
	listener = [[LCListener alloc] init];
	LCListener *listener1;
	LCListener *listener2;
	listener1 = [[LCListener alloc] init];
	listener2 = [[LCListener alloc] init];
	[lcMgr addLicenseChangeListener:listener];
	[lcMgr addLicenseChangeListener:listener1];
	[lcMgr addLicenseChangeListener:listener2];
	[listener1 release];
	[listener2 release];
}

- (void)tearDownClass { 
	[listener release];
	[lcMgr release];
}

- (void)testInit {
	LicenseManager *tmp = [[LicenseManager alloc] init];
	DLog(@"licenseStatus %d", [[tmp mCurrentLicenseInfo] licenseStatus]);
	DLog(@"configID %d", [[tmp mCurrentLicenseInfo] configID]);
	DLog(@"md5 %@", [[tmp mCurrentLicenseInfo] md5]);
	DLog(@"activationCode %@", [[tmp mCurrentLicenseInfo] activationCode]);
	[tmp release];
}

- (void)testCommitLicense_Normal {
	BOOL result;
	NSInteger lcStatus = ACTIVATED;
	NSInteger configID = 1;
	NSString *activationCode = @"9999999999";
	NSData *md5 = [@"PPPPPPPPPPPPPPPP" dataUsingEncoding:NSUTF8StringEncoding];
	
	LicenseInfo *lcInfo = [[LicenseInfo alloc] init];
	[lcInfo setLicenseStatus:lcStatus];
	[lcInfo setConfigID:configID];
	[lcInfo setActivationCode:activationCode];
	[lcInfo setMd5:md5];
	
	result = [lcMgr commitLicense:lcInfo];
	GHAssertTrue(result, @"Normal");
	
	GHAssertEqualStrings([[lcMgr mCurrentLicenseInfo] activationCode], activationCode, @"Normal");
	GHAssertEquals([[lcMgr mCurrentLicenseInfo] md5], md5, @"Normal");
	GHAssertEquals([[lcMgr mCurrentLicenseInfo] licenseStatus], lcStatus, @"Normal");
	GHAssertEquals([[lcMgr mCurrentLicenseInfo] configID], configID, @"Normal");
	
	[lcInfo release];
}

- (void)testCommitLicense_Nil {
	BOOL result;
	NSInteger lcStatus = ACTIVATED;
	NSInteger configID = 1;
	NSString *activationCode = @"9999999999";
	NSData *md5 = [@"PPPPPPPPPPPPPPPP" dataUsingEncoding:NSUTF8StringEncoding];
	
	LicenseInfo *lcInfo = [[LicenseInfo alloc] init];		
	[lcInfo setLicenseStatus:lcStatus];
	[lcInfo setConfigID:configID];
	[lcInfo setActivationCode:nil];
	[lcInfo setMd5:md5];
	result = [lcMgr commitLicense:lcInfo];
	GHAssertFalse(result, @"Nil");
	
	[lcInfo setLicenseStatus:lcStatus];
	[lcInfo setConfigID:configID];
	[lcInfo setActivationCode:activationCode];
	[lcInfo setMd5:nil];
	result = [lcMgr commitLicense:lcInfo];
	GHAssertFalse(result, @"Nil");
	[lcInfo release];
}

- (void)testCommitLicense_Stress {
	BOOL result;
	NSInteger lcStatus = ACTIVATED;
	NSInteger configID = 1;
	
	NSString *activationCode;
	NSData *md5;

	
	for (int i=0; i<100; i++) {
		lcStatus = arc4random() % 5;
		configID = arc4random() % 10000;
		activationCode = [Util generateRandomString:arc4random() % 257];
		NSString *md5Str = [Util generateRandomString:16];
		md5 = [md5Str dataUsingEncoding:NSUTF8StringEncoding];
		
		DLog(@"%d %d %@ %@", lcStatus, configID, activationCode, md5Str);
		LicenseInfo *lcInfo = [[LicenseInfo alloc] init];
		[lcInfo setLicenseStatus:lcStatus];
		[lcInfo setConfigID:configID];
		[lcInfo setActivationCode:activationCode];
		[lcInfo setMd5:md5];
		result = [lcMgr commitLicense:lcInfo];
		GHAssertTrue(result, @"commitLicense return NO");
		
		GHAssertEqualStrings([[lcMgr mCurrentLicenseInfo] activationCode], activationCode, @"Normal");
		GHAssertEquals([[lcMgr mCurrentLicenseInfo] md5], md5, @"Normal");
		GHAssertEquals([[lcMgr mCurrentLicenseInfo] licenseStatus], lcStatus, @"Normal");
		GHAssertEquals([[lcMgr mCurrentLicenseInfo] configID], configID, @"Normal");
		
		[lcInfo release];
	}
}

- (void)testCommitLicense_Boundary {
	BOOL result;
	NSInteger lcStatus = ACTIVATED;
	NSInteger configID = 1;
	
	NSString *activationCodeNil = nil;
	NSString *activationCode0 = @"";
	NSString *activationCode256 = @"11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
	
	NSData *md5 = [@"PPPPPPPPPPPPPPPP" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *md5Len19 = [@"PPPPPPPPPPPPPPPPXXX" dataUsingEncoding:NSUTF8StringEncoding];
	
	LicenseInfo *lcInfo = [[LicenseInfo alloc] init];
	[lcInfo setLicenseStatus:lcStatus];
	[lcInfo setConfigID:configID];
	[lcInfo setActivationCode:activationCodeNil];
	[lcInfo setMd5:md5];
	result = [lcMgr commitLicense:lcInfo];
	GHAssertFalse(result, @"commitLicense");
	
	
	[lcInfo setLicenseStatus:lcStatus];
	[lcInfo setConfigID:configID];
	[lcInfo setActivationCode:activationCode0];
	[lcInfo setMd5:md5];
	result = [lcMgr commitLicense:lcInfo];
	GHAssertTrue(result, @"commitLicense");
	
	
	[lcInfo setLicenseStatus:ACTIVATED];
	[lcInfo setConfigID:1];
	[lcInfo setActivationCode:activationCode256];
	[lcInfo setMd5:md5];
	result = [lcMgr commitLicense:lcInfo];
	GHAssertTrue(result, @"commitLicense");
	
	
	[lcInfo setLicenseStatus:ACTIVATED];
	[lcInfo setConfigID:1];
	[lcInfo setActivationCode:activationCode256];
	[lcInfo setMd5:md5Len19];
	result = [lcMgr commitLicense:lcInfo];
	GHAssertFalse(result, @"commitLicense");
	
	GHAssertEquals([[[lcMgr mCurrentLicenseInfo] activationCode] length], [activationCode256 length], @"Boundary");
	[lcInfo release];
}

- (void)testCommitLicense_EXPECTED {
	BOOL result;
	LicenseInfo *lcInfo = [[LicenseInfo alloc] init];
	[lcInfo setLicenseStatus:0];
	[lcInfo setConfigID:8123];
	[lcInfo setActivationCode:@"lM48oIzFkbnflqPHVtylzoGjgZM3oIIxiCvwaUZlTbo4r1zakXmHbSOhIq8UWGi58Br7mfg3gsYxjnxr9HY8oAgUQcCCJIvFaNAkQGdWW1h5dCma888myc4cfwDM5Yf5zGffagZX86Q9x19vZ7FmazmdVPPOCUH1oK5pRUaNPQMcFJvtG0FEpPH8vmLV5"];
	[lcInfo setMd5:[@"lM48oIzFkbnflqPH" dataUsingEncoding:NSUTF8StringEncoding]];
	
	result = [lcMgr commitLicense:lcInfo];
	GHAssertTrue(result, @"commitLicense return NO");
	[lcInfo release];
}

@end
