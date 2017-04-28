//
//  VideoTNProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "VideoTNProvider.h"
#import "VideoFileThumbnailEvent.h"

@implementation VideoTNProvider

@synthesize total;

-(id)init {
	if (self = [super init]) {
		total = 2;
		count = 0;
	}
	return self;
}

-(BOOL)hasNext {
	return (count < total);
}

-(id)getObject {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]]; 
	[dateFormatter release];
	
	VideoFileThumbnailEvent *event = [[VideoFileThumbnailEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setMediaType:107];
	[event setParingID:12345];
	[event setActualDuration:arc4random()%500];
	[event setActualFileSize:arc4random()%200];
	
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"avi"];
//	NSData *mediaData = [NSData dataWithContentsOfFile:path];
//	[event setMediaData:mediaData];
	
	count++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
