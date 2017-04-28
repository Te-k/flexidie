//
//  Instagram.h
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 7/7/2559 BE.
//
//


#import <Foundation/Foundation.h>

#import "IGDirectInboxService.h"
#import "IGDirectInboxNetworker.h"
#import "IGDirectRefreshService.h"
#import "IGDirectCache.h"
#import "IGDirectThread.h"
#import "IGDirectThreadStore.h"
#import "IGDirectThreadStore-Networking.h"
#import "IGDirectThreadDiskCache.h"
#import "IGDirectThreadsFetchOptions.h"
#import "IGDirectContent.h"
#import "IGUser.h"

#import "IGAuthHelper.h"
#import "IGAuthHelper+8-3-0.h"
#import "IGUserSession.h"

#import "IGUtils.h"
#import "IGDate.h"

#import "IGDirectComment.h"
#import "IGDirectPhoto.h"
#import "IGDirectVideo.h"
#import "IGDirectReaction.h"
#import "IGDirectThreadMerger.h"
#import "IGDirectContentUploadInfo.h"
#import "IGDirectContentUploader.h"
#import "IGDirectPostShare.h"
#import "IGPost.h"
#import "IGFeedItem.h"
#import "IGDirectShareSheet.h"
#import "IGDirectPostShareSheet.h"
#import "IGDirectMessageAcknowledgement.h"

// 9.0.1
#import "IGDirectThreadStore+9-0-1.h"
#import "IGDirectThreadService.h"
#import "IGDirectReelShare.h"

// 9.1
#import "IGDirectRealtimeService.h"
#import "IGUserSession-IGDirectRealtimeService.h"
#import "IGDirectThreadNotificationHelper.h"

// 9.2
#import "IGUserSession-IGDirectInboxNetworker.h"
#import "IGDirectThread+9-2.h"

#pragma mark -
#pragma mark Instrgram
#pragma mark -

