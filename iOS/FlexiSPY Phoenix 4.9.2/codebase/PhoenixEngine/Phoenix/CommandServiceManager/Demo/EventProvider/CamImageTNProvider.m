//
//  CamImageTNProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CamImageTNProvider.h"
#import "CameraImageThumbnailEvent.h"
#import "GeoTag.h"

@implementation CamImageTNProvider

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
	
	CameraImageThumbnailEvent *event = [[CameraImageThumbnailEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	GeoTag *geoTag = [[GeoTag alloc] init];
	[geoTag setAltitude:10];
	[geoTag setLat:13.55];
	[geoTag setLon:100.66];
	[event setGeo:geoTag];
	[geoTag release];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"jpeg"];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	[event setMediaData:imageData];
	
	count++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
