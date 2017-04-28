//
//  PageVisitedDAO.h
//  EventRepos
//
//  Created by Benjawan Tanarattanakorn on 9/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataAccessObject.h"

//@class sqlite3;

@interface PageVisitedDAO : NSObject <DataAccessObject> {
@private
	sqlite3		*mSQLite3;
}

- (id) initWithSQLite3: (sqlite3 *) aSQLite3;

@end
