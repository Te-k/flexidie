//
//  FxSqliteView.h
//  FxSqLite
//
//  Created by Makara Khloth on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class sqlite3_stmt;

@interface FxSqliteView : NSObject {
@private
	sqlite3_stmt*	sqliteStmt;
	NSUInteger	numColumn;
	BOOL		eof;
}

@property (readonly) NSUInteger numColumn;
@property (readonly) BOOL eof;

- (id) initWithNewSqlite3Stmt: (sqlite3_stmt*) newSqliteStmt;

- (BOOL) nextRow;
- (void) done; // Must call to finalize sqlite3_stmt otherwise database would be locked for later transaction

// Use table field index to read the value from this view; index 0 match to first column
- (NSString*) stringFieldValue: (NSInteger) fieldIndex;
- (NSInteger) intFieldValue: (NSInteger) fieldIndex;
- (long long int) int64FieldValue: (NSInteger) aFieldIndex;
- (float) floatFieldValue: (NSInteger) fieldIndex;
- (NSData*) dataFieldValue: (NSInteger) fieldIndex;

@end
