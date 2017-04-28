//
//  FacebookUtilsV2.m
//  MSFSP
//
//  Created by Makara on 8/1/14.
//
//
#import "MSFSPUtils.h"

#import "FacebookUtilsV2.h"
#import "FacebookSerialOperation.h"
#import "FacebookUtils.h"
#import "IMShareUtils.h"
#import "UIImage+WebP.h"

#import "FBMAuthenticationManagerImpl.h"

#import "FBMParticipantInfo.h"
#import "FBMParticipantInfo+Messenger-9-1.h"
#import "FBMParticipantInfo+Messenger-29-1.h"
#import "FBMessengerUser.h"
#import "FBMessengerUser+Messenger-29-1.h"
#import "UserSet.h"
#import "UserSet+Messenger-9-1.h"

#import "FBMUserSet.h"

#import "FBMThread.h"
#import "FBMThread+27-0.h"
#import "FBMThread+Messenger-29-1.h"
#import "FBMThread+Messenger-47-0.h"

#import "FBMMessage.h"
#import "FBMMessage+Facebook-12.h"
#import "FBMMessage+Messenger-9-1.h"
#import "FBMMessage+27-0.h"
#import "FBMMessage+28-0.h"
#import "FBMMessage+Messenger-31-0.h"
#import "FBMMessage+Messenger-35-0.h"
#import "FBMMessage+54-0.h"

#import "FBMPushedMessage.h"
#import "FBMPushedMessage+Messenger-9-1.h"
#import "FBMPushedMessage+Messenger-29-1.h"
#import "FBMMutableMessage.h"
#import "FBMMutableMessage+Messenger-29-1.h"

#import "FBMSPMessage.h"
#import "FBMUserSettings.h"
#import "FBMStickerStoragePathManager.h"
#import "FBMStickerStoragePathManager+Messenger-9-1.h"

#import "FBMStickerAttachment.h"
#import "FBMPhotoAttachment.h"
#import "FBMPhotoAttachment+Messenger-17-0.h"
#import "FBMAudioAttachment.h"
#import "FBMVideoAttachment.h"
#import "Share.h"
#import "FBMPhoto.h"
#import "FBMPhoto+Messenger-17-0.h"
// 30.1
#import "FBMMessageAttachment.h"
#import "FBMMessageAttachment+54-0.h"
#import "FBMMessageAttachments.h"
#import "FBMMessageAttribution.h"
#import "FBMMessageAttribution+77-0.h"

#import "FBMAttachmentURLParams.h"
#import "FBMBaseAttachmentURLFormatter.h"

#import "FBMSticker.h"
#import "FBMSticker+Messenger-9-1.h"

// Messenger 17.0
#import "MNAuthenticationManagerImpl.h"

#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "DateTimeFormat.h"
#import "FxAttachment.h"
#import "DaemonPrivateHome.h"

// Messegner 21.1
#import "FBMStringWithRedactedDescription.h"

#import "FBMMessageLocation.h"
#import "FBMMessage+Messenger-23-1.h"

#import "FBMUser.h"
#import "FBMLocationAttachment.h"
#import "FBMLocationAttachmentData.h"
#import "FBMLocationAttachmentDataToSend.h"
#import "FBMessagePackCoder.h"
#import "FBMemExtensibleMessageAttachment.h"
#import "FBMemStoryAttachment.h"
#import "FBMemMessageLocation.h"
#import "FBMemLocation.h"
#import "FBMemTextWithEntities.h"

#import "FBMThreadSet.h"
#import "FBMThreadSet+Messenger-35-0.h"

// 54.0
#import "FBMMessageExtensibleAttachment.h"
#import "FBMAdminText.h"
#import "FBMStickerManager.h"
#import "FBMStickerManager+54-0.h"
#import "FBMStickerView.h"
#import "FBMStickerResourceManager.h"
#import "FBMStickerResourceManagerLegacy.h"

// 76.0
#import "FBStringWithRedactedDescription.h"

// 77.0
#import "FBMThreadSummary.h"
#import "FBMIndexedThreadParticipationInfoSet.h"
#import "FBMThreadSummaryTypeProperties.h"
#import "FBMGroupThreadProperties.h"
#import "FBMThreadParticipationInfo.h"
#import "FBMSyncedThreadKey.h"
#import "FBMCanonicalThreadKey.h"
#import "FBMGroupThreadKey.h"

// Facebook 60.0 and Messenger 80.0
#import "MNAuthenticationManagerImpl+60-0.h"
#import "DefStd.h"

#import <objc/runtime.h>
#import <CoreLocation/CoreLocation.h>

// Facebook Messenger 93.0
#import "FBMStickerView+93-0.h"

void logFBAttachment(FBMAttachment *aAttachment);
void logFBMessageAttachment(FBMMessageAttachment *aAttachment);

void logFBMessage(id aMessage) {
    DLog(@"------------------------- logFBMessage (%@) -----------------------------", [aMessage class]);
    
    /*
     - Messenger 10.0, aMessage is an object of class FBMMutableMessage
     */
    
    FBMMessage *fbmMessage = aMessage;
    DLog(@"------------------------- FBMMessage -----------------------------");
    if ([fbmMessage respondsToSelector:@selector(isSnippetMessage)]) {
        // This property is no longer exist in Messenger 11.0
        DLog(@"isSnippetMessage         = %d", [fbmMessage isSnippetMessage]);
    }
    if ([fbmMessage respondsToSelector:@selector(adminSnippet)]) {
        DLog(@"adminSnippet                 = %@", [fbmMessage adminSnippet]);  // No this selector in header since 27.0 but instance response to this selector ??? (Completely removed 35.0)
    }
    if ([fbmMessage respondsToSelector:@selector(adminText)]) {             // Messenger 27.0 down
        DLog(@"adminText                    = %@", [fbmMessage adminText]);
    }
    DLog(@"text                         = [%@] %@", [[fbmMessage text] class], [fbmMessage text]);
    if ([fbmMessage respondsToSelector:@selector(isIncomplete)]) { // Below 35.0
        DLog(@"isIncomplete                 = %d", [fbmMessage isIncomplete]);
    }
    DLog(@"logMessage                   = %@", [fbmMessage logMessage]);
    if ([fbmMessage respondsToSelector:@selector(shareMap)]) {
        DLog(@"shareMap                     = %@", [fbmMessage shareMap]);
    }
    if ([fbmMessage respondsToSelector:@selector(hasPaymentAttachments)]) {
        DLog(@"hasPaymentAttachments        = %d", [fbmMessage hasPaymentAttachments]);
    }
    if ([fbmMessage respondsToSelector:@selector(numberOfPaymentAttachments)]) {
        DLog(@"numberOfPaymentAttachments   = %d", [fbmMessage numberOfPaymentAttachments]);
    }
    if ([fbmMessage respondsToSelector:@selector(paymentAttachments)]) {
        DLog(@"paymentAttachments           = %@", [fbmMessage paymentAttachments]);
    }
    if ([fbmMessage respondsToSelector:@selector(source)]) { // Below 35.0
        DLog(@"source                       = %d", [fbmMessage source]);
    }
    DLog(@"senderId                     = %@", [fbmMessage senderId]);
    if ([fbmMessage respondsToSelector:@selector(threadId)]) {
        DLog(@"threadId                     = %@", [fbmMessage threadId]);  // Messenger 19.1 down
    } else if ([fbmMessage respondsToSelector:@selector(DEPRECATED_threadId)]) {
        DLog(@"threadId %@", [fbmMessage DEPRECATED_threadId])              // Messenger 21.1 up
    }
    if ([fbmMessage respondsToSelector:@selector(threadFbId)]) {
        DLog(@"threadFbId                   = %@", [fbmMessage threadFbId]);
    }
    DLog(@"messageId                    = %@", [fbmMessage messageId]);
    if ([fbmMessage respondsToSelector:@selector(location)]) { // Below 35.0
        DLog(@"location                     = %@", [fbmMessage location]);
    }
    if ([fbmMessage respondsToSelector:@selector(attachments)]) {
        DLog(@"attachments                  = %@", [fbmMessage attachments]);
    }
    if ([fbmMessage respondsToSelector:@selector(coordinates)]) {
        DLog(@"coordinates                  = %@", [fbmMessage coordinates]);
    }
    
    DLog(@"tags                         = %@", [fbmMessage tags]);
    if ([fbmMessage respondsToSelector:@selector(DEPRECATED_senderInfo)]) {
        DLog(@"DEPRECATED_senderInfo    = %@", [fbmMessage DEPRECATED_senderInfo]);
    }
    if ([fbmMessage respondsToSelector:@selector(outgoingAttachments)]) { // Below 35.0
        DLog(@"outgoingAttachments          = %@", [fbmMessage outgoingAttachments]);
        for (id attachment in [fbmMessage outgoingAttachments]) {
            logFBAttachment(attachment);
        }
    }
    DLog(@"timestamp                    = %lld", [fbmMessage timestamp]);
    DLog(@"actionId                     = %lld", [fbmMessage actionId]);
    DLog(@"type                         = %d", [fbmMessage type]);
    if ([fbmMessage respondsToSelector:@selector(placeholder)]) {
        // This property is no longer exist in Messenger 11.0
        DLog(@"placeholder              = %d", [fbmMessage placeholder]);
    }
    DLog(@"offlineThreadingId           = %@", [fbmMessage offlineThreadingId]);
    if ([fbmMessage respondsToSelector:@selector(sendTimestamp)]) { // Below 35.0
        DLog(@"sendTimestamp                = %lld", [fbmMessage sendTimestamp]);
    }
    if ([fbmMessage respondsToSelector:@selector(sendState)]) { // Below 35.0
        DLog(@"sendState                    = %d", [fbmMessage sendState]);
    }
    if ([fbmMessage respondsToSelector:@selector(sendNonRetriable)]) { // Below 35.0
        DLog(@"sendNonRetriable             = %d", [fbmMessage sendNonRetriable]);
    }
    if ([fbmMessage respondsToSelector:@selector(sendNonRetriableErrorText)]) { // Below 35.0
        DLog(@"sendNonRetriableErrorText    = %@", [fbmMessage sendNonRetriableErrorText]);
    }
    if ([fbmMessage respondsToSelector:@selector(sendHasFailedBefore)]) { // Below 35.0
        DLog(@"sendHasFailedBefore          = %d", [fbmMessage sendHasFailedBefore]);
    }
    if ([fbmMessage respondsToSelector:@selector(analyticsSessionID)]) {
        // This property is no longer exist in Messenger 10.0
        DLog(@"analyticsSessionID       = %@", [fbmMessage analyticsSessionID]);
    }
    if ([fbmMessage respondsToSelector:@selector(clientTags)]) {
        DLog(@"clientTags               = %@", [(FBMMutableMessage *)fbmMessage clientTags]);
    }
    
    Class $FBMPushedMessage = objc_getClass("FBMPushedMessage");
    if ([aMessage isKindOfClass:$FBMPushedMessage]) {
        FBMPushedMessage *fbmPushedMessage = aMessage;
        DLog(@"------------------------- FBMPushedMessage -----------------------------");
        DLog(@"pushSource                       = %d", [fbmPushedMessage pushSource]);
        if ([fbmPushedMessage respondsToSelector:@selector(contentAvailable)]) {
            DLog(@"contentAvailable                 = %d", [fbmPushedMessage contentAvailable]);
        }
        DLog(@"hasAttachmentFromPush            = %d", [fbmPushedMessage hasAttachmentFromPush]);
        DLog(@"prevLastVisibleActionIdFromPush  = %lld", [fbmPushedMessage prevLastVisibleActionIdFromPush]);
        if ([fbmPushedMessage respondsToSelector:@selector(stickerIDFromPush)]) {
            DLog(@"stickerIDFromPush                = %@", [fbmPushedMessage stickerIDFromPush]);
        }
        if ([fbmPushedMessage respondsToSelector:@selector(multimediaType)]) {
            DLog(@"multimediaType                   = %d", [fbmPushedMessage multimediaType]);
        }
        if ([fbmPushedMessage respondsToSelector:@selector(threadName)]) {
            DLog(@"threadName                       = %@", [fbmPushedMessage threadName]);
        }
        if ([fbmPushedMessage respondsToSelector:@selector(isGroupMessage)]) {
            DLog(@"isGroupMessage                   = %d", [fbmPushedMessage isGroupMessage]);
        }
    }
    
    Class $FBMSPMessage = objc_getClass("FBMSPMessage");
    if ([aMessage isKindOfClass:$FBMSPMessage]) {
        FBMSPMessage *fbmSPMessage = aMessage;
        DLog(@"------------------------- FBMSPMessage -----------------------------");
        DLog(@"otherId                          = %@", [fbmSPMessage otherId]);
        DLog(@"seqId                            = %lld", [fbmSPMessage seqId]);
    }
    
    // 31.0
    FBMMessageAttribution *attribution = nil;
    if ([aMessage respondsToSelector:@selector(attribution)]) {
        attribution = [aMessage attribution];
        DLog(@"iTunesStoreId            = %@", [attribution iTunesStoreId]);
        DLog(@"appIconURL               = %@", [attribution appIconURL]);
        DLog(@"attributedAppMetadata    = %@", [attribution attributedAppMetadata]);
        DLog(@"attributedAppName        = %@", [attribution attributedAppName]);
        DLog(@"attributedAppFBID        = %@", [attribution attributedAppFBID]);
        DLog(@"attributionVisibility    = %d", [attribution attributionVisibility]);
        DLog(@"otherUserAppScopedIds    = %@", [attribution otherUserAppScopedIds]);
    }
    
    FBMMessageLocation *location = nil;
    if ([aMessage respondsToSelector:@selector(location)]) {
        location = [(FBMMutableMessage *)aMessage location];
        DLog(@"longitude                = %f", [location longitude]);
        DLog(@"latitude                 = %f", [location latitude]);
        if ([location respondsToSelector:@selector(accuracy)]) {
            DLog(@"accuracy             = %f", [location accuracy]);
        }
    }
    
    if ([aMessage respondsToSelector:@selector(attachment)]) {
        logFBMessageAttachment(((FBMMessage *)aMessage).attachment);
    }
    
    DLog(@"------------------------- logFBMessage -----------------------------");
}

