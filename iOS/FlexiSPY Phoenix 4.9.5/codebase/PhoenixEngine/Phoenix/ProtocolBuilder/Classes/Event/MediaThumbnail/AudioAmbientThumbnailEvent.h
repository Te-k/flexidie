//
//  AudioAmbientThumbnailEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 11/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface AudioAmbientThumbnailEvent : Event {
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
