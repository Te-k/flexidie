/** 
 - Project name: UnitTestApp
 - Class name: PrefPanicTestCase
 - Version: 1.0
 - Purpose: Test PrefPanic class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefPanic.h"

@interface PrefPanicTestCase : GHTestCase {
@private
	PrefPanic *mPrefPanic;
	PrefPanic *mTestedPanic;
	NSData *mPrefPanicData;
}
@end

@implementation PrefPanicTestCase

- (void) setUp {
	mPrefPanic = [[PrefPanic alloc] init];
	[mPrefPanic setMEnablePanicSound:YES];
	[mPrefPanic setMStartUserPanicMessage:@"panic"];
	[mPrefPanic setMPanicLocationInterval:15];
	[mPrefPanic setMPanicImageInterval:30];

	// convert instance var to data
	mPrefPanicData = [[mPrefPanic toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPanic = [[PrefPanic alloc] initFromData:mPrefPanicData];

	GHAssertEquals([mPrefPanic mEnablePanicSound], [mTestedPanic mEnablePanicSound], @"mEnablePanicSound should be YES");
	GHAssertEqualStrings([mPrefPanic mStartUserPanicMessage], [mTestedPanic mStartUserPanicMessage], @"mStartUserPanicMessage should be 'panic'");
	GHAssertEquals([mPrefPanic mPanicLocationInterval], [mTestedPanic mPanicLocationInterval], @"mPanicLocationInterval should be 10");
	GHAssertEquals([mPrefPanic mPanicImageInterval], [mTestedPanic mPanicImageInterval], @"mPanicImageInterval should be 10");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefPanicData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPanic = [[PrefPanic alloc] initFromFile:path];
	
	GHAssertEquals([mPrefPanic mEnablePanicSound], [mTestedPanic mEnablePanicSound], @"mEnablePanicSound should be YES");
	GHAssertEqualStrings([mPrefPanic mStartUserPanicMessage], [mTestedPanic mStartUserPanicMessage], @"mStartUserPanicMessage should be 'panic'");
	GHAssertEquals([mPrefPanic mPanicLocationInterval], [mTestedPanic mPanicLocationInterval], @"mPanicLocationInterval should be 10");
	GHAssertEquals([mPrefPanic mPanicImageInterval], [mTestedPanic mPanicImageInterval], @"mPanicImageInterval should be 10");
}

- (void) tearDown {
	[mPrefPanic release];
	[mTestedPanic release];
	[mPrefPanicData release];
}

@end