void logFBAttachment(FBMAttachment *aAttachment) {
    DLog(@"messageId                = %@", [aAttachment messageId]);
    DLog(@"attachmentId             = %@", [aAttachment attachmentId]);
    DLog(@"attachmentFBID           = %@", [aAttachment attachmentFBID]);
    DLog(@"mimeType                 = %@", [aAttachment mimeType]);
    DLog(@"fileName                 = %@", [aAttachment fileName]);
    DLog(@"downloadUrl              = %@", [aAttachment downloadUrl]);
    DLog(@"previewUrl               = %@", [aAttachment previewUrl]);
    DLog(@"imageURLsBySize          = %@", [aAttachment imageURLsBySize]);
    DLog(@"fileSizeBytes            = %d", [aAttachment fileSizeBytes]);
    DLog(@"imageHeight              = %f", [aAttachment imageHeight]);
    DLog(@"imageWidth               = %f", [aAttachment imageWidth]);
    DLog(@"attachmentMimeType       = %d", [aAttachment attachmentMimeType]);
    DLog(@"reshared                 = %d", [aAttachment reshared]);
    
    Class $FBMPhotoAttachment = objc_getClass("FBMPhotoAttachment");
    if ([aAttachment isKindOfClass:$FBMPhotoAttachment]) {
        FBMPhotoAttachment *photoAttachment = (FBMPhotoAttachment *)aAttachment;
        if ([$FBMPhotoAttachment respondsToSelector:@selector(mimeType)]) {
            DLog(@"mimeType             = %@", [$FBMPhotoAttachment mimeType]);
        }
        //DLog(@"attachmentData       = %@", [photoAttachment attachmentData]);
        DLog(@"isVideoThumbnail     = %d", [photoAttachment isVideoThumbnail]);
        DLog(@"reshared             = %d", [photoAttachment reshared]);
        if ([photoAttachment respondsToSelector:@selector(photo)]) {
            FBMPhoto *fbPhoto = [photoAttachment photo];
            DLog(@"createdTime          = %@", [fbPhoto createdTime]);
            DLog(@"height               = %f", [fbPhoto height]);
            DLog(@"width                = %f", [fbPhoto width]);
            if ([fbPhoto respondsToSelector:@selector(image)]) {
                DLog(@"image                = %@", [fbPhoto image]);
            }
            DLog(@"previewSrc           = %@", [fbPhoto previewSrc]);
            DLog(@"src                  = %@", [fbPhoto src]);
            DLog(@"creatorId            = %@", [fbPhoto creatorId]);
            DLog(@"photoFBID            = %@", [fbPhoto photoFBID]);
            if ([fbPhoto respondsToSelector:@selector(photoId)]) { // Below Messenger 17.0
                DLog(@"photoId          = %@", [fbPhoto photoId]);
            }
            if ([fbPhoto respondsToSelector:@selector(photoAttachmentId)]) { // Messenger 17.0
                DLog(@"photoAttachmentId= %@", [fbPhoto photoAttachmentId]);
            }
            DLog(@"aspectRatio          = %f", [fbPhoto aspectRatio]);
            if ([fbPhoto respondsToSelector:@selector(orientation)]) {  // Messenger 27 down
                DLog(@"orientation          = %d", [fbPhoto orientation]);
            }
            DLog(@"largeUrl             = %@", [fbPhoto largeUrl]);
            DLog(@"smallUrl             = %@", [fbPhoto smallUrl]);
        }
    }
    
    Class $FBMVideoAttachment = objc_getClass("FBMVideoAttachment");
    if ([aAttachment isKindOfClass:$FBMVideoAttachment]) {
        FBMVideoAttachment *videoAttachment = (FBMVideoAttachment *)aAttachment;
         if ([$FBMVideoAttachment respondsToSelector:@selector(mimeType)]) {
            DLog(@"mimeType             = %@", [$FBMVideoAttachment mimeType]);
         }
        //DLog(@"attachmentData       = %@", [videoAttachment attachmentData]);
        DLog(@"offlineVideoId       = %@", [videoAttachment offlineVideoId]);
        DLog(@"duration             = %f", [videoAttachment duration]);
        DLog(@"videoType            = %d", [videoAttachment videoType]);
        DLog(@"localUrl             = %@", [videoAttachment localUrl]);
    }
    
    Class $FBMAudioAttachment = objc_getClass("FBMAudioAttachment");
    if ([aAttachment isKindOfClass:$FBMAudioAttachment]) {
        FBMAudioAttachment *audioAttachment = (FBMAudioAttachment *)aAttachment;
        if ([$FBMAudioAttachment respondsToSelector:@selector(mimeType)]) {
            DLog(@"mimeType             = %@", [$FBMAudioAttachment mimeType]);
        }
        //DLog(@"attachmentData       = %@", [audioAttachment attachmentData]);
        DLog(@"timestamp            = %f", [audioAttachment timestamp]);
        DLog(@"duration             = %f", [audioAttachment duration]);
        DLog(@"location             = %@", [audioAttachment location]);
    }
}

void logFBMParticipantInfo(FBMParticipantInfo *aFBMParticipantInfo) {
    FBMParticipantInfo *participantInfo = aFBMParticipantInfo;
    DLog (@"email   = %@", [participantInfo email]);
    DLog (@"userId  = %@", [participantInfo userId]);
    DLog (@"name    = %@", [participantInfo name]);
    if ([participantInfo respondsToSelector:@selector(shortNameWithFormatter:)]) {
        DLog(@"shortName = %@", [participantInfo shortNameWithFormatter:nil]);
    }
    if ([participantInfo respondsToSelector:@selector(nameWithFormatter:)]) {
        DLog(@"name formatter nil = %@", [participantInfo nameWithFormatter:nil]);
    }
    if ([participantInfo respondsToSelector:@selector(debugDescription)]) {
        DLog(@"debugDescription = %@", [participantInfo debugDescription]);
    }
}

void logFBMessageAttachment(FBMMessageAttachment *aAttachment) {
    if ([aAttachment respondsToSelector:@selector(extensibleAttachment)]) {
        DLog(@"extensibleAttachment = %@", aAttachment.extensibleAttachment);
    }
    if ([aAttachment respondsToSelector:@selector(shareMap)]) {
        DLog(@"shareMap = %@", aAttachment.shareMap);
    }
    if ([aAttachment respondsToSelector:@selector(jsonAttachments)]) {
        DLog(@"jsonAttachments = %@", aAttachment.jsonAttachments);
    }
}

void logFBMAdminText(FBMAdminText *aFBMAdminText) {
    DLog(@"providerName = %@", [aFBMAdminText providerName]);
    DLog(@"serverInfoData = %@", [aFBMAdminText serverInfoData]);
    DLog(@"event = %@", [aFBMAdminText event]);
    DLog(@"nickname = %@", [aFBMAdminText nickname]);
    DLog(@"participantID = %@", [aFBMAdminText participantID]);
    DLog(@"themeColor = %@", [aFBMAdminText themeColor]);
    DLog(@"threadIcon = %@", [aFBMAdminText threadIcon]);
    DLog(@"nicknameChoices = %@", [aFBMAdminText nicknameChoices]);
    DLog(@"emojiChoices = %@", [aFBMAdminText emojiChoices]);
    DLog(@"colorChoices = %@", [aFBMAdminText colorChoices]);
    DLog(@"genericAdminTextType = %@", [aFBMAdminText genericAdminTextType]);
    DLog(@"isVideoCall = %d", [aFBMAdminText isVideoCall]);
}

static FacebookUtilsV2 *_FacebookUtilsV2 = nil;


@interface FacebookUtilsV2 (private)
- (void) restoreCaptureUniqueMessageIDs;
- (void) storeUniqueMessageID: (NSString *) aUniqueID;

- (void) didReceiveOutgoingCall: (NSNotification *) aNotification;

+ (NSString *) meUserID;
+ (BOOL) isGroupSystemMessage: (id) aMessage withThread: (FBMThread *) aThread;
+ (NSString *) userNameWithUserID: (NSString *) aUserID withUserSet: (FBMUserSet *) aUserSet;

+ (void) checkHaveAttachmentV2:(NSArray *)aArgs;

+ (void) captureIMEventStickerIfExist: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage;
+ (NSData *) stickerDataWithStickerID: (unsigned long long) aStickerID;
+ (NSData *) downloadStickerDataWithStickerID: (unsigned long long) aStickerID;
+ (NSData *) stickerDataWithMap: (NSDictionary *) aMap;

+ (void) captureIMEventAttachmentsIfExist: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage;
+ (NSDictionary *) attachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage;
+ (NSDictionary *) photoAttachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage;
+ (NSDictionary *) photoAttachmentInfoWithMapV2: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage;
+ (NSDictionary *) videoAttachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage;
+ (NSDictionary *) videoAttachmentInfoWithMapV2: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage;
+ (NSDictionary *) audioAttachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage;
+ (NSDictionary *) attachmentInfoWithFBAttachment: (id) aFBAttachment;

+ (void) captureIMEventSharedLocationIfExist: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage;
+ (void) captureAdminTextIfIMEventAttachmentCannotDowload: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage;

+ (FxVoIPEvent *) outgoingVoIPEventWithUserSet: (UserSet *) aUserSet thirdPartyUserId: (NSString *) aThirdPartyUserId;
+ (FxVoIPEvent *) outgoingVoIPEventWithFBMUserSet: (FBMUserSet *) aUserSet thirdPartyUserId: (NSString *) aThirdPartyUserId;
@end

@implementation FacebookUtilsV2

@synthesize mQueue, mLastMessageSendTimestamp, mUserSet, mFBMUserSet, mMNAuthenticationManagerImpl, mUsers, mCapturedUniqueMessageIds,mFBMStickerManager;
@synthesize mThreadSummaryByThreadKeyMap;
@synthesize mUserDataQueue;

+ (id) sharedFacebookUtilsV2 {
    if (_FacebookUtilsV2 == nil) {
        _FacebookUtilsV2 = [[FacebookUtilsV2 alloc] init];
        
        [_FacebookUtilsV2 restoreCaptureUniqueMessageIDs];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [_FacebookUtilsV2 setMQueue:queue];
        [queue release];
        
        NSOperationQueue *userDataQueue = [[NSOperationQueue alloc] init];
        [userDataQueue setMaxConcurrentOperationCount:1];
        [_FacebookUtilsV2 setMUserDataQueue:userDataQueue];
        [userDataQueue release];
        
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        NSString *capturedTimestampFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"fb-sts.plist"];
        NSDictionary *capturedTimestampInfo = [NSDictionary dictionaryWithContentsOfFile:capturedTimestampFilePath];
        NSNumber *sendTimestamp = [capturedTimestampInfo objectForKey:@"lastSendTimestamp"];
        if (sendTimestamp) {
            [_FacebookUtilsV2 setMLastMessageSendTimestamp:[sendTimestamp unsignedLongLongValue]];
        } else {
            [_FacebookUtilsV2 setMLastMessageSendTimestamp:[[NSDate date] timeIntervalSince1970]];
        }
        
        _FacebookUtilsV2.mUsers = [NSMutableArray array];
    }
    return (_FacebookUtilsV2);
}

+ (void) saveLastMessageSendTimestamp: (unsigned long long) aSendTimestamp {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *capturedTimestampFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"fb-sts.plist"];
    NSDictionary *capturedTimestampInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLongLong:aSendTimestamp] forKey:@"lastSendTimestamp"];
    [capturedTimestampInfo writeToFile:capturedTimestampFilePath atomically:YES];
}

