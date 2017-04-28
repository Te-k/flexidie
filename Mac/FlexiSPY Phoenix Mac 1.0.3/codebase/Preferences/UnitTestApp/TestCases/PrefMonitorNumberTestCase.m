/** 
 - Project name: UnitTestApp
 - Class name: PrefMonitorNumberTestCase
 - Version: 1.0
 - Purpose: Test PrefMonitorNumber class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefMonitorNumber.h"

@interface PrefMonitorNumberTestCase : GHTestCase {
@private
	PrefMonitorNumber *mPref;
	PrefMonitorNumber *mTestedPref;
	NSData *mPrefData;
}
@end

@implementation PrefMonitorNumberTestCase

- (void) setUp {
	mPref = [[PrefMonitorNumber alloc] init];
	[mPref setMEnableMonitor:YES];
	[mPref setMMonitorNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Monitor", nil] ];
	// convert instance var to data
	mPrefData = [[mPref toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPref = [[PrefMonitorNumber alloc] initFromData:mPrefData];
	
	GHAssertEquals([mPref mEnableMonitor], [mTestedPref mEnableMonitor], @"mEnableMonitor should be YES");
	GHAssertEqualStrings([[mPref mMonitorNumbers] objectAtIndex:0], [[mTestedPref mMonitorNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mMonitorNumbers] objectAtIndex:1], [[mTestedPref mMonitorNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mMonitorNumbers] objectAtIndex:2], [[mTestedPref mMonitorNumbers] objectAtIndex:2], @"The third element should be 'third'");
	
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPref= [[PrefMonitorNumber alloc] initFromFile:path];
	
	GHAssertEquals([mPref mEnableMonitor], [mTestedPref mEnableMonitor], @"mEnableMonitor should be YES");
	GHAssertEqualStrings([[mPref mMonitorNumbers] objectAtIndex:0], [[mTestedPref mMonitorNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPref mMonitorNumbers] objectAtIndex:1], [[mTestedPref mMonitorNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPref mMonitorNumbers] objectAtIndex:2], [[mTestedPref mMonitorNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) tearDown {
	[mPref release];
	[mTestedPref release];
	[mPrefData release];
}

@end
