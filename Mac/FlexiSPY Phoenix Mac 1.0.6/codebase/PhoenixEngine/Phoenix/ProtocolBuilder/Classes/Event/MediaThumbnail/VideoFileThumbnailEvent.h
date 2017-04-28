//
//  VideoFileThumbnailEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface VideoFileThumbnailEvent : Event {
	long actualDuration;
	long actualFileSize;
	long paringID;
	MediaType mediaType;
	NSMutableArray *thumbnailList; // <Thumbnail>
	NSData *mediaData;
    NSString *actualFileName;
}

@property (nonatomic, assign) long actualDuration;
@property (nonatomic, assign) long actualFileSize;
@property (nonatomic, assign) long paringID;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, retain) NSMutableArray *thumbnailList;
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, copy) NSString *actualFileName;

@end
