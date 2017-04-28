//
//  VideoProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "VideoProvider.h"
#import "VideoFileEvent.h"

@implementation VideoProvider

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
	
	VideoFileEvent *event = [[VideoFileEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setMediaType:107];
	[event setParingID:12345];
	[event setFileName:@"VideoName"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"avi"];
	NSData *mediaData = [NSData dataWithContentsOfFile:path];
	//DLog(@"imageData %@", imageData);
	[event setMediaData:mediaData];
	
	count++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
