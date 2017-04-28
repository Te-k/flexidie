//
//  LargeRegularEventDataProvider.h
//  EDM
//
//  Created by Makara Khloth on 1/10/17.
//
//

#import <Foundation/Foundation.h>

#import "DataProvider.h"
#import "EventDataProvider.h"

@protocol EventRepository;
@class EventResultSet;

@interface LargeRegularEventDataProvider : EventDataProvider <DataProvider> {
    id <EventRepository> mEventRepository;
    
    EventResultSet *mEventRS;
    NSUInteger mCurrentIndex;
}

@property (nonatomic, retain) EventResultSet *mEventRS;

- (instancetype) initWithEventRepository: (id <EventRepository>) aEventRepository eventKeysDatabase: (EventKeysDatabase *) aEventKeysDatabase;

- (id) commandData;

@end
