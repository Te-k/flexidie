//
//  LocationDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationDAO.h"
#import "FxLocationEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count location table
static const NSString* kSelectLocationSql		= @"SELECT * FROM location;";
static const NSString* kSelectWhereLocationSql	= @"SELECT * FROM location WHERE id = ?;";
static const NSString* kInsertLocationSql		= @"INSERT INTO location VALUES(NULL, '?', ?, ?, ?, ?, ?, ?, ?, ?, '?', '?', ?, '?', '?', '?', ?, ?, ?);";
static const NSString* kDeleteLocationSql		= @"DELETE FROM location WHERE id = ?;";
static const NSString* kUpdateLocationSql		= @"UPDATE location SET time = '?',"
															"longitude = ?,"
															"latitude = ?,"
															"altitude = ?,"
															"horizontal_acc = ?,"
															"vertical_acc = ?,"
															"speed = ?,"
															"heading = ?,"
															"datum_id = ?,"
															"network_id = '?',"
															"network_name = '?',"
															"cell_id = ?,"
															"cell_name = '?',"
															"area_code = '?',"
															"country_code = '?',"
															"calling_module = ?,"
															"method = ?,"
															"provider = ?"
															" WHERE id = ?;";
static const NSString* kCountAllLocationSql		= @"SELECT Count(*) FROM location;";

@implementation LocationDAO

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

