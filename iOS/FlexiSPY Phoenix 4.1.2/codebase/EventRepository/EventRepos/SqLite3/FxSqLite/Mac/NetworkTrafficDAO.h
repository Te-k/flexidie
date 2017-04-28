//
//  NetworkTrafficDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import <Foundation/Foundation.h>

#import "DataAccessObject.h"

@interface NetworkTrafficDAO : NSObject <DataAccessObject> {
@private
    sqlite3		*mSQLite3;
}

- (id) initWithSQLite3: (sqlite3 *) aSQLite3;

@end
