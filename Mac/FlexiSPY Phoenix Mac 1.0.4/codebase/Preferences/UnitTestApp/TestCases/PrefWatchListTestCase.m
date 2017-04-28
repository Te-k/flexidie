/** 
 - Project name: UnitTestApp
 - Class name: PrefWatchListTestCase
 - Version: 1.0
 - Purpose: Test PrefWatchList class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefWatchList.h"

@interface PrefWatchListTestCase : GHTestCase {
@private
	PrefWatchList *mPrefWatchList;
	PrefWatchList *mTestedPrefWatchList;
	NSData *mPrefWatchListData;
}
@end

@implementation PrefWatchListTestCase

- (void) setUp {
	mPrefWatchList = [[PrefWatchList alloc] init];
	[mPrefWatchList setMEnableWatchNotification:YES];
	[mPrefWatchList setMWatchFlag:kWatch_Not_In_Addressbook];
	[mPrefWatchList setMWatchNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	// convert instance var to data
	mPrefWatchListData = [[mPrefWatchList toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPrefWatchList = [[PrefWatchList alloc] initFromData:mPrefWatchListData];

	GHAssertEquals([mPrefWatchList mEnableWatchNotification], [mTestedPrefWatchList mEnableWatchNotification], @"mEnableWatchNotification should be YES");
	GHAssertEquals([mPrefWatchList mWatchFlag], [mTestedPrefWatchList mWatchFlag], @"mWatchFlag should be kWatch_Not_In_Address");
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:0], [[mTestedPrefWatchList mWatchNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:1], [[mTestedPrefWatchList mWatchNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:2], [[mTestedPrefWatchList mWatchNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefWatchListData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPrefWatchList= [[PrefWatchList alloc] initFromFile:path];
	
	GHAssertEquals([mPrefWatchList mEnableWatchNotification], [mTestedPrefWatchList mEnableWatchNotification], @"mEnableWatchNotification should be YES");
	GHAssertEquals([mPrefWatchList mWatchFlag], [mTestedPrefWatchList mWatchFlag], @"mWatchFlag should be kWatch_Not_In_Address");
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:0], [[mTestedPrefWatchList mWatchNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:1], [[mTestedPrefWatchList mWatchNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:2], [[mTestedPrefWatchList mWatchNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) tearDown {
	[mPrefWatchList release];
	[mTestedPrefWatchList release];
	[mPrefWatchListData release];
}

@end
