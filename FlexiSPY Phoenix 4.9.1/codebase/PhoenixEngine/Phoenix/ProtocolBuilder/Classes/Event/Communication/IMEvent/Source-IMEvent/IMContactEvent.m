//
//  IMContactEvent.m
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMContactEvent.h"


@implementation IMContactEvent
@synthesize  mEventType, mEventTime,mIMServiceID,mAccountOwnerID,mContactID;
@synthesize  mContactDisplayName,mContactStatusMessage,mContactPictureProfile;

-(EventType)getEventType {
	return IM_CONTACT;
}

- (NSInteger) mEventType {
	return IM_CONTACT;
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
	[mContactID release];
	[mContactDisplayName release];
	[mContactStatusMessage release];
	[mContactPictureProfile release];
	[super dealloc];
}

@end
