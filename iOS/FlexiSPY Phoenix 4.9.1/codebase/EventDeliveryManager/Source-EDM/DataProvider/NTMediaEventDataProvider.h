//
//  NTMediaEventDataProvider.h
//  EDM
//
//  Created by Makara Khloth on 1/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventDataProvider.h"
#import "DataProvider.h"
#import "EventRepository.h"

@class EventKeysDatabase;
@class EventResultSet;

@interface NTMediaEventDataProvider : EventDataProvider <DataProvider> {
@private
	id <EventRepository>	mEventRepository;
	EventResultSet*			mEventResultSet;
	
	NSInteger	mEventCount;
	NSInteger	mEventIndex;
}

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository
			 eventKeysDatabase: (EventKeysDatabase*) aEventKeysDatabase;

- (id) commandData;

@end
