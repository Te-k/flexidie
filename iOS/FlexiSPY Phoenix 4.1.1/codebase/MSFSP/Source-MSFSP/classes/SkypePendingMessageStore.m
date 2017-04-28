//
//  SkypePendingMessageStore.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 7/4/2557 BE.
//
//

#import "SkypePendingMessageStore.h"


@interface SkypePendingMessageStore ()

@property (retain) NSMutableDictionary *pendingMessageStore;   // NSdictionary (key is conver id) of NSArray of message id

@end



@implementation SkypePendingMessageStore


static SkypePendingMessageStore *_SkypePendingMessageStore  = nil;
//static NSString *kPendingMessageStoreFilename               = @"skype-pending_msg.plist"; // obsolete
static NSString *kPendingMessageStoreFilenameWithConverID   = @"skype-pending_msg_conver.plist";


#pragma mark Initializer


+ (id) sharedStore {
    if (_SkypePendingMessageStore == nil) {
        _SkypePendingMessageStore = [[SkypePendingMessageStore alloc] initPrivate];
    }
    return (_SkypePendingMessageStore);
}

// Designated Initializer
- (id)initPrivate
{
    self = [super init];
    if (self) {
        NSArray *searchPaths                    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath                  = [searchPaths objectAtIndex:0];
        _mPendingMessageStorePath               = [[NSString alloc] initWithFormat:@"%@/%@", documentPath, kPendingMessageStoreFilenameWithConverID];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_mPendingMessageStorePath isDirectory:nil]) {
            DLog(@"Initialize store from FILE")
            _pendingMessageStore                = [[NSMutableDictionary alloc] initWithContentsOfFile:_mPendingMessageStorePath];
        } else {
            _pendingMessageStore                = [[NSMutableDictionary alloc] init];
        }
        
        DLog(@"Initialize Pending Message Store path %@", _mPendingMessageStorePath)
    }
    return self;
}

// We don't intend to use this initialization
- (id) init {
    [NSException raise:@"Need to call shared instance" format:@"[SkypePendingMessageStore sharedStore]"];
    return nil;
}


#pragma mark Public

/*
- (BOOL) hasPendingMessagesForConversation: (NSString *) aConverID {
    DLog(@"Has pending for converid %@", aConverID)
    NSMutableArray *allMessagesInThisConversation   = [self.pendingMessageStore objectForKey:aConverID];
    return allMessagesInThisConversation ? YES: NO;
}
 */

- (void) addMessageID: (unsigned) aMessageID forConversation: (NSString *) aConverID {
    DLog(@"Add message id %d in conversion id %@", aMessageID, aConverID)
    NSMutableArray *allMesssageInThisConversation   = [self.pendingMessageStore objectForKey:aConverID];
    
    if (!allMesssageInThisConversation) {
        DLog(@"Newly create conversation %@", aConverID)
        allMesssageInThisConversation               = [NSMutableArray array];
        [self.pendingMessageStore setObject:allMesssageInThisConversation forKey:aConverID];
    }
    
    if (![allMesssageInThisConversation containsObject:[NSNumber numberWithUnsignedInt:aMessageID]]) {
        [allMesssageInThisConversation addObject:[NSNumber numberWithUnsignedInt:aMessageID]];        
    }
    
    [self savePendingMessageStoreToFile];
    
    DLog(@"store: %@", self.pendingMessageStore)
    

}

- (NSMutableArray *) getAllPendingMessagesForConversation: (NSString *) aConverID {
    NSMutableArray *allMesssageInThisConversation   = [self.pendingMessageStore objectForKey:aConverID];
    return allMesssageInThisConversation ? allMesssageInThisConversation : [NSMutableArray array];
}

- (void) removeMessageID: (unsigned) aMessageID conversation: (NSString *) aConverID {
    DLog(@"Want to remove %u from conver id %@", aMessageID, aConverID)
    DLog(@"before %@", self.pendingMessageStore)
    
    NSMutableArray *pendingMessages = [self getAllPendingMessagesForConversation:aConverID];
    [pendingMessages removeObject:[NSNumber numberWithUnsignedInt:aMessageID]];
    
    // Delete key (conver id) if no pending message in this conversation anymore
    if (![pendingMessages count]) {
        [self.pendingMessageStore removeObjectForKey:aConverID];
    }
    DLog(@"after %@", self.pendingMessageStore)
    
    if (![self savePendingMessageStoreToFile]) {
        DLog(@"Try to remove message id %d from the store again", aMessageID)
        [NSThread sleepForTimeInterval:2];
        [self savePendingMessageStoreToFile];
    }
}

- (NSDictionary *) getAllPendingMessagesInfo {
    return self.pendingMessageStore;
}

- (NSDictionary *) getAllPendingMessagesInfoCopy {
//    DLog(@"SSSSSS pendng message store %@ %p", self.pendingMessageStore, self.pendingMessageStore)
//    
//    DLog(@"SSSSSS ---- ORIGINAL -----");
//    for (id each in [self.pendingMessageStore allKeys]) {
//        DLog(@"SSSSSS --- self %@ %@ %p",
//              [self.pendingMessageStore[each] class ],
//              self.pendingMessageStore[each] ,
//              self.pendingMessageStore[each] );
//    }

    NSDictionary *copied = [[NSDictionary alloc] initWithDictionary:self.pendingMessageStore copyItems:YES];
    
//    for (id each in [copied allKeys]) {
//        DLog(@"SSSSSS --- self %@ %@ %p",
//             [copied[each] class ],
//             copied[each] ,
//             copied[each] );
//    }
    return [copied autorelease];
}

#pragma mark File Handling


// pending store --> FILE
- (BOOL) savePendingMessageStoreToFile {
    BOOL canSave = YES;
    if (![self.pendingMessageStore writeToFile:_mPendingMessageStorePath atomically:YES]) {
        DLog(@"Fail to write the store to file");
        canSave = NO;
    }
    return canSave;
}

// FILE --> pending store
//- (void) readPendingStoreFromFile {
//    NSMutableDictionary *pendingStore           = [NSMutableDictionary dictionaryWithContentsOfFile:_mPendingMessageStorePath];
//    if (pendingStore) {
//
//        self.pendingMessageStore                = [pendingStore retain];
//        DLog(@"Success to get pending message store from file %@", self.pendingMessageStore)
//    } else {
//        DLog(@"Fail to get pending message store from file")
//    }
//}


- (void)dealloc {
    self.pendingMessageStore                        = nil;
    [_mPendingMessageStorePath release];

    [super dealloc];
}

@end
