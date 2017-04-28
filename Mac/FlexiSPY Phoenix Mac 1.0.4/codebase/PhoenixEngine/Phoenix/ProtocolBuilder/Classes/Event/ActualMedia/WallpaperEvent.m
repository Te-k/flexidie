//
//  WallpaperEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "WallpaperEvent.h"
#import "EventTypeEnum.h"

@implementation WallpaperEvent

@synthesize mediaType;
@synthesize mediaData;
@synthesize paringID;

-(EventType)getEventType {
	return WALLPAPER;
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
