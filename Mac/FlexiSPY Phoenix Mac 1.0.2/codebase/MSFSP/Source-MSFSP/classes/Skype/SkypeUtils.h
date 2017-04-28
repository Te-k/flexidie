//
//  SkypeUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class FxIMEvent, FxVoIPEvent;
@class SKMessage, ConversationLists, DomainObjectPool, SKPCallEventMessage;
@class FxRecipient, SharedFile2IPCSender;

@interface SkypeUtils : NSObject {
	SKMessage	*mLastSKMessage;
	ConversationLists	*mConversationLists;
	DomainObjectPool	*mDomainObjectPool;
	
	SharedFile2IPCSender	*mIMSharedFileSender;
	SharedFile2IPCSender	*mVOIPSharedFileSender;
}

@property (retain) SKMessage *mLastSKMessage;
@property (retain) ConversationLists *mConversationLists;
@property (retain) DomainObjectPool *mDomainObjectPool;

@property (retain) SharedFile2IPCSender *mIMSharedFileSender;
@property (retain) SharedFile2IPCSender *mVOIPSharedFileSender;

+ (SkypeUtils *) sharedSkypeUtils;

+ (void) sendSkypeEvent: (FxIMEvent *) aIMEvent;
+ (void) sendSkypeVoIPEvent: (FxVoIPEvent *) aVoIPEvent;
+ (BOOL) isMissVoIPCall: (FxEventDirection) aDirection
				message: (SKMessage *) aMessage;
+ (FxVoIPEvent *) createSkypeVoIPEventForMessage: (SKMessage *) aMessage
									   direction: (FxEventDirection) aDirection
									   recipient: (FxRecipient *) aRecipient;

// For skype version 5.x
+ (FxVoIPEvent *) createSkypeVoIPEventForMessagev2: (SKPCallEventMessage *) aMessage
                                         direction: (FxEventDirection) aDirection
                                         recipient: (FxRecipient *) aRecipient;

- (void) capturePhotoAttachment; // For Skype 4.9.x.x onward

@end
