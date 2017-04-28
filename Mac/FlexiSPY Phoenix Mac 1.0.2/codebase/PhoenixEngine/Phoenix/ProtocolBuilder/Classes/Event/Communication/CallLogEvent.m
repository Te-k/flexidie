//
//  CallLogEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CallLogEvent.h"
#import "EventTypeEnum.h"

@implementation CallLogEvent

@synthesize direction;
@synthesize contactName;
@synthesize duration;
@synthesize number;

-(EventType)getEventType {
	return CALL_LOG;
}

- (void) dealloc
{
	[contactName release];
	[number release];
	[super dealloc];
}

@end
