//
//  IMessageUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMMessage, FxIMEvent;

@interface IMessageUtils : NSObject {
@private
	NSInteger mLastMessageID;
}

@property (nonatomic, assign) NSInteger mLastMessageID;

+ (IMessageUtils *) shareIMessageUtils;

+ (BOOL) sendData: (NSData *) aData;

+ (void) captureAttachmentsAndSendFromMessage: (IMMessage *) aMessage toEvent: (FxIMEvent *) aIMEvent;

@end
