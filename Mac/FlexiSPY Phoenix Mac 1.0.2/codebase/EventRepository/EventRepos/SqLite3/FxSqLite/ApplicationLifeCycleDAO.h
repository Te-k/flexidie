//
//  ApplicationLifeCycleDAO.h
//  EventRepos
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface ApplicationLifeCycleDAO : NSObject <DataAccessObject> {
@private
	sqlite3*	mSqliteDatabase; // Not own
}

- (id) initWithSqlite3: (sqlite3*) aNewSqlite3Database;

@end
