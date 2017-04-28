//
//  ActualEventDataProvider.h
//  EDM
//
//  Created by Makara Khloth on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventDataProvider.h"
#import "DataProvider.h"
#import "EventRepository.h"

@class EventKeysDatabase;
@class EventResultSet;
@class FxEvent;

@interface ActualEventDataProvider : EventDataProvider <DataProvider> {
@private
	id <EventRepository>	mEventRepository;
	FxEvent*		mFxEvent;
	BOOL			mDone;
}

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andEventKeysDatabase: (EventKeysDatabase*) aDatabase;
- (id) commandData: (NSInteger) aPairId;

@end

