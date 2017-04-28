//
//  PrefCallRecordTestCase.m
//  UnitTestApp
//
//  Created by Makara Khloth on 11/26/15.
//
//

#import "GHUnitIOS/GHUnit.h"
#import "PrefCallRecord.h"

@interface PrefCallRecordTestCase : GHTestCase {
@private
    PrefWatchList *mPrefCallRecord;
    PrefWatchList *mTestedPrefCallRecord;
    NSData *mPrefCallRecordData;
}
@end

@implementation PrefCallRecordTestCase

- (void) setUp {
    mPrefCallRecord = [[PrefWatchList alloc] init];
    [mPrefCallRecord setMEnableWatchNotification:YES];
    [mPrefCallRecord setMWatchFlag:kWatch_Not_In_Addressbook];
    [mPrefCallRecord setMWatchNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
    // convert instance var to data
    mPrefCallRecordData = [[mPrefCallRecord toData] retain];
}

- (void) testInitFromData {
    // create another by initFromData
    mTestedPrefCallRecord = [[PrefWatchList alloc] initFromData:mPrefCallRecordData];
    
    GHAssertEquals([mPrefCallRecord mEnableWatchNotification], [mTestedPrefCallRecord mEnableWatchNotification], @"mEnableWatchNotification should be YES");
    GHAssertEquals([mPrefCallRecord mWatchFlag], [mTestedPrefCallRecord mWatchFlag], @"mWatchFlag should be kWatch_Not_In_Address");
    GHAssertEqualStrings([[mPrefCallRecord mWatchNumbers] objectAtIndex:0], [[mTestedPrefCallRecord mWatchNumbers] objectAtIndex:0], @"The first element should be 'first'");
    GHAssertEqualStrings([[mPrefCallRecord mWatchNumbers] objectAtIndex:1], [[mTestedPrefCallRecord mWatchNumbers] objectAtIndex:1], @"The second element should be 'second'");
    GHAssertEqualStrings([[mPrefCallRecord mWatchNumbers] objectAtIndex:2], [[mTestedPrefCallRecord mWatchNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testInitFromFile {
    // Write data to a file
    NSString *path = @"/Users/Shared/UnitTestApp.txt";
    [mPrefCallRecordData  writeToFile:path atomically:NO];
    
    // Create another by initFromFile
    mTestedPrefCallRecord= [[PrefWatchList alloc] initFromFile:path];
    
    GHAssertEquals([mPrefCallRecord mEnableWatchNotification], [mTestedPrefCallRecord mEnableWatchNotification], @"mEnableWatchNotification should be YES");
    GHAssertEquals([mPrefCallRecord mWatchFlag], [mTestedPrefCallRecord mWatchFlag], @"mWatchFlag should be kWatch_Not_In_Address");
    GHAssertEqualStrings([[mPrefCallRecord mWatchNumbers] objectAtIndex:0], [[mTestedPrefCallRecord mWatchNumbers] objectAtIndex:0], @"The first element should be 'first'");
    GHAssertEqualStrings([[mPrefCallRecord mWatchNumbers] objectAtIndex:1], [[mTestedPrefCallRecord mWatchNumbers] objectAtIndex:1], @"The second element should be 'second'");
    GHAssertEqualStrings([[mPrefCallRecord mWatchNumbers] objectAtIndex:2], [[mTestedPrefCallRecord mWatchNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) tearDown {
    [mPrefCallRecord release];
    [mTestedPrefCallRecord release];
    [mPrefCallRecordData release];
}

@end
