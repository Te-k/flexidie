//
//  EventDataProvider.h
//  EDM
//
//  Created by Makara Khloth on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EventKeys;
@class EventKeysDatabase;

@interface EventDataProvider : NSObject {
@private
	EventKeysDatabase*	mEventKeyDatabase;
}

- (id) initWithEventKeysDatabase: (EventKeysDatabase*) aDatabase;

- (void) insertEventKeys: (EventKeys*) aEventKeys andEDPType: (NSInteger) aEDPType;
- (void) deleteEventKeys: (NSInteger) aEDPType;
- (EventKeys*) selectEventKeys: (NSInteger) aEDPType;

@end