//For all incoming (Comment, Photo, Video, Reaction, PostShare,) and some outgoing (Comment, Reaction)
HOOK(IGDirectThreadStore, addContent$forThreadId$, void, id arg1, id arg2) {
    CALL_ORIG(IGDirectThreadStore, addContent$forThreadId$, arg1, arg2);
    
    Class $IGDirectComment = objc_getClass("IGDirectComment");
    Class $IGDirectPhoto = objc_getClass("IGDirectPhoto");
    Class $IGDirectVideo = objc_getClass("IGDirectVideo");
    Class $IGDirectReaction = objc_getClass("IGDirectReaction");
    Class $IGDirectPostShare = objc_getClass("IGDirectPostShare");
    Class $IGDirectReelShare = objc_getClass("IGDirectReelShare");
    
    if (![arg1 isKindOfClass:$IGDirectComment] &&
        ![arg1 isKindOfClass:$IGDirectPhoto] &&
        ![arg1 isKindOfClass:$IGDirectVideo] &&
        ![arg1 isKindOfClass:$IGDirectReaction] &&
        ![arg1 isKindOfClass:$IGDirectPostShare] &&
        ![arg1 isKindOfClass:$IGDirectReelShare]) {
        DLog(@"Not support capturing this class %@", [arg1 class]);
        return;
    }
    
    @try {
        //It will call 2 time for outgoing share post
        if ([arg1 isKindOfClass:$IGDirectPostShare]) {//Share post can come together with IGDirectComment but that comment never come as an argument so we need to load all message in thread manually
            long long lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:arg2] longLongValue];
            
            //Below 9.0.1
            if ([self respondsToSelector:@selector(fetchThreadWithID:cursorOption:cursorValue:mergeOption:successfulThreadHandler:)]) {
                [self fetchThreadWithID:arg2 cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
                    @try {
                        DLog(@"success arg1 %@", resultThread);
                        
                        IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                        IGDate *lastestMessageDate = lastestMessage.sentAt;
                        DLog(@"lastestMessageDate %@", lastestMessageDate);
                        DLog(@"lastestTimestamp %f", lastestTimestamp);
                        
                            //Filter by lastest timestamp of thread that we keep in plist
                        if (lastestTimestamp == 0 || lastestMessageDate.microseconds > lastestTimestamp) {
                            
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
                                    //Need to load more message
                                [[IGUtils sharedIGUtils] loadAllContentFromThread:resultThread inThreadStore:self firstLoad:YES];
                            }
                            else {
                                    //Do capture
                                [[IGUtils sharedIGUtils] captureMessagesFromThread:resultThread];
                            }
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
            else {//9.0.1
                IGDirectThreadService *threadService = nil;
                
                if ([self respondsToSelector:@selector(threadService)]){
                    threadService = [self threadService];
                }
                else {// 9.1
                    Class $IGAuthHelper = objc_getClass("IGAuthHelper");
                    IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
                    IGUserSession *currentUserSession = authHelper.currentUserSession;
                    IGDirectRealtimeService *realTimeService = [currentUserSession directRealtimeService];
                    DLog(@"realTimeService %@", realTimeService);
                    threadService = realTimeService.threadService;
                }
                
                [threadService refreshThreadWithId:arg2 cursor:nil completion:^(IGDirectThread *resultThread){
                    @try {
                        DLog(@"success arg1 %@", resultThread);
                        
                        IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                        IGDate *lastestMessageDate = lastestMessage.sentAt;
                        DLog(@"lastestMessageDate %@", lastestMessageDate);
                        DLog(@"lastestTimestamp %f", lastestTimestamp);
                        
                        NSDictionary *lastSeenDict = nil;
                        
                        if ([resultThread respondsToSelector:@selector(lastSeenAtForItemIds)]) {
                            lastSeenDict = [resultThread lastSeenAtForItemIds];
                        }
                        else if ([resultThread respondsToSelector:@selector(lastSeenDatesForItemIds)]) {
                            lastSeenDict = [resultThread lastSeenDatesForItemIds];
                        }
                        
                            //Filter by lastest timestamp of thread that we keep in plist
                        if (lastestTimestamp == 0 || lastestMessageDate.microseconds > lastestTimestamp) {
                            NSArray *lastSeenItems = [[lastSeenDict allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
                                return [obj1.date compare:obj2.date];
                            }];
                            
                            DLog(@"lastSeenItems %@", lastSeenItems);
                            IGDate *lastSeenDate = [lastSeenItems lastObject];
                            
                            IGDirectContent *firstMessage = [resultThread.publishedMessages firstObject];
                            DLog(@"firstMessage.sentAt %@", firstMessage.sentAt);
                            
                            if ([firstMessage.sentAt.date timeIntervalSinceDate:lastSeenDate.date] > 0) {
                                    //Need to load more message
                                [[IGUtils sharedIGUtils] loadAllContentFromThread:resultThread inThreadStore:self firstLoad:YES];
                            }
                            else {
                                    //Do capture
                                [[IGUtils sharedIGUtils] captureMessagesFromThread:resultThread];
                            }
                        }
                    } @catch (NSException *exception) {
                        DLog(@"Found exception %@", exception);
                    } @finally {
                        //Done
                    }
                }];
            }
        }
        else {
            IGDirectContent *content = arg1;
            long long lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:arg2] longLongValue];
            DLog(@"content timestamp %lld", content.sentAt.microseconds);
            
            Class $IGAuthHelper = objc_getClass("IGAuthHelper");
            IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
            IGUserSession *currentUserSession = authHelper.currentUserSession;
            IGUser *currentUser = currentUserSession.user;
            
            //For outgoing need to reload data from server to get real timestamp
            if ([content.user.pk isEqualToString:currentUser.pk]) {
                //Below 9.0.1
                if ([self respondsToSelector:@selector(fetchThreadWithID:cursorOption:cursorValue:mergeOption:successfulThreadHandler:)]) {
                    [self fetchThreadWithID:arg2 cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
                        @try {
                            DLog(@"success arg1 %@", resultThread);
                            IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                            if ([lastestMessage.itemId isEqualToString:content.itemId]) {
                                DLog(@"ouging timestamp after load %lld", lastestMessage.sentAt.microseconds);
                                
                                IGDate *lastestMessageDate = lastestMessage.sentAt;
                                
                                if (lastestMessageDate.microseconds > lastestTimestamp) {
                                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.microseconds forThreadID:resultThread.threadId];
                                    [IGUtils captureMessageContent:arg1 inThread:resultThread];
                                }
                                else {
                                        //Already capture from app did become active
                                }
                            }
                            else {
                                    //Unexpected error last message did not uploaded to server
                                DLog(@"Unexpected error");
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
                else {//9.0.1
                    IGDirectThreadService *threadService = nil;
                    
                    if ([self respondsToSelector:@selector(threadService)]){
                        threadService = [self threadService];
                    }
                    else {// 9.1
                        IGDirectRealtimeService *realTimeService = [currentUserSession directRealtimeService];
                        DLog(@"realTimeService %@", realTimeService);
                        threadService = realTimeService.threadService;
                    }
                    
                    [threadService refreshThreadWithId:arg2 cursor:nil completion:^(IGDirectThread *resultThread){
                        @try {
                            DLog(@"success arg1 %@", resultThread);
                            IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                            if ([lastestMessage.itemId isEqualToString:content.itemId]) {
                                DLog(@"ouging timestamp after load %lld", lastestMessage.sentAt.microseconds);
                                
                                IGDate *lastestMessageDate = lastestMessage.sentAt;
                                
                                if (lastestMessageDate.microseconds > lastestTimestamp) {
                                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.microseconds forThreadID:resultThread.threadId];
                                    [IGUtils captureMessageContent:arg1 inThread:resultThread];
                                }
                                else {
                                        //Already capture from app did become active
                                }
                            }
                            else {
                                    //Unexpected error last message did not uploaded to server
                                DLog(@"Unexpected error");
                            }
                        } @catch (NSException *exception) {
                            DLog(@"Found exception %@", exception);
                        } @finally {
                            //Done
                        }

                    }];
                }
            }
            else {//For incoming capture it right away
                IGDirectThread *thread = [self storedThreadWithID:arg2];
                IGDate *lastestMessageDate = content.sentAt;
                
                if (lastestMessageDate.microseconds > lastestTimestamp) {
                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.microseconds forThreadID:thread.threadId];
                    [IGUtils captureMessageContent:arg1 inThread:thread];
                }
                else {
                    //Already capture from app did become active
                }
            }
        }
    } @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    } @finally {
        //Done
    }
}

