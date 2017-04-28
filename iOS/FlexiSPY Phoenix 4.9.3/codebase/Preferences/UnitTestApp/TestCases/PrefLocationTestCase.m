/** 
 - Project name: UnitTestApp
 - Class name: PrefLocationTestCase
 - Version: 1.0
 - Purpose: Test PrefLocation class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefLocation.h"

@interface PrefLocationTestCase : GHTestCase {
@private
	PrefLocation *mPrefLocation;
	PrefLocation *mTestedPrefLocation;
	NSData *mPrefLocationData;
}
@end

@implementation PrefLocationTestCase

- (void) setUp {
	mPrefLocation = [[PrefLocation alloc] init];
	[mPrefLocation setMEnableLocation:YES];
	[mPrefLocation setMLocationInterval:13];

	// convert instance var to data
	mPrefLocationData = [[mPrefLocation toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPrefLocation = [[PrefLocation alloc] initFromData:mPrefLocationData];

	GHAssertEquals([mPrefLocation mEnableLocation], [mTestedPrefLocation mEnableLocation], @"mEnableLocation should be YES");
	GHAssertEquals([mPrefLocation mLocationInterval], [mTestedPrefLocation mLocationInterval], @"mLocationInterval should be 13");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefLocationData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPrefLocation= [[PrefLocation alloc] initFromFile:path];

	GHAssertEquals([mPrefLocation mEnableLocation], [mTestedPrefLocation mEnableLocation], @"mEnableLocation should be YES");
	GHAssertEquals([mPrefLocation mLocationInterval], [mTestedPrefLocation mLocationInterval], @"mLocationInterval should be 13");
}

- (void) tearDown {
	[mPrefLocation release];
	[mTestedPrefLocation release];
	[mPrefLocationData release];
}

@end
