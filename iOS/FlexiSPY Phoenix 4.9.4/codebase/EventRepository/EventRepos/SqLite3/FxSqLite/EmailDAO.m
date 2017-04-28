//
//  EmailDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EmailDAO.h"
#import "FxEmailEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count email table
static const NSString* kSelectEmailSql			= @"SELECT * FROM email;";
static const NSString* kSelectWhereEmailSql		= @"SELECT * FROM email WHERE id = ?;";
static const NSString* kInsertEmailSql			= @"INSERT INTO email VALUES(NULL, '?', ?, '?', '?', '?', '?', ?);";
static const NSString* kDeleteEmailSql			= @"DELETE FROM email WHERE id = ?;";
static const NSString* kUpdateEmailSql			= @"UPDATE email SET time = '?',"
														"direction = ?,"
														"sender_email = '?',"
														"contact_name = '?',"
														"subject = '?',"
														"message = '?',"
														"html_text = ?"
														" WHERE id = ?;";
static const NSString* kCountAllEmailSql		= @"SELECT Count(*) FROM email;";
static const NSString* kCountDirectionEmailSql	= @"SELECT Count(*) FROM email WHERE direction = ?;";

@implementation EmailDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteEmailSql];
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
	FxEmailEvent* newEmailEvent = (FxEmailEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertEmailSql];
	[sqlString formatString:newEmailEvent.dateTime atIndex:0];
	[sqlString formatInt:newEmailEvent.direction atIndex:1];
	[sqlString formatString:newEmailEvent.senderEmail atIndex:2];
	[sqlString formatString:newEmailEvent.senderContactName atIndex:3];
	[sqlString formatString:newEmailEvent.subject atIndex:4];
	[sqlString formatString:newEmailEvent.message atIndex:5];
	[sqlString formatInt:newEmailEvent.html atIndex:6];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereEmailSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxEmailEvent* newEmailEvent = [[FxEmailEvent alloc] init];
	newEmailEvent.eventId = [fxSqliteView intFieldValue:0];
	newEmailEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newEmailEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
	newEmailEvent.senderEmail = [fxSqliteView stringFieldValue:3];
	newEmailEvent.senderContactName = [fxSqliteView stringFieldValue:4];
	newEmailEvent.subject = [fxSqliteView stringFieldValue:5];
	newEmailEvent.message = [fxSqliteView stringFieldValue:6];
	newEmailEvent.html = [fxSqliteView intFieldValue:7];
	[fxSqliteView done];
	[newEmailEvent autorelease];
	return (newEmailEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectEmailSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxEmailEvent* newEmailEvent = [[FxEmailEvent alloc] init];
		newEmailEvent.eventId = [fxSqliteView intFieldValue:0];
		newEmailEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newEmailEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
		newEmailEvent.senderEmail = [fxSqliteView stringFieldValue:3];
		newEmailEvent.senderContactName = [fxSqliteView stringFieldValue:4];
		newEmailEvent.subject = [fxSqliteView stringFieldValue:5];
		newEmailEvent.message = [fxSqliteView stringFieldValue:6];
		newEmailEvent.html = [fxSqliteView intFieldValue:7];
		[eventArrays addObject:newEmailEvent];
		[newEmailEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateEmailSql];
	FxEmailEvent* emailEvent = (FxEmailEvent*)newEvent;
	[sqlString formatString:emailEvent.dateTime atIndex:0];
	[sqlString formatInt:emailEvent.direction atIndex:1];
	[sqlString formatString:emailEvent.senderEmail atIndex:2];
	[sqlString formatString:emailEvent.senderContactName atIndex:3];
	[sqlString formatString:emailEvent.subject atIndex:4];
	[sqlString formatString:emailEvent.message atIndex:5];
	[sqlString formatInt:emailEvent.html atIndex:6];
	[sqlString formatInt:emailEvent.eventId atIndex:7];
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
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllEmailSql];
	
	// In count
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.inCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.outCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.missedCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.unknownCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.localIMCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	return (detailedCount);
}

@end
