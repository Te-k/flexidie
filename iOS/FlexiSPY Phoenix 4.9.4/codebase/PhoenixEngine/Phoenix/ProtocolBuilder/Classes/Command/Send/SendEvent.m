//
//  SendEvent.m
//  PhoenixPorting1
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendEvent.h"

@implementation SendEvent

@synthesize eventCount;
@synthesize eventProvider;

- (CommandCode)getCommand {
	return SEND_EVENTS;
}

- (void) dealloc {
	[eventProvider release];
	[super dealloc];
}

@end
