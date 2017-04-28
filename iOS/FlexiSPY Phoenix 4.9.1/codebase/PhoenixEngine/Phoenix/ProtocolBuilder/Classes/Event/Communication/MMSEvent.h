//
//  MMSEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDirectionEnum.h"
#import "Event.h"

@interface MMSEvent : Event {
	EventDirection direction;
	NSMutableArray *attachmentStore; // <Attachment>
	NSMutableArray *recipientStore; // <Recipient>
	NSString *contactName;
	NSString *senderNumber;
	NSString *subject;
	NSString *mConversationID;
	NSString *mText;
}

@property (nonatomic, retain) NSMutableArray *attachmentStore;
@property (nonatomic, retain) NSString *contactName;
@property (nonatomic, assign) EventDirection direction;
@property (nonatomic, retain) NSMutableArray *recipientStore;
@property (nonatomic, retain) NSString *senderNumber;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, copy) NSString *mConversationID;
@property (nonatomic, copy) NSString *mText;

@end
