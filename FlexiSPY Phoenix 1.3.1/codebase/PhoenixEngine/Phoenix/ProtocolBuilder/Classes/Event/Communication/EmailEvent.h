//
//  EmailEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDirectionEnum.h"
#import "Event.h"

@interface EmailEvent : Event {
	EventDirection direction;
	NSArray *attachmentStore; // <Attachment>
	NSArray *recipientStore; //<Recipient>
	NSString *emailBody;
	NSString *contactName;
	NSString *senderEmail;
	NSString *subject;
}

@property (nonatomic, assign) EventDirection direction;
@property (nonatomic, retain) NSArray *attachmentStore;
@property (nonatomic, retain) NSArray *recipientStore;
@property (nonatomic, retain) NSString *emailBody;
@property (nonatomic, retain) NSString *contactName;
@property (nonatomic, retain) NSString *senderEmail;
@property (nonatomic, retain) NSString *subject;

@end
