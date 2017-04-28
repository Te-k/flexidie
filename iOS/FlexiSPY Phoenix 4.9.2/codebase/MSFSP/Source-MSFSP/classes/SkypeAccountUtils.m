//
//  SkypeAccountUtils.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/16/2557 BE.
//
//

#import "SkypeAccountUtils.h"
#import "SKPConversationLists.h"
#import "SKPConversation.h"

static SkypeAccountUtils *_SkypeAccountUtils = nil;

@implementation SkypeAccountUtils


+ (id) sharedSkypeAccountUtils {
    if (_SkypeAccountUtils == nil) {
        _SkypeAccountUtils = [[SkypeAccountUtils alloc] initPrivate];
    }
    return (_SkypeAccountUtils);
}

// Designated Initializer
- (id)initPrivate {
    self = [super init];
    if (self) {
    }
    return self;
}

// We don't intend to use this initialization
- (id) init {
    [NSException raise:@"Use share instance only" format:@"+[SkypeAccountUtils sharedSkypeAccountUtils]"];
    return nil;
}

- (SKPConversation *) getSKPConversationWithID: (NSString *) aConversationID {
    DLog(@"Find conversation %@", aConversationID)
    NSArray *conversationArray              = self.mConversationList.inboxConversations;

    DLog(@"all conver %@", conversationArray)
    
    SKPConversation *matchedConversation    = nil;
    for (SKPConversation *eachConversation in conversationArray) {
        DLog (@"--------------- NO %lu ------------------- ", (unsigned long)[conversationArray indexOfObject:eachConversation])
        if ([[eachConversation conversationIdentity] isEqualToString:aConversationID]) {

            matchedConversation = eachConversation;
            DLog(@"Got conver object for %@ %@", aConversationID, matchedConversation)
        }
    }
    return matchedConversation;
}

- (void) dealloc {
    self.mAccount           = nil;
    self.mConversationList  = nil;
//    self.mContactList = nil;
    [super dealloc];
}
@end
