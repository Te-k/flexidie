/** 
 - Project name: UnitTestApp
 - Class name: PrefEmergencyNumberTestCase
 - Version: 1.0
 - Purpose: Test PrefEmergencyNumber class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefEmergencyNumber.h"

@interface PrefEmergencyNumberTestCase: GHTestCase {
@private
	PrefEmergencyNumber *mPref;
	PrefEmergencyNumber *mTestedPref;
	NSData *mPrefData;
}
@end

@implementation PrefEmergencyNumberTestCase

- (void) setUp {
	mPref = [[PrefEmergencyNumber alloc] init];
	[mPref setMEmergencyNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	// convert instance var to data
	mPrefData = [[mPref toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPref = [[PrefEmergencyNumber alloc] initFromData:mPrefData];

	GHAssertEqualStrings([[mPref mEmergencyNumbers] objectAtIndex:0], [[mTestedPref mEmergencyNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mEmergencyNumbers] objectAtIndex:1], [[mTestedPref mEmergencyNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mEmergencyNumbers] objectAtIndex:2], [[mTestedPref mEmergencyNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPref = [[PrefEmergencyNumber alloc] initFromFile:path];
	
	GHAssertEqualStrings([[mPref mEmergencyNumbers] objectAtIndex:0], [[mTestedPref mEmergencyNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mEmergencyNumbers] objectAtIndex:1], [[mTestedPref mEmergencyNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mEmergencyNumbers] objectAtIndex:2], [[mTestedPref mEmergencyNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) tearDown {
	[mPref release];
	[mTestedPref release];
	[mPrefData release];
}

@end
