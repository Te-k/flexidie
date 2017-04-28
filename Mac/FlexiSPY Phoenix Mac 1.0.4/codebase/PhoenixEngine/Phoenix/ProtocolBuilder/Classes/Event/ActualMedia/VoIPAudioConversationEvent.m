//
//  VoIPAudioConversationEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 3/29/16.
//
//

#import "VoIPAudioConversationEvent.h"

@implementation VoIPAudioConversationEvent
@synthesize mCategory,mDirection,mDuration,mOwnerId,mOwnerName,mIsMonitor,mRecipients,mAudioData;

-(EventType)getEventType {
    return VOIP_AUDIO_CONVERSATION;
}

- (void) dealloc {
    [mOwnerId release];
    [mOwnerName release];
    [mRecipients release];
    [mAudioData release];
    [super dealloc];
}
@end
