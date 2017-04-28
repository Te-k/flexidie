//
//  BookmarkDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface BookmarkDAO : NSObject <DataAccessObject2> {
@private
	sqlite3		*mSqlite3; // Not own
}

- (id) initWithSqlite3: (sqlite3 *) aSqlite3;

@end
