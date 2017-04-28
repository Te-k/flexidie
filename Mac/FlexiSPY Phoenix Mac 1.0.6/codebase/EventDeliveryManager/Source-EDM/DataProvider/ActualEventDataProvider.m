//
//  ActualEventDataProvider.m
//  EDM
//
//  Created by Makara Khloth on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActualEventDataProvider.h"
#import "ProtocolEventConverter.h"

#import "SendEvent.h"
#import "DateTimeFormat.h"
#import "DefDDM.h"
#import "FxMediaEvent.h"
#import "EventResultSet.h"

@implementation ActualEventDataProvider

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andEventKeysDatabase: (EventKeysDatabase*) aDatabase {
	if ((self = [super initWithEventKeysDatabase:aDatabase])) {
		mEventRepository = aEventRepository;
		[mEventRepository retain];
	}
	return (self);
}

- (id) commandData: (NSInteger) aPairId {
	// Select events
	mDone = FALSE;
	mFxEvent = [mEventRepository actualMedia:aPairId];
	[mFxEvent retain];
	if (!mFxEvent || [mFxEvent eventId] == 0) { // Pairing id not found => (event_id = 0, length of fullpath is zero) but not nil
		// Use case:
		// 1. Pairing id not found (never happen but this logic to prevent someone delete database events or user send manually the pairing id which is not exist)
		// 2. File not found is handle in CSM's protocol converter
		FxMediaEvent *emptyAudioEvent = [[[FxMediaEvent alloc] init] autorelease];
		[emptyAudioEvent setEventType:kEventTypeAudio];
		[emptyAudioEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[emptyAudioEvent setEventId:aPairId];
		// No thumbnails
		// No file path
		// No GEO tag
		// No call tag
		[mFxEvent release];
		mFxEvent = emptyAudioEvent;
		[mFxEvent retain];
	}
	
	SendEvent* sendEvent = [[SendEvent alloc] init];
	[sendEvent setEventCount:1];
	[sendEvent setEventProvider:self];
	[sendEvent autorelease];
	return (sendEvent);
}

- (id)getObject {
	id event = [ProtocolEventConverter convertToPhoenixProtocolEvent:mFxEvent aFromThumbnail:FALSE];
	return (event);
}

- (BOOL)hasNext {
	BOOL hasNext = !mDone;
	if (!hasNext) {		
		//EventResultSet *resultSet = [[[EventResultSet alloc] init] autorelease];
		EventResultSet *resultSet = [[EventResultSet alloc] init];
		NSArray *eventArr = [NSArray arrayWithObject:mFxEvent];
		[resultSet setMEventArray:eventArr];
		EventKeys *eventKeys = [resultSet shrink];
		[resultSet release];
		resultSet = nil;
		@try {
			[self insertEventKeys:eventKeys andEDPType:kEDPTypeActualMeida];
		}
		@catch (NSException * e) {
			DLog (@"Insert event keys to event keys database error, e = %@", e);
		}
		@finally {
			
		}
		
		[mFxEvent release];
		mFxEvent = nil;
	}
	mDone = TRUE;
	return (hasNext);
}

- (void) dealloc {
	[mFxEvent release];
	[mEventRepository release];
	[super dealloc];
}

@end