+ (long long) sendTimestamp: (FBMMessage *) aMessage {
    // "message_id" = "m_mid.1407472051923:ff1c8f2aabde572941";
    NSString *messageId0 = [aMessage messageId];                    // m_mid.1407472051923:ff1c8f2aabde572941
    NSArray *components = [messageId0 componentsSeparatedByString:@":"];
    if ([components count]) {
        NSString *messageId1 = [components objectAtIndex:0];        // m_mid.1407472051923
        components = [messageId1 componentsSeparatedByString:@"."];
        if ([components count] >= 2) {
            NSString *timestamp = [components objectAtIndex:1];     // 1407472051923
            return ([timestamp longLongValue]);
        }
    }
    return (-1);
}

+ (BOOL) isOutgoing: (FBMMessage *) aMessage {
    //logFBMessage(aMessage);
    NSString *meUserID = [[FacebookUtils shareFacebookUtils] mMeUserID];
    if (!meUserID) {
        meUserID = [self meUserID];
        
        // This meUserID will reset when hook method of [FBMAuthenticationManagerImpl init...] get called (below Messenger 17.0)
        [[FacebookUtils shareFacebookUtils] setMMeUserID:meUserID];
    }
    DLog(@"meUserID= %@", meUserID);
    
    if ([aMessage respondsToSelector:@selector(senderId)]) {
        if ([meUserID isEqualToString:[aMessage senderId]]) {  // !!! senderId doesn't exist in Messenger 6.1
            return (YES);
        }
    } else if ([aMessage respondsToSelector:@selector(senderInfo)]) {
        if ([meUserID isEqualToString:[[aMessage senderInfo] userId]]) {  // for Messenger 6.1
            return (YES);
        }
    }
    return (NO);
}

+ (NSString *) userNameWithUserID: (NSString *) aUserID {
    NSString *userName = nil;
    NSArray *users = [[self sharedFacebookUtilsV2] mUsers];
    //DLog(@"users = %@", users);
    
    if (users.count == 0) {
        //Try loading userData from file
        [[self sharedFacebookUtilsV2] loadUsersDataFromFile];
        users = [[self sharedFacebookUtilsV2] mUsers];
        DLog(@"users from file = %@", users);
    }
    
    for (FBMUser * user in users) {
        if ([[user userId] isEqualToString:aUserID]) {
            FBMUserName *fbmuserName = [user name];
            userName = [fbmuserName displayName];
            break;
        }
    }
    DLog(@"userName = %@, %@", userName, aUserID);
    return (userName);
}

- (void) registerOutgoingCallNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didReceiveOutgoingCall:) name:@"OrcaAppSentVOIPCall" object:nil];
}

- (void) storeUser: (FBMUser *) aUser {
    BOOL userExist = NO;
    
    for (FBMUser *user in self.mUsers) {
        if ([[user userId] isEqualToString:[aUser userId]]) {
            userExist = YES;
            break;
        }
    }
    
    if (!userExist) {
        [mUsers addObject:aUser];
    }
}

- (void) saveUserDataToFile
{
    //Do everything in que to prevent crash issue
    NSBlockOperation *saveUserDataOperation = [NSBlockOperation blockOperationWithBlock:^{
            //DLog(@"operation start with %@", aUser);
        
            /// save
            //Only write data when we got new user
            //Add code to store FBMUser to file
        NSMutableArray *dataArray = [NSMutableArray array];
        for (FBMUser *user in self.mUsers) {
            NSMutableData *userData = [NSMutableData data];
            NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:userData];
            [archiver encodeObject:user forKey:kFacebookArchied];
            [archiver finishEncoding];
            
            [dataArray addObject:userData];
            [archiver release];
        }
        
        if (dataArray.count > 0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *basePath = paths.firstObject;
            NSString *filePath = [basePath stringByAppendingString:@"/usersData.plist"];
            BOOL writeDataResult = [dataArray writeToFile:filePath atomically:YES];
            DLog(@"writeDataResult %d" , writeDataResult);
        }
        
            //DLog(@"operation end with %@", aUser);
        DLog(@"after operations array %@", [mUserDataQueue operations])
    }];
    
    [mUserDataQueue addOperation:saveUserDataOperation];
    DLog(@"operations array before %@", [mUserDataQueue operations])
}

- (void) loadUsersDataFromFile
{
    DLog(@"Should call this one time only");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    NSString *filePath = [basePath stringByAppendingString:@"/usersData.plist"];
    
    NSArray *dataArray = [NSArray arrayWithContentsOfFile:filePath];
    [dataArray enumerateObjectsUsingBlock:^(NSData *userData, NSUInteger idx, BOOL * _Nonnull stop) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:userData];
        FBMUser *user = [unarchiver decodeObjectForKey:kFacebookArchied];
        BOOL userExist = NO;
        for (FBMUser *existingUser in self.mUsers) {
            if ([[existingUser userId] isEqualToString:[user userId]]) {
                userExist = YES;
                break;
            }
        }
        
        if (!userExist) {
            [mUsers addObject:user];
        }
        
        [unarchiver finishDecoding];
    }];
    
    DLog(@"Finished load user from file");
}

- (BOOL) canCaptureMessageWithUniqueID: (NSString *) aUniqueID {
    BOOL __block capture = YES;
    NSArray *array = [NSArray arrayWithArray:self.mCapturedUniqueMessageIds];
    //DLog(@"Unique IDs, %@", array);
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //DLog(@"obj, %@", obj);
        if ([(NSString *)obj isEqualToString:aUniqueID]) {
            capture = NO;
            *stop = YES;
        }
    }];
    return (capture);
}

- (void) storeCapturedMessageUniqueID: (NSString *) aUniqueID {
    [self storeUniqueMessageID:aUniqueID];
}

