//
//  AudioAmbientEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 11/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaTypeEnum.h"
#import "Event.h"

@interface AudioAmbientEvent : Event {
	MediaType mediaType;
	long paringID;
	NSData *mediaData;
	NSString *fileName;
	NSInteger mDuration;
}

@property (nonatomic, assign) MediaType mediaType;
@property (nonatomic, assign) long paringID;
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger mDuration;

@end
