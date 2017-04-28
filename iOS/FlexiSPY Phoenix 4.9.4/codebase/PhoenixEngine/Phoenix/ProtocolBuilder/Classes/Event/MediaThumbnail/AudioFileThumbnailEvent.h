//
//  AudioFileThumnailEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface AudioFileThumbnailEvent : Event {
	long actualDuration;
	long actualFileSize;
	long paringID;
	MediaType mediaType;
	NSData *mediaData;
}

@property (nonatomic, assign) long actualDuration;
@property (nonatomic, assign) long actualFileSize;
@property (nonatomic, assign) long paringID;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, retain) NSData *mediaData;


@end