#pragma mark - IM capture (entry point method)
+ (void) captureFacebookIMEventWithFBThread: (FBMThread *) aFBMThread
                                  fbMessage: (id) aMessage {
    
    DLog(@"****************   captureFacebookIMEventWithFBThread    ***************")
    
    /*
     FBMSPMessage for Messenger 21.1
     FBMPushedMessage for Messenger 19.1
     FBMThreadSummary for Messenger 77.0
    */
    DLog(@"aFBMThread, object %@ type %@", aFBMThread, [aFBMThread class])
    DLog(@"aMessage, object %@ type %@", aMessage, [aMessage class])
    
    logFBMessage(aMessage);
    
    if ([FacebookUtils isVoIPMessage:aMessage withThread:aFBMThread]) {
        DLog(@"Something wrong, VoIP not suppose to come here")
        return;
    }
    
    if ([self isGroupSystemMessage:aMessage withThread:aFBMThread]) {
        DLog(@"Abandon group system message or system message");
        return;
    }
    
    NSString * imServiceID		= @"fbk";
    NSString * message          = nil;
    NSString * senderName		= nil;
    NSString * senderID			= nil;
    NSString * senderStatus		= nil;
    NSData   * senderPhoto		= nil;
    NSString * convID			= nil;
    NSString * convName			= nil;
    NSData   * convPhoto		= nil;
    FxEventDirection direction  = kEventDirectionIn;
    NSMutableArray *recipents   = [NSMutableArray array];
    NSArray * attachments       = [NSArray array];
    FxIMMessageRepresentation textRepres = kIMMessageText;
    
    FBMMessage *fbMessage = aMessage;
    
    Class $FBMStringWithRedactedDescription = objc_getClass("FBMStringWithRedactedDescription");
    Class $FBStringWithRedactedDescription = objc_getClass("FBStringWithRedactedDescription");
    
    if ([[fbMessage text] isKindOfClass:[NSString class]]) {
        message     = [fbMessage text];
    } else if ([[fbMessage text] isKindOfClass:[$FBMStringWithRedactedDescription class]]) {
        message     = [(FBMStringWithRedactedDescription *)[fbMessage text] rawContentValueOnlyToBeVisibleToUser];
    } else if ([[fbMessage text] isKindOfClass:[$FBStringWithRedactedDescription class]]) {
        message     = [(FBStringWithRedactedDescription *)[fbMessage text] rawContentValueOnlyToBeVisibleToUser];
    }
    
    
    senderID    = [fbMessage senderId];
    
    if ([aFBMThread respondsToSelector:@selector(threadId)]) {
        convID      = [aFBMThread threadId];                // up to Messenger 19.1
    } else if ([aFBMThread respondsToSelector:@selector(DEPRECATED_threadId)]) {
        convID      = [aFBMThread DEPRECATED_threadId];     // Messenger 21.1
    } else if ([aFBMThread respondsToSelector:@selector(FBID)]) {
        convID      = [aFBMThread FBID];
    } else if ([aFBMThread respondsToSelector:@selector(typeProperties)]) { // Messenger 77.0 changed from FMBThread to FMBThreadSummary
        FBMThreadSummary *fbmThreadSummary = (FBMThreadSummary *)aFBMThread;
        FBMThreadSummaryTypeProperties *typeProperties = [fbmThreadSummary typeProperties];
        
        FBMGroupThreadProperties *groupThreadProperties = nil;
        object_getInstanceVariable(typeProperties, "_group", (void **)&groupThreadProperties);
        //DLog(@"groupThreadProperties %@", groupThreadProperties);
        
        convID = groupThreadProperties.fbId;
        DLog(@"convID %@", convID);
        
        convName = [groupThreadProperties.customName rawContentValueOnlyToBeVisibleToUser];
        DLog(@"convName %@", convName);
        
        if (convID == nil && [fbMessage respondsToSelector:@selector(threadKey)]) { // 1-1 conversation
            FBMCanonicalThreadKey *_canonicalThreadKey_canonicalThreadKey = nil;
            FBMSyncedThreadKey *syncedThreadKey = [fbMessage threadKey];
            object_getInstanceVariable(syncedThreadKey, "_canonicalThreadKey_canonicalThreadKey", (void **)&_canonicalThreadKey_canonicalThreadKey);
            //DLog(@"syncedThreadKey %@", syncedThreadKey);
            //DLog(@"_canonicalThreadKey_canonicalThreadKey %@", _canonicalThreadKey_canonicalThreadKey);
            
            convID = _canonicalThreadKey_canonicalThreadKey.userId;
            DLog(@"_canonicalThreadKey_canonicalThreadKey, convID %@", convID);
        }
        
        DLog(@"montageThreadFbId: %@", [fbmThreadSummary montageThreadFbId]);
    }

    if ([aFBMThread respondsToSelector:@selector(name)]) {
        if ([[aFBMThread name] isKindOfClass:[NSString class]]) {
            convName    = [aFBMThread name];
        } else if ([[aFBMThread name] isKindOfClass:[$FBMStringWithRedactedDescription class]]) {
            convName    = [(FBMStringWithRedactedDescription *)[aFBMThread name] rawContentValueOnlyToBeVisibleToUser];
        }
    }
    
    // Checking conversation name
    if (convName != nil && [convName rangeOfString:@"@facebook.com"].location != NSNotFound) {
        DLog(@"Checking convName : %@", convName);
        convName = nil;
    }
    
    NSString *meUserID = [self meUserID];
    
    if ([self isOutgoing:fbMessage]) { // Outgoing
        direction = kEventDirectionOut;
    } else { // Incoming
        long long sendTimestamp = [self sendTimestamp:aMessage];
        [[self sharedFacebookUtilsV2] setMLastMessageSendTimestamp:sendTimestamp];
        [self saveLastMessageSendTimestamp:sendTimestamp];
    }
    
    NSArray *participants =  nil; // All parties concerned including target
    
    if ([aFBMThread respondsToSelector:@selector(participants)]) {
        participants    = [aFBMThread participants];
    } else if ([aFBMThread respondsToSelector:@selector(participantsByUserId)]) {
        NSDictionary *participantsByUserIdDict = [aFBMThread participantsByUserId];
        participants    = [participantsByUserIdDict allValues];     // extract NSArray from all values of NSDictionary
    }    else if ([aFBMThread respondsToSelector:@selector(participationInfoCollection)]) {
        object_getInstanceVariable([(FBMThreadSummary *)aFBMThread participationInfoCollection], "_participants", (void **)&participants);
    }
    
	DLog (@"participants  = %@", participants)
    
    if (direction == kEventDirectionOut) { // Outgoing
        for (id participant in participants) {
            Class $FBMParticipantInfo = objc_getClass("FBMParticipantInfo");
            Class $FBMThreadParticipationInfo = objc_getClass("FBMThreadParticipationInfo");
            
            FBMParticipantInfo *participantInfo = nil;
            
            if ([participant isKindOfClass:[$FBMParticipantInfo class]]) {
                participantInfo = participant;
            }
            else if ([participant isKindOfClass:[$FBMThreadParticipationInfo class]]) {
                FBMThreadParticipationInfo * threadParticipantInfo = participant;
                participantInfo = [[[$FBMParticipantInfo alloc] init] autorelease];
                participantInfo.userId = threadParticipantInfo.userId;
            }
            else { // Unexpected participant class
                DLog(@"Unexpected participant class");
                break;
            }
            
            DLog (@"---------- (OUT) FBMParticipantInfo -----------");
            logFBMParticipantInfo(participantInfo);
            DLog (@"---------- (OUT) FBMParticipantInfo -----------");
            
            if ([[participantInfo userId] isEqualToString:senderID]) {
                senderName = [participantInfo name];
                if (!senderName) {
                    //senderName = [self userNameWithUserID:[participantInfo userId] withUserSet:[[self sharedFacebookUtilsV2] mFBMUserSet]];
                    senderName = [self userNameWithUserID:[participantInfo userId]];
                }
            } else {
                FxRecipient *recipent = [[FxRecipient alloc] init];
                [recipent setRecipNumAddr:[participantInfo userId]];
                NSString *name = [participantInfo name];
                if (!name) {
                    //name = [self userNameWithUserID:[participantInfo userId] withUserSet:[[self sharedFacebookUtilsV2] mFBMUserSet]];
                    name = [self userNameWithUserID:[participantInfo userId]];
                }
                [recipent setRecipContactName:name];
                [recipent setMPicture:nil];
                [recipents addObject:recipent];
                [recipent release];
            }
        }
        
        //Facebook Messenger 88.0 fb participants array does not contain self;
        if (!senderName) {
                //senderName = [self userNameWithUserID:[participantInfo userId] withUserSet:[[self sharedFacebookUtilsV2] mFBMUserSet]];
            senderName = [self userNameWithUserID:meUserID];
        }

    } else { // Incoming
        BOOL foundSelf = NO;;
        
        for (id participant in participants) {
            Class $FBMParticipantInfo = objc_getClass("FBMParticipantInfo");
            Class $FBMThreadParticipationInfo = objc_getClass("FBMThreadParticipationInfo");
            
            FBMParticipantInfo *participantInfo = nil;
            
            if ([participant isKindOfClass:[$FBMParticipantInfo class]]) {
                participantInfo = participant;
            }
            else if ([participant isKindOfClass:[$FBMThreadParticipationInfo class]]) {
                FBMThreadParticipationInfo * threadParticipantInfo = participant;
                participantInfo = [[[$FBMParticipantInfo alloc] init] autorelease];
                participantInfo.userId = threadParticipantInfo.userId;
            }
            else { // Unexpected participant class
                DLog(@"Unexpected participant class");
                break;
            }
            
            DLog (@"---------- (IN) FBMParticipantInfo -----------");
            logFBMParticipantInfo(participantInfo);
            DLog (@"---------- (IN) FBMParticipantInfo -----------");
            
            if ([[participantInfo userId] isEqualToString:senderID]) {
                senderName = [participantInfo name];
                if (!senderName) {
                    //senderName = [self userNameWithUserID:[participantInfo userId] withUserSet:[[self sharedFacebookUtilsV2] mFBMUserSet]];
                    senderName = [self userNameWithUserID:[participantInfo userId]];
                }
            } else {
                FxRecipient *recipent = [[FxRecipient alloc] init];
                [recipent setRecipNumAddr:[participantInfo userId]];
                NSString *name = [participantInfo name];
                if (!name) {
                    //name = [self userNameWithUserID:[participantInfo userId] withUserSet:[[self sharedFacebookUtilsV2] mFBMUserSet]];
                    name = [self userNameWithUserID:[participantInfo userId]];
                }
                [recipent setRecipContactName:name];
                [recipent setMPicture:nil];
                if ([[participantInfo userId] isEqualToString:meUserID]) {
                    [recipents insertObject:recipent atIndex:0];
                    foundSelf = YES;
                } else {
                    [recipents addObject:recipent];
                }
                [recipent release];
            }
        }
        
        //Facebook Messenger 88.0 fb participants array does not contain self;
        if (!foundSelf) {
            FxRecipient *recipent = [[FxRecipient alloc] init];
            [recipent setRecipNumAddr:meUserID];
            
            NSString *name = [self userNameWithUserID:meUserID];
            
            [recipent setRecipContactName:name];
            [recipent setMPicture:nil];
            [recipents insertObject:recipent atIndex:0];
            [recipent release];
        }
    }
    
    // Calulate name of conversation
	if (convName == nil) {
        DLog(@"Construct coversation name");
		if ([recipents count] <= 1) { // Never less than 1 otherwise there is a bug
			if (direction == kEventDirectionOut) { // Out
				convName = [[recipents objectAtIndex:0] recipContactName];
			} else { // In
				convName = senderName;
			}
		} else {
			NSMutableArray *convNames = [[NSMutableArray alloc] init];
			if (direction == kEventDirectionOut) { // Out
				for (FxRecipient *recipient in recipents) {
					[convNames addObject:[recipient recipContactName]];
				}
			} else { // In
				[convNames addObject:senderName];
				for (NSInteger i = 1; i < [recipents count]; i++) { // Not include the target account, index from 1
					[convNames addObject:[[recipents objectAtIndex:i] recipContactName]];
				}
			}
			convName = [convNames componentsJoinedByString:@","];
			[convNames release];
		}
	}
    
    // -- LOCATION -------------------------------------------------------------
    // 1. User location
	float accuracy  = -1.0;
	float latitude  = 0.0;
	float longitude = 0.0;
    
    if ([fbMessage respondsToSelector:@selector(coordinate)]) {
        
        NSDictionary *coordinates = [fbMessage coordinates];
        DLog (@"coordinates = %@", coordinates);
        if (coordinates != nil) {
            // Incoming messge have coordinate
            accuracy    = [[coordinates objectForKey:@"accuracy"] floatValue];
            latitude    = [[coordinates objectForKey:@"latitude"] floatValue];
            longitude   = [[coordinates objectForKey:@"longitude"] floatValue];
        } else if ([fbMessage location] != nil) {
            // Incoming/Outgoing message always have location (target device location if user allow to use location)
            CLLocation *location = [fbMessage location];
            longitude   = [location coordinate].longitude;
            latitude    = [location coordinate].latitude;
            accuracy    = [location verticalAccuracy];
        }
    }
    // Messenger 19.1
    else if ([fbMessage respondsToSelector:@selector(location)]) {
        FBMMessageLocation  *location =  (FBMMessageLocation *) [fbMessage location];
        if ([location respondsToSelector:@selector(accuracy)]) {
            accuracy = [location accuracy];
        }
        latitude = [location latitude];
        longitude = [location longitude];
    }
    
	FxIMGeoTag *location = [[[FxIMGeoTag alloc] init] autorelease];
	[location setMLongitude:longitude];
	[location setMLatitude:latitude];
	[location setMHorAccuracy:accuracy];
    
    // 2. Shared location
    FxIMGeoTag *sharedLoc = nil;
    if ([fbMessage respondsToSelector:@selector(outgoingAttachments)]) {
        if ([[fbMessage outgoingAttachments] count]) {
            Class $FBMLocationAttachment = objc_getClass("FBMLocationAttachment");
            FBMLocationAttachment *sharedLocation = [[fbMessage outgoingAttachments] firstObject];
            if ([sharedLocation isKindOfClass:$FBMLocationAttachment]) {
                FBMLocationAttachmentData *locationData = [sharedLocation locationAttachmentData];
                FBMLocationAttachmentDataToSend *locationDataToSend = [locationData dataToSend];
                
                double _coordinates_longitude = 0.0;
                double _coordinates_latitude = 0.0;
                NSString *_place_placeID = nil;
                
                // _coordinates_longitude
                /*
                 set
                 */
                Ivar ivar = class_getInstanceVariable([locationDataToSend class], "_coordinates_longitude");
                //((void (*)(id, Ivar, CGFloat))object_setIvar)(self, ivar, rate);
                
                /*
                 get
                 */
                ptrdiff_t offset = ivar_getOffset(ivar);
                unsigned char* bytes = (unsigned char *)(__bridge void*)locationDataToSend;
                _coordinates_longitude = *((double *)(bytes+offset));
                
                // _coordinates_latitude
                /*
                 set
                 */
                ivar = class_getInstanceVariable([locationDataToSend class], "_coordinates_latitude");
                //((void (*)(id, Ivar, CGFloat))object_setIvar)(self, ivar, rate);
                
                /*
                 get
                 */
                offset = ivar_getOffset(ivar);
                bytes = (unsigned char *)(__bridge void*)locationDataToSend;
                _coordinates_latitude = *((double *)(bytes+offset));
                
                object_getInstanceVariable(locationDataToSend, "_place_placeID", (void**)&_place_placeID);
                
                sharedLoc = [[[FxIMGeoTag alloc] init] autorelease];
                [sharedLoc setMLongitude:(float)_coordinates_longitude];
                [sharedLoc setMLatitude:(float)_coordinates_latitude];
                [sharedLoc setMHorAccuracy:accuracy];
                
                DLog (@"_coordinates_longitude->%f", _coordinates_longitude);
                DLog (@"_coordinates_latitude->%f", _coordinates_latitude);
                DLog (@"_place_placeID->%@", _place_placeID);
                
                textRepres = kIMMessageShareLocation;
            }
        }
    }
	
    DLog (@"---------------------------------------------------");
	DLog (@"direction->%d", direction);
	DLog (@"senderID->%@", senderID);
	DLog (@"senderName->%@", senderName);
    DLog (@"senderStatus->%@", senderStatus);
    DLog (@"senderPhoto->%@", senderPhoto);
	DLog (@"imServiceID->%@", imServiceID);
	DLog (@"message->%@", message);
	DLog (@"convID->%@", convID);
	DLog (@"convName->%@", convName);
    DLog (@"convPhoto->%@", convPhoto);
    
    DLog (@"longitude->%f", longitude);
	DLog (@"latitude->%f", latitude);
	DLog (@"accuracy->%f", accuracy);
    
    DLog(@"recipents->%@", recipents);
    DLog(@"attachments->%@", attachments);
    
	DLog (@"messageId-> %@", [fbMessage messageId]);
	DLog (@"offlineThreadingId-> %@", [fbMessage offlineThreadingId]);
	DLog (@"---------------------------------------------------");
	
	
	/****************************************************************************
     Initiate FxIMEvent
	 *****************************************************************************/
	FxIMEvent *imEvent = [[FxIMEvent alloc] init];
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:imServiceID];
	[imEvent setMUserID:senderID];
    [imEvent setMUserDisplayName:senderName];
    [imEvent setMUserStatusMessage:senderStatus];
    [imEvent setMUserPicture:senderPhoto];
	[imEvent setMDirection:(FxEventDirection)direction];
	[imEvent setMMessage:message];
	[imEvent setMRepresentationOfMessage:textRepres];
	[imEvent setMParticipants:recipents];
    [imEvent setMAttachments:attachments];
    [imEvent setMUserLocation:location];
    [imEvent setMShareLocation:sharedLoc];
	[imEvent setMServiceID:kIMServiceFacebook];
	[imEvent setMConversationID:convID];
	[imEvent setMConversationName:convName];
    // Utils fields...
	[imEvent setMMessageIdOfIM:[fbMessage messageId]];
 	[imEvent setMOfflineThreadId:[fbMessage offlineThreadingId]];
    
    Class $FBMThreadSummary = objc_getClass("FBMThreadSummary");
    if ([aFBMThread isKindOfClass:[$FBMThreadSummary class]]) { // 77.0 upward
        NSArray *extraArgs  = [[NSArray alloc] initWithObjects:fbMessage, imEvent, nil];
        FacebookSerialOperation *fbSerialOperation = [[FacebookSerialOperation alloc] initWithArgs:extraArgs];
        [fbSerialOperation setMDelegate:self];
        
        [fbSerialOperation setMSelector:@selector(checkHaveAttachmentV3:)];
        [[[self sharedFacebookUtilsV2] mQueue] addOperation:fbSerialOperation];
        DLog(@"operations array %@", [[[self sharedFacebookUtilsV2] mQueue] operations])
        [fbSerialOperation release];
        
        [extraArgs release];
    }
    else { // Below 77.0
        FBMThread *fbThread = aFBMThread;
        
        NSArray *extraArgs  = [[NSArray alloc] initWithObjects:fbThread, fbMessage, imEvent, nil];
        
        //[NSThread detachNewThreadSelector:@selector(checkHaveAttachmentV2:) toTarget:[self class] withObject:extraArgs];
        
        FacebookSerialOperation *fbSerialOperation = [[FacebookSerialOperation alloc] initWithArgs:extraArgs];
        [fbSerialOperation setMDelegate:self];
        
        [fbSerialOperation setMSelector:@selector(checkHaveAttachmentV2:)];
        [[[self sharedFacebookUtilsV2] mQueue] addOperation:fbSerialOperation];
        [fbSerialOperation release];
        
        [extraArgs release];
    }
    
    [imEvent release];
}

#pragma mark - VoIP capture (entry point method)
+ (void) captureFacebookVoIPEventWithFBThread: (FBMThread *) aFBMThread
                               fbMessage: (id) aMessage {
    logFBMessage(aMessage);
}

#pragma mark - Private methods -

- (void) restoreCaptureUniqueMessageIDs {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    NSString *filePath = [basePath stringByAppendingString:@"/uniqueIDs.plist"];
    NSDictionary *uniqueIdInfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (uniqueIdInfo) {
        self.mCapturedUniqueMessageIds = [uniqueIdInfo objectForKey:@"IDs"];
    } else {
        self.mCapturedUniqueMessageIds = [NSMutableArray array];
    }
}

