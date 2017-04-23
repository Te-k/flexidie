//
//  AudioAmbientThumbnailEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 11/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioAmbientThumbnailEvent.h"
#import "EventTypeEnum.h"

@implementation AudioAmbientThumbnailEvent

@synthesize actualDuration;
@synthesize actualFileSize;
@synthesize mediaData;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return AUDIO_AMBIENT_RECORDING_THUMBNAIL;
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
