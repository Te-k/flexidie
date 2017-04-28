//
//  FxSmsEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

@class FxRecipient;

@interface FxSmsEvent : FxEvent {
@protected
	NSString*	contactName;
	NSString*	senderNumber;
	NSString*	smsSubject;
	NSString*	smsData;
	FxEventDirection direction;
	NSMutableArray*	recipientArray;
	NSString	*mConversationID;
}

@property (nonatomic, copy) NSString* contactName;
@property (nonatomic, copy) NSString* senderNumber;
@property (nonatomic, copy) NSString* smsSubject;
@property (nonatomic, copy) NSString* smsData;
@property (nonatomic, assign) FxEventDirection direction;
@property (nonatomic, retain) NSMutableArray *recipientArray;
@property (nonatomic, copy) NSString *mConversationID;

- (void) addRecipient: (FxRecipient*) recipient;

@end
