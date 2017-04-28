//
//  EventResultSet.m
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventResultSet.h"
#import "EventKeys.h"
#import "FxEvent.h"
#import "EventRepositoryUtils.h"

@implementation EventResultSet

@synthesize mEventArray;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

// Override set property
- (void) setMEventArray: (NSArray *) aEventArray {
	if (mEventArray) {
		[mEventArray release];
		mEventArray = nil;
	}
	mEventArray = aEventArray;
	[mEventArray retain];
	mShrinked = NO;
}

- (NSArray*) events: (FxEventType) aEventType {
	NSMutableArray* eventArray = [[NSMutableArray alloc] init];
	for (FxEvent* event in mEventArray) {
		if ([event eventType] == aEventType) {
			[eventArray addObject:event];
		} else { // Map media type to thumbnail type
			FxEventType thumbnailEventType = [EventRepositoryUtils mapMediaToThumbnailEventType:[event eventType]];
			if (thumbnailEventType == aEventType) {
				[eventArray addObject:event];
			}
		}
	}
	[eventArray autorelease];
	return (eventArray);
}

- (EventKeys*) shrink {
	EventKeys* eventKeys = nil;
	if (!mShrinked) {
		NSMutableDictionary* eventTypeIdArrayDic = [[NSMutableDictionary alloc] init];
		NSInteger eventType;
		for (eventType = kEventTypeUnknown; eventType < kEventTypeMaxEventType; eventType++) {
			NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
			[eventTypeIdArrayDic setObject:eventIdArray forKey:[NSNumber numberWithInt:eventType]];
			[eventIdArray release];
		}
		
		for (FxEvent* event in mEventArray) {
			NSMutableArray* eventIdArray = [eventTypeIdArrayDic objectForKey:[NSNumber numberWithInt:[event eventType]]];
			[eventIdArray addObject:[NSNumber numberWithInt:[event eventId]]];
		}
		
		eventKeys = [[EventKeys alloc] init];
		for (eventType = kEventTypeUnknown; eventType < kEventTypeMaxEventType; eventType++) {
			NSArray* eventIdArray = [eventTypeIdArrayDic objectForKey:[NSNumber numberWithInt:eventType]];
			if ([eventIdArray count]) {
				[eventKeys put:(FxEventType)eventType withEventIdArray:eventIdArray];
			}
		}
		[eventKeys autorelease];
		[eventTypeIdArrayDic release];
		[mEventArray release];
		mEventArray = nil;
		mShrinked = TRUE;
	}
	return (eventKeys);
}

- (void) dealloc {
	DLog (@"Event result set is deallocated.., is shrinked = %d", mShrinked);
	[mEventArray release];
	[super dealloc];
}

@end
