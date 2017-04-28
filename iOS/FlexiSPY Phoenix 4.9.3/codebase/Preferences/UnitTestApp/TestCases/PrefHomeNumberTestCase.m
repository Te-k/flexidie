/** 
 - Project name: UnitTestApp
 - Class name: PrefHomeNumberTestCase
 - Version: 1.0
 - Purpose: Test PrefHomeNumber class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefHomeNumber.h"

@interface PrefHomeNumberTestCase: GHTestCase {
@private
	PrefHomeNumber *mPref;
	PrefHomeNumber *mTestedPref;
	NSData *mPrefData;
}
@end

@implementation PrefHomeNumberTestCase

- (void) setUp {
	mPref = [[PrefHomeNumber alloc] init];
	[mPref setMHomeNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	// convert instance var to data
	mPrefData = [[mPref toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPref = [[PrefHomeNumber alloc] initFromData:mPrefData];

	GHAssertEqualStrings([[mPref mHomeNumbers] objectAtIndex:0], [[mTestedPref mHomeNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mHomeNumbers] objectAtIndex:1], [[mTestedPref mHomeNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mHomeNumbers] objectAtIndex:2], [[mTestedPref mHomeNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPref = [[PrefHomeNumber alloc] initFromFile:path];
	
	GHAssertEqualStrings([[mPref mHomeNumbers] objectAtIndex:0], [[mTestedPref mHomeNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mHomeNumbers] objectAtIndex:1], [[mTestedPref mHomeNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mHomeNumbers] objectAtIndex:2], [[mTestedPref mHomeNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) tearDown {
	[mPref release];
	[mTestedPref release];
	[mPrefData release];
}

@end
