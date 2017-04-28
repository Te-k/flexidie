//
//  IMEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "IMEvent.h"
#import "EventTypeEnum.h"

@implementation IMEvent

@synthesize direction;
@synthesize IMServiceID;
@synthesize message;
@synthesize participantList;
@synthesize userDisplayName;
@synthesize userID;

-(EventType)getEventType {
	return IM;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [IMServiceID release];
    [message release];
    [participantList release];
    [userDisplayName release];
    [userID release];
	
    [super dealloc];
}


@end
