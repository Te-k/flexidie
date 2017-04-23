//
//  CameraImageEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@class GeoTag;

@interface CameraImageEvent : Event {
	long paringID;
	MediaType mediaType;
	GeoTag *geo;
	NSString *fileName;
	NSData *mediaData;
}

@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, assign) long paringID;
@property (nonatomic, retain) GeoTag *geo;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSData *mediaData;

@end
