//
//  ThumbnailDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface ThumbnailDAO : NSObject <DataAccessObject3> {
@private
	sqlite3*	sqliteDatabase; // Not own
}

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database;

@end
