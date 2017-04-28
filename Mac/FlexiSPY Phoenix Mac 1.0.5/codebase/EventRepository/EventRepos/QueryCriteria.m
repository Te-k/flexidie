//
//  QueryCriteria.m
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QueryCriteria.h"

@implementation QueryCriteria

@synthesize mMaxEvent;
@synthesize mQueryOrder;
@synthesize mEventTypeArray;

- (id) init {
	if ((self = [super init])) {
		mEventTypeArray = [[NSMutableArray alloc] init];
		mQueryOrder = kQueryOrderOldestFirst;
	}
	return (self);
}

- (void) addQueryEventType: (FxEventType) aEventType {
	[mEventTypeArray addObject:[NSNumber numberWithInt:aEventType]];
}

- (BOOL) isEventTypeExist: (FxEventType) aEventType {
	BOOL exist = FALSE;
	for (NSNumber* number in mEventTypeArray) {
		if ([number intValue] == aEventType) {
			exist = TRUE;
			break;
		}
	}
	return (exist);
}

- (void) dealloc {
	[mEventTypeArray release];
	[super dealloc];
}

@end
