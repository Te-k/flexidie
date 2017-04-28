//
//  CalendarEntry.h
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntryType.h";
#import "Priority.h";
#import "RecurringType.h";
#import "RecurrenceStructure.h"

@interface CalendarEntry : NSObject {
	//NSInteger mUIDLength;
	NSString * mUID;
	EntryType mCalendarEntryType;
	NSString * mSubject;
	NSString * mCreatedDateTime;
	NSString * mLastModifiedDateTime;
	NSString * mStartDateTime;
	NSString * mEndDateTime;
	NSString * mOriginalDateTime;
	Priority mPriority;
	NSString * mLocation;
	NSString * mDescription;
	NSString * mOrganizerName;
	NSString * mOrganizerUID;
	NSArray * mAttendeeStructures;
	RecurringType mIsRecurring;
	RecurrenceStructure *mRecurrenceStructure;
}

//@property (nonatomic,assign)NSInteger mUIDLength;
@property (nonatomic,copy)NSString * mUID;
@property (nonatomic,assign)EntryType mCalendarEntryType;
@property (nonatomic,copy)NSString * mSubject;
@property (nonatomic,copy)NSString * mCreatedDateTime;
@property (nonatomic,copy)NSString * mLastModifiedDateTime;
@property (nonatomic,copy)NSString * mStartDateTime;
@property (nonatomic,copy)NSString * mEndDateTime;
@property (nonatomic,copy)NSString * mOriginalDateTime;
@property (nonatomic,assign)Priority mPriority;
@property (nonatomic,copy)NSString * mLocation;
@property (nonatomic,copy)NSString * mDescription;
@property (nonatomic,copy)NSString * mOrganizerName;
@property (nonatomic,copy)NSString * mOrganizerUID;
@property (nonatomic,retain)NSArray * mAttendeeStructures;
@property (nonatomic,assign)RecurringType mIsRecurring;
@property (nonatomic,retain)RecurrenceStructure *mRecurrenceStructure;


@end
