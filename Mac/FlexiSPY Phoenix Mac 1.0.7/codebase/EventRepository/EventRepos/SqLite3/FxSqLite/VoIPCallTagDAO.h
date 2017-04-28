//
//  VoIPCallTagDAO.h
//  EventRepos
//
//  Created by Makara Khloth on 10/10/16.
//
//

#import <Foundation/Foundation.h>

#import "DataAccessObject.h"

@interface VoIPCallTagDAO : NSObject <DataAccessObject1> {
    sqlite3 *mSQLite3; // Not own
}

- (instancetype) initWithSqlite3: (sqlite3 *) aSQLite3;

@end
