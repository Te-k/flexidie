//
//  SMSSendMessage.m
//  SMSSender
//
//  Created by Makara Khloth on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SMSSendMessage.h"

@implementation SMSSendMessage

@synthesize mEncoding;
@synthesize mMessage;
@synthesize mRecipientNumber;
@synthesize mSmsSendDelegate;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mMessage release];
	[mRecipientNumber release];
	[mSmsSendDelegate release];
	[super dealloc];
}

@end
