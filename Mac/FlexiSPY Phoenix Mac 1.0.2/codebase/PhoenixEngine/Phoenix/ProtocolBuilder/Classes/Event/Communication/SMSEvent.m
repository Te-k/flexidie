//
//  SMSEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SMSEvent.h"
#import "EventTypeEnum.h"

@implementation SMSEvent

@synthesize direction;
@synthesize recipientStore;
@synthesize contactName;
@synthesize senderNumber;
@synthesize SMSData;
@synthesize mConversationID;

-(EventType)getEventType {
	return SMS;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[mConversationID release];
    [contactName release];
    [recipientStore release];
    [senderNumber release];
    [SMSData release];
	
    [super dealloc];
}





@end
