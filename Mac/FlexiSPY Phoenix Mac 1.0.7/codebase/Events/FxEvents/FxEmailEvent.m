//
//  FxEmailEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEmailEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"

@implementation FxEmailEvent

- (id) init {
	if (self = [super init]) {
		eventType = kEventTypeMail;
		direction = kEventDirectionUnknown;
		recipientArray = [[NSMutableArray alloc] init];
		attachmentArray = [[NSMutableArray alloc] init];
		html = FALSE;
	}
	return (self);
}

- (void) dealloc {
	[senderEmail release];
	[senderContactName release];
	[subject release];
	[message release];
	[recipientArray release];
	[attachmentArray release];
	[super dealloc];
}

@synthesize direction;
@synthesize senderEmail;
@synthesize senderContactName;
@synthesize subject;
@synthesize message;
@synthesize html;
@synthesize recipientArray;
@synthesize attachmentArray;

- (void) addRecipient: (FxRecipient*) recipient {
	[recipientArray addObject:recipient]; // Make copy of recipient and add to an array
}

- (void) addAttachment: (FxAttachment*) attachment {
	[attachmentArray addObject:attachment]; // Make copy of attachment and add to an array
}

//- (NSString *) description {
//	return [NSString stringWithFormat:@"sender mail %@ \n"
//			"sender name %@		\n"
//			"sub %@				\n"
//			"message %@			\n"
//			"html %d			\n"
//			"recipient %@		\n"
//			"attachment %@		\n",
//			self.senderEmail,
//			self.senderContactName,
//			self.subject,
//			self.message,
//			self.html,
//			self.recipientArray,
//			self.attachmentArray];
//}

@end
