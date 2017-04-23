//
//  AudioFileEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface AudioFileEvent : Event {
	NSData *mediaData;
	NSString *fileName;
	MediaType mediaType;
	long paringID;
}
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, assign) long paringID;

@end
