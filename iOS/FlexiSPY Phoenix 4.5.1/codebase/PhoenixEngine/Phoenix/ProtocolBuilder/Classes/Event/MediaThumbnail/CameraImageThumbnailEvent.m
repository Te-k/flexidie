//
//  CameraImageThumbnailEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CameraImageThumbnailEvent.h"
#import "EventTypeEnum.h"

@implementation CameraImageThumbnailEvent

@synthesize actualFileSize;
@synthesize geo;
@synthesize mediaData;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return CAMERA_IMAGE_THUMBNAIL;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [geo release];
    [mediaData release];
	
    [super dealloc];
}


@end
