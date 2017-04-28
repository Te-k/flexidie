//
//  EmailEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "EmailEvent.h"
#import "EventTypeEnum.h"

@implementation EmailEvent

@synthesize attachmentStore;
@synthesize direction;
@synthesize emailBody;
@synthesize recipientStore;
@synthesize contactName;
@synthesize senderEmail;
@synthesize subject;

-(EventType)getEventType {
	return MAIL;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [attachmentStore release];
    [emailBody release];
    [recipientStore release];
    [contactName release];
    [senderEmail release];
    [subject release];
	
    [super dealloc];
}



@end
