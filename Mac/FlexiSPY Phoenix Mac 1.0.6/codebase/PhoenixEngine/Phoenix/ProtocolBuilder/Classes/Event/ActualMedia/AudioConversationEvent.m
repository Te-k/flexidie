//
//  AudioConversationEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AudioConversationEvent.h"
#import "EventTypeEnum.h"

@implementation AudioConversationEvent

@synthesize mediaData;
@synthesize embeddedCallInfo;
@synthesize fileName;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return AUDIO_CONVERSATION;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [mediaData release];
    [embeddedCallInfo release];
    [fileName release];
	
    [super dealloc];
}


@end
