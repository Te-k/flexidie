//
//  CallTagDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface CallTagDAO : NSObject <DataAccessObject1> {
@private
	sqlite3*	sqliteDatabase; // Not own
}

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database;

// DataAccessObject1
- (NSInteger) deleteRow: (NSInteger) rowId;
- (NSInteger) insertRow: (id) row;
- (id) selectRow: (NSInteger) rowId;
- (NSArray*) selectMaxRow: (NSInteger) maxRow;
- (NSInteger) updateRow: (id) row;
- (NSInteger) countRow;

@end
