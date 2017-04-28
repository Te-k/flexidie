//
//  Calendar.m
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Calendar.h"


@implementation Calendar
@synthesize  mCalendarId,mCalendarName,mCalendarEntries;

-(void)dealloc{
	[mCalendarName release];
	[mCalendarEntries release];
	[super dealloc];
}

@end
