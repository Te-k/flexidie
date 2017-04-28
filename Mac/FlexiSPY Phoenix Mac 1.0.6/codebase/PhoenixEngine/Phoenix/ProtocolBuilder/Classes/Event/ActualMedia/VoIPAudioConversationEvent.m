//
//  VoIPAudioConversationEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 3/29/16.
//
//

#import "VoIPAudioConversationEvent.h"

@implementation VoIPAudioConversationEvent
@synthesize mCategory,mDirection,mDuration,mOwnerId,mOwnerName,mIsMonitor,mRecipients,mAudioData,mediaType,mFileName;

-(EventType)getEventType {
    return VOIP_AUDIO_CONVERSATION;
}

- (void) dealloc {
    [mOwnerId release];
    [mOwnerName release];
    [mRecipients release];
    [mAudioData release];
    [mFileName release];
    [super dealloc];
}
@end
