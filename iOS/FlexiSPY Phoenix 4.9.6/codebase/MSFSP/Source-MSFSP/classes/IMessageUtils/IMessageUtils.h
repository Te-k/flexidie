//
//  IMessageUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMMessage, FxIMEvent, IMChat;

@interface IMessageUtils : NSObject {
@private
	NSInteger mLastMessageID;
}

@property (nonatomic, assign) NSInteger mLastMessageID;

+ (IMessageUtils *) shareIMessageUtils;

+ (BOOL) sendData: (NSData *) aData;

+ (void) captureAttachmentsAndSendFromMessage: (IMMessage *) aMessage toEvent: (FxIMEvent *) aIMEvent;

+ (FxIMEvent *) incomingIMEventWithChat: (IMChat *) aIMChat message: (IMMessage *) aIMMessage;
+ (FxIMEvent *) outgoingIMEventWithChat: (IMChat *) aIMChat message: (IMMessage *) aIMMessage;

@end
