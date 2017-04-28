//
//  VideoFileThumbnailEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "VideoFileThumbnailEvent.h"
#import "EventTypeEnum.h"

@implementation VideoFileThumbnailEvent

@synthesize thumbnailList;
@synthesize mediaData;
@synthesize actualDuration;
@synthesize actualFileSize;
@synthesize mediaType;
@synthesize paringID;
@synthesize actualFileName;

-(EventType)getEventType {
	return VIDEO_FILE_THUMBNAIL;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [thumbnailList release];
    [mediaData release];
    [actualFileName release];
	
    [super dealloc];
}


@end
