//
//  SystemEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SystemEventProvider.h"
#import "SystemEvent.h"

@implementation SystemEventProvider

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
	
	SystemEvent *event = [[SystemEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setCategory:1];
	[event setDirection:0];
	[event setMessage:@"Hello World System event"];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
