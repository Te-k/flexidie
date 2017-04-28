//
//  WallpaperThumbnailEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "WallpaperThumbnailEvent.h"
#import "EventTypeEnum.h"

@implementation WallpaperThumbnailEvent

@synthesize actualFileSize;
@synthesize mediaType;
@synthesize mediaData;
@synthesize paringID;

-(EventType)getEventType {
	return WALLPAPER_THUMBNAIL;
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
