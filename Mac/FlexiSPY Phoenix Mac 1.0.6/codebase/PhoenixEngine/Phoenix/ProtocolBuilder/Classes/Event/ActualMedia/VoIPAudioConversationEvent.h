//
//  VoIPAudioConversationEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 3/29/16.
//
//

#import <Foundation/Foundation.h>

#import "MediaTypeEnum.h"
#import "Event.h"

@interface VoIPAudioConversationEvent : Event {
    int mCategory;
    int mDirection;
    int mDuration;
    NSString *mOwnerId;
    NSString *mOwnerName;
    bool mIsMonitor;
    NSArray *mRecipients; // EmbeddedVoIPCallInfo
    id mAudioData;
    MediaType mediaType;
    NSString *mFileName;
}
@property (nonatomic, assign) int mCategory;
@property (nonatomic, assign) int mDirection;
@property (nonatomic, assign) int mDuration;
@property (nonatomic, copy) NSString *mOwnerId;
@property (nonatomic, copy) NSString *mOwnerName;
@property (nonatomic, assign) bool mIsMonitor;
@property (nonatomic, retain) NSArray *mRecipients; // EmbeddedVoIPCallInfo
@property (nonatomic, retain) id mAudioData;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, copy) NSString *mFileName;
@end
