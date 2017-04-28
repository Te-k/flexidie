/**
 - Project name :  MSFSP
 - Class name   :  WhatsAppUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  25/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class FMDatabase;
@class BlockEvent;
@class WAChatStorage;
@class WAMessage;


@interface WhatsAppUtils : NSObject {
@private
	FMDatabase		*mWhatsAppDB;
	NSDictionary	*mAccountInfo;
	
	
	NSArray			*mParticipantArray;		// for outgoing
	NSArray			*mRecipientArray;		// for outgoing
	
	NSString		*mSenderContactName;
}


@property (nonatomic, retain) NSDictionary *mAccountInfo;
@property (nonatomic, retain) NSArray *mParticipantArray;
@property (nonatomic, retain) NSArray *mRecipientArray;
@property (nonatomic, retain) NSString *mSenderContactName;


+ (BlockEvent *)	createBlockEventForWhatsAppWithParticipant: (NSArray *) aParticipantArray 
											  withDirection: (NSInteger) aDirection;
+ (NSArray *)		createFxRecipientArray: (NSArray *) aParticipantArray;
+ (NSString *)		formatWhatsAppID:(NSString*) aWID;
//+ (NSString *)		getSender: (id) aArg;
+ (id)				incomingMessageParts: (id) aArg;
+ (NSString *)		getPhoneNumberWithCountryCode;
+ (NSString *)		getSenderOfIncomingMessage: (WAMessage *) aMessage;



// Outgoing
- (NSArray *)		getRecipientFromDBForOutgoingEvent: (NSString *) aMessageID;
- (void)			retrieveParticipantFromDBForOutgoingEvent: (id) aOutGoingEvent;

// Incoming
- (NSArray *)		getParticipantForIncomingEvent: (id) aOutGoingEvent excludeSender: (NSString *)sender;
- (NSDictionary *)	accountInfo:(NSString *) aUserID 
					  userName:(NSString *) aUserName;
- (void)			sendWhatsAppEventForMessage: (NSString *) aMessage		
							senderID: (NSString *) aSender
						  senderName: (NSString *) aSenderName
						participants: (NSArray *) aParticipantArray 
						   direction: (FxEventDirection) aDirection;
- (void)			outgoingEventSendingThread: (id) aMessage;

@end
