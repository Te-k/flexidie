//
//  FacebookSerialOperation.m
//  MSFSP
//
//  Created by Makara on 8/7/14.
//
//

#import "FacebookSerialOperation.h"

@implementation FacebookSerialOperation

@synthesize mDelegate, mSelector;

- (id) initWithArgs: (NSArray *) aArgs {
    if (self = [super init]) {
        mArgs = aArgs;
        [mArgs retain];
    }
    return (self);
}

- (void) main {
    DLog(@"mDelegate, %@", mDelegate)
    DLog(@"mSelector, %@", NSStringFromSelector(mSelector))
    if (mDelegate) {
        [mDelegate performSelector:mSelector withObject:mArgs];
    }
}

- (void) dealloc {
    [mArgs release];
    [super dealloc];
}

@end
