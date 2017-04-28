//
//  DDMDBException.m
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMDBException.h"

@interface DDMDBException (private)

- (id) initWithName: (NSString*) aExcName andReason: (NSString*) aExcReason;

@end

@implementation DDMDBException

- (id) initWithName: (NSString*) aExcName andReason: (NSString*) aExcReason;
{
	if ((self = [super initWithName:aExcName andReason:aExcReason]))
	{
		errorCategory = kFxErrorDDMDatabase;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

+ (id) exceptionWithName: (NSString*) aExcName andReason: (NSString*) aExcReason
{
	DDMDBException* exception = [[DDMDBException alloc] initWithName:aExcName andReason:aExcReason];
	[exception autorelease];
	return (exception);
}

@end