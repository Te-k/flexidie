//
//  MailEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/13/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "EmailEventProvider.h"
#import "EmailEvent.h"
#import "Recipient.h"
#import "Participant.h"

@implementation EmailEventProvider

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

	EmailEvent *event = [[EmailEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
//	UNKNOWN_EVENT_DIRECTION,
//	IN,
//	OUT,
//	MISSED,
//	LOCAL
	
	[event setDirection:arc4random()%3];
	[event setEmailBody:[NSString stringWithFormat:@"Email body %d", count]];
	[event setContactName:[NSString stringWithFormat:@"Contact Name %d", count]];
	[event setSenderEmail:[NSString stringWithFormat:@"Sender Email %d", count]];
	[event setSubject:[NSString stringWithFormat:@"Subject %d", count]];

	Recipient *recipient = [[Recipient alloc] init];
	[recipient setContactName:@"xx"];
	[recipient setRecipient:@"yy"];
	[recipient setRecipientType:1];
	Recipient *recipient2 = [[Recipient alloc] init];
	[recipient2 setContactName:@"222"];
	[recipient2 setRecipient:@"222"];
	[recipient2 setRecipientType:1];
	
	NSArray *recipients = [NSArray arrayWithObjects:recipient, recipient2, nil];
	[recipient release];
	[recipient2 release];
	
	[event setRecipientStore:recipients];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
