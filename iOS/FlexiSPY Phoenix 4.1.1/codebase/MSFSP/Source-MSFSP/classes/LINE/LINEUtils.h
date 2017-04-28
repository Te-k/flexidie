//
//  LINEUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"
#import "FxIMEvent.h"
#import "VideoDownloadOperation.h"

@class FxIMEvent;
@class FxRecipient;
@class FxAttachment;
@class FxIMGeoTag;
@class TalkUserObject;
@class LineLocation;
@class ContactModel;
@class FxVoIPEvent;
@class SharedFile2IPCSender;

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


@interface LINEUtils : NSObject <VideoDownloadDelegate> {
	NSOperationQueue	*mLineEventSenderQueue;
    NSOperationQueue    *mLineVideoDownloadQueue;
	NSMutableDictionary	*mOutgoingMessageDictionary;
	NSMutableArray		*mOutgoingMessageArray;				// used for indexing
	NSMutableArray		*mOutgoingMessageObjectArray;
	
	SharedFile2IPCSender	*mIMSharedFileSender;
	SharedFile2IPCSender	*mVOIPSharedFileSender;
}

@property (retain) NSOperationQueue *mLineEventSenderQueue;
@property (retain) NSOperationQueue *mLineVideoDownloadQueue;

@property (retain) NSMutableDictionary *mOutgoingMessageDictionary;
@property (retain) NSMutableArray *mOutgoingMessageArray;
@property (retain) NSMutableArray *mOutgoingMessageObjectArray;

@property (retain) SharedFile2IPCSender	*mIMSharedFileSender;
@property (retain) SharedFile2IPCSender *mVOIPSharedFileSender;

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

//+ (BOOL) isLineVersionIsEqualOrGreaterThan: (float) aVersion;

+ (FxIMGeoTag *) getIMGeoTax: (LineLocation *) aLineLocation;

+ (NSData *) getContactPictureProfile: (NSString *) aContactMID;

+ (NSData *) getPictureProfileWithTalkUserObject: (TalkUserObject *) aTalkUserObject; // For LINE v 3.7

+ (NSData *) getOwnerPictureProfile: (NSString *) aOwnerUID;

+ (BOOL) isUnSupportedContentType: (LineContentType) aLineContentType;

+ (BOOL) isIndividualConversationForChatType: (NSNumber *) aChatType participants: (NSArray *) aParticipants;

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

// for prevent duplicated outgoing message
+ (void) storeMessageID: (id) aMessageID;
+ (void) addTimestamp: (NSNumber *) aTimestamp
	existingMessageID: (NSString *) aMessageID;
+ (BOOL) isDuplicatedMessageWithTimestamp: (NSNumber *) aTimestamp;

+ (void) storeMessageObject : (id) aMessageObject;
+ (BOOL) isDuplicatedMessageObject: (id) aMessageObject;

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
						   thumbnailData: (NSData *) aThumbnailData
                                  hidden: (BOOL) aIsHidden ;

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

+ (void) sendContactContentTypeEventUserID: (NSString *) aUserID						// user id
						   userDisplayName: (NSString *) aUserDisplayName				// user display name
						 userStatusMessage: (NSString *) aUserStatusMessage			// user status message
					userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

								 direction: (FxEventDirection) aDirection				// direction

							conversationID: (NSString *) aConversationID				// conversation id
						  conversationName: (NSString *) aConversationName			// conversation name
				conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

							  participants: (NSArray *) aParticipants

							  contactModel: (ContactModel *) aContactModel
                                    hidden: (BOOL) aIsHidden;

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

+ (void) sendSharedLocationContentTypeEventUserID: (NSString *) aUserID						// user id
								  userDisplayName: (NSString *) aUserDisplayName				// user display name
								userStatusMessage: (NSString *) aUserStatusMessage			// user status message
						   userProfilePictureData: (NSData *) aUserProfilePictureData		// user profile picture

										direction: (FxEventDirection) aDirection				// direction

								   conversationID: (NSString *) aConversationID				// conversation id
								 conversationName: (NSString *) aConversationName			// conversation name
					   conversationProfilePicture: (NSData *) aConversationProfilePicture	// conversation profile pic

									 participants: (NSArray *) aParticipants

									shareLocation: (FxIMGeoTag *) aSharedLocation
                                           hidden: (BOOL) aIsHidden;

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
					 stickerPackageVersion: (unsigned) aStickerPackageVersion
                                    hidden: (BOOL) aIsHidden;

+ (void) sendAnyContentTypeEventUserID: (NSString *) aUserID						// user id
					   userDisplayName: (NSString *) aUserDisplayName				// user display name
					 userStatusMessage: (NSString *) aUserStatusMessage				// user status message
				userProfilePictureData: (NSData *) aUserProfilePictureData			// user profile picture
						  userLocation: (FxIMGeoTag *) aUserLocation

				 messageRepresentation: (FxIMMessageRepresentation) aMessageRepresentation
							   message: (NSString *) aMessage
							 direction: (FxEventDirection) aDirection				// direction

						conversationID: (NSString *) aConversationID				// conversation id
					  conversationName: (NSString *) aConversationName				// conversation name
			conversationProfilePicture: (NSData *) aConversationProfilePicture		// conversation profile pic

						  participants: (NSArray *) aParticipants														

						   attachments: (NSArray *) aAttachments

						 shareLocation: (FxIMGeoTag *) aSharedLocation;

+ (void) sendLINEVoIPEvent: (FxVoIPEvent *) aVoIPEvent;

+ (FxVoIPEvent *) createLINEVoIPEventForContactID: (NSString *) aContactID
									  contactName: (NSString *) aContactName
										 duration: (NSInteger) aDuration
										direction: (FxEventDirection) aDirection;

+ (FxAttachment *) attachment: (NSData *) aActualData thumbnail: (NSData *) aThumbnailData extension: (NSString *) aExtension;
	
//+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
