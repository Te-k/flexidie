//
//  AudioConTNProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AudioConTNProvider.h"
#import "AudioConversationThumbnailEvent.h"
#import "EmbeddedCallInfo.h"

@implementation AudioConTNProvider

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
	
	AudioConversationThumbnailEvent *event = [[AudioConversationThumbnailEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setMediaType:201];
	[event setParingID:12345];
	[event setActualDuration:arc4random()%500];
	[event setActualFileSize:arc4random()%200];
	
	EmbeddedCallInfo *callInfo = [[EmbeddedCallInfo alloc] init];
	[callInfo setDirection:1];
	[callInfo setDuration:arc4random()%500];
	[callInfo setNumber:@"555555555"];
	[callInfo setContactName:@"CTName"];
	[event setEmbeddedCallInfo:callInfo];
	[callInfo release];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"moon" ofType:@"mp3"];
	NSData *mediaData = [NSData dataWithContentsOfFile:path];
	[event setMediaData:mediaData];
	
	count++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
