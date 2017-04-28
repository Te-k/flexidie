
/**
 - Project name :  MSFSP
 - Class name   :  SMSUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  31/1/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import <Foundation/Foundation.h>

@class CKSMSMessage;

@interface SMSUtils : NSObject {

}

+ (void) createEvent: (id) aMessage
		   recipient: (id) aRecipient
	  blockEventType: (NSInteger) aBlockEventType
		   direction: (NSInteger) aDirection;
+ (NSArray *) messageParts: (CKSMSMessage *) aMessage;
+ (BOOL) isSMS: (NSArray *) aMessageParts;
+ (BOOL) isParticipantsHasEmailAddress: (NSArray *) aParticipants;
+ (BOOL) isIOS5;
+ (BOOL) isIOS4;

@end
