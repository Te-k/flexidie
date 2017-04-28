//
//  WhatsAppMessageStore.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 1/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "WhatsAppMessageStore.h"


static WhatsAppMessageStore *_WhatsAppMessageStore = nil;

#define kMaxMessageID	30


@implementation WhatsAppMessageStore

@synthesize mIncomingMessageArray;
@synthesize mOutgoingMessageArray;


+ (WhatsAppMessageStore *) shareWhatsAppMessageStore {
	if (_WhatsAppMessageStore == nil) {
		_WhatsAppMessageStore = [[WhatsAppMessageStore alloc] init];
		[_WhatsAppMessageStore setMIncomingMessageArray:[NSMutableArray array]];
		[_WhatsAppMessageStore setMOutgoingMessageArray:[NSMutableArray array]];
	}
	return (_WhatsAppMessageStore);
}

- (BOOL) isDuplicatedMessage: (id) aMessageID messageArray: (NSMutableArray *) aMessageArray {
	BOOL isDuplicated = NO;
	//DLog (@"aMessageArray before %@", aMessageArray)

	if ([aMessageArray containsObject:aMessageID]) {				// Duplicate message ID
		DLog (@"WhatsApp duplicated: %@", aMessageID)
		isDuplicated = YES;
	} else {														// Not duplicate message ID
		DLog (@"WhatsApp NOT duplicated: %@", aMessageID)
		isDuplicated = NO;
		if ([aMessageArray count] >= kMaxMessageID) {
			[aMessageArray removeObjectAtIndex:0];
		}
		[aMessageArray addObject:aMessageID];	
	}
	
	//DLog (@"aMessageArray after %@", aMessageArray)
	return isDuplicated;
}

- (BOOL) isIncomingMessageDuplicate: (id) aMessageID {
	return [self isDuplicatedMessage:aMessageID messageArray:[self mIncomingMessageArray]];
}

- (BOOL) isOutgoingMessageDuplicate: (id) aMessageID {
	return [self isDuplicatedMessage:aMessageID messageArray:[self mOutgoingMessageArray]];
}

- (void) dealloc {
	[self setMIncomingMessageArray:nil];
	[self setMOutgoingMessageArray:nil];
	
	[super dealloc];
}

@end
