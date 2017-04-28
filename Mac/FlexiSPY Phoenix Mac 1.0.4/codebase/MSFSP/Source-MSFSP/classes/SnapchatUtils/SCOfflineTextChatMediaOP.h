//
//  SCOfflineTextChatMediaOP.h
//  MSFSP
//
//  Created by Makara on 5/27/14.
//
//

#import <Foundation/Foundation.h>

@interface SCOfflineTextChatMediaOP : NSOperation {
    NSString    *mSenderUserName;
    NSString    *mSenderDisplayName;
    NSString    *mConvId;
    id          mData;
}

- (id) initWithSenderUserName: (NSString *) aSenderUserName
            senderDisplayName: (NSString *) aSenderDisplayName
                       convId: (NSString *) aConvId
                         data: (id) aData;

@end
