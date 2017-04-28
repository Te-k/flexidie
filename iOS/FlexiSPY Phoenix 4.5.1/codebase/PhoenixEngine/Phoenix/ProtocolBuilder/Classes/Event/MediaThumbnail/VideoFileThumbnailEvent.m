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
	
    [super dealloc];
}


@end
