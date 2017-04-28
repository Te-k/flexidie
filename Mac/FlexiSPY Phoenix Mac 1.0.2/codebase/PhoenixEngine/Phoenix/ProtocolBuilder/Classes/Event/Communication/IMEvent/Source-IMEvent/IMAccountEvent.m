//
//  IMAccountEvent.m
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMAccountEvent.h"


@implementation IMAccountEvent
@synthesize mEventType,mEventTime,mIMServiceID,mAccountOwnerID,mAccountOwnerDisplayName,mAccountOwnerStatusMessage,mAccountOwnerPictureProfile;

-(EventType)getEventType {
	return IM_ACCOUNT;
}

- (NSInteger) mEventType {
	return IM_ACCOUNT;
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
	[mAccountOwnerDisplayName release];
	[mAccountOwnerStatusMessage release];
	[mAccountOwnerPictureProfile release];
	[super dealloc];
}

@end
