//
//  AudioFileEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AudioFileEvent.h"
#import "EventTypeEnum.h"

@implementation AudioFileEvent

@synthesize mediaData;
@synthesize fileName;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return AUDIO_FILE;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [mediaData release];
    [fileName release];
	
    [super dealloc];
}


@end
