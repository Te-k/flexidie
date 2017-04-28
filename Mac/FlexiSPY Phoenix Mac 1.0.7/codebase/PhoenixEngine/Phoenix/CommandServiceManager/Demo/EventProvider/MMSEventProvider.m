//
//  MMSEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/13/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "MMSEventProvider.h"
#import "MMSEvent.h"

@implementation MMSEventProvider

@synthesize total;

-(id)init {
	if (self = [super init]) {
		total = 10;
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
	
	MMSEvent *event = [[MMSEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setDirection:arc4random()%3];
	[event setContactName:[NSString stringWithFormat:@"Contact Name %d", count]];
	[event setSenderNumber:[NSString stringWithFormat:@"Sender Number %d", count]];
	[event setSubject:[NSString stringWithFormat:@"Subject %d", count]];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
