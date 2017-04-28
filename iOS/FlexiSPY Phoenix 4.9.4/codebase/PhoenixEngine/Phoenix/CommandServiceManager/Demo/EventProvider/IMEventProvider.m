//
//  IMEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/13/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "IMEventProvider.h"
#import "IMEvent.h"
#import "Participant.h"

@implementation IMEventProvider

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
	
	IMEvent *event = [[IMEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setDirection:arc4random()%3];
	[event setIMServiceID:[NSString stringWithFormat:@"fbk"]];
	[event setMessage:[NSString stringWithFormat:@"Message %d ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", count]];
	[event setUserDisplayName:[NSString stringWithFormat:@"Display Name %d", count]];
	[event setUserID:[NSString stringWithFormat:@"Display Name %d", count]];

	Participant *participant1 = [[Participant alloc] init];
	[participant1 setName:@"Name1"];
	[participant1 setUID:@"UID1"];
	Participant *participant2 = [[Participant alloc] init];
	[participant2 setName:@"Name2"];
	[participant2 setUID:@"UID2"];
	
	NSArray *participants = [NSArray arrayWithObjects:participant1, participant2, nil];
	[participant1 release];
	[participant2 release];
	
	[event setParticipantList:participants];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}

@end
