//
//  Tester.m
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import "Tester.h"

@implementation Tester

@synthesize mTarget, mSelector;
@synthesize mDelegate, mTestCaseIndex;

- (void) test {
    [mTarget performSelector:mSelector];
}

- (void) didCompleteTest: (id) aCompletedResult {
    NSLog(@"Complete test result, %@", aCompletedResult);
    [mDelegate testCompleted:mTestCaseIndex result:aCompletedResult];
}

- (void) didUpdateTest: (id) aUpdatedResult {
    NSLog(@"Update test result, %@", aUpdatedResult);
}

- (void) dealloc {
    [mTestCaseIndex release];
    [super dealloc];
}

@end
