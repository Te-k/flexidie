//
//  Event1Provider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/8/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "PanicOnEventProvider.h"
#import "PanicStatus.h"

@implementation PanicOnEventProvider

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
	
	PanicStatus *panicStatus = [[PanicStatus alloc] init];
	[panicStatus setStatus:1];
	[panicStatus setEventId:999];
	[panicStatus setTime:dateString];
	count ++;
	DLog(@"getObject %@", panicStatus);
	return [panicStatus autorelease];
}

@end