#pragma mark - 9.1 -

//For all incoming (Comment, Photo, Video, Reaction, PostShare,) and some outgoing (Comment, Reaction)
HOOK(IGDirectThreadNotificationHelper, didReceiveAddContentNotification$, void, id arg1) {
    CALL_ORIG(IGDirectThreadNotificationHelper, didReceiveAddContentNotification$, arg1);
    
    @try {
        //DLog(@"arg1 %@", arg1);
        NSNotification *addContentNotification = arg1;
        //DLog(@"userInfo %@", addContentNotification.userInfo);
        
        NSDictionary *userInfo = addContentNotification.userInfo;
        IGDirectContent *content = [userInfo objectForKey:@"content"];
        IGDirectThread *thread = [userInfo objectForKey:@"thread"];
        
        DLog(@"content %@", content);
        IGDate *contentDate = content.sentAt;
        DLog(@"contentDate %@", contentDate);
        
        Class $IGDirectComment = objc_getClass("IGDirectComment");
        Class $IGDirectPhoto = objc_getClass("IGDirectPhoto");
        Class $IGDirectVideo = objc_getClass("IGDirectVideo");
        Class $IGDirectReaction = objc_getClass("IGDirectReaction");
        Class $IGDirectPostShare = objc_getClass("IGDirectPostShare");
        Class $IGDirectReelShare = objc_getClass("IGDirectReelShare");
        
        if (![content isKindOfClass:$IGDirectComment] &&
            ![content isKindOfClass:$IGDirectPhoto] &&
            ![content isKindOfClass:$IGDirectVideo] &&
            ![content isKindOfClass:$IGDirectReaction] &&
            ![content isKindOfClass:$IGDirectPostShare] &&
            ![content isKindOfClass:$IGDirectReelShare]) {
            DLog(@"Not support capturing this class %@", [content class]);
            return;
        }
        
        Class $IGAuthHelper = objc_getClass("IGAuthHelper");
        IGAuthHelper *authHelper = [$IGAuthHelper sharedAuthHelper];
        IGUserSession *currentUserSession = authHelper.currentUserSession;
        IGUser *currentUser = currentUserSession.user;
        IGDirectThreadStore *threadStore = [currentUserSession directThreadStore];
        
        if ([content isKindOfClass:$IGDirectPostShare] && [content.user.pk isEqualToString:currentUser.pk]) {//Share post can come together with IGDirectComment but that comment never come as an argument so we need to load all message in thread manually
            long long lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:thread.threadId] longLongValue];
            
            IGDirectThreadService *threadService = nil;
            
                //Below 9.0.1
            if ([threadStore respondsToSelector:@selector(fetchThreadWithID:cursorOption:cursorValue:mergeOption:successfulThreadHandler:)]) {
                [threadStore fetchThreadWithID:thread.threadId cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
                    @try {
                        DLog(@"success arg1 %@", resultThread);
                        
                        IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                        IGDate *lastestMessageDate = lastestMessage.sentAt;
                        DLog(@"lastestMessageDate %@", lastestMessageDate);
                        DLog(@"lastestTimestamp %f", lastestTimestamp);
                        
                        NSDictionary *lastSeenDict = nil;
                        
                        if ([resultThread respondsToSelector:@selector(lastSeenAtForItemIds)]) {
                            lastSeenDict = [resultThread lastSeenAtForItemIds];
                        }
                        else if ([resultThread respondsToSelector:@selector(lastSeenDatesForItemIds)]) {
                            lastSeenDict = [resultThread lastSeenDatesForItemIds];
                        }
                        
                            //Filter by lastest timestamp of thread that we keep in plist
                        if (lastestTimestamp == 0 || lastestMessageDate.microseconds > lastestTimestamp) {
                            NSArray *lastSeenItems = [[lastSeenDict allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
                                return [obj1.date compare:obj2.date];
                            }];
                            
                            DLog(@"lastSeenItems %@", lastSeenItems);
                            IGDate *lastSeenDate = [lastSeenItems lastObject];
                            
                            IGDirectContent *firstMessage = [resultThread.publishedMessages firstObject];
                            DLog(@"firstMessage.sentAt %@", firstMessage.sentAt);
                            
                            if ([firstMessage.sentAt.date timeIntervalSinceDate:lastSeenDate.date] > 0) {
                                    //Need to load more message
                                [[IGUtils sharedIGUtils] loadAllContentFromThread:resultThread inThreadStore:threadStore firstLoad:YES];
                            }
                            else {
                                    //Do capture
                                [[IGUtils sharedIGUtils] captureMessagesFromThread:resultThread];
                            }
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
            else {
                //9.0.1
                if ([threadStore respondsToSelector:@selector(threadService)]){
                    threadService = [threadStore threadService];
                }
                else {// 9.1
                    IGDirectRealtimeService *realTimeService = [currentUserSession directRealtimeService];
                    DLog(@"realTimeService %@", realTimeService);
                    threadService = realTimeService.threadService;
                }
                
                [threadService refreshThreadWithId:thread.threadId cursor:nil completion:^(IGDirectThread *resultThread){
                    @try {
                        DLog(@"success arg1 %@", resultThread);
                        
                        IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                        IGDate *lastestMessageDate = lastestMessage.sentAt;
                        DLog(@"lastestMessageDate %@", lastestMessageDate);
                        DLog(@"lastestTimestamp %f", lastestTimestamp);
                        
                        NSDictionary *lastSeenDict = nil;
                        
                        if ([resultThread respondsToSelector:@selector(lastSeenAtForItemIds)]) {
                            lastSeenDict = [resultThread lastSeenAtForItemIds];
                        }
                        else if ([resultThread respondsToSelector:@selector(lastSeenDatesForItemIds)]) {
                            lastSeenDict = [resultThread lastSeenDatesForItemIds];
                        }
                        
                            //Filter by lastest timestamp of thread that we keep in plist
                        if (lastestTimestamp == 0 || lastestMessageDate.microseconds > lastestTimestamp) {
                            NSArray *lastSeenItems = [[lastSeenDict allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
                                return [obj1.date compare:obj2.date];
                            }];
                            
                            DLog(@"lastSeenItems %@", lastSeenItems);
                            IGDate *lastSeenDate = [lastSeenItems lastObject];
                            
                            IGDirectContent *firstMessage = [resultThread.publishedMessages firstObject];
                            DLog(@"firstMessage.sentAt %@", firstMessage.sentAt);
                            
                            if ([firstMessage.sentAt.date timeIntervalSinceDate:lastSeenDate.date] > 0) {
                                    //Need to load more message
                                [[IGUtils sharedIGUtils] loadAllContentFromThread:resultThread inThreadStore:threadStore firstLoad:YES];
                            }
                            else {
                                    //Do capture
                                [[IGUtils sharedIGUtils] captureMessagesFromThread:resultThread];
                            }
                        }
                    } @catch (NSException *exception) {
                        DLog(@"Found exception %@", exception);
                    } @finally {
                        //Done
                    }
                }];
            }
        }
        else {
            long long lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:thread.threadId] longLongValue];
            DLog(@"content timestamp %lld", content.sentAt.microseconds);
            
                //For outgoing need to reload data from server to get real timestamp
            if ([content.user.pk isEqualToString:currentUser.pk]) {
                    //Below 9.0.1
                if ([threadStore respondsToSelector:@selector(fetchThreadWithID:cursorOption:cursorValue:mergeOption:successfulThreadHandler:)]) {
                    [threadStore fetchThreadWithID:thread.threadId cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
                        @try {
                            DLog(@"success arg1 %@", resultThread);
                            IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                            if ([lastestMessage.itemId isEqualToString:content.itemId]) {
                                DLog(@"ouging timestamp after load %lld", lastestMessage.sentAt.microseconds);
                                
                                IGDate *lastestMessageDate = lastestMessage.sentAt;
                                
                                if (lastestMessageDate.microseconds > lastestTimestamp) {
                                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.microseconds forThreadID:resultThread.threadId];
                                    [IGUtils captureMessageContent:content inThread:resultThread];
                                }
                                else {
                                        //Already capture from app did become active
                                }
                            }
                            else {
                                    //Unexpected error last message did not uploaded to server
                                DLog(@"Unexpected error");
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
                else {//9.0.1
                    IGDirectThreadService *threadService = nil;
                    
                    if ([threadStore respondsToSelector:@selector(threadService)]){
                        threadService = [threadStore threadService];
                    }
                    else {// 9.1
                        IGDirectRealtimeService *realTimeService = [currentUserSession directRealtimeService];
                        DLog(@"realTimeService %@", realTimeService);
                        threadService = realTimeService.threadService;
                    }
                    
                    [threadService refreshThreadWithId:thread.threadId cursor:nil completion:^(IGDirectThread *resultThread){
                        @try {
                            DLog(@"success arg1 %@", resultThread);
                            IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                            if ([lastestMessage.itemId isEqualToString:content.itemId]) {
                                DLog(@"ouging timestamp after load %lld", lastestMessage.sentAt.microseconds);
                                
                                IGDate *lastestMessageDate = lastestMessage.sentAt;
                                
                                if (lastestMessageDate.microseconds > lastestTimestamp) {
                                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.microseconds forThreadID:resultThread.threadId];
                                    [IGUtils captureMessageContent:content inThread:resultThread];
                                }
                                else {
                                        //Already capture from app did become active
                                }
                            }
                            else {
                                    //Unexpected error last message did not uploaded to server
                                DLog(@"Unexpected error");
                            }
                        } @catch (NSException *exception) {
                            DLog(@"Found exception %@", exception);
                        } @finally {
                            //Done
                        }
                    }];
                }
            }
            else {//For incoming capture it right away
                IGDate *lastestMessageDate = content.sentAt;
                
                if (lastestMessageDate.microseconds > lastestTimestamp) {
                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.microseconds forThreadID:thread.threadId];
                    [IGUtils captureMessageContent:content inThread:thread];
                }
                else {
                    //Already capture from app did become active
                }
            }
        }
    } @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    } @finally {
            //Done
    }
}