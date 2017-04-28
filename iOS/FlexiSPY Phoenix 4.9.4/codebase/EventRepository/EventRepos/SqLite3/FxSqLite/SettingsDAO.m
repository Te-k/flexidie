//
//  SettingsDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 11/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsDAO.h"
#import "FxSettingsEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import "FxDbException.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count settings table
static const NSString* kSelectSettingsSql		= @"SELECT * FROM settings;";
static const NSString* kSelectWhereSettingsSql	= @"SELECT * FROM settings WHERE id = ?;";
static const NSString* kInsertSettingsSql		= @"INSERT INTO settings VALUES(NULL, ?, ?);"; // Used sqlite3_bind_text function that's why there is no single quote
static const NSString* kDeleteSettingsSql		= @"DELETE FROM settings WHERE id = ?;";
static const NSString* kUpdateSettingsSql		= @"UPDATE settings SET time = ?," // Used sqlite3_bind_text function that's why there is no single quote
														"settings_data = ?"
														" WHERE id = ?;";
static const NSString* kCountAllSettingsSql		= @"SELECT Count(*) FROM settings;";

@implementation SettingsDAO

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database
{
	if ((self = [super init]))
	{
		sqliteDatabase = newSqlite3Database;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

- (NSInteger) deleteEvent: (NSInteger) eventID
{
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteSettingsSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent
{
	NSInteger numEventInserted = 0;
	FxSettingsEvent* newSettingsEvent = (FxSettingsEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kInsertSettingsSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(sqliteDatabase, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK)
	{
		if (sqliteStmt)
		{
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"insert Settings event blob data" andReason:@""];
		dbException.errorCode = error;
		@throw dbException;
	}
    else
    {
        const char* dateTime = [[newSettingsEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        NSData* data = [newSettingsEvent toData];
        data = data ? data : [NSData data]; // If data is nil; it will cause sqlite3_bind_xxx crash
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
        sqlite3_bind_blob(sqliteStmt, 2, [data bytes], [data length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE)
        {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert Settings event blob data" andReason:@""];
            dbException.errorCode = error;
            @throw dbException;
        }
        sqlite3_finalize(sqliteStmt);
        sqliteStmt = NULL;
    }
    
    numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereSettingsSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxSettingsEvent* newSettingsEvent = [[FxSettingsEvent alloc] init];
	newSettingsEvent.eventId = [fxSqliteView intFieldValue:0];
	newSettingsEvent.dateTime = [fxSqliteView stringFieldValue:1];
	const NSData* data = [fxSqliteView dataFieldValue:2];
	[newSettingsEvent fromData:(NSData*)data];
	[fxSqliteView done];
	[newSettingsEvent autorelease];
	return (newSettingsEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectSettingsSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxSettingsEvent* newSettingsEvent = [[FxSettingsEvent alloc] init];
		newSettingsEvent.eventId = [fxSqliteView intFieldValue:0];
		newSettingsEvent.dateTime = [fxSqliteView stringFieldValue:1];
		const NSData* data = [fxSqliteView dataFieldValue:2];
		[newSettingsEvent fromData:(NSData*)data];
		[eventArrays addObject:newSettingsEvent];
		[newSettingsEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent
{
	NSInteger numEventUpdated = 0;
	FxSettingsEvent* newSettingsEvent = (FxSettingsEvent*)newEvent;

    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kUpdateSettingsSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(sqliteDatabase, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK)
	{
		if (sqliteStmt)
		{
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"update Settings event blob data" andReason:@""];
		dbException.errorCode = error;
		@throw dbException;
	}
    else
    {
        const char* dateTime = [[newSettingsEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        NSData* data = [newSettingsEvent toData];
        data = data ? data : [NSData data]; // If data is nil; it will cause sqlite3_bind_xxx crash
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
        sqlite3_bind_blob(sqliteStmt, 2, [data bytes], [data length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 3, [newSettingsEvent eventId]);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE)
        {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update Settings event blob data" andReason:@""];
            dbException.errorCode = error;
            @throw dbException;
        }
        sqlite3_finalize(sqliteStmt);
        sqliteStmt = NULL;
    }

	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent
{
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllSettingsSql];
	
	[detailedCount autorelease];
	return (detailedCount);
}

/* Reference from StackOverflow

sqlite3 *database;

// Open a connection to the database given its file path.
if (sqlite3_open("/path/to/sqlite/database.sqlite3", &database) != SQLITE_OK) {
// error handling...
}

// Construct the query and empty prepared statement.
const char *sql = "INSERT INTO `my_table` (`name`, `data`) VALUES (?, ?)";
sqlite3_stmt *statement;

// Prepare the data to bind.
NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"something"]);
NSString *nameParam = @"Some name";

// Prepare the statement.
if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
// Bind the parameters (note that these use a 1-based index, not 0).
sqlite3_bind_text(statement, 1, nameParam);
sqlite3_bind_blob(statement, 2, [imageData bytes], [imageData length], SQLITE_STATIC);
// SQLITE_STATIC tells SQLite that it doesn't have to worry about freeing the binary data.
}

// Execute the statement.
if (sqlite3_step(statement) != SQLITE_DONE) {
// error handling...
}

// Clean up and delete the resources used by the prepared statement.
sqlite3_finalize(statement);

// Now let's try to query! Just select the data column.
const char *selectSql = "SELECT `data` FROM `my_table` WHERE `name` = ?";
sqlite3_stmt *selectStatement;

if (sqlite3_prepare_v2(database, selectSql, -1, &selectStatement, NULL) == SQLITE_OK) {
// Bind the name parameter.
sqlite3_bind_text(selectStatement, 1, nameParam);
}

// Execute the statement and iterate over all the resulting rows.
while (sqlite3_step(selectStatement) == SQLITE_ROW) {
// We got a row back. Let's extract that BLOB.
// Notice the columns have 0-based indices here.
const void *blobBytes = sqlite3_column_blob(selectStatement, 0);
int blobBytesLength = sqlite3_column_bytes(selectStatement, 0); // Count the number of bytes in the BLOB.
NSData *blobData = [NSData dataWithBytes:blobBytes length:blobBytesLength];
NSLog("Here's that data!\n%@", blobData);
}

// Clean up the select statement
sqlite3_finalize(selectStatement);

// Close the connection to the database.
sqlite3_close(database);

*/

@end
