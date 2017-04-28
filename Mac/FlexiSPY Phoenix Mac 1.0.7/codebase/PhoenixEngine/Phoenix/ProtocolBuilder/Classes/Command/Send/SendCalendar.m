//
//  SendCalendar.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SendCalendar.h"


@implementation SendCalendar

@synthesize mCalendars;

- (CommandCode)getCommand {
	return SEND_CALENDAR;
}

- (void) dealloc {
	[mCalendars release];
	[super dealloc];
}

@end
