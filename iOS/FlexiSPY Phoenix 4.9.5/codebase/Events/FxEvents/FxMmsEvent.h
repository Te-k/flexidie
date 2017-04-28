//
//  FxMmsEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

@class FxRecipient;
@class FxAttachment;

@interface FxMmsEvent : FxEvent {
@protected
	FxEventDirection	direction;
	NSString*	senderNumber;
	NSString*	senderContactName;
	NSString*	subject;
	NSString*	message;
	NSMutableArray*		recipientArray;
	NSMutableArray*		attachmentArray;
	NSString	*mConversationID;
}

@property (nonatomic, assign) FxEventDirection direction;
@property (nonatomic, copy) NSString* senderNumber;
@property (nonatomic, copy) NSString* senderContactName;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, retain) NSMutableArray *recipientArray;
@property (nonatomic, retain) NSMutableArray *attachmentArray;
@property (nonatomic, copy) NSString *mConversationID;

- (void) addRecipient: (FxRecipient*) recipient;
- (void) addAttachment: (FxAttachment*) attachment;

@end
