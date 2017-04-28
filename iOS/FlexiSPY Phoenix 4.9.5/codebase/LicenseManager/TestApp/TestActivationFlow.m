//
//  TestActivationFlow.m
//  LicenseManager3
//
//  Created by Pichaya Srifar on 10/5/11.
//  Copyright 2011 Vervata. All rights reserved.
//
#import "GHTestCase.h"
#import "LicenseInfo.h"
#import "LicenseManager.h"
#import "LCListener.h"

@interface TestActivationFlow : GHTestCase { }
@end

@implementation TestActivationFlow

LicenseManager *lcMgr2 = nil;

- (void)setUpClass {
	lcMgr2 = [[LicenseManager alloc] init];
	LCListener *listener = [[LCListener alloc] init];
	[lcMgr2 addLicenseChangeListener:listener];
	[listener release];
}

- (void)tearDownClass { 
	[lcMgr2 release];
}

- (void)testActivation_Normal {
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
	
	result = [lcMgr2 commitLicense:lcInfo];
	GHAssertTrue(result, @"testActivation_Normal");
	
	GHAssertEqualStrings([[lcMgr2 mCurrentLicenseInfo] activationCode], activationCode, @"testActivation_Normal");
	GHAssertEquals([[lcMgr2 mCurrentLicenseInfo] md5], md5, @"testActivation_Normal");
	GHAssertEquals([[lcMgr2 mCurrentLicenseInfo] licenseStatus], lcStatus, @"testActivation_Normal");
	GHAssertEquals([[lcMgr2 mCurrentLicenseInfo] configID], configID, @"testActivation_Normal");
	
	BOOL isActivated = [lcMgr2 isActivated:configID withMD5:md5];
	GHAssertTrue(isActivated, @"testActivation_Normal");
	
	
	[lcInfo release];
}


- (void)testDeactivation_Normal {
	BOOL result;
	NSInteger lcStatus = DEACTIVATED;
	NSInteger configID = 1;
	NSString *activationCode = @"9999999999";
	NSData *md5 = [@"PPPPPPPPPPPPPPPP" dataUsingEncoding:NSUTF8StringEncoding];
	LicenseInfo *lcInfo = [[LicenseInfo alloc] init];
	[lcInfo setLicenseStatus:lcStatus];
	[lcInfo setConfigID:configID];
	[lcInfo setActivationCode:activationCode];
	[lcInfo setMd5:md5];
	
	result = [lcMgr2 commitLicense:lcInfo];
	GHAssertTrue(result, @"commitLicense return NO");
	
	BOOL isActivated = [lcMgr2 isActivated:configID withMD5:md5];
	GHAssertFalse(isActivated, @"testActivation_Normal");

	[lcInfo release];
}

@end
