//
//  FxRecipient.m
//  FxEvents
//
//  Created by Makara Khloth on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxRecipient.h"

@implementation FxRecipient

@synthesize mStatusMessage, mPicture;

- (id) init {
	if ((self = [super init])) {
		recipType = kFxRecipientTO;
	}
	return (self);
}

- (id)copyWithZone:(NSZone *)zone {
	FxRecipient *me = [[[self class] allocWithZone:zone] init];
	if (me) {
		[me setDbId:[self dbId]];
		[me setRecipType:[self recipType]];
		
		NSString *number = [[self recipNumAddr] copyWithZone:zone];
		[me setRecipNumAddr:number];
		[number release];
		
		NSString *contactName = [[self recipContactName] copyWithZone:zone];
		[me setRecipContactName:contactName];
		[contactName release];
		
		// New fields... for IM only
		NSString *statusMessage = [[self mStatusMessage] copyWithZone:zone];
		[me setMStatusMessage:statusMessage];
		[statusMessage release];
		
		NSData *picture = [[self mPicture] copyWithZone:zone];
		[me setMPicture:picture];
		[picture release];
	}
	return (me);
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.dbId]];
    [aCoder encodeObject:[NSNumber numberWithInt:self.recipType]];
    [aCoder encodeObject:self.recipNumAddr];
    [aCoder encodeObject:self.recipContactName];
    [aCoder encodeObject:self.mStatusMessage];
    [aCoder encodeObject:self.mPicture];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.dbId = [[aDecoder decodeObject] unsignedIntegerValue];
        self.recipType = (FxRecipientType)[[aDecoder decodeObject] intValue];
        self.recipNumAddr = [aDecoder decodeObject];
        self.recipContactName = [aDecoder decodeObject];
        self.mStatusMessage = [aDecoder decodeObject];
        self.mPicture = [aDecoder decodeObject];
    }
    return self;
}

- (NSString *) description {
	NSString *string = [NSString stringWithFormat:@"unique = %lu, type = %d, address = %@, contact = %@, "
							 "status = %@, picture size = %lu", (unsigned long)dbId, recipType, recipNumAddr, recipContactName,
							 mStatusMessage, (unsigned long)[mPicture length]];
	return (string);
}

- (void) dealloc {
	[mStatusMessage release];
	[mPicture release];
	[recipNumAddr release];
	[recipContactName release];
	[super dealloc];
}

@synthesize recipNumAddr;
@synthesize recipContactName;
@synthesize recipType;
@synthesize dbId;

@end
