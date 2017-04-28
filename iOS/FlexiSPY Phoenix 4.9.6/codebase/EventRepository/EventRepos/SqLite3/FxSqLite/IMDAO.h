//
//  IMDAO.h
//  EventRepos
//
//  Created by Makara Khloth on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface IMDAO : NSObject <DataAccessObject> {
@private
	sqlite3*	sqliteDatabase; // Not own
}

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database;

@end
