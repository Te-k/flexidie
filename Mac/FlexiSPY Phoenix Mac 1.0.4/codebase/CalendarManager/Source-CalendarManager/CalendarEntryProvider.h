//
//  CalendarEntryProvider.h
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@class EKEventStore;

@interface CalendarEntryProvider : NSObject <DataProvider> {
	NSArray			*mCalendarEntryArray;
	NSInteger		mCalendarEntryCount;
	NSInteger		mCalendarEntryIndex;
	
	// An EKEventStore object requires a relatively large amount of time to initialize and release. 
	// An event store instance MUST NOT be released before other Event Kit objects; otherwise, undefined behavior may occur.
	EKEventStore	*mEventStore;			// not own
}


@property (retain) NSArray *mCalendarEntryArray;
@property (retain)	EKEventStore *mEventStore;
@property (assign) 	NSInteger mCalendarEntryCount;
@property (assign) 	NSInteger mCalendarEntryIndex;

- (BOOL) hasNext;			// DataProvider protocol
- (id) getObject;			// DataProvider protocol
- (id) commandData;

@end
