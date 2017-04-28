//
//  EventKeysDAO.h
//  EDM
//
//  Created by Makara Khloth on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class EventKeys;

@interface EventKeysDAO : NSObject {
@private
	FMDatabase*	mDatabase;
}

@property (readonly) FMDatabase* mDatabase;

- (id) initWithDatabase: (FMDatabase*) aDatabase;

- (void) insertEventKeys: (EventKeys*) aEventKey withEDPType: (NSInteger) aEDPType;
- (EventKeys*) selectEventKeys: (NSInteger) aEDPType;
- (void) deleteEventKeys: (NSInteger) aEDPType;

@end
