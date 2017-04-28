//
//  FileActivityDAO.h
//  EventRepos
//
//  Created by Makara Khloth on 9/28/15.
//
//

#import <Foundation/Foundation.h>

#import "DataAccessObject.h"

@interface FileActivityDAO : NSObject <DataAccessObject> {
@private
    sqlite3		*mSQLite3;
}

- (id) initWithSQLite3: (sqlite3 *) aSQLite3;

@end
