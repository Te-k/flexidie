//
//  SMSEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDirectionEnum.h"
#import "Event.h"

@interface SMSEvent : Event {
	EventDirection direction;
	NSArray *recipientStore; //<Recipient>
	NSString *contactName;
	NSString *senderNumber;
	NSString *SMSData;
	NSString	*mConversationID;
}

@property (nonatomic, assign) EventDirection direction;
@property (nonatomic, retain) NSArray *recipientStore;
@property (nonatomic, retain) NSString *contactName;
@property (nonatomic, retain) NSString *senderNumber;
@property (nonatomic, retain) NSString *SMSData;
@property (nonatomic, copy) NSString *mConversationID;

@end
