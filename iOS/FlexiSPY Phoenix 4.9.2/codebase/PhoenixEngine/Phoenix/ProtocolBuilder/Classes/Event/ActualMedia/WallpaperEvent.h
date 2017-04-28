//
//  WallpaperEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface WallpaperEvent : Event {
	MediaType mediaType;
	long paringID;
	NSData *mediaData;
}

@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, assign) long paringID;
@property (nonatomic, retain) NSData *mediaData;

@end
