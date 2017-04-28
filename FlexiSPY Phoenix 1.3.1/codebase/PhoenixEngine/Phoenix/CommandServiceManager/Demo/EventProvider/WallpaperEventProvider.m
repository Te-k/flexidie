//
//  WallpaperEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/14/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "WallpaperEventProvider.h"
#import "WallpaperEvent.h"

@implementation WallpaperEventProvider

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
	
	WallpaperEvent *event = [[WallpaperEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];

	[event setMediaType:1];
	[event setParingID:12345];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"pic" ofType:@"jpg"];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	//DLog(@"imageData %@", imageData);
	[event setMediaData:imageData];
	
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}


@end
