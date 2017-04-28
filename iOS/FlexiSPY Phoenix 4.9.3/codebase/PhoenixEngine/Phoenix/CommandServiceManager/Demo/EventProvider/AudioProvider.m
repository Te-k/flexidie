//
//  AudioProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AudioProvider.h"
#import "AudioFileEvent.h"

@implementation AudioProvider

@synthesize total;

-(id)init {
	if (self = [super init]) {
		total = 5;
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
	
	AudioFileEvent *event = [[AudioFileEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setMediaType:201];
	[event setParingID:12345];
	[event setFileName:@"AudioName"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"moon" ofType:@"mp3"];
	NSData *mediaData = [NSData dataWithContentsOfFile:path];
	//DLog(@"imageData %@", imageData);
	[event setMediaData:mediaData];
	
	count++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
