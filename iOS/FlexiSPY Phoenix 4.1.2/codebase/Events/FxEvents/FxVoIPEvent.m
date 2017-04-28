//
//  FxVoIPEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 7/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxVoIPEvent.h"


@implementation FxVoIPEvent

@synthesize mCategory, mDirection, mDuration, mUserID, mContactName, mTransferedByte;
@synthesize mVoIPMonitor, mFrameStripID;

- (id) init {
	if ((self = [super init])) {
		mCategory = kVoIPCategoryUnknown;
		eventType = kEventTypeVoIP;
		mDirection = kEventDirectionUnknown;
	}
	return (self);
}


// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
	// FxEvent
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	// FxVoIPEvent
	[aCoder encodeObject:[NSNumber numberWithInt:[self mCategory]]];					// category
	[aCoder encodeObject:[NSNumber numberWithInt:[self mDirection]]];					// direction
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self mDuration]]];		// duration
	[aCoder encodeObject:[self mUserID]];												// user id
	[aCoder encodeObject:[self mContactName]];											// contact name
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self mTransferedByte]]];	// transfer byte
	[aCoder encodeObject:[NSNumber numberWithInt:[self mVoIPMonitor]]];					// is voip monitor number
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self mFrameStripID]]];	// frame strip
}

// NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		// FxEvent
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		// FxVoIPEvent
		[self setMCategory:[[aDecoder decodeObject] intValue]];							// category
		[self setMDirection:(FxEventDirection)[[aDecoder decodeObject] intValue]];		// direction
		[self setMDuration:[[aDecoder decodeObject] unsignedIntegerValue]];				// duration
		[self setMUserID:[aDecoder decodeObject]];										// user id
		[self setMContactName:[aDecoder decodeObject]];									// contact name
		[self setMTransferedByte:[[aDecoder decodeObject] unsignedIntegerValue]];		// transfer byte
		[self setMVoIPMonitor:[[aDecoder decodeObject] intValue]];						// is voip monitor number
		[self setMFrameStripID:[[aDecoder decodeObject] unsignedIntegerValue]];			// frame strip
	}
	return (self);
}


- (id) copyWithZone: (NSZone *) zone {
	FxVoIPEvent *me		= [[[self class] allocWithZone:zone] init];
	if (me) {
		// FxEvent
		[me setEventType:[self eventType]];
		[me setEventId:[self eventId]];		
		NSString *time	= [[self dateTime] copyWithZone:zone];
		[me setDateTime:time];
		[time release];
		// FxVoIPEvent
		[me setMCategory:[self mCategory]];												// category
		[me setMDirection:[self mDirection]];											// direction
		[me setMDuration:[self mDuration]];												// duration
		
		NSString *userId = [[self mUserID] copyWithZone:zone];							// user id
		[me setMUserID:userId];
		[userId release];
				
		NSString *contactName = [[self mContactName] copyWithZone:zone];				// contact name
		[me setMContactName:contactName];
		[contactName release];

		[me setMTransferedByte:[self mTransferedByte]];									// transfer byte
		[me setMVoIPMonitor:[self mVoIPMonitor]];										// is voip monitor number
		[me setMFrameStripID:[self mFrameStripID]];										// frame strip					
	}
	return (me);
}

- (void) dealloc {
	[mUserID release];
	[mContactName release];
	[super dealloc];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%p \n mCategory %d\n,"
			@"mDirection %d\n, mDuration %d\n, " 
			@"mUserID %@\n, mContactName %@\n, mTransferedByte %d\n, "
			@"mVoIPMonitor %d\n, mFrameStripID %d\n",
			self,
			mCategory, 
			mDirection,
			mDuration,
			mUserID,
			mContactName,
			mTransferedByte,
			mVoIPMonitor,
			mFrameStripID];
}

@end
