//
//  MMSEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "MMSEvent.h"
#import "EventTypeEnum.h"

@implementation MMSEvent

@synthesize attachmentStore;
@synthesize contactName;
@synthesize direction;
@synthesize recipientStore;
@synthesize senderNumber;
@synthesize subject;
@synthesize mConversationID;
@synthesize mText;

-(EventType)getEventType {
	return MMS;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[mText release];
	[mConversationID release];
    [attachmentStore release];
    [contactName release];
    [recipientStore release];
    [senderNumber release];
    [subject release];
	
    [super dealloc];
}



@end
