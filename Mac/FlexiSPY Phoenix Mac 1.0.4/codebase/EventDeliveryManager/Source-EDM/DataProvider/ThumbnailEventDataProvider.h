//
//  ThumbnailEventDataProvider.h
//  EDM
//
//  Created by Makara Khloth on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventDataProvider.h"
#import "DataProvider.h"
#import "EventRepository.h"

@class EventResultSet;

@interface ThumbnailEventDataProvider : EventDataProvider <DataProvider> {
@private
	id <EventRepository>	mEventRepository;
	EventResultSet*			mEventResultSet;
	
	NSInteger	mEventCount;
	NSInteger	mEventIndex;
}

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andEventKeysDatabase: (EventKeysDatabase*) aDatabase;
- (id) commandData;

@end
