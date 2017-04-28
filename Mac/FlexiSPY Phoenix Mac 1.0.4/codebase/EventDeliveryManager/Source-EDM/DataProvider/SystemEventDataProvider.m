//
//  SystemEventDataProvider.m
//  EDM
//
//  Created by Makara Khloth on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SystemEventDataProvider.h"
#import "ProtocolEventConverter.h"

#import "SendEvent.h"

#import "EventResultSet.h"
#import "QueryCriteria.h"

#import "DefDDM.h"

@implementation SystemEventDataProvider

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
	[queryCriteria addQueryEventType:kEventTypeSystem];
	mEventResultSet = [mEventRepository systemEvents:queryCriteria];
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
	id event = [ProtocolEventConverter convertToPhoenixProtocolEvent:[[mEventResultSet mEventArray] objectAtIndex:mEventIndex] aFromThumbnail:FALSE];
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
			[self insertEventKeys:eventKeys andEDPType:kEDPTypeSystem];
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

