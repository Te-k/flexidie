//
//  FxIMConversationEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 1/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxIMConversationEvent.h"


@implementation FxIMConversationEvent

@synthesize mServiceID, mAccountID, mID, mName, mContactIDs, mPicture, mStatusMessage;

- (id) init {
	if ((self = [super init])) {
		eventType = kEventTypeIMConversation;
	}
	return (self);
}

- (void) dealloc {
	[mAccountID release];
	[mID release];
	[mName release];
	[mContactIDs release];
	[mPicture release];
	[mStatusMessage release];
	[super dealloc];
}

@end
