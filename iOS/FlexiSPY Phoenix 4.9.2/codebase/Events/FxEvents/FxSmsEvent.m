//
//  FxSmsEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxSmsEvent.h"

@implementation FxSmsEvent

- (id) init {
	if (self = [super init]) {
		eventType = kEventTypeSms;
		direction = kEventDirectionUnknown;
		recipientArray = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void) dealloc {
	[mConversationID release];
	[contactName release];
	[senderNumber release];
	[smsSubject release];
	[smsData release];
	[recipientArray release]; // Release all items in array and release itself
	[super dealloc];
}

@synthesize contactName;
@synthesize senderNumber;
@synthesize smsSubject;
@synthesize smsData;
@synthesize direction;
@synthesize recipientArray;
@synthesize mConversationID;

- (void) addRecipient: (FxRecipient*) recipient {
	[recipientArray addObject:recipient]; // Make copy of recipient and add to an array
}

@end
