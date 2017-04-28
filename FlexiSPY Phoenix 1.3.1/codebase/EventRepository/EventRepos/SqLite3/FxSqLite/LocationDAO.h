//
//  LocationDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

@class sqlite3;

@interface LocationDAO : NSObject <DataAccessObject> {
@private
	sqlite3*	sqliteDatabase; // Not own
}

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database;

// DataAccessObject
- (NSInteger) deleteEvent: (NSInteger) eventID;
- (NSInteger) insertEvent: (FxEvent*) newEvent;
- (FxEvent*) selectEvent: (NSInteger) eventID;
- (NSArray*) selectMaxEvent: (NSInteger) maxEvent;
- (NSInteger) updateEvent: (FxEvent*) newEvent;
- (DetailedCount*) countEvent;

@end
