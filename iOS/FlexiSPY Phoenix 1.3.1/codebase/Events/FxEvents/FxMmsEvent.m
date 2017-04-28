//
//  FxMmsEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxMmsEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"

@implementation FxMmsEvent

- (id) init {
	if ((self = [super init])) {
		eventType = kEventTypeMms;
		direction = kEventDirectionUnknown;
		recipientArray = [[NSMutableArray alloc] init];
		attachmentArray = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void) dealloc {
	[mConversationID release];
	[senderNumber release];
	[senderContactName release];
	[subject release];
	[message release];
	[recipientArray release];
	[attachmentArray release];
	[super dealloc];
}
	
@synthesize direction;
@synthesize senderNumber;
@synthesize senderContactName;
@synthesize subject;
@synthesize message;
@synthesize recipientArray;
@synthesize attachmentArray;
@synthesize mConversationID;

- (void) addRecipient: (FxRecipient*) recipient {
	[recipientArray addObject:recipient]; // Make copy of recipient and add to an array
}

- (void) addAttachment: (FxAttachment*) attachment {
	[attachmentArray addObject:attachment]; // Make copy of attachment and add to an array
}

@end
