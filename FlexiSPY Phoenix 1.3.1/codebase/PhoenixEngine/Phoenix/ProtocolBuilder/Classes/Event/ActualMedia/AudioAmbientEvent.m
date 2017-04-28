//
//  AudioAmbientEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 11/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioAmbientEvent.h"
#import "EventTypeEnum.h"

@implementation AudioAmbientEvent

@synthesize mediaData;
@synthesize fileName;
@synthesize mediaType;
@synthesize paringID;
@synthesize mDuration;

-(EventType)getEventType {
	return AUDIO_AMBIENT_RECORDING;
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