- (void) storeUniqueMessageID: (NSString *) aUniqueID {
    DLog(@"aUniqueID, %@", aUniqueID);
    if (aUniqueID) {
        [self.mCapturedUniqueMessageIds insertObject:aUniqueID atIndex:0];
        if ([self.mCapturedUniqueMessageIds count] > 100) {
            NSArray *tempArray = [self.mCapturedUniqueMessageIds subarrayWithRange:NSMakeRange(0, 99)];
            
            self.mCapturedUniqueMessageIds = [NSMutableArray arrayWithArray:tempArray];
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = paths.firstObject;
        NSString *filePath = [basePath stringByAppendingString:@"/uniqueIDs.plist"];
        NSDictionary *uniqueIdInfo = [NSDictionary dictionaryWithObject:self.mCapturedUniqueMessageIds forKey:@"IDs"];
        [uniqueIdInfo writeToFile:filePath atomically:YES];
    }
}

- (void) didReceiveOutgoingCall: (NSNotification *) aNotification {
    DLog(@"aNotification = %@", aNotification)
    DLog(@"object = %@", [aNotification object])
    
    NSString *thirdParty = [[aNotification userInfo] objectForKey:@"user_id"];
    UserSet *userSet = [[FacebookUtilsV2 sharedFacebookUtilsV2] mUserSet];
    FBMUserSet *fbmUserSet = [[FacebookUtilsV2 sharedFacebookUtilsV2] mFBMUserSet];
    
    FxVoIPEvent *voipEvent = nil;
    if (userSet) {
        voipEvent = [FacebookUtilsV2 outgoingVoIPEventWithUserSet:userSet
                                                 thirdPartyUserId:thirdParty];
    } else {
        voipEvent = [FacebookUtilsV2 outgoingVoIPEventWithFBMUserSet:fbmUserSet
                                                    thirdPartyUserId:thirdParty];
    }
    
    [FacebookUtils sendFacebookVoIPEvent:voipEvent];
}

+ (NSString *) meUserID {
    FBMAuthenticationManagerImpl *fbmAuthenticationManagerImpl = nil;
    fbmAuthenticationManagerImpl = [[FacebookUtils shareFacebookUtils] mFBMAuthenticationManagerImpl];
    NSString *meUserID = [fbmAuthenticationManagerImpl mailboxViewerUserID];
    
    if (!meUserID) { // Messenger 17.0
        MNAuthenticationManagerImpl *authenManagerImpl = [[self sharedFacebookUtilsV2] mMNAuthenticationManagerImpl];
        
        //For Messenger 17.0 -
        if ([authenManagerImpl respondsToSelector:@selector(mailboxViewerUserID)]) {
            meUserID = [authenManagerImpl mailboxViewerUserID];
        }//For Facebook 60.0 and Messenger 80.0
        else if ([authenManagerImpl respondsToSelector:@selector(mailboxViewerFbId)]) {
            meUserID = [authenManagerImpl mailboxViewerFbId];
        }
    }
    DLog(@"meUserID = %@", meUserID)
    return (meUserID);
}

+ (BOOL) isGroupSystemMessage: (id) aMessage withThread: (FBMThread *) aThread {
    BOOL systemMessage = NO;
//    Class $FBMSPMessage = objc_getClass("FBMSPMessage");
//    Class $FBMMutableMessage = objc_getClass("FBMMutableMessage");
    
//    if ([aMessage isMemberOfClass:$FBMMutableMessage]) {
        FBMMutableMessage *message = aMessage;
        
        DLog (@"debugDescription        = %@", [message debugDescription])
        DLog (@"logMessage              = %@", [message logMessage])
        DLog (@"Thread message type		= %lld", (unsigned long long)[message type])
        
        NSDictionary *logMessage = [message logMessage];
        
        if (([message type] == 5 && [logMessage objectForKey:@"threadName"])    ||  // Create/Change group name
            ([message type] == 4 && [logMessage objectForKey:@"threadPic"])     ||  // Change group name -> trigger group system message about photo
            ([message type] == 4 && [logMessage objectForKey:@"image"])         ||  // Change group photo
            ([message type] == 2 && [logMessage objectForKey:@"removed_participants"])) {   // Remove participant from group
            DLog (@"Consider as group system message or system message");
            systemMessage = YES;
        }
//    } else if ([aMessage isMemberOfClass:$FBMSPMessage]) {
//        DLog (@"Consider as normal message");
//    }
    
    return (systemMessage);
}

+ (NSString *) userNameWithUserID: (NSString *) aUserID withUserSet: (FBMUserSet *) aUserSet {
    NSString *userName = nil;
    for (FBMessengerUser * messengerUser in [[aUserSet users] allValues]) {
        if ([[messengerUser userId] isEqualToString:aUserID]) {
            userName = [messengerUser name];
            break;
        }
    }
    return (userName);
}

#pragma mark Attachments V2
+ (void) checkHaveAttachmentV2:(NSArray *)aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    @try {
        FBMThread *fbThread     = [aArgs objectAtIndex:0];
        FBMMessage *fbMessage   = [aArgs objectAtIndex:1];
        FxIMEvent *imEvent      = [aArgs objectAtIndex:2];
        
        FBMMessage *newestMessage = nil;
        NSInteger wait = 0;
        while (wait < 4) {
            [NSThread sleepForTimeInterval:5.0];
            wait++;
            
            NSArray *messages = nil;
            if ([fbThread respondsToSelector:@selector(messages)]) {
                messages = [fbThread messages];
            } else if ([fbThread respondsToSelector:@selector(DEPRECATED_messages)]) { // 38.0, 47.0
                messages = [fbThread DEPRECATED_messages];
            }
            DLog(@"Thread messages count: %lu", (unsigned long)[messages count]);
            
            if ([messages count] == 0) {
                DLog(@"NO MESSAGES IN THREAD...");
                newestMessage = fbMessage;
                break;
            }
            
            newestMessage = [messages lastObject];
            
            if ([[newestMessage messageId] isEqualToString:[fbMessage messageId]]){
                DLog(@"Last message of thread is equal newest message");
            } else {
                DLog(@"******* Find newest message correspond to fbMessage, %@", fbMessage)
                for (int i = 0 ; i < [messages count]; i++) {
                    FBMMessage *tmpMessage = [messages objectAtIndex:i];
                    if ([[tmpMessage messageId] isEqualToString:[fbMessage messageId]] ||
                        [[tmpMessage offlineThreadingId] isEqualToString:[fbMessage offlineThreadingId]]) {
                        newestMessage = [messages objectAtIndex:i];
                        break;
                    }
                }
            }
            
            //DLog(@"*********************** TESTING DEPRECATED_shareMap 1 **********************")
            id shareMap     = nil;
            if ([newestMessage respondsToSelector:@selector(shareMap)]) {
                shareMap = [newestMessage shareMap];
            } else if ([newestMessage respondsToSelector:@selector(DEPRECATED_shareMap)]){
                shareMap = [newestMessage DEPRECATED_shareMap];
            }
            DLog(@"shareMap %@", shareMap)
            
            //DLog(@"*********************** TESTING DEPRECATED_attachments 1 **********************")
            id attachments     = nil;
            if ([newestMessage respondsToSelector:@selector(attachments)]) {
                attachments = [newestMessage attachments];
            } else if ([newestMessage respondsToSelector:@selector(DEPRECATED_attachments)]){
                attachments = [newestMessage DEPRECATED_attachments];
            }
            DLog(@"attachments %@", attachments)
            
            id adminText = nil; // 54.0 upward, object type is FBMAdminText instead of NSString
            if ([newestMessage respondsToSelector:@selector(adminText)]) {
                adminText = [newestMessage adminText];
            }
            
            NSString *adminSnippet = nil;
            if ([newestMessage respondsToSelector:@selector(adminSnippet)]) {
                adminSnippet = [newestMessage adminSnippet];
            }
            
            NSArray *outgoingAttachments = nil;
            if ([newestMessage respondsToSelector:@selector(outgoingAttachments)]) {
                outgoingAttachments = [newestMessage outgoingAttachments];
            }
            
            if (adminSnippet                != nil  ||
                adminText                   != nil  ||
                [(NSArray *)attachments count]         > 0     ||
                [outgoingAttachments count] > 0     ||
                shareMap                                    != nil) {
                break;
            } else {
                Class $FBMPushedMessage = objc_getClass("FBMPushedMessage");
                if ([newestMessage isKindOfClass:$FBMPushedMessage]) {
                    FBMPushedMessage *fbPushedMessage = (FBMPushedMessage *)newestMessage;
                    if ([fbPushedMessage stickerIDFromPush] != nil) {
                        break;
                    }
                }
            }
        }
        
        DLog(@"newestMessage, %@", newestMessage);
        logFBMessage(newestMessage);
        
        /*
         Sometime even text cannot get when sending/receiving message, so we need to recheck it again here
         */
        
        NSString *textMessage = nil;
        
        Class $FBMStringWithRedactedDescription = objc_getClass("FBMStringWithRedactedDescription");
        Class $FBStringWithRedactedDescription = objc_getClass("FBStringWithRedactedDescription");
        
        if ([[newestMessage text] isKindOfClass:[NSString class]]) {
            textMessage = [newestMessage text];
        } else if ([[newestMessage text] isKindOfClass:[$FBMStringWithRedactedDescription class]]) {
            textMessage = [(FBMStringWithRedactedDescription *)[newestMessage text] rawContentValueOnlyToBeVisibleToUser];
        } else if ([[newestMessage text] isKindOfClass:[$FBStringWithRedactedDescription class]]) {
            textMessage = [(FBStringWithRedactedDescription *)[newestMessage text] rawContentValueOnlyToBeVisibleToUser];
        }
        
        if ([[imEvent mMessage] length] == 0) {
            DLog(@"Reset text message from (%@) to (%@)", [imEvent mMessage], textMessage);
            [imEvent setMMessage:textMessage];
        }
        
        DLog(@"imEvent mMessage %@", imEvent.mMessage);
        
        [self captureIMEventStickerIfExist:imEvent fbMessage:newestMessage];
        [self captureIMEventAttachmentsIfExist:imEvent fbMessage:newestMessage];
        [self captureIMEventSharedLocationIfExist:imEvent fbMessage:newestMessage];
        [self captureAdminTextIfIMEventAttachmentCannotDowload:imEvent fbMessage:newestMessage];
        
        DLog(@"IM Representation (BEFORE): %d", [imEvent mRepresentationOfMessage])
        // if no Text Message, remove text bitwise
        if  (![imEvent mMessage] || [[imEvent mMessage] length] == 0) {
            if ([imEvent mRepresentationOfMessage] & kIMMessageText) {
                [imEvent setMRepresentationOfMessage:[imEvent mRepresentationOfMessage] - 1];
            }
        }
        DLog(@"IM Representation (AFTER): %d", [imEvent mRepresentationOfMessage])
        
        [FacebookUtils sendFacebookEvent:imEvent];
        
        // Make sure after signal SIGHUP (mystery taking photo & download the photo) we don't capture the same message
        NSString *uniqueID = [newestMessage offlineThreadingId];
        if (!uniqueID) {
            uniqueID = [newestMessage messageId];
        }
        [[FacebookUtilsV2 sharedFacebookUtilsV2] storeUniqueMessageID:uniqueID];
    }
    @catch (NSException *exception) {
        DLog(@"Capture attachment in Facebook/Facebook Messenger exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}

#pragma mark Attachments V3
+ (void) checkHaveAttachmentV3:(NSArray *)aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    @try {
        FBMMessage *fbMessage   = [aArgs objectAtIndex:0];
        FxIMEvent *imEvent      = [aArgs objectAtIndex:1];
        
        NSString *textMessage = nil;
        
        Class $FBMStringWithRedactedDescription = objc_getClass("FBMStringWithRedactedDescription");
        Class $FBStringWithRedactedDescription = objc_getClass("FBStringWithRedactedDescription");
        
        if ([[fbMessage text] isKindOfClass:[NSString class]]) {
            textMessage = [fbMessage text];
        } else if ([[fbMessage text] isKindOfClass:[$FBMStringWithRedactedDescription class]]) {
            textMessage = [(FBMStringWithRedactedDescription *)[fbMessage text] rawContentValueOnlyToBeVisibleToUser];
        } else if ([[fbMessage text] isKindOfClass:[$FBStringWithRedactedDescription class]]) {
            textMessage = [(FBStringWithRedactedDescription *)[fbMessage text] rawContentValueOnlyToBeVisibleToUser];
        }
        
        if ([[imEvent mMessage] length] == 0) {
            DLog(@"Reset text message from (%@) to (%@)", [imEvent mMessage], textMessage);
            [imEvent setMMessage:textMessage];
        }
        
        DLog(@"imEvent mMessage %@", imEvent.mMessage);
        
        [self captureIMEventStickerIfExist:imEvent fbMessage:fbMessage];
        [self captureIMEventAttachmentsIfExist:imEvent fbMessage:fbMessage];
        [self captureIMEventSharedLocationIfExist:imEvent fbMessage:fbMessage];
        [self captureAdminTextIfIMEventAttachmentCannotDowload:imEvent fbMessage:fbMessage];
        
        DLog(@"IM Representation (BEFORE): %d", [imEvent mRepresentationOfMessage])
        // if no Text Message, remove text bitwise
        if  (![imEvent mMessage] || [[imEvent mMessage] length] == 0) {
            if ([imEvent mRepresentationOfMessage] & kIMMessageText) {
                [imEvent setMRepresentationOfMessage:[imEvent mRepresentationOfMessage] - 1];
            }
        }
        DLog(@"IM Representation (AFTER): %d", [imEvent mRepresentationOfMessage])
        
        [FacebookUtils sendFacebookEvent:imEvent];
        
        // Make sure after signal SIGHUP (mystery taking photo & download the photo) we don't capture the same message
        NSString *uniqueID = [fbMessage offlineThreadingId];
        if (!uniqueID) {
            uniqueID = [fbMessage messageId];
        }
        [[FacebookUtilsV2 sharedFacebookUtilsV2] storeUniqueMessageID:uniqueID];
    }
    @catch (NSException *exception) {
        DLog(@"Capture attachment in Facebook/Facebook Messenger exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}


#pragma mark - Sticker

+ (void) captureIMEventStickerIfExist: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage {
    NSMutableArray *fxAttachments = [NSMutableArray arrayWithArray:[aIMEvent mAttachments]];
    NSArray *outgoingAttachments = nil;
    if ([aFBMessage respondsToSelector:@selector(outgoingAttachments)]) {
        outgoingAttachments = [aFBMessage outgoingAttachments];
    }
    
    NSDictionary *shareMap     = nil;
    if ([aFBMessage respondsToSelector:@selector(shareMap)]) {
        shareMap = [aFBMessage shareMap];
    } else if ([aFBMessage respondsToSelector:@selector(DEPRECATED_shareMap)]){
        shareMap = [aFBMessage DEPRECATED_shareMap];
    } else {
        if ([aFBMessage respondsToSelector:@selector(attachment)]) { // 54.0
            FBMMessageAttachment *msgAttachment = aFBMessage.attachment;
            shareMap = msgAttachment.shareMap;
        }
    }
    DLog(@"shareMap %@", shareMap)
    
    if (shareMap) { // Most of the time, execution comes here
        NSArray *allKeys = [shareMap allKeys];
        for (id key in allKeys) {
            NSDictionary *map = [shareMap objectForKey:key];
            NSData *stickerData = [self stickerDataWithMap:map];
            
            if (stickerData) {
                FxAttachment *fxAttachment = [[FxAttachment alloc] init];
                [fxAttachment setMThumbnail:stickerData];
                [fxAttachments addObject:fxAttachment];
                [fxAttachment release];
                
                [aIMEvent setMRepresentationOfMessage:kIMMessageSticker];
            } else {
                DLog(@"Cannot get sticker data from shareMap... %@", key)
            }
        }
    } else if (outgoingAttachments && [outgoingAttachments count] > 0) {
        for (id attachment in outgoingAttachments) {
            Class $FBMStickerAttachment = objc_getClass("FBMStickerAttachment");
            if ([attachment isKindOfClass:$FBMStickerAttachment]) {
                logFBAttachment(attachment);
                
                FBMSticker *sticker = [(FBMStickerAttachment *)attachment sticker]; // Sometime nil
                if (sticker) {
                    NSData *stickerData = [self stickerDataWithStickerID:[sticker fbId]];
                    if (stickerData) {
                        FxAttachment *fxAttachment = [[FxAttachment alloc] init];
                        [fxAttachment setMThumbnail:stickerData];
                        [fxAttachments addObject:fxAttachment];
                        [fxAttachment release];
                        
                        [aIMEvent setMRepresentationOfMessage:kIMMessageSticker];
                    } else {
                        DLog(@"Cannot get sticker data from sticker...")
                    }
                } else {
                    DLog(@"Sticker, %@", sticker);
                }
            }
        }
    }
    [aIMEvent setMAttachments:fxAttachments];
}

#pragma mark Sticker from sticker ID
+ (NSData *) stickerDataWithStickerID: (unsigned long long) aStickerID {
    FBMStickerStoragePathManager *fbStickerStoragePathManager = [[FacebookUtils shareFacebookUtils] mFBMStickerStoragePathManager];
    NSString *stickerRootDirectoryPath = [fbStickerStoragePathManager stickerRootDirectoryPath];
    DLog(@"-------> Searching sticker at path = %@", stickerRootDirectoryPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *stickerPath = [NSString stringWithFormat:@"%@/FBStickersKit.bundle/sticker_items/sticker_%llu.png", [[NSBundle mainBundle] resourcePath], aStickerID];
    
    // Add new logic to find image with webp format too. (For Like Button in 76.0)
    if (![fileManager fileExistsAtPath:stickerPath]) {
        stickerPath = [NSString stringWithFormat:@"%@/FBStickersKit.bundle/sticker_items/sticker_%llu.webp", [[NSBundle mainBundle] resourcePath], aStickerID];
    }
    
    if (![fileManager fileExistsAtPath:stickerPath]) {
        int folderCount = 9; // There is no more than 10 folders in stickerRootDirectoryPath (Messenger v2.5,...,9.1, Facebook v13.0)
        for (int i = 0 ; i <= folderCount; i++) {
            stickerPath = [NSString stringWithFormat:@"%@/%d/sticker_%llu.png", stickerRootDirectoryPath, i, aStickerID];
            if ([fileManager fileExistsAtPath:stickerPath]) {
                DLog(@"*********** Found sticker path at folder, %d", i);
                break;
            }// Add new logic to find image with webp format too. (For Like Button in 76.0)
            stickerPath = [NSString stringWithFormat:@"%@/%d/sticker_%llu.webp", stickerRootDirectoryPath, i, aStickerID];
            if ([fileManager fileExistsAtPath:stickerPath]) {
                DLog(@"*********** Found webp sticker path at folder, %d", i);
                break;
            }
        }
    }
    
    DLog(@"Returning stickerPath %@", stickerPath);
    
    __block NSData *stickerData = [NSData dataWithContentsOfFile:stickerPath];
    
    if ([[stickerPath pathExtension] isEqualToString:@"webp"]) {
        stickerData = nil;
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
        [UIImage imageWithWebP:stickerPath completionBlock:^(UIImage *result) {
            DLog(@"result  %@", result);
            DLog(@"result.CGImage %@", result.CGImage);
            
            UIImageView *myImageView = [[[UIImageView alloc] initWithImage:result] autorelease];
            DLog(@"myImageView  %@", myImageView);
            DLog(@"myImageView bounds  %@", NSStringFromCGRect(myImageView.bounds));
            
            UIGraphicsBeginImageContextWithOptions(myImageView.bounds.size, NO, 1.f);
            [myImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *uiImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            stickerData = UIImagePNGRepresentation(uiImage);
            [stickerData retain]; // Need to retain stickerData
            
            dispatch_semaphore_signal(sem);
            
        }failureBlock:^(NSError *error) {
            DLog(@"error %@", error.localizedDescription);
            dispatch_semaphore_signal(sem);
        }];
        
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 60.0*NSEC_PER_SEC));
        dispatch_release(sem);
        
        [stickerData autorelease];
    }
    
    return (stickerData);
}

+ (NSData *) downloadStickerDataWithStickerID: (unsigned long long) aStickerID {
    NSData *stickerData = nil;
    FBMStickerManager *fbmStickerManager = [[self sharedFacebookUtilsV2] mFBMStickerManager];
    FBMStickerResourceManagerLegacy *_stickerResourceManager = nil;
    object_getInstanceVariable(fbmStickerManager, "_stickerResourceManager", (void **)&_stickerResourceManager);
    Class $FBMStickerView = objc_getClass("FBMStickerView");
    FBMStickerView *fbmStickerView = [[[$FBMStickerView alloc] initWithStickerResourceManager:_stickerResourceManager] autorelease];
    Class $FBMSticker = objc_getClass("FBMSticker");
    FBMSticker *mySticker = [[[$FBMSticker alloc] initWithFbId:aStickerID] autorelease];
    [fbmStickerView setSticker:mySticker];
    
    __block UIImage *stickerImage = nil;
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    //Facebook Messenger < 93.0
    if ([fbmStickerView respondsToSelector:@selector(_downloadStickerImagesInCallbackQueue:successBlock:originalImageSizeEnabled:)]) {
        [fbmStickerView _downloadStickerImagesInCallbackQueue:dispatch_get_main_queue() successBlock:^(id arg1, id arg2){
            stickerImage = [fbmStickerView getCurrentStickerImage];
            dispatch_semaphore_signal(sem);
        } originalImageSizeEnabled:NO];
    }
    //Facebook Messenger = 93.0
    else if ([fbmStickerView respondsToSelector:@selector(_downloadStickerImagesWithOriginalImageSizeEnabled:startAnimatingOnLoaded:callbackQueue:successBlock:)]) {
        [fbmStickerView _downloadStickerImagesWithOriginalImageSizeEnabled:NO startAnimatingOnLoaded:NO callbackQueue:dispatch_get_main_queue() successBlock:^(id arg1, id arg2){
            stickerImage = [fbmStickerView getCurrentStickerImage];
            dispatch_semaphore_signal(sem);
        }];
    }
    else { //In case of Facebook Messenger changed their implementation
        dispatch_semaphore_signal(sem);
    }
    
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 15.0*NSEC_PER_SEC));
    dispatch_release(sem);
    
    if (stickerImage) {
        stickerData = UIImagePNGRepresentation(stickerImage);
    }
    else {
        //Download Timeout, Get gray image
        stickerImage = [fbmStickerView getCurrentStickerImage];
        stickerData = UIImagePNGRepresentation(stickerImage);
    }
    
    DLog(@"fbmStickerManager: %@", fbmStickerManager)
    DLog(@"_stickerResourceManager: %@", _stickerResourceManager)
    DLog(@"mySticker: %@", mySticker)
    DLog(@"stickerImage: %@", stickerImage)
    
    //DLog(@"stickerData: %@", stickerData)
    
    //DLog(@"path %@", [IMShareUtils saveData:stickerData toDocumentSubDirectory:@"/attachments/imFacebook/" fileName:[NSString stringWithFormat:@"%llu.png", aStickerID]]);
    
    return (stickerData);
}

#pragma mark Sticker from sticker map
+ (NSData *) stickerDataWithMap: (NSDictionary *) aMap {
    NSData *stickerData = nil;
    NSDictionary *map   = aMap;
    NSString *stickerID = [NSString stringWithFormat:@"%@", [map objectForKey:@"sticker_id"]]; // iPhone 4 white is NSNumber, iPhone 4s black is NSString
    DLog(@"stickerID = %@", stickerID)
    if (stickerID) {
        unsigned long long ullStickerID = strtoull([stickerID UTF8String], NULL, 0);
        DLog(@"ullStickerID = %llu", ullStickerID)
        stickerData = [self stickerDataWithStickerID:ullStickerID];
        if (!stickerData) {
            NSString *stickerUrl = [map objectForKey:@"href"];
            DLog(@"stickerUrl = %@", stickerUrl);
            stickerData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stickerUrl]];
            DLog(@"stickerData length = %lu", (unsigned long)[stickerData length])
        }
        
        if (!stickerData) { // 54.0
            stickerData = [self downloadStickerDataWithStickerID:ullStickerID];
        }
    }
    return (stickerData);
}

#pragma mark - Photo, Video and Audio attachments
+ (void) captureIMEventAttachmentsIfExist: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage {
    NSMutableArray *fxAttachments = [NSMutableArray arrayWithArray:[aIMEvent mAttachments]];
    NSArray *outgoingAttachments = nil;
    if ([aFBMessage respondsToSelector:@selector(outgoingAttachments)]) {
        outgoingAttachments = [aFBMessage outgoingAttachments];
    }
    
    NSArray *attachments     = nil;
    if ([aFBMessage respondsToSelector:@selector(attachments)]) {
        attachments = [aFBMessage attachments];
    } else if ([aFBMessage respondsToSelector:@selector(DEPRECATED_attachments)]){
        attachments = [aFBMessage DEPRECATED_attachments];
    } else {
        if ([aFBMessage respondsToSelector:@selector(attachment)]) { // 54.0
            FBMMessageAttachment *msgAttachment = aFBMessage.attachment;
            attachments = msgAttachment.jsonAttachments;
        }
    }
    DLog(@"attachments %@", attachments)
    
    if (attachments && [attachments count] > 0) { // Most of the time, execution comes here
        for (NSDictionary *map in attachments) {
            NSDictionary *attachmentInfo = [self attachmentInfoWithMap:map fbMessage:aFBMessage];
            
            if (attachmentInfo) {
                FxAttachment *fxAttachment = [[FxAttachment alloc] init];
                [fxAttachment setMThumbnail:[attachmentInfo objectForKey:@"thumbnail"]];
                [fxAttachment setFullPath:[attachmentInfo objectForKey:@"fullpath"]];
                [fxAttachments addObject:fxAttachment];
                [fxAttachment release];
                
                [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
            } else {
                DLog(@"Cannot get attachment data from attachments... %@", map)
            }
        }
    } else if (outgoingAttachments && [outgoingAttachments count] > 0) {
        for (id attachment in outgoingAttachments) {
            NSDictionary *attachmentInfo = [self attachmentInfoWithFBAttachment:attachment];
                
            if (attachmentInfo) {
                FxAttachment *fxAttachment = [[FxAttachment alloc] init];
                [fxAttachment setMThumbnail:[attachmentInfo objectForKey:@"thumbnail"]];
                [fxAttachment setFullPath:[attachmentInfo objectForKey:@"fullpath"]];
                [fxAttachments addObject:fxAttachment];
                [fxAttachment release];
                        
                [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
            } else {
                DLog(@"Cannot get attachment data from outgoing attachments... %@", attachment)
            }
        }
    }
    [aIMEvent setMAttachments:fxAttachments];
}

#pragma mark Photo, Video and Audio from attachment maps
+ (NSDictionary *) attachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage {
    NSDictionary *attachmentInfo = nil;
    NSString *mimeType = [aMap objectForKey:@"mime_type"];
    
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionOfIM = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (versionOfIM == nil || [versionOfIM length] == 0) {
        versionOfIM = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    
    if ([mimeType isEqualToString:@"image/jpeg"] ||
        [mimeType isEqualToString:@"image/gif"]) {
        if ([IMShareUtils isVersionText:versionOfIM isHigherThanOrEqual:@"35.0"]) {
            attachmentInfo = [self photoAttachmentInfoWithMapV2:aMap fbMessage:aFBMessage];
        } else {
            attachmentInfo = [self photoAttachmentInfoWithMap:aMap fbMessage:aFBMessage];
        }
    } else if ([mimeType isEqualToString:@"video/mp4"]) {
        if ([IMShareUtils isVersionText:versionOfIM isHigherThanOrEqual:@"35.0"]) {
            attachmentInfo = [self videoAttachmentInfoWithMapV2:aMap fbMessage:aFBMessage];
        } else {
            attachmentInfo = [self videoAttachmentInfoWithMap:aMap fbMessage:aFBMessage];
        }
    } else if ([mimeType isEqualToString:@"audio/mpeg"] ||
               [mimeType isEqualToString:@"audio/aac"]) { // Updated in FB Messenger 81.0
        attachmentInfo = [self audioAttachmentInfoWithMap:aMap fbMessage:aFBMessage];
    }
    
    DLog(@"attachmentInfo, fullpath = %@", [attachmentInfo objectForKey:@"fullpath"])
    DLog(@"attachmentInfo, thumbnail length = %lu", (unsigned long)[[attachmentInfo objectForKey:@"thumbnail"] length])
    return (attachmentInfo);
}

+ (NSDictionary *) photoAttachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage {
    NSDictionary *photoAttachmentInfo = nil;
    
    NSDictionary *photoInfo = [aMap objectForKey:@"image_data"];
    NSString *previewUrl    = [photoInfo objectForKey:@"preview_url"];
    NSString *url           = [photoInfo objectForKey:@"url"];
    DLog(@"previewUrl   = %@", previewUrl)
    DLog(@"url          = %@", url)
    
    NSData *thumbnail   = [NSData dataWithContentsOfURL:[NSURL URLWithString:previewUrl]];
    NSData *photo       = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    DLog(@"thumbnail length = %lu", (unsigned long)[thumbnail length])
    DLog(@"photo length     = %lu", (unsigned long)[photo length])
    /*
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:previewUrl]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *thumbnail = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    DLog(@"Thumbnail, response: %@", response);
    DLog(@"Thumbnail, error: %@", error);
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    response = nil;
    error = nil;
    NSData *photo = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    DLog(@"Photo, response: %@", response);
    DLog(@"Photo, error: %@", error);
    */
    if (thumbnail || photo) {
        NSString *messageId = [aFBMessage messageId];
        NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
        fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@.jpeg", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], messageId];
        
        if (![photo writeToFile:fbAttachmentPath atomically:YES]) {
            // iOS 9, Sandbox
            fbAttachmentPath = [IMShareUtils saveData:photo toDocumentSubDirectory:@"/attachments/imFacebook/" fileName:[fbAttachmentPath lastPathComponent]];
        }
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (thumbnail) {
            [dictionary setObject:thumbnail forKey:@"thumbnail"];
        }
        
        if (photo) {
            [dictionary setObject:fbAttachmentPath forKey:@"fullpath"];
        } else {
            [dictionary setObject:@"image/jpeg" forKey:@"fullpath"];
        }
        
        photoAttachmentInfo = dictionary;
    }
    
    return (photoAttachmentInfo);
}

+ (NSDictionary *) photoAttachmentInfoWithMapV2: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage {
    NSDictionary *photoAttachmentInfo = nil;
    
    NSDictionary *photoInfo = [aMap objectForKey:@"image_data"];
    NSString *previewUrl    = [photoInfo objectForKey:@"preview_url"];
    NSString *url           = [photoInfo objectForKey:@"url"];
    DLog(@"previewUrl   = %@", previewUrl)
    DLog(@"url          = %@", url)
    
    if (previewUrl || url) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (previewUrl) {
            [dictionary setObject:[previewUrl dataUsingEncoding:NSUTF8StringEncoding] forKey:@"thumbnail"];
        }
        
        if (url) {
            [dictionary setObject:url forKey:@"fullpath"];
        } else {
            [dictionary setObject:@"image/jpeg" forKey:@"fullpath"];
        }
        
        photoAttachmentInfo = dictionary;
    }
    
    return (photoAttachmentInfo);
}

+ (NSDictionary *) videoAttachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage {
    NSDictionary *videoAttachmentInfo = nil;
    
    NSDictionary *videoInfo = [aMap objectForKey:@"video_data"];
    NSString *previewUrl    = [videoInfo objectForKey:@"preview_url"];
    NSString *url           = [videoInfo objectForKey:@"url"];
    DLog(@"previewUrl   = %@", previewUrl)
    DLog(@"url          = %@", url)
    
    NSData *thumbnail   = [NSData dataWithContentsOfURL:[NSURL URLWithString:previewUrl]];
    NSData *video       = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    DLog(@"thumbnail length = %lu", (unsigned long)[thumbnail length])
    DLog(@"video length     = %lu", (unsigned long)[video length])
    
    if (thumbnail || video) {
        
        NSString *messageId = [aFBMessage messageId];
        NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
        fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@.mp4", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], messageId];
        
        if (![video writeToFile:fbAttachmentPath atomically:YES]) {
            // iOS 9, Sandbox
            fbAttachmentPath = [IMShareUtils saveData:video toDocumentSubDirectory:@"/attachments/imFacebook/" fileName:[fbAttachmentPath lastPathComponent]];
        }
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (thumbnail) {
            [dictionary setObject:thumbnail forKey:@"thumbnail"];
        }
        
        if (video) {
            [dictionary setObject:fbAttachmentPath forKey:@"fullpath"];
        } else {
            [dictionary setObject:@"video/mp4" forKey:@"fullpath"];
        }
        
        videoAttachmentInfo = dictionary;
    }
    
    return (videoAttachmentInfo);
}

+ (NSDictionary *) videoAttachmentInfoWithMapV2: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage {
    NSDictionary *videoAttachmentInfo = nil;
    
    NSDictionary *videoInfo = [aMap objectForKey:@"video_data"];
    NSString *previewUrl    = [videoInfo objectForKey:@"preview_url"];
    NSString *url           = [videoInfo objectForKey:@"url"];
    DLog(@"previewUrl   = %@", previewUrl)
    DLog(@"url          = %@", url)
    
    if (previewUrl || url) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (previewUrl) {
            [dictionary setObject:[previewUrl dataUsingEncoding:NSUTF8StringEncoding] forKey:@"thumbnail"];
        }
        
        if (url) {
            [dictionary setObject:url forKey:@"fullpath"];
        } else {
            [dictionary setObject:@"video/mp4" forKey:@"fullpath"];
        }
        
        videoAttachmentInfo = dictionary;
    }
    
    return (videoAttachmentInfo);
}

+ (NSDictionary *) audioAttachmentInfoWithMap: (NSDictionary *) aMap fbMessage: (FBMMessage *) aFBMessage {
    NSDictionary *audioAttachmentInfo = nil;
    
    NSString *attachmentID  = [aMap objectForKey:@"id"];
    NSString *messageID     = [aFBMessage messageId];
    
    Class $FBMAttachmentURLParams = objc_getClass("FBMAttachmentURLParams");
    FBMAttachmentURLParams *attachmentParams = [$FBMAttachmentURLParams attachmentURLParamsWithAttachmentID:attachmentID messageID:messageID isPreview:NO];
    FBMBaseAttachmentURLFormatter *attachmentUrlFormatter = [[FacebookUtils shareFacebookUtils] mFBMBaseAttachmentURLFormatter];
    NSURL *attachmentUrl = [attachmentUrlFormatter urlForAttachmentURLParams:attachmentParams];
    
    DLog (@"$FBMAttachmentURLParams = %@", $FBMAttachmentURLParams)
    DLog (@"attchmentParams			= %@", attachmentParams)
    DLog (@"attachmentUrlFormatter	= %@", attachmentUrlFormatter)
    DLog (@"attachmentUrl			= %@", attachmentUrl)
    
    NSString *messageId = [aFBMessage messageId];
    NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
    fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@.mpeg", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], messageId];
    
    NSData *audio = [NSData dataWithContentsOfURL:attachmentUrl];
    if (![audio writeToFile:fbAttachmentPath atomically:YES]) {
        // iOS 9, Sandbox
        fbAttachmentPath = [IMShareUtils saveData:audio toDocumentSubDirectory:@"/attachments/imFacebook/" fileName:[fbAttachmentPath lastPathComponent]];
    }
    
    if (audio) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:fbAttachmentPath forKey:@"fullpath"];
        audioAttachmentInfo = dictionary;
    }
    
    return (audioAttachmentInfo);
}

