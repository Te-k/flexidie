//
//  WallpaperTNEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/14/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "WallpaperTNEventProvider.h"
#import "WallpaperThumbnailEvent.h"

@implementation WallpaperTNEventProvider

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
	
	WallpaperThumbnailEvent *event = [[WallpaperThumbnailEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setMediaType:1];
	[event setParingID:12345];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"jpeg"];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	//DLog(@"imageData %@", imageData);
	[event setMediaData:imageData];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}


@end
