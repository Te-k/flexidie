//
//  Event2Provider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/12/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CallLogEventProvider.h"
#import "CallLogEvent.h"

@implementation CallLogEventProvider

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
	
	CallLogEvent *callLog1 = [[CallLogEvent alloc] init];
	[callLog1 setEventId:count];
	[callLog1 setTime:dateString];
	
	[callLog1 setDirection:arc4random()%4];
	[callLog1 setDuration:arc4random()%60];
	[callLog1 setContactName:[NSString stringWithFormat:@"Contact Name %d", count]];
	[callLog1 setNumber:[NSString stringWithFormat:@"01234567%d", count]];

	count++;
	DLog(@"getObject %@", callLog1);
	return [callLog1 autorelease];
}

@end
