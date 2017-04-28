//
//  IMConversationEvent.m
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMConversationEvent.h"


@implementation IMConversationEvent
@synthesize mEventType,mEventTime,mIMServiceID,mAccountOwnerID,mConversationID,mConversationName,mContacts,mPictureProfile,mStatusMessage;

-(EventType)getEventType {
	return IM_CONVERSATION;
}

- (NSInteger) mEventType {
	return IM_CONVERSATION;
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
	[mAccountOwnerID release];
	[mConversationID release];
	[mConversationName release];
	[mStatusMessage release];
	[mPictureProfile release];
	[mContacts release];
	[super dealloc];
}

@end
