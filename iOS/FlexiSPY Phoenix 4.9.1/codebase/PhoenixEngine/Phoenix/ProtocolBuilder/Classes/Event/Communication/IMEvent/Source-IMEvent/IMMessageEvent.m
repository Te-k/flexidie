//
//  IMMessageEvent.m
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMMessageEvent.h"


@implementation IMMessageEvent
@synthesize mEventType,mEventTime,mDirection,mIMServiceID,mConversationID,mMessageOriginatorID,mTextRepresentation,mData,mAttachments;
@synthesize mMessageOriginatorlocationPlace,mMessageOriginatorlocationlongtitude,mMessageOriginatorlocationlatitude,mMessageOriginatorlocationHoraccuracy;
@synthesize mShareLocationPlace,mShareLocationlongtitude,mShareLocationlatitude,mShareLocationHoraccuracy;

-(EventType)getEventType {
	return IM_MESSAGE;
}

- (NSInteger) mEventType {
	return IM_MESSAGE;
}

- (void) setTime: (NSString *) aEventTime {
	if (time) {
		[time release];
		time = nil;
	}
	if (mEventTime) {
		[mEventTime release];
		mEventTime = nil;
	}
	time = [[NSString alloc] initWithString:aEventTime];
	mEventTime = [[NSString alloc] initWithString:aEventTime];
}

- (void) setMEventTime: (NSString *) aEventTime {
	if (mEventTime) {
		[mEventTime release];
		mEventTime = nil;
	}
	if (time) {
		[time release];
		time = nil;
	}
	mEventTime = [[NSString alloc] initWithString:aEventTime];
	time = [[NSString alloc] initWithString:aEventTime];
}

- (void) dealloc {
	[mEventTime release];
	[mConversationID release];
	[mMessageOriginatorID release];
	[mData release];
	[mAttachments release];
	[mMessageOriginatorlocationPlace release];
	[mShareLocationPlace release];
	[super dealloc];
}

@end