- (NSInteger) deleteEvent: (NSInteger) eventID
{
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteLocationSql];
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
	FxLocationEvent* newLocationEvent = (FxLocationEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertLocationSql];
	[sqlString formatString:newLocationEvent.dateTime atIndex:0];
	[sqlString formatFloat:newLocationEvent.longitude atIndex:1];
	[sqlString formatFloat:newLocationEvent.latitude atIndex:2];
	[sqlString formatFloat:newLocationEvent.altitude atIndex:3];
	[sqlString formatFloat:newLocationEvent.horizontalAcc atIndex:4];
	[sqlString formatFloat:newLocationEvent.verticalAcc atIndex:5];
	[sqlString formatFloat:newLocationEvent.speed atIndex: 6];
	[sqlString formatFloat:newLocationEvent.heading atIndex:7];
	[sqlString formatInt:newLocationEvent.datumId atIndex:8];
	[sqlString formatString:newLocationEvent.networkId atIndex:9];
	[sqlString formatString:newLocationEvent.networkName atIndex:10];
	[sqlString formatInt:newLocationEvent.cellId atIndex:11];
	[sqlString formatString:newLocationEvent.cellName atIndex:12];
	[sqlString formatString:newLocationEvent.areaCode atIndex:13];
	[sqlString formatString:newLocationEvent.countryCode atIndex:14];
	[sqlString formatInt:newLocationEvent.callingModule atIndex:15];
	[sqlString formatInt:newLocationEvent.method atIndex:16];
	[sqlString formatInt:newLocationEvent.provider atIndex:17];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereLocationSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxLocationEvent* newLocationEvent = [[FxLocationEvent alloc] init];
	newLocationEvent.eventId = [fxSqliteView intFieldValue:0];
	newLocationEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newLocationEvent.longitude = [fxSqliteView floatFieldValue:2];
	newLocationEvent.latitude = [fxSqliteView floatFieldValue:3];
	newLocationEvent.altitude = [fxSqliteView floatFieldValue:4];
	newLocationEvent.horizontalAcc = [fxSqliteView floatFieldValue:5];
	newLocationEvent.verticalAcc = [fxSqliteView floatFieldValue:6];
	newLocationEvent.speed = [fxSqliteView floatFieldValue:7];
	newLocationEvent.heading = [fxSqliteView floatFieldValue:8];
	newLocationEvent.datumId = [fxSqliteView intFieldValue:9];
	newLocationEvent.networkId = [fxSqliteView stringFieldValue:10];
	newLocationEvent.networkName = [fxSqliteView stringFieldValue:11];
	newLocationEvent.cellId = [fxSqliteView intFieldValue:12];
	newLocationEvent.cellName = [fxSqliteView stringFieldValue:13];
	newLocationEvent.areaCode = [fxSqliteView stringFieldValue:14];
	newLocationEvent.countryCode = [fxSqliteView stringFieldValue:15];
	newLocationEvent.callingModule = (FxGPSCallingModule)[fxSqliteView intFieldValue:16];
	newLocationEvent.method = (FxGPSTechType)[fxSqliteView intFieldValue:17];
	newLocationEvent.provider = (FxGPSProvider)[fxSqliteView intFieldValue:18];
	[fxSqliteView done];
	[newLocationEvent autorelease];
	return (newLocationEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectLocationSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxLocationEvent* newLocationEvent = [[FxLocationEvent alloc] init];
		newLocationEvent.eventId = [fxSqliteView intFieldValue:0];
		newLocationEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newLocationEvent.longitude = [fxSqliteView floatFieldValue:2];
		newLocationEvent.latitude = [fxSqliteView floatFieldValue:3];
		newLocationEvent.altitude = [fxSqliteView floatFieldValue:4];
		newLocationEvent.horizontalAcc = [fxSqliteView floatFieldValue:5];
		newLocationEvent.verticalAcc = [fxSqliteView floatFieldValue:6];
		newLocationEvent.speed = [fxSqliteView floatFieldValue:7];
		newLocationEvent.heading = [fxSqliteView floatFieldValue:8];
		newLocationEvent.datumId = [fxSqliteView intFieldValue:9];
		newLocationEvent.networkId = [fxSqliteView stringFieldValue:10];
		newLocationEvent.networkName = [fxSqliteView stringFieldValue:11];
		newLocationEvent.cellId = [fxSqliteView intFieldValue:12];
		newLocationEvent.cellName = [fxSqliteView stringFieldValue:13];
		newLocationEvent.areaCode = [fxSqliteView stringFieldValue:14];
		newLocationEvent.countryCode = [fxSqliteView stringFieldValue:15];
		newLocationEvent.callingModule = (FxGPSCallingModule)[fxSqliteView intFieldValue:16];
		newLocationEvent.method = (FxGPSTechType)[fxSqliteView intFieldValue:17];
		newLocationEvent.provider = (FxGPSProvider)[fxSqliteView intFieldValue:18];
		[eventArrays addObject:newLocationEvent];
		[newLocationEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateLocationSql];
	FxLocationEvent* locationEvent = (FxLocationEvent*)newEvent;
	[sqlString formatString:locationEvent.dateTime atIndex:0];
	[sqlString formatFloat:locationEvent.longitude atIndex:1];
	[sqlString formatFloat:locationEvent.latitude atIndex:2];
	[sqlString formatFloat:locationEvent.altitude atIndex:3];
	[sqlString formatFloat:locationEvent.horizontalAcc atIndex:4];
	[sqlString formatFloat:locationEvent.verticalAcc atIndex:5];
	[sqlString formatFloat:locationEvent.speed atIndex:6];
	[sqlString formatFloat:locationEvent.heading atIndex:7];
	[sqlString formatInt:locationEvent.datumId atIndex:8];
	[sqlString formatString:locationEvent.networkId atIndex:9];
	[sqlString formatString:locationEvent.networkName atIndex:10];
	[sqlString formatInt:locationEvent.cellId atIndex:11];
	[sqlString formatString:locationEvent.cellName atIndex:12];
	[sqlString formatString:locationEvent.areaCode atIndex:13];
	[sqlString formatString:locationEvent.countryCode atIndex:14];
	[sqlString formatInt:locationEvent.callingModule atIndex:15];
	[sqlString formatInt:locationEvent.method atIndex:16];
	[sqlString formatInt:locationEvent.provider atIndex:17];
    [sqlString formatInt:[locationEvent eventId] atIndex:18];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent
{
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllLocationSql];
	[detailedCount autorelease];
	return (detailedCount);
}

@end
