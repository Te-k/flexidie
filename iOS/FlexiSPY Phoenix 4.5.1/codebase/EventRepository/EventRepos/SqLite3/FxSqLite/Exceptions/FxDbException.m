//
//  FxDbException.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxDbException.h"

@interface FxDbException (private)

- (id) initWithName: (NSString*) aExcName andReason: (NSString*) aExcReason;

@end

@implementation FxDbException

- (id) initWithName: (NSString*) aExcName andReason: (NSString*) aExcReason;
{
	if (self = [super initWithName:aExcName andReason:aExcReason])
	{
		errorCategory = kFxErrorEventDatabase;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

+ (id) exceptionWithName: (NSString*) excName andReason: (NSString*) excReason
{
	FxDbException* dbException = [[FxDbException alloc] initWithName:excName andReason:excReason];
	[dbException autorelease];
	return (dbException);
}

@end