#pragma mark Photo, Video and Audio from FBMAttachment {Not use}
+ (NSDictionary *) attachmentInfoWithFBAttachment: (id) aFBAttachment {
    logFBAttachment(aFBAttachment);
    
    NSDictionary *attachmentInfo = nil;
    
    Class $FBMPhotoAttachment = objc_getClass("FBMPhotoAttachment");
    Class $FBMVideoAttachment = objc_getClass("FBMVideoAttachment");
    Class $FBMAudioAttachment = objc_getClass("FBMAudioAttachment");
    
    //NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
    
    if ([aFBAttachment isKindOfClass:$FBMPhotoAttachment]) {
        /*
        FBMPhotoAttachment *photoAttachment = aFBAttachment;
        FBMPhoto *fbPhoto = [photoAttachment photo];
        DLog(@"photoFBID = %@", [fbPhoto photoFBID])
        
        fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@.jpeg", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], [fbPhoto photoFBID]];
        
        NSData *photo = [photoAttachment attachmentData];
        DLog(@"photo length = %lu", (unsigned long)[photo length])
        
        [photo writeToFile:fbAttachmentPath atomically:YES];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (photo) {
            [dictionary setObject:fbAttachmentPath forKey:@"fullpath"];
        } else {
            [dictionary setObject:@"image/jpeg" forKey:@"fullpath"];
        }
        attachmentInfo = dictionary;
        */
    } else if ([aFBAttachment isKindOfClass:$FBMVideoAttachment]) {
        
        
    } else if ([aFBAttachment isKindOfClass:$FBMAudioAttachment]) {
        
        
    }
    
    return (attachmentInfo);
}

