//
//  ThumbnailEventProvider.m
//  TestApp
//
//  Created by Makara Khloth on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailEventProvider.h"

#import "SendEvent.h"
#import "CameraImageThumbnailEvent.h"

@implementation ThumbnailEventProvider

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) commandData {
	mEventLeft = 1;
	SendEvent* sendEvent = [[SendEvent alloc] init];
	[sendEvent setEventCount:(int)mEventLeft];
	[sendEvent setEventProvider:self];
	[sendEvent autorelease];
	return (sendEvent);
}

- (id)getObject {
	CameraImageThumbnailEvent* camImageThumbnail = [[CameraImageThumbnailEvent alloc] init];
	[camImageThumbnail setEventId:1];
	[camImageThumbnail setTime:@"20-10-2011 03:04:45"];
	[camImageThumbnail setMediaType:(MediaType)PNG];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Doc-thumbnail" ofType:@"png"];
	NSFileManager* fm = [NSFileManager defaultManager];
	//NSDictionary* attr = [fm fileAttributesAtPath:path traverseLink:FALSE];
    NSDictionary* attr = [fm attributesOfItemAtPath:path error:nil];
	[camImageThumbnail setActualFileSize:[[attr objectForKey:NSFileSize] intValue]];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	[camImageThumbnail setMediaData:imageData];
	[camImageThumbnail setParingID:1];
	[camImageThumbnail autorelease];
	@synchronized (self) {
		mEventLeft--;
	}
	return (camImageThumbnail);
}

- (BOOL)hasNext {
	return (mEventLeft > 0);
}

- (void) dealloc {
	[super dealloc];
}

@end