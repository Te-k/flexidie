//
//  AudioConversationThumbnailEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@class EmbeddedCallInfo;

@interface AudioConversationThumbnailEvent : Event {
	long actualDuration;
	long actualFileSize;
	long paringID;
	MediaType mediaType;
	EmbeddedCallInfo *embeddedCallInfo;
	NSData *mediaData;
}

@property (nonatomic, assign) long actualDuration;
@property (nonatomic, assign) long actualFileSize;
@property (nonatomic, assign) long paringID;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, retain) EmbeddedCallInfo *embeddedCallInfo;
@property (nonatomic, retain) NSData *mediaData;

@end