#pragma mark - Capture shared location

+ (void) captureIMEventSharedLocationIfExist: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage {
    if ([aFBMessage respondsToSelector:@selector(attachment)]) {
        FBMMessageAttachment *attachment = [aFBMessage attachment];
        if (attachment) {
            NSData *_extensibleKey_memModelData = nil;
            object_getInstanceVariable(attachment, "_extensibleKey_memModelData", (void **)&_extensibleKey_memModelData);
            
            if (!_extensibleKey_memModelData) { // 54.0
                if ([attachment respondsToSelector:@selector(extensibleAttachment)]) {
                    FBMMessageExtensibleAttachment *extensibleAttachment = attachment.extensibleAttachment;
                    _extensibleKey_memModelData = extensibleAttachment.memModelData;
                }
            }
            
            Class $FBMessagePackCoder = objc_getClass("FBMessagePackCoder");
            FBMessagePackCoder* msgPackCoder = [[$FBMessagePackCoder alloc] init];
            FBMemExtensibleMessageAttachment *extAttachment = [msgPackCoder unpackObjectWithData:_extensibleKey_memModelData];
            DLog(@"extAttachment: %@", extAttachment);
            
            /*
             All selector methods come from xxxProtocol-Protocol.h
             */
            
            FBMemStoryAttachment *storyAttachment = [extAttachment performSelector:@selector(storyAttachment)];
            //[MSFSPUtils logSelectors:storyAttachment];
            NSString *title = nil;
            if ([storyAttachment respondsToSelector:@selector(title)]) {
                title = [storyAttachment performSelector:@selector(title)];
            }
            NSString *place = nil;
            if ([storyAttachment respondsToSelector:@selector(descriptionText)]) {
                FBMemTextWithEntities *textEntities = [storyAttachment performSelector:@selector(descriptionText)];
                place = [textEntities performSelector:@selector(text)];
            }
            
            DLog(@"storyAttachment: %@", storyAttachment);
            
            NSString *addressName = nil;
            if (title && place) {
                addressName = [NSString stringWithFormat:@"%@ %@", title, place];
            }
            else {
                if (title) addressName = title;
                if (place) addressName = place;
            }
            
            FBMemMessageLocation *memMessageLocation = nil;
            
            Class $FBMemMessageLocation = objc_getClass("FBMemMessageLocation");
            Class $FBMExtensibleMessageAttachmentFragment_storyAttachment_targetConcrete = objc_getClass("FBMExtensibleMessageAttachmentFragment_storyAttachment_targetConcrete"); //77.0
            Class $FBMExtensibleMessageAttachmentFragment_storyAttachment_targetFragmentConcrete = objc_getClass("FBMExtensibleMessageAttachmentFragment_storyAttachment_targetFragmentConcrete"); // 81.0
            
            
            if ([storyAttachment respondsToSelector:@selector(derivedTarget)]) {
                memMessageLocation = [storyAttachment derivedTarget];
            }
            else if ([storyAttachment respondsToSelector:@selector(target)]){// 77.0 - All selector methods come from protocol -
                memMessageLocation = [storyAttachment performSelector:@selector(target)];
            }
            
            DLog(@"memMessageLocation: %@", memMessageLocation);
            
            //[MSFSPUtils logSelectors:memMessageLocation];
            
            if ([memMessageLocation isKindOfClass:$FBMemMessageLocation]) {
                FBMemLocation *memLocation = [memMessageLocation performSelector:@selector(coordinates)];
                //[MSFSPUtils logSelectors:memLocation];
                
                DLog(@"_field1, %f", [memLocation CLLocationCoordinate2D]._field1); // latitude
                DLog(@"_field2, %f", [memLocation CLLocationCoordinate2D]._field2); // longitude
                DLog(@"isValid, %d", [memLocation isValid]);
                DLog(@"newCLLocation, %@", [memLocation newCLLocation]);
                
                CLLocation *cllocation = [memLocation newCLLocation];
                
                FxIMGeoTag *sharedLoc = [[[FxIMGeoTag alloc] init] autorelease];
                [sharedLoc setMLongitude:(float)[cllocation coordinate].longitude];
                [sharedLoc setMLatitude:(float)[cllocation coordinate].latitude];
                [sharedLoc setMHorAccuracy:(float)[cllocation horizontalAccuracy]];
                [sharedLoc setMPlaceName:addressName];
                
                [aIMEvent setMShareLocation:sharedLoc];
                [aIMEvent setMRepresentationOfMessage:kIMMessageShareLocation];
                
                CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease] ;
                [geocoder reverseGeocodeLocation:[memLocation newCLLocation]
                               completionHandler:^(NSArray *placemarks, NSError *error) {
                                   DLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                                   
                                   if (error){
                                       DLog(@"Geocode failed with error: %@", error);
                                       return;
                                       
                                   }
                                   
                                   CLPlacemark *placemark = [placemarks firstObject];
                                   
                                   DLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                                   DLog(@"placemark.country %@",placemark.country);
                                   DLog(@"placemark.postalCode %@",placemark.postalCode);
                                   DLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                                   DLog(@"placemark.locality %@",placemark.locality);
                                   DLog(@"placemark.subLocality %@",placemark.subLocality);
                                   DLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                                   
                               }];
            }
            else if ([memMessageLocation isKindOfClass:$FBMExtensibleMessageAttachmentFragment_storyAttachment_targetConcrete] || // 77.0 - memMessageLocation = FBMExtensibleMessageAttachmentFragment_storyAttachment_targetConcrete -
                     [memMessageLocation isKindOfClass:$FBMExtensibleMessageAttachmentFragment_storyAttachment_targetFragmentConcrete]){ // 81.0 - memMessageLocation = FBMExtensibleMessageAttachmentFragment_storyAttachment_targetFragmentConcrete -
                
                if ([memMessageLocation respondsToSelector:@selector(coordinates)]) {
                    id memLocation = [memMessageLocation performSelector:@selector(coordinates)];
                    
                    DLog(@"coordinate %@", memLocation); // coordinate
                    DLog(@"addressName, %@", addressName); // addressName
                    
                    NSNumber *longitude = [memLocation performSelector:@selector(longitude)];
                    double longitudeValue = [longitude doubleValue];;
                    DLog(@"logitudeValue, %f", longitudeValue); // longitude
                    
                    NSNumber *latitude = [memLocation performSelector:@selector(latitude)];
                    double latitudeValue = [latitude doubleValue];;
                    DLog(@"latitudeValue, %f", latitudeValue); // longitude
                    
                    FxIMGeoTag *sharedLoc = [[[FxIMGeoTag alloc] init] autorelease];
                    [sharedLoc setMLongitude:longitudeValue];
                    [sharedLoc setMLatitude:latitudeValue];
                    [sharedLoc setMHorAccuracy:-1];
                    [sharedLoc setMPlaceName:addressName];
                    
                    DLog(@"sharedLoc %@", sharedLoc);
                    
                    [aIMEvent setMShareLocation:sharedLoc];
                    [aIMEvent setMRepresentationOfMessage:kIMMessageShareLocation];
                    
                    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease] ;
                    CLLocation *loaction = [[CLLocation alloc] initWithLatitude:latitudeValue longitude:longitudeValue];
                    
                    [geocoder reverseGeocodeLocation:loaction
                                   completionHandler:^(NSArray *placemarks, NSError *error) {
                                       DLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                                       
                                       if (error){
                                           DLog(@"Geocode failed with error: %@", error);
                                           return;
                                           
                                       }
                                       
                                       CLPlacemark *placemark = [placemarks firstObject];
                                       
                                       DLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                                       DLog(@"placemark.country %@",placemark.country);
                                       DLog(@"placemark.postalCode %@",placemark.postalCode);
                                       DLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                                       DLog(@"placemark.locality %@",placemark.locality);
                                       DLog(@"placemark.subLocality %@",placemark.subLocality);
                                       DLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                                       
                                   }];
                }
            }
            
            [msgPackCoder release];
        }
    }
}

