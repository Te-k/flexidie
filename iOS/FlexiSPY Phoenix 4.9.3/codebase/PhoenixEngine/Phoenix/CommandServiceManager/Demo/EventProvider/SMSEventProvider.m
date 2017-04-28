//
//  SMSEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/13/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SMSEventProvider.h"
#import "SMSEvent.h"
#import "Recipient.h"

@implementation SMSEventProvider

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

	SMSEvent *event = [[SMSEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];

	[event setDirection:arc4random()%3];
	[event setContactName:@"Contact Name"];
	[event setSenderNumber:@"123456789"];
	[event setSMSData:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"];
	
	Recipient *recipient = [[Recipient alloc] init];
	[recipient setContactName:@"xx"];
	[recipient setRecipient:@"yy"];
	[recipient setRecipientType:1];
	NSArray *recipients = [NSArray arrayWithObject:recipient];
	[recipient release];
	
	[event setRecipientStore:recipients];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
