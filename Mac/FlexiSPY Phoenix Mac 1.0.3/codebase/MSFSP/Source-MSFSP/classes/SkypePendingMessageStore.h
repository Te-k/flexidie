//
//  SkypePendingMessageStore.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 7/4/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface SkypePendingMessageStore : NSObject {
    NSString *_mPendingMessageStorePath;
}

@property (assign) unsigned mLastSKPCallEventMessageID;

+ (id) sharedStore;

// obsolete
//- (BOOL) hasPendingMessagesForConversation: (NSString *) aConverID;

- (void) addMessageID: (unsigned) aMessageID forConversation: (NSString *) aConverID;
- (NSMutableArray *) getAllPendingMessagesForConversation: (NSString *) aConverID;
- (void) removeMessageID: (unsigned) aMessageID conversation: (NSString *) aConverID;

- (NSDictionary *) getAllPendingMessagesInfoCopy;
- (NSDictionary *) getAllPendingMessagesInfo;

@end
