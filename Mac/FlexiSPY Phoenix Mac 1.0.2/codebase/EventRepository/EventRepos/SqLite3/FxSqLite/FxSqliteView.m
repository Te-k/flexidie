//
//  FxSqliteView.m
//  FxSqLite
//
//  Created by Makara Khloth on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxSqliteView.h"
#import "FxDbException.h"

#import <sqlite3.h>

@interface FxSqliteView (private)

- (void) checkFieldIndex: (NSInteger) fieldIndex;
- (BOOL) isFieldNull: (NSInteger) fieldIndex;

@end

@implementation FxSqliteView

@synthesize numColumn;
@synthesize eof;

- (id) initWithNewSqlite3Stmt: (sqlite3_stmt*) newSqliteStmt
{
	if ((self = [super init]))
	{
		sqliteStmt = newSqliteStmt;
		eof = (sqlite3_step(sqliteStmt) == SQLITE_DONE);
		numColumn = sqlite3_column_count(sqliteStmt);
	}
	return (self);
}

- (void) dealloc
{
	[self done];
	[super dealloc];
}

- (const BOOL) nextRow
{
	NSInteger moreRowError = sqlite3_step(sqliteStmt);
	
	if (moreRowError == SQLITE_DONE)
	{
		eof = TRUE;
	}
	else if (moreRowError == SQLITE_ROW)
	{
		eof = FALSE;
	}
	else
	{
		[self done];
		FxDbException* dbException = [FxDbException exceptionWithName:@"Sqlite3 nextRow error" andReason:@""];
		dbException.errorCode = moreRowError;
		@throw dbException;
	}
	return (eof);
}

- (void) done
{
	if (sqliteStmt)
	{
		sqlite3_finalize(sqliteStmt);
		sqliteStmt = NULL;
	}
}

- (NSString*) stringFieldValue: (NSInteger) fieldIndex
{
	[self checkFieldIndex:fieldIndex];
	NSString* string = [NSString string];
	if (![self isFieldNull:fieldIndex])
	{
		NSInteger utf8StringLen = sqlite3_column_bytes(sqliteStmt, fieldIndex);
		if (utf8StringLen)
		{
			// Memory for utf8String would clean automatically according to document
			const char* utf8String = (const char*)sqlite3_column_blob(sqliteStmt, fieldIndex);
			string = [NSString stringWithUTF8String:utf8String];
		}
	}
	return (string);
}

- (NSInteger) intFieldValue: (NSInteger) fieldIndex
{
	[self checkFieldIndex:fieldIndex];
	NSInteger intValue = 0;
	if (![self isFieldNull:fieldIndex])
	{
		intValue = sqlite3_column_int(sqliteStmt, fieldIndex);
	}
	return (intValue);
}

- (long long int) int64FieldValue: (NSInteger) aFieldIndex {
	[self checkFieldIndex:aFieldIndex];
	long long int int64Value = 0;
	if (![self isFieldNull:aFieldIndex]) {
		int64Value = sqlite3_column_int64(sqliteStmt, aFieldIndex);
	}
	return (int64Value);
}

- (float) floatFieldValue: (NSInteger) fieldIndex
{
	[self checkFieldIndex:fieldIndex];
	float floatValue = 0.0;
	if (![self isFieldNull:fieldIndex])
	{
		floatValue = sqlite3_column_double(sqliteStmt, fieldIndex);
	}
	return (floatValue);
}

- (const NSData*) dataFieldValue: (NSInteger) fieldIndex
{
	[self checkFieldIndex:fieldIndex];
	NSData* data = [NSData data];
	if (![self isFieldNull:fieldIndex])
	{
		NSInteger bytesLen = sqlite3_column_bytes(sqliteStmt, fieldIndex);
		if (bytesLen)
			{
			// Memory for bytes would clean automatically according to document
			const void* bytes = sqlite3_column_blob(sqliteStmt, fieldIndex);
			data = [NSData dataWithBytes:bytes length:bytesLen];
			}
	}
	return (data);
}

- (void) checkFieldIndex: (NSInteger) fieldIndex
{
	if (fieldIndex < 0 || fieldIndex > numColumn - 1)
	{
        [self done];
		FxDbException* dbException = [FxDbException exceptionWithName:@"Sqlite3 view field index out of range" andReason:[NSString stringWithFormat:@"field count %d", numColumn]];
		dbException.errorCode = kViewColumnEventDatabaseNotFound;
		@throw dbException;
	}
}

- (BOOL) isFieldNull: (NSInteger) fieldIndex
{
	return (sqlite3_column_type(sqliteStmt, fieldIndex) == SQLITE_NULL);
}

@end
