//
//  FxCallTag.m
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxCallTag.h"

@implementation FxCallTag

@synthesize dbId;
@synthesize direction;
@synthesize duration;
@synthesize contactNumber;
@synthesize contactName;

- (id) init
{
	if (self = [super init])
	{
		dbId = 0;
		direction = kEventDirectionUnknown;
		duration = 0;
	}
	return (self);
}

- (void) dealloc
{
	[contactNumber release];
	[contactName release];
	[super dealloc];
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self dbId]]];		// NSUInteger
	[aCoder encodeObject:[NSNumber numberWithInt:[self direction]]];			// FxEventDirection
	[aCoder encodeObject:[NSNumber numberWithInteger:[self duration]]];		// NSInteger
	[aCoder encodeObject:[self contactNumber]];
	[aCoder encodeObject:[self contactName]];
}

- (id) initWithCoder: (NSCoder *)aDecoder {
	if ((self = [super init])) {
		[self setDbId:[[aDecoder decodeObject] unsignedIntValue]];
		[self setDirection:(FxEventDirection)[[aDecoder decodeObject] intValue]];
 		[self setDuration:[[aDecoder decodeObject] integerValue]];
		[self setContactNumber:[aDecoder decodeObject]];
		[self setContactName:[aDecoder decodeObject]];
	}
	return self;
}

@end
