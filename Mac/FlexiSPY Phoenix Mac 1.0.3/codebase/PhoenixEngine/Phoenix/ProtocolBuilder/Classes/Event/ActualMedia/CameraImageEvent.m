//
//  CameraImageEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CameraImageEvent.h"
#import "EventTypeEnum.h"

@implementation CameraImageEvent

@synthesize fileName;
@synthesize geo;
@synthesize mediaData;
@synthesize mediaType;
@synthesize paringID;

-(EventType)getEventType {
	return CAMERA_IMAGE;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [fileName release];
    [geo release];
    [mediaData release];
	
    [super dealloc];
}


@end
