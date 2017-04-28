//
//  DAOFactory.h
//  FxSqLite
//
//  Created by Makara Khloth on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEventEnums.h"

//@class sqlite3;

@interface DAOFactory : NSObject {

}
+ (id) dataAccessObject: (FxEventType) eventType withSqlite3: (sqlite3*) refSqlite3;

@end
