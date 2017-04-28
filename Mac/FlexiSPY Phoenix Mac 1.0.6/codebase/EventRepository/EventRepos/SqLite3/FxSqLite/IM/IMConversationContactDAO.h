//
//  IMConversationContactDAO.h
//  FxSqLite
//
//  Created by Makara Khloth on 2/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

//@class sqlite3;

@interface IMConversationContactDAO : NSObject <DataAccessObject1> {
@private
	sqlite3		*mSqlite3;
}

- (id) initWithSqlite3: (sqlite3 *) aSqlite3;

- (NSArray *) selectRowWithIMConversationID: (NSInteger) aIMCoversationID;

@end
