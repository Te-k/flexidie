//
//  DAOFunction.m
//  FxSqLite
//
//  Created by Makara Khloth on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "FxDbException.h"

#import <sqlite3.h>

@implementation DAOFunction

+ (void) execDML: (sqlite3*) sqliteDatabase withSqlStatement: (const NSString*) sqlStatement
{
	char* errorMessage = NULL;
	NSInteger sqliteError = sqlite3_exec(sqliteDatabase, [sqlStatement cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
	
	NSString* errString = nil;
	if (errorMessage)
	{
		errString = [NSString stringWithUTF8String:errorMessage];
		sqlite3_free(errorMessage);
	}
	
	if (sqliteError != SQLITE_OK)
	{
		FxDbException* dbException = [FxDbException exceptionWithName:@"execDML error" andReason:errString];
		dbException.errorCode = sqliteError;
		@throw dbException;
	}
}

+ (NSInteger) execScalar: (sqlite3*) sqliteDatabase withSqlStatement: (const NSString*) sqlStatement
{
	NSInteger count = 0;
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement :sqlStatement];
	count = [fxSqliteView intFieldValue:0];
	[fxSqliteView done];
	return (count);
}

+ (FxSqliteView*) execQuery: (sqlite3*) sqliteDatabase withSqlStatement: (const NSString*) sqlStatement
{
	FxSqliteView* fxSqliteView = NULL;
	sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [sqlStatement cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(sqliteDatabase, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK)
	{
		if (sqliteStmt)
		{
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"execQuery error" andReason:@""];
		dbException.errorCode = error;
		@throw dbException;
	}
	else
	{
		fxSqliteView = [[FxSqliteView alloc] initWithNewSqlite3Stmt:sqliteStmt]; // Pass ownership
		[fxSqliteView autorelease];
	}
	return (fxSqliteView);
}

@end
