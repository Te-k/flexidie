//
//  DatabaseManager.h
//  FxSqLite
//
//  Created by Makara Khloth on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class sqlite3;
@class DatabaseSchema;

@interface DatabaseManager : NSObject {
@private
	sqlite3*	sqlite3Database;
	BOOL		dbOpen;
	NSString*	dbFileName;
	DatabaseSchema*		dbSchema;
}

- (void) openDB;
- (void) closeDb;
- (void) dropDB;
- (sqlite3*) sqlite3db;
- (NSString*) dbFullName;
- (NSUInteger) lastInsertRowId;
- (DatabaseSchema*) databaseSchema;

@end
