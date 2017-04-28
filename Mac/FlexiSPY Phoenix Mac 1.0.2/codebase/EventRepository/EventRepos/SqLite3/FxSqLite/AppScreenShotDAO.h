//
//  AppScreenShotDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 4/26/16.
//
//

#import <Foundation/Foundation.h>

#import "DataAccessObject.h"

@interface AppScreenShotDAO : NSObject <DataAccessObject> {
@private
    sqlite3		*mSQLite3;
}

- (id) initWithSQLite3: (sqlite3 *) aSQLite3;

@end
