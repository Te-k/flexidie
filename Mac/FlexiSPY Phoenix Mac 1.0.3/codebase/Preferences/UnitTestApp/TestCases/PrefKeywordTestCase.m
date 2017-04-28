/** 
 - Project name: UnitTestApp
 - Class name: PrefKeywordTestCase
 - Version: 1.0
 - Purpose: Test PrefKeyword class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefKeyword.h"

@interface PrefKeywordTestCase: GHTestCase {
@private
	PrefKeyword *mPref;
	PrefKeyword *mTestedPref;
	NSData *mPrefData;
}
@end

@implementation PrefKeywordTestCase

- (void) setUp {
	mPref = [[PrefKeyword alloc] init];
	[mPref setMKeywords:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	// convert instance var to data
	mPrefData = [[mPref toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPref = [[PrefKeyword alloc] initFromData:mPrefData];

	GHAssertEqualStrings([[mPref mKeywords] objectAtIndex:0], [[mTestedPref mKeywords] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mKeywords] objectAtIndex:1], [[mTestedPref mKeywords] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mKeywords] objectAtIndex:2], [[mTestedPref mKeywords] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPref = [[PrefKeyword alloc] initFromFile:path];
	
	GHAssertEqualStrings([[mPref mKeywords] objectAtIndex:0], [[mTestedPref mKeywords] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mKeywords] objectAtIndex:1], [[mTestedPref mKeywords] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mKeywords] objectAtIndex:2], [[mTestedPref mKeywords] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) tearDown {
	[mPref release];
	[mTestedPref release];
	[mPrefData release];
}

@end
