//
//  VideoFileEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface VideoFileEvent : Event {
	long paringID;
	MediaType mediaType;
	NSString *fileName;
	NSData *mediaData;
}

@property (nonatomic, assign) long paringID;
@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSData *mediaData;

@end
