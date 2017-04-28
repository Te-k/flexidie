//
//  PanicImageEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/14/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "PanicImageEventProvider.h"
#import "PanicImage.h"

@implementation PanicImageEventProvider

@synthesize total;

-(id)init {
	if (self = [super init]) {
		total = 1;
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
	
	PanicImage *event = [[PanicImage alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setLat:1234.044];
	[event setLon:1.2];
	[event setAltitude:500];
	[event setCoordinateAccuracy:2];
	[event setNetworkName:@"networkName"];
	[event setNetworkID:@"NWID"];
	[event setCellName:@"cellName"];
	[event setCellID:100];
	[event setCountryCode:66];
	[event setAreaCode:77];
	[event setMediaType:1];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"pic" ofType:@"jpg"];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	//DLog(@"imageData %@", imageData);
	[event setMediaData:imageData];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}


@end
