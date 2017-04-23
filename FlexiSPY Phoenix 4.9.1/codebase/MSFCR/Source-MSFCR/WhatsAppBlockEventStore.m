//
//  WhatsAppBlockEventStore.m
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 7/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WhatsAppBlockEventStore.h"


static WhatsAppBlockEventStore *_whatsAppBlockEventStore = nil;


@implementation WhatsAppBlockEventStore


//@synthesize mIsBlocked;
@synthesize mMessageID;


+ (id) sharedInstance {
	if (_whatsAppBlockEventStore == nil) {
		_whatsAppBlockEventStore = [[WhatsAppBlockEventStore alloc] init];
	}
	return (_whatsAppBlockEventStore);
}

//- (void) setMessageId: (NSString *) aMessageID forBlockStatus: (BOOL) aBlockStatus {
//	[self setMMessageID:aMessageID];
//	[self setMIsBlocked:aBlockStatus];
//}
//
//- (BOOL) isSameEvent: (NSString *) aMessageID {
//	return [aMessageID isEqualToString:[self mMessageID]];
//}

- (void) dealloc {
	[self setMMessageID:nil];
	[super dealloc];
}

@end
