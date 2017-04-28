//
//  CallTagDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CallTagDAO.h"
#import "FxCallTag.h"
#import "DAOFunction.h"
#import "FxSqlString.h"
#import "FxSqliteView.h"

// Select/Insert/Delete/Update/Count call tag table
static const NSString* kSelectCallTagSql		= @"SELECT * FROM call_tag;";
static const NSString* kSelectWhereCallTagSql	= @"SELECT * FROM call_tag WHERE id = ?;";
static const NSString* kInsertCallTagSql		= @"INSERT INTO call_tag VALUES(?, ?, ?, '?', '?');";
static const NSString* kDeleteCallTagSql		= @"DELETE FROM call_tag WHERE id = ?;";
static const NSString* kUpdateCallTagSql		= @"UPDATE call_tag SET direction = ?,"
														"duration = ?,"
														"number = '?',"
														"contact_name = '?'"
														" WHERE id = ?;";
static const NSString* kCountAllCallTagSql		= @"SELECT Count(*) FROM call_tag;";


@implementation CallTagDAO

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database
{
	if (self = [super init])
	{
		sqliteDatabase = newSqlite3Database;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

- (NSInteger) deleteRow: (NSInteger) rowId
{
	NSInteger numRowDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteCallTagSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowDeleted++;
	return (numRowDeleted);
}

- (NSInteger) insertRow: (id) row
{
	NSInteger numRowInserted = 0;
	FxCallTag* newRow = row;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertCallTagSql];
    [sqlString formatInt:[newRow dbId] atIndex:0];
	[sqlString formatInt:newRow.direction atIndex:1];
	[sqlString formatInt:newRow.duration atIndex:2];
	[sqlString formatString:newRow.contactNumber atIndex:3];
	[sqlString formatString:newRow.contactName atIndex:4];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereCallTagSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxCallTag* newRow = nil;
	if (!fxSqliteView.eof) {
		newRow = [[FxCallTag alloc] init];
		newRow.dbId = [fxSqliteView intFieldValue:0];
		newRow.direction = (FxEventDirection)[fxSqliteView intFieldValue:1];
		newRow.duration = [fxSqliteView intFieldValue:2];
		newRow.contactNumber = [fxSqliteView stringFieldValue:3];
		newRow.contactName = [fxSqliteView stringFieldValue:4];
		[newRow autorelease];
	}
	[fxSqliteView done];
	return (newRow);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow
{
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectCallTagSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof)
	{
		FxCallTag* newRow = [[FxCallTag alloc] init];
		newRow.dbId = [fxSqliteView intFieldValue:0];
		newRow.direction = (FxEventDirection)[fxSqliteView intFieldValue:1];
		newRow.duration = [fxSqliteView intFieldValue:2];
		newRow.contactNumber = [fxSqliteView stringFieldValue:3];
		newRow.contactName = [fxSqliteView stringFieldValue:4];
		[rowArrays addObject:newRow];
		[newRow release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

- (NSInteger) updateRow: (id) row
{
	NSInteger numRowUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateCallTagSql];
	FxCallTag* callTag = row;
	[sqlString formatInt:callTag.direction atIndex:0];
	[sqlString formatInt:callTag.duration atIndex:1];
	[sqlString formatString:callTag.contactNumber atIndex:2];
	[sqlString formatString:callTag.contactName atIndex:3];
	[sqlString formatInt:callTag.dbId atIndex:4];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger) countRow
{
	NSInteger rowCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllCallTagSql];
	return (rowCount);
}

@end
