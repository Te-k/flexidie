//
//  EventBaseDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface EventBaseDAO : NSObject <DataAccessObject2> {
@private
	sqlite3*	sqliteDatabase; // Not own
}

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database;

// DataAccessObject2
- (EventCount*) countAllEvent;
- (NSUInteger) totalEventCount;

@end
