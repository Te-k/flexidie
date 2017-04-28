//
//  AttendeeStructure.m
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AttendeeStructure.h"


@implementation AttendeeStructure
@synthesize mAttendeeName,mAttendeeUID;

- (void) dealloc {
	[mAttendeeUID release];
	[mAttendeeName release];
	[super dealloc];
}

@end
