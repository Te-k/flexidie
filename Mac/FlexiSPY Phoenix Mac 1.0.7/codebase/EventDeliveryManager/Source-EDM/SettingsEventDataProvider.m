//
//  SettingsEventDataProvider.m
//  EDM
//
//  Created by Makara Khloth on 11/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsEventDataProvider.h"
#import "ProtocolEventConverter.h"

#import "SendEvent.h"

#import "EventResultSet.h"
#import "QueryCriteria.h"

#import "DefDDM.h"

@implementation SettingsEventDataProvider

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andEventKeysDatabase: (EventKeysDatabase*) aDatabase {
	if ((self = [super initWithEventKeysDatabase:aDatabase])) {
		mEventRepository = aEventRepository;
		[mEventRepository retain];
	}
	return (self);
}

- (id) commandData {
	// Select events
	QueryCriteria* queryCriteria = [[QueryCriteria alloc] init];
	[queryCriteria setMMaxEvent:50];
	[queryCriteria setMQueryOrder:kQueryOrderOldestFirst];
	[queryCriteria addQueryEventType:kEventTypeSettings];
	mEventResultSet = [mEventRepository settingsEvents:queryCriteria];
	[mEventResultSet retain];
	[queryCriteria release];
	mEventIndex = 0;
	mEventCount = [[mEventResultSet mEventArray] count];
	SendEvent* sendEvent = [[SendEvent alloc] init];
	[sendEvent setEventCount:mEventCount];
	[sendEvent setEventProvider:self];
	[sendEvent autorelease];
	return (sendEvent);
}

- (id)getObject {
	id event = [ProtocolEventConverter convertToPhoenixProtocolEvent:[[mEventResultSet mEventArray] objectAtIndex:mEventIndex] fromThumbnail:FALSE];
	mEventIndex++;
	return (event);
}

- (BOOL)hasNext {
	BOOL hasNext = (mEventIndex < mEventCount);
	if (!hasNext) {
		EventKeys* eventKeys = [mEventResultSet shrink];
		[mEventResultSet release];
		mEventResultSet = nil;
		@try {
			[self insertEventKeys:eventKeys andEDPType:kEDPTypeSettings];
		}
		@catch (NSException * e) {
			
		}
		@finally {
			
		}
	}
	return (hasNext);
}

- (void) dealloc {
	[mEventResultSet release];
	[mEventRepository release];
	[super dealloc];
}

@end
