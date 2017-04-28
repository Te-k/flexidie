//
//  WallpaperThumbnailEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface WallpaperThumbnailEvent : Event {
	uint32_t actualFileSize;
	MediaType mediaType;
	NSData *mediaData;
	uint32_t paringID;
}

@property (nonatomic, assign) uint32_t actualFileSize;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, assign) uint32_t paringID;

@end
