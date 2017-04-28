//
//  FileTransferDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import <Foundation/Foundation.h>

#import "DataAccessObject.h"

@interface FileTransferDAO : NSObject <DataAccessObject> {
@private
    sqlite3		*mSQLite3;
}

- (id) initWithSQLite3: (sqlite3 *) aSQLite3;

@end
