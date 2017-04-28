//
//  SkypeOperation.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/16/2557 BE.
//
//


@class SKPConversation;
@class SKPCallEventMessage;

typedef enum {
    kSkypeOperationTypeRealTimeMessage  = 1,
    kSkypeOperationTypePendingMessage   = 2
} SkypeOperationType;


@interface SkypeOperation : NSOperation {
    SKPConversation     *_mConversation;
    unsigned            _mMessageID;
    SkypeOperationType  _mSkypeOperationType;
    
    SKPCallEventMessage *mEarlierCallMessage;
}

- (id) initWithMessageID: (unsigned) aMessageID
            conversation: (SKPConversation *) aConversation
           operationType: (SkypeOperationType) aSkpOperationType;
    
@end
