//
//  IMMessageAttachmentDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 2/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface IMMessageAttachmentDAO : NSObject <DataAccessObject1> {
@private
	sqlite3		*mSqlite3;
}

- (id) initWithSqlite3: (sqlite3 *) aSqlite3;

- (NSArray *) selectRowWithIMMessageID: (NSInteger) aIMMessageID;

@end
