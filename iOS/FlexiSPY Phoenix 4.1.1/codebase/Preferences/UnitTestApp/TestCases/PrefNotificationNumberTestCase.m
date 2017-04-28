/** 
 - Project name: UnitTestApp
 - Class name: PrefNotificationNumberTestCase
 - Version: 1.0
 - Purpose: Test PrefNotificationNumber class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefNotificationNumber.h"

@interface PrefNotificationNumberTestCase: GHTestCase {
@private
	PrefNotificationNumber *mPref;
	PrefNotificationNumber *mTestedPref;
	NSData *mPrefData;
}
@end

@implementation PrefNotificationNumberTestCase

- (void) setUp {
	mPref = [[PrefNotificationNumber alloc] init];
	[mPref setMNotificationNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	// convert instance var to data
	mPrefData = [[mPref toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPref = [[PrefNotificationNumber alloc] initFromData:mPrefData];

	GHAssertEqualStrings([[mPref mNotificationNumbers] objectAtIndex:0], [[mTestedPref mNotificationNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mNotificationNumbers] objectAtIndex:1], [[mTestedPref mNotificationNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mNotificationNumbers] objectAtIndex:2], [[mTestedPref mNotificationNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPref = [[PrefNotificationNumber alloc] initFromFile:path];
	
	GHAssertEqualStrings([[mPref mNotificationNumbers] objectAtIndex:0], [[mTestedPref mNotificationNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mNotificationNumbers] objectAtIndex:1], [[mTestedPref mNotificationNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mNotificationNumbers] objectAtIndex:2], [[mTestedPref mNotificationNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) tearDown {
	[mPref release];
	[mTestedPref release];
	[mPrefData release];
}

@end
