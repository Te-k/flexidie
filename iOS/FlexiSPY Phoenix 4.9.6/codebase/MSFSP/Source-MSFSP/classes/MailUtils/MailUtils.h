/**
 - Project name :  MSFSP
 - Class name   :  MailUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MailType.h"

@class SharedFile2IPCSender;

@interface MailUtils : NSObject {
	SharedFile2IPCSender	*mMailSharedFileSender;
}

@property (retain) SharedFile2IPCSender *mMailSharedFileSender;

+ (MailUtils *) sharedMailUtils;

- (void) outgoingMessageWithOutgoingMessageDelivery: (id) aMessage 
										andContents: (id) aContents;

- (void) outgoingMessageWithOutgoingMessageDelivery: (id) aMessage
									andContentArray: (id) aContentArray;

- (void) incomingWithMessage: (id) aMessage 
				 andMimeBody: (id) aMimeBody;

- (void) deliveredOutgoingMail: (double) aTimeStamps;
- (void) removeUnsentMail: (double) aTimeStamps;

@end
