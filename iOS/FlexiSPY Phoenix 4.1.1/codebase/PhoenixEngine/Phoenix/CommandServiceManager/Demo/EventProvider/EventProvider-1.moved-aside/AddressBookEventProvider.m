//
//  AddressBookEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AddressBookEventProvider.h"


@implementation AddressBookEventProvider

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
	
	WallpaperEvent *event = [[WallpaperEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
