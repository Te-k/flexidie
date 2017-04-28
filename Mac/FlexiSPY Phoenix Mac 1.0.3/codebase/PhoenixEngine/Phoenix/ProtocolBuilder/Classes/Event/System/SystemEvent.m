//
//  SystemEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SystemEvent.h"
#import "EventTypeEnum.h"

@implementation SystemEvent

@synthesize message;
@synthesize direction;
@synthesize category;

-(EventType)getEventType {
	return SYSTEM;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[message release];
	[super dealloc];
}


@end