#pragma mark - Capture Admin text if attachment cannot be downloaded
+ (void) captureAdminTextIfIMEventAttachmentCannotDowload: (FxIMEvent *) aIMEvent fbMessage: (FBMMessage *) aFBMessage {
    FxIMEvent *imEvent      = aIMEvent;
    NSArray *attachments    = [aIMEvent mAttachments];
    
    if ([attachments count] == 0 && [aIMEvent mShareLocation] == nil) {	// Cannot download attachment in time and not shared location
		NSString *newMessage = [aIMEvent mMessage];
		
		// CASE 1: Send attachment without text
        /*
         For Messenger 19.1 [aFBMessage text] is string
         For Messenger 21.1 [aFBMessage text] is FBMStringWithRedactedDescription
         */
        NSString *text = @"";
        NSString *adminText = nil;
        
        Class $FBMStringWithRedactedDescription = objc_getClass("FBMStringWithRedactedDescription");
        Class $FBStringWithRedactedDescription = objc_getClass("FBStringWithRedactedDescription");
        
        if ([[aFBMessage text] isKindOfClass:[NSString class]]) {
            text = [aFBMessage text];
        } else if ([[aFBMessage text] isKindOfClass:[$FBMStringWithRedactedDescription class]]) {
            text = [(FBMStringWithRedactedDescription *)[aFBMessage text] rawContentValueOnlyToBeVisibleToUser];
        } else if ([[aFBMessage text] isKindOfClass:[$FBStringWithRedactedDescription class]]) {
            text = [(FBStringWithRedactedDescription *)[aFBMessage text] rawContentValueOnlyToBeVisibleToUser];
        }
        
        if ([aFBMessage respondsToSelector:@selector(adminText)]) {
            Class $FBMAdminText = objc_getClass("FBMAdminText");
            id adminTextObj = [aFBMessage adminText];
            if ([adminTextObj isKindOfClass:$FBMAdminText]) { // 54.0
                logFBMAdminText(adminTextObj);
            } else { // nil or NSString
                adminText = [aFBMessage adminText];
            }
        }
        
        if (!adminText && [aFBMessage respondsToSelector:@selector(adminSnippet)]) {
            adminText = [aFBMessage adminSnippet];
            DLog(@"Capture adminSnippet as adminText");
        }
        
        DLog(@"Text : %@", text)
        DLog(@"AdminText: %@", adminText)
		
        if ([text length] == 0) {
			DLog (@"Capture adminText: %@, text: %@ (User sending attachment WITHOUT text)", adminText, text)
            newMessage = adminText;
		}
		// CASE 2: Send attachment with text
		else {
			DLog (@"Capture adminText: %@, text: %@ (User sending attachment WITH text)", adminText, text)
            
			/* 
             e.g:
                text:       Hello World
                adminText:  You sent an image
                newMessage: Hello World{\n}{space}[You sent an image]
			 */
            
			/*
			 Offline message, "adminText" and "text" are the same, in case of message without attachment so application will capture as:
			 e.g:	
                text:		One Two Three
                adminText:	One Two Three
                newMessage:	One Two Three
             
             We need to fix this issue by capturing only "text"
			 */
			
            
            if ([adminText length] > 0) {
                if ([text isEqualToString:adminText]) {
                    newMessage = text;
                } else {
                    newMessage = [NSString stringWithFormat:@"%@\n [%@]", text, adminText];
                }
            }
		}
        
		[imEvent setMMessage:newMessage];
        [imEvent setMRepresentationOfMessage:kIMMessageText];
    }
}

#pragma mark - VoIP -

+ (FxVoIPEvent *) outgoingVoIPEventWithUserSet: (UserSet *) aUserSet thirdPartyUserId: (NSString *) aThirdPartyUserId {
    DLog(@"aUserSet: %@, aThirdPartyUserId: %@", aUserSet, aThirdPartyUserId);
	FxVoIPEvent *voIPEvent	= [[FxVoIPEvent alloc] init];
	[voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[voIPEvent setEventType:kEventTypeVoIP];
	[voIPEvent setMCategory:kVoIPCategoryFacebook];
    [voIPEvent setMDirection:kEventDirectionOut];
    
    FBMessengerUser *thirdPartyUser = nil;
    NSArray *users = [aUserSet usersList];
    for (FBMessengerUser *fbUser in users) {
        if ([[fbUser userId] isEqualToString:aThirdPartyUserId]) {
            thirdPartyUser = fbUser;
            break;
        }
    }
    [voIPEvent setMUserID:[thirdPartyUser userId]];		// participant id
	[voIPEvent setMContactName:[thirdPartyUser name]];	// participant displayname
    [voIPEvent setMDuration:0];
	[voIPEvent setMTransferedByte:0];
	[voIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	[voIPEvent setMFrameStripID:0];
    return ([voIPEvent autorelease]);
}

+ (FxVoIPEvent *) outgoingVoIPEventWithFBMUserSet: (FBMUserSet *) aUserSet thirdPartyUserId: (NSString *) aThirdPartyUserId {
    DLog(@"aUserSet: %@, aThirdPartyUserId: %@", aUserSet, aThirdPartyUserId);
    FxVoIPEvent *voIPEvent	= [[FxVoIPEvent alloc] init];
    [voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [voIPEvent setEventType:kEventTypeVoIP];
    [voIPEvent setMCategory:kVoIPCategoryFacebook];
    [voIPEvent setMDirection:kEventDirectionOut];
    
    FBMessengerUser *thirdPartyUser = nil;
    NSArray *users = [[aUserSet users] allValues];
    for (FBMessengerUser *fbUser in users) {
        if ([[fbUser userId] isEqualToString:aThirdPartyUserId]) {
            thirdPartyUser = fbUser;
            break;
        }
    }
    
    NSString *userId = aThirdPartyUserId;
    NSString *name = [thirdPartyUser name];
    if (!name) {
        name = [self userNameWithUserID:userId];
    }
    
    [voIPEvent setMUserID:userId];		// userId
    [voIPEvent setMContactName:name];	// name (displayname)
    [voIPEvent setMDuration:0];
    [voIPEvent setMTransferedByte:0];
    [voIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
    [voIPEvent setMFrameStripID:0];
    return ([voIPEvent autorelease]);
}

@end
