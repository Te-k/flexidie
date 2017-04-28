//
//  PrefFileActivityTestCase.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/30/15.
//
//

#import "GHUnitIOS/GHUnit.h"

#import "PreferenceManagerImpl.h"
#import "PrefFileActivity.h"

@interface PrefFileActivityTestCase : GHTestCase {
@private
    PrefFileActivity *mPrefFileActivity;
}
@property (nonatomic, retain) PrefFileActivity *mPrefFileActivity;
@end

@implementation PrefFileActivityTestCase

@synthesize mPrefFileActivity;

- (void) setUp {
    PrefFileActivity *prefFileActivity = [[PrefFileActivity alloc] init];
    prefFileActivity.mEnable = YES;
    prefFileActivity.mActivityType = (kFileActivityCopy | kFileActivityCreate);
    prefFileActivity.mExcludedFileActivityPaths = [NSArray arrayWithObjects:@"/var/system", @"/Applications", nil];
    self.mPrefFileActivity = prefFileActivity;
    
    PreferenceManagerImpl *manager = [[PreferenceManagerImpl alloc] init];
    [manager savePreference:prefFileActivity];
    [manager release];
}

- (void) testReadData {
    PreferenceManagerImpl *manager = [[PreferenceManagerImpl alloc] init];
    PrefFileActivity *prefFileActivity = (PrefFileActivity *)[manager preference:kFileActivity];
    
    GHAssertEquals([prefFileActivity mEnable], [self.mPrefFileActivity mEnable], @"mEnable should be YES");
    GHAssertEquals([prefFileActivity mActivityType], [self.mPrefFileActivity mActivityType], @"mActivityType should be (kFileActivityCopy | kFileActivityCreate)");
    int i = 0;
    for (NSString *path in prefFileActivity.mExcludedFileActivityPaths) {
        GHAssertEqualStrings(path, [self.mPrefFileActivity.mExcludedFileActivityPaths objectAtIndex:i], @"Every elements in excluded paths must be equal");
        i++;
    }
    
    [manager release];
}

- (void) tearDown {
    [mPrefFileActivity release];
}

@end
