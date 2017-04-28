//
//  GPSTagDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GPSTagDAO.h"
#import "FxGPSTag.h"
#import "DAOFunction.h"
#import "FxSqlString.h"
#import "FxSqliteView.h"

// Select/Insert/Delete/Update/Count gps tag table
static const NSString* kSelectGPSTagSql			= @"SELECT * FROM gps_tag;";
static const NSString* kSelectWhereGPSTagSql	= @"SELECT * FROM gps_tag WHERE id = ?;";
static const NSString* kInsertGPSTagSql			= @"INSERT INTO gps_tag VALUES(?, ?, ?, ?, ?, '?', '?', '?');";
static const NSString* kDeleteGPSTagSql			= @"DELETE FROM gps_tag WHERE id = ?;";
static const NSString* kUpdateGPSTagSql			= @"UPDATE gps_tag SET longitude = ?,"
														"latitude = ?,"
														"altitude = ?,"
														"cell_id = ?,"
														"area_code = '?',"
														"network_id = '?',"
														"country_code = '?'"
														" WHERE id = ?;";
static const NSString* kCountAllGPSTagSql		= @"SELECT Count(*) FROM gps_tag;";

@implementation GPSTagDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteGPSTagSql];
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
	FxGPSTag* newRow = row;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertGPSTagSql];
    [sqlString formatInt:[newRow dbId] atIndex:0];
	[sqlString formatFloat:newRow.longitude atIndex:1];
	[sqlString formatFloat:newRow.latitude atIndex:2];
	[sqlString formatFloat:newRow.altitude atIndex:3];
	[sqlString formatInt:newRow.cellId atIndex:4];
	[sqlString formatString:newRow.areaCode atIndex:5];
	[sqlString formatString:newRow.networkId atIndex: 6];
	[sqlString formatString:newRow.countryCode atIndex:7];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereGPSTagSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxGPSTag* newRow = nil;
	if (!fxSqliteView.eof) {
		newRow = [[FxGPSTag alloc] init];
		newRow.dbId = [fxSqliteView intFieldValue:0];
		newRow.longitude = [fxSqliteView floatFieldValue:1];
		newRow.latitude = [fxSqliteView floatFieldValue:2];
		newRow.altitude = [fxSqliteView floatFieldValue:3];
		newRow.cellId = [fxSqliteView intFieldValue:4];
		newRow.areaCode = [fxSqliteView stringFieldValue:5];
		newRow.networkId = [fxSqliteView stringFieldValue:6];
		newRow.countryCode = [fxSqliteView stringFieldValue:7];
		[newRow autorelease];
	}
	[fxSqliteView done];
	return (newRow);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow
{
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectGPSTagSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof)
	{
		FxGPSTag* newRow = [[FxGPSTag alloc] init];
		newRow.dbId = [fxSqliteView intFieldValue:0];
		newRow.longitude = [fxSqliteView floatFieldValue:1];
		newRow.latitude = [fxSqliteView floatFieldValue:2];
		newRow.altitude = [fxSqliteView floatFieldValue:3];
		newRow.cellId = [fxSqliteView intFieldValue:4];
		newRow.areaCode = [fxSqliteView stringFieldValue:5];
		newRow.networkId = [fxSqliteView stringFieldValue:6];
		newRow.countryCode = [fxSqliteView stringFieldValue:7];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateGPSTagSql];
	FxGPSTag* gpsTag = row;
	[sqlString formatFloat:gpsTag.longitude atIndex:0];
	[sqlString formatFloat:gpsTag.latitude atIndex:1];
	[sqlString formatFloat:gpsTag.altitude atIndex:2];
	[sqlString formatInt:gpsTag.cellId atIndex:3];
	[sqlString formatString:gpsTag.areaCode atIndex:4];
	[sqlString formatString:gpsTag.networkId atIndex:5];
	[sqlString formatString:gpsTag.countryCode atIndex:6];
	[sqlString formatInt:gpsTag.dbId atIndex:7];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger) countRow
{
	NSInteger rowCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllGPSTagSql];
	return (rowCount);
}

@end
