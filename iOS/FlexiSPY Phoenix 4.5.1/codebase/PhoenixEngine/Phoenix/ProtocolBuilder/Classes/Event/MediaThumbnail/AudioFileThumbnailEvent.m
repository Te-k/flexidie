//
//  AudioFileThumnailEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AudioFileThumbnailEvent.h"
#import "EventTypeEnum.h"

@implementation AudioFileThumbnailEvent

@synthesize actualDuration;
@synthesize actualFileSize;
@synthesize mediaData;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return AUDIO_FILE_THUMBNAIL;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [mediaData release];
	
    [super dealloc];
}


@end
