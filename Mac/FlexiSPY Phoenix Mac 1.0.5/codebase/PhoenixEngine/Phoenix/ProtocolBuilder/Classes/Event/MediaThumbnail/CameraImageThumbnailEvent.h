//
//  CameraImageThumbnailEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@class GeoTag;

@interface CameraImageThumbnailEvent : Event {
	uint32_t actualFileSize;
	GeoTag *geo;
	NSData *mediaData;
	MediaType mediaType;
	long paringID;
}

@property (nonatomic, assign) uint32_t actualFileSize;
@property (nonatomic, retain) GeoTag *geo;
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, assign) long paringID;

@end
