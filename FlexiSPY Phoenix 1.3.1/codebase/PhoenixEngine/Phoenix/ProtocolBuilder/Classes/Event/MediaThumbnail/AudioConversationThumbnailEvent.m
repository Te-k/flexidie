//
//  AudioConversationThumbnailEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AudioConversationThumbnailEvent.h"
#import "EventTypeEnum.h"

@implementation AudioConversationThumbnailEvent

@synthesize actualDuration;
@synthesize actualFileSize;
@synthesize mediaData;
@synthesize embeddedCallInfo;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return AUDIO_CONVERSATION_THUMBNAIL;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [mediaData release];
    [embeddedCallInfo release];
	
    [super dealloc];
}



@end
