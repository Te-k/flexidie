//
//  SkypeWaiter.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/16/2557 BE.
//
//
 
@class SKPConversation;

@interface SkypeWaiter : NSObject {
    NSOperationQueue        *mQueue;
    NSMutableDictionary     *mQueueList;        // NSDictionary of NSOperationQueue (key is chat id , value is NSOperationQueue)
//    NSDictionary *mPendingMessage;
}

@property (retain) NSDictionary *mPendingMessage;

+ (id) sharedSkypeWaiter;

// obsoleted
- (void) captureRealTimeMessageID: (unsigned) aMessageID conversation: (SKPConversation *) aConversation;
- (void) capturePendingIncomingMessagesInConversation: (SKPConversation *) aConversation;

// realtime and offline
- (void) captureRealTimeMessageIDV2: (unsigned) aMessageID conversation: (SKPConversation *) aConversation isPending: (BOOL) aIsPending;

// pending message before Skype is quit
- (void) preparePendingIncomingMessages;
- (void) captureAllPendingIncomingMessages;


@end
