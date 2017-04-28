//
//  VideoFileEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "VideoFileEvent.h"
#import "EventTypeEnum.h"

@implementation VideoFileEvent

@synthesize fileName;
@synthesize mediaData;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return VIDEO_FILE;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [fileName release];
    [mediaData release];
	
    [super dealloc];
}


@end
