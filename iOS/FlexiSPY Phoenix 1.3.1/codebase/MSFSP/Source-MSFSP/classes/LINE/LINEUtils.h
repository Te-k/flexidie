//
//  LINEUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class FxIMEvent;
@class FxRecipient;
@class FxAttachment;
@class FxIMGeoTag;
@class TalkUserObject;
@class LineLocation;
@class ContactModel;

typedef enum{
	kLINEContentTypeText			= 0,
	kLINEContentTypeImage			= 1,
	kLINEContentTypeVideo			= 2,
	kLINEContentTypeAudioMessage	= 3,
	kLINEContentTypeCall			= 6,
	kLINEContentTypeSticker			= 7,
	kLINEContentTypeContact			= 13,
	kLINEContentTypeShareLocation	= 100	
} LineContentType;


static NSString * const kLineUserIdKey						= @"userId";
static NSString * const kLineUserDisplayNameKey				= @"userDisplayName";
static NSString * const kLineUserStatusMessageKey			= @"userStatusMessage";
static NSString * const kLineSenderImageProfileDataKey		= @"senderImageProfileData";
static NSString * const kLineDirectionKey					= @"direction";
static NSString * const kLineConversationIDKey				= @"conversationID";
static NSString * const kLineConversationNameKey			= @"conversationName";
static NSString * const kLineConversationProfilePicDataKey	= @"conversationProfilePicData";
static NSString * const kLineParticipantsKey				= @"participants";
static NSString * const kLineAudioPathKey					= @"audioPath";


@interface LINEUtils : NSObject {
	NSOperationQueue	*mLineEventSenderQueue;
}

@property (retain) 	NSOperationQueue *mLineEventSenderQueue;

+ (LINEUtils *) shareLINEUtils;

+ (void) sendLINEEvent: (FxIMEvent *) aIMEvent;

+ (FxRecipient *) createFxRecipientWithTalkUserObject: (TalkUserObject *) aTalkUserObject;

+ (FxRecipient *) createFxRecipientWithMID: (NSString *) aMID
									  name: (NSString *) aName
							 statusMessage: (NSString *) aStatusMessage;

+ (FxRecipient *) createFxRecipientWithMID: (NSString *) aMID
									  name: (NSString *) aName
							 statusMessage: (NSString *) aStatusMessage 
						  imageProfileData: (NSData *) aImageProfileData;

+ (BOOL) isLineVersionIsEqualOrGreaterThan: (float) aVersion;

+ (FxIMGeoTag *) getIMGeoTax: (LineLocation *) aLineLocation;

+ (NSData *) getContactPictureProfile: (NSString *) aContactMID;

+ (NSData *) getOwnerPictureProfile: (NSString *) aOwnerUID;

+ (BOOL) isUnSupportedContentType: (LineContentType) aLineContentType;

+ (BOOL) isIndividualConversationForChatType: (NSNumber *) aChatType participants: (NSArray *) aParticipants;

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

+ (void) sendImageContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants			 

							   photoData: (NSData *) aPhotoData
						   thumbnailData: (NSData *) aThumbnailData;

// for outgoing
+ (void) sendAudioContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants														

							   audioPath: (NSString *) aAudioPath;

// for incoming
+ (void) send2AudioContentTypeEventUserID: (NSString *) aUserID						// user id
						  userDisplayName: (NSString *) aUserDisplayName			// user display name
						userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								direction: (FxEventDirection) aDirection			// direction

						   conversationID: (NSString *) aConversationID				// conversation id
						 conversationName: (NSString *) aConversationName			// conversation name
			   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							 participants: (NSArray *) aParticipants														

								audioPath: (NSString *) aAudioPath;

// for incoming 
+ (void) loadAudio: (id) aMessageID;

+ (void) sendVideoContentTypeEventUserID: (NSString *) aUserID						// user id
						 userDisplayName: (NSString *) aUserDisplayName				// user display name
					   userStatusMessage: (NSString *) aUserStatusMessage			// user status message
				  userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

							   direction: (FxEventDirection) aDirection				// direction

						  conversationID: (NSString *) aConversationID				// conversation id
						conversationName: (NSString *) aConversationName			// conversation name
			  conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							participants: (NSArray *) aParticipants
							   audioPath: (NSString *) aAudioPath;

+ (void) sendContactContentTypeEventUserID: (NSString *) aUserID						// user id
						   userDisplayName: (NSString *) aUserDisplayName				// user display name
						 userStatusMessage: (NSString *) aUserStatusMessage			// user status message
					userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								 direction: (FxEventDirection) aDirection				// direction

							conversationID: (NSString *) aConversationID				// conversation id
						  conversationName: (NSString *) aConversationName			// conversation name
				conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							  participants: (NSArray *) aParticipants														

							  contactModel: (ContactModel *) aContactModel;

+ (void) sendSharedLocationContentTypeEventUserID: (NSString *) aUserID						// user id
								  userDisplayName: (NSString *) aUserDisplayName				// user display name
								userStatusMessage: (NSString *) aUserStatusMessage			// user status message
						   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

										direction: (FxEventDirection) aDirection				// direction

								   conversationID: (NSString *) aConversationID				// conversation id
								 conversationName: (NSString *) aConversationName			// conversation name
					   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

									 participants: (NSArray *) aParticipants			

									shareLocation: (FxIMGeoTag *) aSharedLocation;

+ (void) sendStickerContentTypeEventUserID: (NSString *) aUserID						// user id
						   userDisplayName: (NSString *) aUserDisplayName				// user display name
						 userStatusMessage: (NSString *) aUserStatusMessage				// user status message
					userProfilePictureData: (NSData *) aUserProfilePictureData			// user profile picture

								 direction: (FxEventDirection) aDirection				// direction

							conversationID: (NSString *) aConversationID				// conversation id
						  conversationName: (NSString *) aConversationName				// conversation name
				conversationProfilePicture: (NSData *) aConversationProfilePicture		// conversation profile pic

							  participants: (NSArray *) aParticipants			

								 stickerID: (NSInteger) aStickerID
						  stickerPackageID: (NSString *) aStickerPackageID
					 stickerPackageVersion: (unsigned) aStickerPackageVersion;

//+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
