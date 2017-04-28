//
//  CalendarEntry.m
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CalendarEntry.h"


@implementation CalendarEntry
@synthesize mUID,mSubject,mCreatedDateTime,mLastModifiedDateTime,mStartDateTime,mEndDateTime,mOriginalDateTime,mLocation,mDescription,mOrganizerName,mOrganizerUID,mAttendeeStructures;
@synthesize mCalendarEntryType,mPriority,mIsRecurring,mRecurrenceStructure;

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ == \n%@", [self mSubject], [self mUID]];
}

-(void)dealloc{
	[mUID release];
	[mSubject release];
	[mCreatedDateTime release];
	[mLastModifiedDateTime release];
	[mStartDateTime release];
	[mEndDateTime release];
	[mOriginalDateTime release];
	[mLocation release];
	[mDescription release];
	[mOrganizerName release];
	[mOrganizerUID release];
	[mAttendeeStructures release];
	[mRecurrenceStructure release];
	[super dealloc];
}
@end
