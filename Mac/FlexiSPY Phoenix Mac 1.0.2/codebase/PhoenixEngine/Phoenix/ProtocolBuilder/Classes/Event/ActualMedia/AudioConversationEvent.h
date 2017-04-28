//
//  AudioConversationEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@class EmbeddedCallInfo;

@interface AudioConversationEvent : Event {
	MediaType mediaType;
	long paringID;
	EmbeddedCallInfo *embeddedCallInfo;
	NSData *mediaData;
	NSString *fileName;
}

@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, assign) long paringID;
@property (nonatomic, retain) EmbeddedCallInfo *embeddedCallInfo;
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, copy) NSString *fileName;

@end
