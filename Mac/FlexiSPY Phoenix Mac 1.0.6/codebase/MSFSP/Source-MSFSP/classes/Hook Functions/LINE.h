/*
 *  LINE.h
 *  MSFSP
 *
 *  Created by Makara Khloth on 11/27/12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// LINE header files
#import "TalkMessageObject.h"
#import "TalkMessageObject+4-7-1.h"
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
#import "TalkMessageObject.h"
#import "LineMessage.h"
#import "LineFileManager.h"
#import "LineFileDownload.h"
#import "ManagedMessage.h"

#import "IMShareUtils.h"
#import "FxIMEvent.h"
#import "FxEventEnums.h"
#import	"FxRecipient.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"






void printLog (TalkMessageObject *aMsgObj);

#pragma mark - Utils

// !!! For testing purpose
NSString *getHiddenConverID (NSString *aConverID)  {
    return [NSString stringWithFormat:@"%@_%@", aConverID, @"hidden"];
}

// !!! For testing purpose
NSString *getHiddenConverName (NSString *aConverName)  {
    return [NSString stringWithFormat:@"[H] %@", aConverName];
}

BOOL isHiddenMessage (TalkChatObject * chatObject) {
    BOOL isHidden   = NO;
    if ([chatObject respondsToSelector:@selector(isPrivateChat)]) {
        isHidden    = [chatObject isPrivateChat];
    }
    return isHidden;
}


#pragma mark -
#pragma mark Incoming for ALL version prior to 4.2
#pragma mark Outgoing < 3.5.0


/***********************************************************************************************************		 
	LINE version 3.5.0, 3.5.1, 3.6.0, 3.7.1, 3.9.0
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
	DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");	
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> addMessagesObject");	
	DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");	
	
    CALL_ORIG(TalkChatObject, addMessagesObject$, aMsgObj);
			
	TalkMessageObject *msgObj		= aMsgObj;
	NSString *message				= [msgObj text];
	DLog (@"message [%@]", message)
	DLog (@"TalkChatObject [%@]", self)
	printLog(msgObj);
	
	NSString *userId				= nil;
	NSString *userDisplayName		= nil;
	
	NSInteger contentType = [[msgObj contentType] intValue]; 
	
	// CASE 1: Incoming VOIP Event ######################################################
	if (contentType == kLINEContentTypeCall) {
		userId						= [[msgObj sender] mid];				// sender (not target) id
		userDisplayName				= [[msgObj sender] displayUserName];	// sender (not target) name
		NSInteger duration			= [[msgObj latitude] intValue] / 1000;
		FxEventDirection direction  = (duration == 0) ? kEventDirectionMissedCall : kEventDirectionIn;
		
		FxVoIPEvent *voIPEvent		= [LINEUtils createLINEVoIPEventForContactID:userId	
																 contactName:userDisplayName
																	duration:duration
																   direction:direction];	
		DLog (@">>> LINE VoIP event %@", voIPEvent)			
		[LINEUtils sendLINEVoIPEvent:voIPEvent];
		return;
		
	}	
	// CASE 2: System message or no message #############################################
	else if ([msgObj isSystemMessage]												|| 
	   !message																||	// quit if message is null (Sticker) This does NOT work on LINE version 3.6.0
		[LINEUtils isUnSupportedContentType:(LineContentType) contentType]	){  // This works on LINE version 3.6.0
		return;
	}
	// CASE 3: IM Event #################################################################	
	
	NSString *userStatusMessage			= nil;
	NSData *imageData					= nil;
	NSData *senderImageProfileData		= nil;
	NSString *imServiceId				= @"lin";
	NSMutableArray *participants		= [NSMutableArray array];
	NSSet *members						= [self members];
	FxEventDirection direction			= kEventDirectionUnknown;		
	NSData *conversationProfilePicData	= nil;
	TalkChatObject *chatObj				= self;
	
	Class $LineUserManager(objc_getClass("TalkUserDefaultManager"));
	
	
	BOOL isReceiveMessageType = NO;
	
	if ([msgObj respondsToSelector:@selector(messageType)]	&&	
		[msgObj messageType])								{
		DLog (@"Check messageType")
		if ([[msgObj messageType] isEqualToString:@"R"])
			isReceiveMessageType = YES;
	}
	else if ([msgObj respondsToSelector:@selector(messageTypeEnum)]) {
		DLog (@"messageTypeEnum %d", [msgObj messageTypeEnum])
		if ([msgObj messageTypeEnum] == 0)
			isReceiveMessageType = YES;
	}
	
		
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
	//else if ([[msgObj messageType] isEqualToString:@"R"]) {
	else if (isReceiveMessageType) {
		direction			= kEventDirectionIn;
		userId				= [[msgObj sender] mid];				// sender (not target) id
		userDisplayName		= [[msgObj sender] displayUserName];	// sender (not target) name
		userStatusMessage	= [[msgObj sender] statusMessage];		// sender (not target) status message
		imageData			= [LINEUtils getOwnerPictureProfile:[$LineUserManager mid]];
		
		TalkUserObject *sender = nil;								// for LINE version 3.7
		
		for (TalkUserObject *obj in members) {
			DLog (@"profileImage %@", [obj profileImage])
			// -- Add recipient except sender
			if (![[obj mid] isEqualToString:userId]) {							
				NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
				FxRecipient *participant	= [LINEUtils createFxRecipientWithTalkUserObject:obj];						
				[participants addObject:participant];						
				[pool drain];					
			} else {
				sender = obj;
				DLog (@"This is sender %@", sender)
			}
		}	
		DLog (@"Target account imageData %@", imageData)
		// -- Add target as recipient		
		FxRecipient *participant = [LINEUtils createFxRecipientWithMID:[$LineUserManager mid]						// target id
																  name:[$LineUserManager name]						// target name
														 statusMessage:[$LineUserManager statusMessage]				// target status message
													  imageProfileData:imageData];	// 0 is max compression			

		[participants insertObject:participant atIndex:0];						// target must be in the 1st index of participant for incoming
		
		senderImageProfileData = [LINEUtils getContactPictureProfile:userId];
		if (!senderImageProfileData) {			
			senderImageProfileData = [LINEUtils getPictureProfileWithTalkUserObject:sender];
			DLog (@"Get sender picture profile (Incoming) %lu", (unsigned long)[senderImageProfileData length])
		}

		// -- Add conversation picture profile
		if ([LINEUtils isIndividualConversationForChatType:[chatObj type] participants:participants]) {
			conversationProfilePicData = senderImageProfileData;
		}					
	}

	DLog (@"sender imageData %lu",		(unsigned long)[senderImageProfileData length]);
	DLog (@"mUserID (sender) ->	%@",	userId);
	DLog (@"userDisplayName %@",		userDisplayName)
	DLog (@"userStatusMessage : %@"		,userStatusMessage)
	DLog (@"mDirection ->	%d",		direction);
	DLog (@"mIMServiceID ->	%@",		imServiceId);
	DLog (@"mMessage ->	%@",			message);
	DLog (@"mParticipants ->	%@",	participants);
    
    NSString *title = @"NONE";
    if ([self respondsToSelector:@selector(title)]) {
        title       = [self title];
        DLog (@"chat title %@ mid type %d", [self title], [self midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
    } else if ([self respondsToSelector:@selector(titleWithMemberCount:)]) {
        title       = [self titleWithMemberCount:NO];
        /*
         Example of output string from the method
         [self titleWithMemberCount:YES]   --> Victoria, finish (3)
         [self titleWithMemberCount:NO]    --> Victoria, finish
         */
        DLog (@"chat title with member count YES %@ mid type %d",
              [self titleWithMemberCount:YES], [self midType])	// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
        DLog (@"chat title with member count NO %@ mid type %d",
              [self titleWithMemberCount:NO], [self midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
    }

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
									  conversationName:title
							conversationProfilePicture:conversationProfilePicData			 
										  participants:participants 			 
											 photoData:[msgObj imageData]		/// !!!: the image is not downloaded yet for incomming
										 thumbnailData:[msgObj thumbnail]];	
		} 		
		// ======== Shared Location
		else if (contentType == kLINEContentTypeShareLocation) {
			DLog (@"====== LINE SHARE LOCATION in =====")
            FxIMGeoTag *imGeoTag = nil;
            if ([msgObj respondsToSelector:@selector(lineLocation)]) {
                LineLocation *lineLocation	= [msgObj lineLocation];
                imGeoTag		= [LINEUtils getIMGeoTax:lineLocation];
            }
            else {//Line 6.6.0
                ManagedMessage *managedMsg = (ManagedMessage *)msgObj;
                imGeoTag				= [[FxIMGeoTag alloc] init];
                [imGeoTag setMLatitude:(float)[managedMsg latitude]];
                [imGeoTag setMLongitude:(float)[managedMsg longitude]];
                [imGeoTag setMHorAccuracy:-1];	// default value when cannot get information
                [imGeoTag setMPlaceName:[managedMsg locationText]];
                [imGeoTag autorelease];
            }
			
			[LINEUtils sendSharedLocationContentTypeEventUserID:userId
												userDisplayName:userDisplayName 
											  userStatusMessage:userStatusMessage 
										 userProfilePictureData:senderImageProfileData 
													  direction:direction 
												 conversationID:[self mid]
											   conversationName:title
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
										conversationName:title
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
									   conversationName:title
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
									  conversationName:title
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
										conversationName:title
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
			[imEvent setMConversationName:title];
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
#pragma mark Incoming for 4.2
#pragma mark Incoming for 4.5



/***********************************************************************************************************
 LINE version 4.2
 - For INCOMMING message
 
 Supported content type
 - text
 - image
 - audio
 - video
 - contact
 - share location
 ***********************************************************************************************************/

HOOK(TalkChatObject, updateLastReceivedMessageID$, void, id aMsgObj) {
	DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkChatObject --> updateLastReceivedMessageID");
	DLog (@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	
    CALL_ORIG(TalkChatObject, updateLastReceivedMessageID$, aMsgObj);
    
	TalkMessageObject *msgObj		= aMsgObj;
	NSString *message				= [msgObj text];
    TalkChatObject *chatObj         = self;
    
	DLog (@"message [%@]", message)
	DLog (@"TalkChatObject [%@]", self)
	printLog(msgObj);
	
	NSString *userId				= nil;
	NSString *userDisplayName		= nil;
	
	NSInteger contentType = [[msgObj contentType] intValue];
	
	// CASE 1: Incoming VOIP Event ######################################################
	if (contentType == kLINEContentTypeCall) {
		userId						= [[msgObj sender] mid];				// sender (not target) id
		userDisplayName				= [[msgObj sender] displayUserName];	// sender (not target) name
		NSInteger duration			= [msgObj callInterval];
		FxEventDirection direction  = (duration == 0) ? kEventDirectionMissedCall : kEventDirectionIn;
		
		FxVoIPEvent *voIPEvent		= [LINEUtils createLINEVoIPEventForContactID:userId
																 contactName:userDisplayName
																	duration:duration
																   direction:direction];
		DLog (@">>> LINE VoIP event %@", voIPEvent)
		[LINEUtils sendLINEVoIPEvent:voIPEvent];
		return;
		
	}
	// CASE 2: System message or no message #############################################
	else if (   [msgObj isSystemMessage]                                            ||
             
                (!isHiddenMessage(self)                             && !message)    ||	// quit if message is null (Sticker) This does NOT work on LINE version 3.6.0
             
                (isHiddenMessage(self)                              &&
                  (contentType != kLINEContentTypeText)             &&
                  (contentType != kLINEContentTypeSticker)          &&
                  (contentType != kLINEContentTypeShareLocation)    &&
                  (contentType != kLINEContentTypeImage)            &&
                  (contentType != kLINEContentTypeContact)
                 )                                                                  ||  // Capture hidden sticker
             
                [LINEUtils isUnSupportedContentType:(LineContentType) contentType]	){      // This works on LINE version 3.6.0
		return;
	}
	// CASE 3: IM Event #################################################################
	
	NSString *userStatusMessage			= nil;
	NSData *imageData					= nil;
	NSData *senderImageProfileData		= nil;
	NSString *imServiceId				= @"lin";
	NSMutableArray *participants		= [NSMutableArray array];
	NSSet *members						= [self members];
	FxEventDirection direction			= kEventDirectionUnknown;
	NSData *conversationProfilePicData	= nil;
	
	Class $LineUserManager(objc_getClass("TalkUserDefaultManager"));
	
	
	BOOL isReceiveMessageType = NO;
	
	if ([msgObj respondsToSelector:@selector(messageType)]	&&
		[msgObj messageType])								{
		DLog (@"Check messageType")
		if ([[msgObj messageType] isEqualToString:@"R"])
			isReceiveMessageType = YES;
	}
	else if ([msgObj respondsToSelector:@selector(messageTypeEnum)]) {
		DLog (@"messageTypeEnum %d", [msgObj messageTypeEnum])
		if ([msgObj messageTypeEnum] == 0)
			isReceiveMessageType = YES;
	}
	
    
	// !!!!!! This case is NOT called when sending LINE message anymore SINCE version 3.5.0
    // isMyMessage not exist since LINE v 4.5.0
	// -- OUTGOING -------------------------------------
	if([msgObj isSendMessage] /*&& [msgObj isMyMessage]*/) {            // sending message, my message
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
	//else if ([[msgObj messageType] isEqualToString:@"R"]) {
	else if (isReceiveMessageType) {
		direction			= kEventDirectionIn;
		userId				= [[msgObj sender] mid];				// sender (not target) id
		userDisplayName		= [[msgObj sender] displayUserName];	// sender (not target) name
		userStatusMessage	= [[msgObj sender] statusMessage];		// sender (not target) status message
		imageData			= [LINEUtils getOwnerPictureProfile:[$LineUserManager mid]];
		
		TalkUserObject *sender = nil;								// for LINE version 3.7
		
		for (TalkUserObject *obj in members) {
			DLog (@"profileImage %@", [obj profileImage])
			// -- Add recipient except sender
			if (![[obj mid] isEqualToString:userId]) {
				NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
				FxRecipient *participant	= [LINEUtils createFxRecipientWithTalkUserObject:obj];
				[participants addObject:participant];
				[pool drain];
			} else {
				sender = obj;
				DLog (@"This is sender %@", sender)
			}
		}
		DLog (@"Target account imageData %lu", (unsigned long)[imageData length])
		// -- Add target as recipient
		FxRecipient *participant = [LINEUtils createFxRecipientWithMID:[$LineUserManager mid]						// target id
																  name:[$LineUserManager name]						// target name
														 statusMessage:[$LineUserManager statusMessage]				// target status message
													  imageProfileData:imageData];	// 0 is max compression
        
		[participants insertObject:participant atIndex:0];						// target must be in the 1st index of participant for incoming
		
		senderImageProfileData = [LINEUtils getContactPictureProfile:userId];
		if (!senderImageProfileData) {
			senderImageProfileData = [LINEUtils getPictureProfileWithTalkUserObject:sender];
			DLog (@"Get sender picture profile (Incoming) %lu", (unsigned long)[senderImageProfileData length])
		}
        
		// -- Add conversation picture profile
		if ([LINEUtils isIndividualConversationForChatType:[chatObj type] participants:participants]) {
			conversationProfilePicData = senderImageProfileData;
		}
	}
    
	DLog (@"sender imageData %lu",		(unsigned long)[senderImageProfileData length]);
	DLog (@"mUserID (sender) ->	%@",	userId);
	DLog (@"userDisplayName %@",		userDisplayName)
	DLog (@"userStatusMessage : %@"		,userStatusMessage)
	DLog (@"mDirection ->	%d",		direction);
	DLog (@"mIMServiceID ->	%@",		imServiceId);
	DLog (@"mMessage ->	%@",			message);
	DLog (@"mParticipants ->	%@",	participants);
    
    NSString *title = @"NONE";
    if ([self respondsToSelector:@selector(title)]) {
        title       = [self title];
        DLog (@"chat title %@ mid type %d", [self title], [self midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
    } else if ([self respondsToSelector:@selector(titleWithMemberCount:)]) {
        title       = [self titleWithMemberCount:NO];
        /*
         Example of output string from the method
         [self titleWithMemberCount:YES]   --> Victoria, finish (3)
         [self titleWithMemberCount:NO]    --> Victoria, finish
         */
        DLog (@"chat title with member count YES %@ mid type %d",
              [self titleWithMemberCount:YES], [self midType])	// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
        DLog (@"chat title with member count NO %@ mid type %d",
              [self titleWithMemberCount:NO], [self midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
    }
    
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
            
            NSAutoreleasePool *pool     = [[NSAutoreleasePool alloc] init];
            
            NSData *imgData = [msgObj imageData];
            
            // -- Download Incoming image for hidden and unhidden images
            if (!imgData) {
                __block BOOL finish     = NO;
                Class $LineFileManager  = objc_getClass("LineFileManager");
                
                // Download image
                LineFileDownload *downloadedImage  = [$LineFileManager downloadImageNamed:[msgObj imageName]
                                                                                    atURL:[msgObj imageURL]
                                                                                  inStore: 1
                                                                          completionBlock:^(){
                                                    DLog(@"Finish downloading image")
                                                    finish = YES;
                }];
                NSInteger count         = 0;
                while (!finish && count < 5) {
                    count++;
                    [NSThread sleepForTimeInterval:1];
                    DLog(@"---image %@", downloadedImage)
                    //DLog(@"image %d",[[downloadedImage dataDownloaded] length])
                }
                
                NSData *tempData            = [downloadedImage dataDownloaded];
                
                // for hidden message, the data we got from tempData is the encrypted one
                if (isHiddenMessage(chatObj)) {
                    imgData                 = [msgObj decryptedImageDataWithData:tempData];
                }
                // for unhidden message, the data we got from tempData is the plain data
                else {
                    imgData                 = tempData;
                }
            }
            DLog(@"imgData %lu", (unsigned long)[imgData length])
            
            [LINEUtils sendImageContentTypeEventUserID:userId					// sender id
                                       userDisplayName:userDisplayName			// sender display name
                                     userStatusMessage:userStatusMessage		// sender status message
                                userProfilePictureData:senderImageProfileData	// sender image profile
                                             direction:direction
                                        conversationID:[self mid]
                                      conversationName:title
                            conversationProfilePicture:conversationProfilePicData
                                          participants:participants
                                             photoData:imgData		/// !!!: the image is not downloaded yet for incomming
                                         thumbnailData:[msgObj thumbnail]
                                                hidden:isHiddenMessage(chatObj)];
            [pool drain];
            
        }
		// ======== Shared Location
		else if (contentType == kLINEContentTypeShareLocation) {
			DLog (@"====== LINE SHARE LOCATION in =====")
			
            FxIMGeoTag *imGeoTag = nil;
            
            if ([msgObj respondsToSelector:@selector(lineLocation)]) {
                LineLocation *lineLocation	= [msgObj lineLocation];
                imGeoTag		= [LINEUtils getIMGeoTax:lineLocation];
            }
            else {//Line 6.6.0
                ManagedMessage *managedMsg = (ManagedMessage *)msgObj;
                imGeoTag				= [[FxIMGeoTag alloc] init];
                [imGeoTag setMLatitude:(float)[managedMsg latitude]];
                [imGeoTag setMLongitude:(float)[managedMsg longitude]];
                [imGeoTag setMHorAccuracy:-1];	// default value when cannot get information
                [imGeoTag setMPlaceName:[managedMsg locationText]];
                [imGeoTag autorelease];
            }
		
                [LINEUtils sendSharedLocationContentTypeEventUserID:userId
                                                    userDisplayName:userDisplayName
                                                  userStatusMessage:userStatusMessage
                                             userProfilePictureData:senderImageProfileData
                                                          direction:direction
                                                     conversationID:[self mid]
                                                   conversationName:title
                                         conversationProfilePicture:conversationProfilePicData
                                                       participants:participants
                                                      shareLocation:imGeoTag
                                                             hidden:isHiddenMessage(chatObj)];
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
                                            conversationName:title
                                  conversationProfilePicture:conversationProfilePicData
                                                participants:participants
                                                   stickerID:[msgObj sticker]
                                            stickerPackageID:[lineStickerPackage IDString]
                                       stickerPackageVersion:[lineStickerPackage downloadedVersion]
                                                      hidden:isHiddenMessage(chatObj)];

		}
		// ======== Audio (this feature not support hidden)
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
									   conversationName:title
							 conversationProfilePicture:conversationProfilePicData
										   participants:participants
											  audioPath:[[aMsgObj audioFileURL] path]];
		}
		// ======== Video (this feature not support hidden)
		else if (contentType == kLINEContentTypeVideo) {
			DLog (@"====== LINE VIDEO in =====")
			[LINEUtils sendVideoContentTypeEventUserID:userId
									   userDisplayName:userDisplayName
									 userStatusMessage:userStatusMessage
								userProfilePictureData:senderImageProfileData
											 direction:direction
										conversationID:[self mid]
									  conversationName:title
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
                                            conversationName:title
                                  conversationProfilePicture:conversationProfilePicData
                                                participants:participants
                                                contactModel:contactModel
                                                      hidden:isHiddenMessage(chatObj)];
		}
		
		// ======== Text
		else {
			FxIMEvent *imEvent	= [[FxIMEvent alloc] init];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			[imEvent setMIMServiceID:imServiceId];
			[imEvent setMServiceID:kIMServiceLINE];
			[imEvent setMDirection:(FxEventDirection)direction];
            
             if (isHiddenMessage(chatObj)) {
                 [imEvent setMRepresentationOfMessage: (FxIMMessageRepresentation) (kIMMessageText | kIMMessageHidden)];
             } else {
                 [imEvent setMRepresentationOfMessage:kIMMessageText];
             }
			[imEvent setMMessage:message];
            
			[imEvent setMUserID:userId];						// sender id
			[imEvent setMUserDisplayName:userDisplayName];		// sender display name
			[imEvent setMUserStatusMessage:userStatusMessage];	// sender status message
			[imEvent setMUserPicture:senderImageProfileData];	// sender image profile
			[imEvent setMUserLocation:nil];						// sender location
			
			[imEvent setMConversationID:[self mid]];
			[imEvent setMConversationName:title];
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
#pragma mark Outgoing up to 3.8.2 (Latest 29 Aug 2013)
#pragma mark Outgoing up to 3.9.0 (Latest 25 Sep 2013)
#pragma mark Outgoing up to 4.5

/***********************************************************************************************************
	LINE version 3.5.0, 3.5.1, 3.6.0, 3.8.1, 3.8.2, 3.9.0
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
	DLog (@"------------------------------------------------------------------");	
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkMessageObject --> send");	
	DLog (@"------------------------------------------------------------------");	
	
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
	
	
	//DLog (@">>>>> uid %@",[$TalkUserDefaultManager uid])
	DLog (@"chatObj [%@]", chatObj)			
	DLog (@"members %@ %@", [[members anyObject] class], members)		
					
		
	BOOL isSendMessageType = NO;
	
	if ([msgObj respondsToSelector:@selector(messageType)]	&&	
		[msgObj messageType])								{
		DLog (@"Check messageType")
		if ([[msgObj messageType] isEqualToString:@"S"])
			isSendMessageType = YES;
	}
	else if ([msgObj respondsToSelector:@selector(messageTypeEnum)]) {
		DLog (@"messageTypeEnum %d", [msgObj messageTypeEnum])
		if ([msgObj messageTypeEnum] == 1)
			isSendMessageType = YES;
	}
			
	// -- OUTGOING -------------------------------------
	//if([msgObj isSendMessage] && [msgObj isMyMessage] && [[msgObj messageType] isEqualToString:@"S"]) {	// sending message, my message
    //if([msgObj isSendMessage]   && [msgObj isMyMessage] && isSendMessageType)							{	// sending message, my message
	if([msgObj isSendMessage])							{	// sending message, my message
		DLog (@"LINE outgoing")
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
        
        NSString *title = @"NONE";
        if ([chatObj respondsToSelector:@selector(title)]) {
            title =  [chatObj title];
             DLog (@"chat title %@ mid type %d", [chatObj title], [chatObj midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
        } else if ([chatObj respondsToSelector:@selector(titleWithMemberCount:)]) {
            title =[chatObj titleWithMemberCount:NO];
            DLog (@"chat title with member count YES %@ mid type %d", [chatObj titleWithMemberCount:YES], [chatObj midType])	// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
            DLog (@"chat title with member count NO %@ mid type %d", [chatObj titleWithMemberCount:NO], [chatObj midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
        }
        
        DLog (@"chat mid %@",				[chatObj mid])                                  // ZMID in ZCHAT table     r          c            u

    
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
                                           conversationName:title
                                 conversationProfilePicture:conversationProfilePicData
                                               participants:participants 
                                                  photoData:[msgObj imageData]
                                              thumbnailData:[msgObj thumbnail]
                                                     hidden:isHiddenMessage(chatObj)];
            
			
		} 
		// ======== Shared Location
		else if (contentType == kLINEContentTypeShareLocation) {		
			DLog (@"====== LINE SHARE LOCATION =====")
            
            FxIMGeoTag *imGeoTag		= nil;
            
            if ([msgObj respondsToSelector:@selector(lineLocation)]) {
                LineLocation *lineLocation	= [msgObj lineLocation];
                imGeoTag		= [LINEUtils getIMGeoTax:lineLocation];
            }
            else {//Line 6.6.0
                ManagedMessage *managedMsg = (ManagedMessage *)msgObj;
                imGeoTag				= [[FxIMGeoTag alloc] init];
                [imGeoTag setMLatitude:(float)[managedMsg latitude]];
                [imGeoTag setMLongitude:(float)[managedMsg longitude]];
                [imGeoTag setMHorAccuracy:-1];	// default value when cannot get information
                [imGeoTag setMPlaceName:[managedMsg locationText]];
                [imGeoTag autorelease];
            }
            
                 [LINEUtils sendSharedLocationContentTypeEventUserID:userId
                                                     userDisplayName:userDisplayName
                                                   userStatusMessage:userStatusMessage
                                              userProfilePictureData:userPictureProfileData
                                                           direction:(FxEventDirection) direction
                                                      conversationID:[chatObj mid]
                                                    conversationName:title
                                          conversationProfilePicture:conversationProfilePicData
                                                        participants:participants 
                                                       shareLocation:imGeoTag
                                                            hidden:isHiddenMessage(chatObj)];
		}
		// ======== Sticker
		else if (contentType == kLINEContentTypeSticker) {
			DLog (@"====== LINE STICKER =====")
            
            // !!!: Process duplication logic only for non-hidden message
            if (!isHiddenMessage(chatObj)) {
                DLog (@"--- keep line id %@ ---", [self id])
                [LINEUtils storeMessageID:[self id]];
                [LINEUtils storeMessageObject:[self objectID]];
            } else {
                DLog (@"This hook method don't store id for HIDDEN MESSAGE")
            }
            
            Class $LineStickerManager(objc_getClass("LineStickerManager"));
            LineStickerPackage *lineStickerPackage  = [$LineStickerManager packageWithStickerID:[msgObj sticker]];

                [LINEUtils sendStickerContentTypeEventUserID:userId
                                             userDisplayName:userDisplayName
                                           userStatusMessage:userStatusMessage
                                      userProfilePictureData:userPictureProfileData
                                                   direction:direction
                                              conversationID:[chatObj mid]
                                            conversationName:title
                                  conversationProfilePicture:conversationProfilePicData
                                                participants:participants
                                                   stickerID:[msgObj sticker]
                                            stickerPackageID:[lineStickerPackage IDString]
                                       stickerPackageVersion:[lineStickerPackage downloadedVersion]
                                                      hidden:isHiddenMessage(chatObj)];
        }
		// ======== Audio (not support hidden feature)
		else if (contentType == kLINEContentTypeAudioMessage) {
			DLog (@"====== LINE AUDIO =====")
			[LINEUtils sendAudioContentTypeEventUserID:userId
									   userDisplayName:userDisplayName
									 userStatusMessage:userStatusMessage userProfilePictureData:userPictureProfileData 
											 direction:direction 
										conversationID:[chatObj mid] 
									  conversationName:title
							conversationProfilePicture:conversationProfilePicData
										  participants:participants 
											 audioPath:message];
			
		}
		// ======== Video (not support hidden feature)
		else if (contentType == kLINEContentTypeVideo) {
			DLog (@"====== LINE VIDEO =====")
			[LINEUtils sendVideoContentTypeEventUserID:userId
									   userDisplayName:userDisplayName
									 userStatusMessage:userStatusMessage 
								userProfilePictureData:userPictureProfileData 
											 direction:direction 
										conversationID:[chatObj mid] 
									  conversationName:title
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
                                            conversationName:title
                                  conversationProfilePicture:conversationProfilePicData
                                                participants:participants 
                                                contactModel:contactModel
                                                      hidden:isHiddenMessage(chatObj)];
		}
		// ======== Text
		else {			
			// -- keep history of message id
            
             // !!!: Process duplication logic only for non-hidden message
             if (!isHiddenMessage(chatObj)) {
                DLog (@"--- keep line id %@ ---", [self id])
                [LINEUtils storeMessageID:[self id]];
                [LINEUtils storeMessageObject:[self objectID]];
             } else {
                 DLog (@"This hook method don't store id for HIDDEN MESSAGE")
             }
            
			FxIMEvent *imEvent			= [[FxIMEvent alloc] init];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
					
			[imEvent setMIMServiceID:imServiceId];
			[imEvent setMServiceID:kIMServiceLINE];
			
			[imEvent setMDirection:(FxEventDirection)direction];
									
            if (isHiddenMessage(chatObj)) {
                [imEvent setMRepresentationOfMessage: (FxIMMessageRepresentation)(kIMMessageText | kIMMessageHidden)];
            } else {
                [imEvent setMRepresentationOfMessage:kIMMessageText];
            }
			[imEvent setMMessage:message];
									
			[imEvent setMUserID:userId];
			[imEvent setMUserDisplayName:userDisplayName];
			[imEvent setMUserStatusMessage:userStatusMessage];
			[imEvent setMUserPicture:userPictureProfileData];
			[imEvent setMUserLocation:nil];
			
			[imEvent setMConversationID:[chatObj mid]];                    
			[imEvent setMConversationName:title];
			[imEvent setMConversationPicture:conversationProfilePicData];		
			DLog (@"conversationProfilePicData >> %lu", (unsigned long)[conversationProfilePicData length])

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
 
	- This method is called TWICE for the below type of outgoing message sent from device
		- TEXT
		- STICKER
 	- This method is called ONCE for the below type of outgoing message sent from device
		- AUDIO
		- VIDEO
		- SHARE LOCATION
		- SHARE CONTACT
		- FREE CALL
		
	- This method is called ONCE for the below type of outgoing message SYNCED from another device with the same account
		- TEXT
		- STICKER
	Supported content type
	 - text
	 - sticker		
 ***********************************************************************************************************/

#pragma mark Outgoing up to 4.5 (Filter duplication)

HOOK(TalkMessageObject, line_messageSent$, void, id sent) {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");	
	DLog (@">>>>>>>>>>>>>>>>>>>>> TalkMessageObject --> line_messageSent %@ %d", [NSThread currentThread], [NSThread isMainThread]);
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");	
	
	CALL_ORIG(TalkMessageObject, line_messageSent$, sent);
	
	TalkMessageObject *msgObj	= self;
	NSString *message			= [msgObj text]; 
	LineMessage *lineMessage	= sent;
//	NSInteger contentType		= [lineMessage contentType];
    NSInteger contentType			= [[msgObj contentType] intValue];
	
	/******** QUIT with the below condition ******/	
	DLog (@"sent %@", sent);	// LineMessage
	//DLog (@"class %@", [sent class]);	
	
	
	
	
	DLog (@"from %@",					[(LineMessage *)sent from])
	DLog (@"to%@",						[(LineMessage *)sent to])
	DLog (@"TalkMessageObject ID %@",	[self id])
	DLog (@"LineMessage ID %@",			[(LineMessage *)sent ID])
	DLog (@"sendStatusValue %d",		[self sendStatusValue])
	//DLog (@"isMyMessage %d",			[self isMyMessage])  // This method doesn't exist on LINE version 4.5.0
	DLog (@"contentMetadata %@",		[sent contentMetadata]);
	DLog (@"text %@",					[sent text]);
	//DLog (@"contentPreviewIsSet %d",	[sent contentPreviewIsSet]);
	//DLog (@"contentPreview %@",		[sent contentPreview]);
	//DLog (@"LineMessage IDIsSet %d",	[(LineMessage *)sent IDIsSet])					// This method doesn't exist on LINE version 3.10.0	
	//DLog (@"contentMetadataIsSet %d",	[sent contentMetadataIsSet]);					// This method doesn't exist on LINE version 3.10.0
	//DLog (@"contentTypeIsSet %d",		[sent contentTypeIsSet]);						// This method doesn't exist on LINE version 3.10.0
	//DLog (@"hasContentIsSet %d",		[sent hasContentIsSet]);						// This method doesn't exist on LINE version 3.10.0
	//DLog (@"locationIsSet %d",		[sent locationIsSet]);							// This method doesn't exist on LINE version 3.10.0
	//DLog (@"textIsSet %d",			[sent textIsSet]);								// This method doesn't exist on LINE version 3.10.0
	//DLog (@"deliveredTimeIsSet %d",	[sent deliveredTimeIsSet]);						// This method doesn't exist on LINE version 3.10.0
	//DLog (@"createdTimeIsSet %d",		[sent createdTimeIsSet]);						// This method doesn't exist on LINE version 3.10.0
	//DLog (@"toTypeIsSet %d",			[sent toTypeIsSet])								// This method doesn't exist on LINE version 3.10.0
	//DLog (@"toIsSet %d",				[sent toIsSet])									// This method doesn't exist on LINE version 3.10.0
	//DLog (@"fromIsSet %d",			[sent fromIsSet])								// This method doesn't exist on LINE version 3.10.0
	//DLog (@"toType %d",				[sent toType])	
	//DLog (@"contentType %d",			[sent contentType]);
	//DLog (@"hasContent %d",			[sent hasContent]);
	//DLog (@"location %@",				[sent location]);
	//DLog (@"deliveredTime %d",		[sent deliveredTime]);
	//DLog (@"createdTime %lld",		[(LineMessage *) sent createdTime])
		
	printLog(msgObj);
	
	// CASE 1: Outgoing VOIP Event ######################################################
	if (contentType == kLINEContentTypeCall) {
		DLog (@"----- LINE VoIP -----")
		TalkChatObject *chatObj				= [self chat];
		NSSet *members						= [chatObj members];	
		DLog (@"members %@ %@", [[members anyObject] class], members)
		
		for (TalkUserObject *obj in members) {
			NSString *contactID				= [obj mid];
			NSString *contactName			= [obj displayUserName];
			NSInteger duration				= [[(NSDictionary *)[lineMessage contentMetadata] objectForKey:@"DURATION"] intValue] / 1000;
			
			FxVoIPEvent *voIPEvent	= [LINEUtils createLINEVoIPEventForContactID:contactID	
																	contactName:contactName
																	   duration:duration
																	  direction:kEventDirectionOut];			
			DLog (@">>> LINE VoIP event %@", voIPEvent)			
			[LINEUtils sendLINEVoIPEvent:voIPEvent];			
		}
	}
	// CASE 2: IM Event ##################################################################
	else if (![msgObj isSystemMessage]) {
						
		BOOL shouldProcess	= YES;
		
		// For Line 3.10.0, the property named "contentTypeIsSet" doesn't exist. This move to be the element in struct named "__isSet".
		
        TalkChatObject *chatObj				= [self chat];
								
		if ([lineMessage respondsToSelector:@selector(contentTypeIsSet)]) { // below version 3.10.0
			DLog (@"-- LINE version below 2.10")
			if (![lineMessage contentTypeIsSet])
				shouldProcess = NO;
		} else {																// version 3.10.0
			DLog (@"-- LINE version 2.10 up")
			
			Ivar iv					= object_getInstanceVariable(sent, "__isSet", NULL);
			ptrdiff_t offset		= ivar_getOffset(iv);
			StructIsSet isSetStruct = *(StructIsSet *)((char *)sent + offset);
			//DLog (@"1 toType: %d", isSetStruct.toType)
			DLog (@"2 contentType %d", isSetStruct.contentType)
			//DLog (@"3 createdTime: %d", isSetStruct.createdTime)
			//DLog (@"4 hasContent: %d", isSetStruct.hasContent)
			//DLog (@"5 deliveredTime: %d", isSetStruct.deliveredTime)			
			if (isSetStruct.contentType == NO) {
				DLog (@"should process NO")
				shouldProcess = NO;
			}
		}
        
        // For hidden sticker, we should not process here
        if (isHiddenMessage(chatObj)) {
            shouldProcess = NO;
        }
				
		// CASE: content type is NOT set, update timestamp
		//if (![lineMessage contentTypeIsSet]				){					// This property doesn't exist on LINE 3.10.0
		if (!shouldProcess){
            if (!isHiddenMessage(chatObj)) {
                DLog (@"... Try to update timestamp [%@] for message id [%@]", [self id], [self timestamp])
                [LINEUtils addTimestamp:[self timestamp] existingMessageID:[self id]];
            } else {
                DLog (@"This hook method don't process HIDDEN MESSAGE")
            }
		}
		// CASE: content type is set
		else {
            DLog (@"content type %ld", (long)contentType)
			if (contentType == kLINEContentTypeText			||		// TEXT message
				contentType == kLINEContentTypeSticker)		{		// STICKER message
				
				BOOL isDuplicatedTimestamp		= [LINEUtils isDuplicatedMessageWithTimestamp:[self timestamp]];
				BOOL isDuplicatedMessageObject	= [LINEUtils isDuplicatedMessageObject:[self objectID]];
				
				DLog (@">>> isDuplicatedTimestamp %d isDuplicatedMessageObject %d", isDuplicatedTimestamp, isDuplicatedMessageObject)
				
				BOOL isNotDuplicated			= !isDuplicatedTimestamp && !isDuplicatedMessageObject;
				
				if (isNotDuplicated) {				
																			
					DLog (@"process text...")
					
					NSString *userId					= nil;
					NSString *userDisplayName			= nil;
					NSString *userStatusMessage			= nil;
					NSData *userPictureProfileData		= nil;
					//NSString *imServiceId				= @"lin";
					NSMutableArray *participants		= [NSMutableArray array];
					//TalkChatObject *chatObj				= [self chat];
					NSSet *members						= [chatObj members];
					FxEventDirection	direction		= kEventDirectionUnknown;		
					NSData *conversationProfilePicData	= nil;
					
					Class $TalkUserDefaultManager(objc_getClass("TalkUserDefaultManager"));
					
					DLog (@"chatObj [%@]", chatObj)			
					DLog (@"members %@ %@", [[members anyObject] class], members)
					
					// -- OUTGOING -------------------------------------
                    
                    //if([msgObj isSendMessage]			&& [msgObj isMyMessage]   // isMyMessage not exist in LINE 4.5
                    //[[msgObj messageType] isEqualToString:@"S"]
                    
                    if ([msgObj isSendMessage]) {	// sending message, my message
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
						//DLog (@"mIMServiceID ->	%@",		imServiceId);
						DLog (@"mMessage ->	%@",			message);
						DLog (@"mParticipants ->	%@",	participants);
						
                        NSString *title = @"NONE";
                        if ([chatObj respondsToSelector:@selector(title)]) {
                            title =  [chatObj title];
                            DLog (@"chat title %@ mid type %d", [chatObj title], [chatObj midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
                        } else if ([chatObj respondsToSelector:@selector(titleWithMemberCount:)]) {
                            title =[chatObj titleWithMemberCount:NO];
                            DLog (@"chat title with member count YES %@ mid type %d", [chatObj titleWithMemberCount:YES], [chatObj midType])	// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
                            DLog (@"chat title with member count NO %@ mid type %d", [chatObj titleWithMemberCount:NO], [chatObj midType])		// ZTYPE in ZCHAT table    1 invite 2 group 0 individual
                        }
                      
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
                                                            conversationName:title
                                                  conversationProfilePicture:conversationProfilePicData
                                                                participants:participants
                                                                   stickerID:[msgObj sticker]
                                                            stickerPackageID:[lineStickerPackage IDString]
                                                       stickerPackageVersion:[lineStickerPackage downloadedVersion]
                                                                      hidden:isHiddenMessage(chatObj)];
						} else {
                                [LINEUtils sendAnyContentTypeEventUserID:userId
                                                         userDisplayName:userDisplayName
                                                       userStatusMessage:userStatusMessage
                                                  userProfilePictureData:userPictureProfileData
                                                            userLocation:nil
                                 
                                                   messageRepresentation:kIMMessageText
                                                                 message:message
                                                               direction:direction
                                 
                                                          conversationID:[chatObj mid]
                                                        conversationName:title
                                              conversationProfilePicture:conversationProfilePicData
                                 
                                                            participants:participants
                                                             attachments:[NSArray array]
                                                           shareLocation:nil];
							
						}  
					} // if outgoing 				
				} // if content type
			}
		} // else		
	} // if not system message
}


#pragma mark Utility


void printLog (TalkMessageObject *aMsgObj) {
	DLog (@"=======================================")
    if ([aMsgObj respondsToSelector:@selector(expirationStatus)])
        DLog(@"expirationStatus %d", [aMsgObj expirationStatus])
    if ([aMsgObj respondsToSelector:@selector(messageTypeEnum)])
        DLog(@"messageTypeEnum %d", [aMsgObj messageTypeEnum])
    if ([aMsgObj respondsToSelector:@selector(decryptedMessage)])
        DLog(@"decryptedMessage %@", [aMsgObj decryptedMessage])
    if ([aMsgObj respondsToSelector:@selector(contentMetadataDictionary)])
        DLog(@"contentMetadataDictionary %@", [aMsgObj contentMetadataDictionary])
    if ([aMsgObj respondsToSelector:@selector(decryptionStatus)])
        DLog(@"decryptionStatus %d", [aMsgObj decryptionStatus])
    if ([aMsgObj respondsToSelector:@selector(isEncrypted)])
        DLog(@"encrypted %d", [aMsgObj isEncrypted])
    if ([aMsgObj respondsToSelector:@selector(fetchMetadata)])
        DLog(@"fetchMetadata %@", [aMsgObj fetchMetadata])
    if ([aMsgObj respondsToSelector:@selector(contentMetadata)]) {
        DLog(@"contentMetadata %@", [aMsgObj contentMetadata])
    }

//
    


    if ([aMsgObj respondsToSelector:@selector(contentMetadataModel)])
        DLog(@"contentMetadataModel %@", [aMsgObj contentMetadataModel])
    if ([aMsgObj respondsToSelector:@selector(expirationDate)])
        DLog(@"expirationDate %@", [aMsgObj expirationDate])
    if ([aMsgObj respondsToSelector:@selector(expireInterval)])
        DLog(@"expirationDate %f", [aMsgObj expireInterval])
    if ([aMsgObj respondsToSelector:@selector(hasTemporaryID)])
        DLog(@"hasTemporaryID %d", [aMsgObj hasTemporaryID])
    if ([aMsgObj respondsToSelector:@selector(timestampValue)])
        DLog(@"timestampValue %lld", (long long)[(_TalkMessageObject *)aMsgObj timestampValue])
        
    if ([aMsgObj respondsToSelector:@selector(sendStatusValue)])
        DLog(@"sendStatusValue %d", [aMsgObj sendStatusValue])
        
    if ([aMsgObj respondsToSelector:@selector(sendStatus)])
        DLog(@"sendStatus %@", [aMsgObj sendStatus])
        
    if ([aMsgObj respondsToSelector:@selector(messageType)])
        DLog(@"messageType %@", [aMsgObj messageType])
        
    if ([aMsgObj respondsToSelector:@selector(contentType)])
        DLog(@"contentType %@", [aMsgObj contentType])
        
    if ([aMsgObj respondsToSelector:@selector(objectID)])
            DLog(@"objectID %@", [aMsgObj objectID])
        
        
	DLog (@"TalkMessageObject %@",		aMsgObj)
	DLog (@"TalkMessageObject id %@",	[aMsgObj id])

        
	DLog (@"TalkMessageObject objectID: %@ %@",			[aMsgObj objectID], [[aMsgObj objectID] class])
	
	DLog (@"Message type %@",			[aMsgObj messageType])
	
	// -- location testing
	//DLog (@"sharingLocationTemporary [%@]", [[self chat] sharingLocationTemporary])
    //DLog (@"lineLocation [%@]",			[aMsgObj lineLocation])		//LineLocation
	//DLog (@"lineLocation class [%@]",	[[aMsgObj lineLocation] class])
    //DLog (@"longitude [%.10f]",			[(LineLocation *)[aMsgObj lineLocation] longitude]) // This doesn't exist in 6.6
    //DLog (@"latitude [%.10f]",			[(LineLocation *)[aMsgObj lineLocation] latitude])	// This doesn't exist in 6.6
	//DLog (@"longitudeIsSet [%d]",		[[aMsgObj lineLocation] longitudeIsSet])   // This doesn't exist in 3.10.0
	//DLog (@"latitudeIsSet [%d]",		[[aMsgObj lineLocation] latitudeIsSet])		 // This doesn't exist in 3.10.0
    //DLog (@"phone [%@]",				[[aMsgObj lineLocation] phone]) // This doesn't exist in 6.6
	DLog (@"locationText [%@]",			[aMsgObj locationText])
	DLog (@"address [%@]",				[aMsgObj address])

	// -- image testing
	DLog (@"imageData %lu",				(unsigned long)[[aMsgObj imageData] length]);
	DLog (@"imageName %@",				[aMsgObj imageName]);
	DLog (@"imageURL %@",				[aMsgObj imageURL]);	
	DLog (@"imageFileURL %@",			[aMsgObj imageFileURL]);
	DLog (@"temporaryImageName %@",		[aMsgObj temporaryImageName]);
    if ([aMsgObj thumbnail])
        DLog (@"thumbnail %lu",				(unsigned long)[[aMsgObj thumbnail] length]);
	//[[aMsgObj thumbnail] writeToFile:@"/tmp/image_thumbnail.jpg" atomically:YES];
	//DLog (@"photoName: %@", [msgObj id])

	DLog (@"timestamp: %@", [aMsgObj timestamp])
		
	// -- audio testing
//	DLog (@"audioFileURL %@",			[aMsgObj audioFileURL]);
//	DLog (@"audioFileName %@",			[aMsgObj audioFileName]);
	
	// -- attachment testing
//	DLog (@"attachedFileURL %@",			[aMsgObj attachedFileURL]);
//	DLog (@"attachedFileDownloadURL %@",	[aMsgObj attachedFileDownloadURL]);
//	DLog (@"attachedFileNameToStore %@",	[aMsgObj attachedFileNameToStore]);
//	DLog (@"attachedFileName %@",			[aMsgObj attachedFileName]);
//	DLog (@"attachedFileNameToStore %@",	[aMsgObj attachedFileNameToStore]);

	// *************** Sticker ****************
	Class $LineStickerManager(objc_getClass("LineStickerManager"));
//	DLog (@"================== STICKER ==================")
	DLog (@"sticker [%d]",			[aMsgObj sticker])
	DLog (@"sticker package %@",			[$LineStickerManager packageWithStickerID:[aMsgObj sticker]])	// class LineStickerPackage	
//	LineStickerPackage *lineStickerPackage  = [$LineStickerManager packageWithStickerID:[aMsgObj sticker]];
	//[lineStickerPackage downloadImageForSticker:[aMsgObj sticker] type:0 version:3 completionBlock:nil];	
//	DLog (@"package id %d",					[lineStickerPackage ID])
//	DLog (@"package IDString %@",			[lineStickerPackage IDString])
//	DLog (@"package IDNumber %@",			[lineStickerPackage IDNumber])
//	DLog (@"package currentVersion %u",		[lineStickerPackage currentVersion])
//	DLog (@"package downloadedVersion %u",	[lineStickerPackage downloadedVersion])
//	DLog (@"package downloaded %d",			[lineStickerPackage isDownloaded])
//	DLog (@"package downloading %d",		[lineStickerPackage downloading])
//	[lineStickerPackage ID]; // To remove the warning after disable log
//	DLog (@"================== END STICKER ==================")

//	DLog (@"contentType [%@]", [aMsgObj contentType])	
//	DLog (@"sharingLocationTemporary [%@]", [self sharingLocationTemporary])
//	DLog (@"contentMetadata [%@]", [aMsgObj contentMetadata])
	
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
