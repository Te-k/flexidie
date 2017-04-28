//
//  FxException.m
//  FxStd
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxException.h"

@implementation FxException

@synthesize errorCategory;
@synthesize errorCode;
@synthesize excName;
@synthesize excReason;

+ (id) exceptionWithName: (NSString*) excName andReason: (NSString*) excReason {
	FxException* exception = [[FxException alloc] initWithName:excName andReason:excReason];
	[exception autorelease];
	return (exception);
}

- (id) initWithName: (NSString*) aExcName andReason: (NSString*) aExcReason; {
	if ((self = [super init])) {
		excName = aExcName;
		[excName retain];
		excReason = aExcReason;
		[excReason retain];
	}
	return (self);
}

- (NSString *) description {
    NSString *description = [NSString stringWithFormat:@"errorCategory = %d, errorCode = %d, excName = %@, excReason = %@",
                             [self errorCategory], [self errorCode], [self excName], [self excReason]];
    return (description);
}

- (void) dealloc {
	[excName release];
	[excReason release];
	[super dealloc];
}

@end
