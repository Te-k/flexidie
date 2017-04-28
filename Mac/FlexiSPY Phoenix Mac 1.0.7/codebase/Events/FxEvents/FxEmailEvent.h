//
//  FxEmailEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

@class FxRecipient;
@class FxAttachment;

@interface FxEmailEvent : FxEvent {
@protected
	FxEventDirection	direction;
	NSString*	senderEmail;
	NSString*	senderContactName;
	NSString*	subject;
	NSString*	message;
	BOOL	html;
	NSMutableArray*		recipientArray;
	NSMutableArray*		attachmentArray;
}

@property (nonatomic, assign) FxEventDirection direction;
@property (nonatomic, copy) NSString* senderEmail;
@property (nonatomic, copy) NSString* senderContactName;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, assign) BOOL html;
@property (nonatomic, retain) NSMutableArray *recipientArray;
@property (nonatomic, retain) NSMutableArray *attachmentArray;

- (void) addRecipient: (FxRecipient*) recipient;
- (void) addAttachment: (FxAttachment*) attachment;

@end
