/** 
 - Project name: UnitTestApp
 - Class name: PrefDeviceLockTestCase
 - Version: 1.0
 - Purpose: Test PrefDeviceLock class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefDeviceLock.h"

@interface PrefDeviceLockTestCase : GHTestCase {
@private
	PrefDeviceLock *mPrefDeviceLock;
	PrefDeviceLock *mTestedPrefDeviceLock;
	NSData *mPrefDeviceLockData;
}
@end

@implementation PrefDeviceLockTestCase

- (void) setUp {
	mPrefDeviceLock = [[PrefDeviceLock alloc] init];
	[mPrefDeviceLock setMEnableAlertSound:YES];
	[mPrefDeviceLock setMDeviceLockMessage:@"lock"];
	[mPrefDeviceLock setMLocationInterval:10];

	// convert instance var to data
	mPrefDeviceLockData = [[mPrefDeviceLock toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPrefDeviceLock = [[PrefDeviceLock alloc] initFromData:mPrefDeviceLockData];
	
	GHAssertEquals([mPrefDeviceLock mEnableAlertSound], [mTestedPrefDeviceLock mEnableAlertSound], @"mEnableAlertSound should be YES");
	GHAssertEqualStrings([mPrefDeviceLock mDeviceLockMessage], [mTestedPrefDeviceLock mDeviceLockMessage], @"mDeviceLockMessage should be 'lock'");
	GHAssertEquals([mPrefDeviceLock mLocationInterval], [mTestedPrefDeviceLock mLocationInterval], @"mLocationInterval should be 10");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefDeviceLockData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPrefDeviceLock = [[PrefDeviceLock alloc] initFromFile:path];

	GHAssertEquals([mPrefDeviceLock mEnableAlertSound], [mTestedPrefDeviceLock mEnableAlertSound], @"mEnableAlertSound should be YES");
	GHAssertEqualStrings([mPrefDeviceLock mDeviceLockMessage], [mTestedPrefDeviceLock mDeviceLockMessage], @"mDeviceLockMessage should be 'lock'");
	GHAssertEquals([mPrefDeviceLock mLocationInterval], [mTestedPrefDeviceLock mLocationInterval], @"mLocationInterval should be 10");
}

- (void) tearDown {
	[mPrefDeviceLock release];
	[mTestedPrefDeviceLock release];
	[mPrefDeviceLockData release];
}

@end
