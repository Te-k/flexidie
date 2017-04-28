//
//  PasswordDAO.m
//  EventRepos
//
//  Created by Makara on 2/24/14.
//
//

#import "PasswordDAO.h"
#import "FxPasswordEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count Password table
static NSString * const kSelectPasswordSql          = @"SELECT * FROM password;";
static NSString * const kSelectWherePasswordSql     = @"SELECT * FROM password WHERE id = ?;";
static NSString * const kInsertPasswordSql          = @"INSERT INTO password VALUES(NULL, '?', '?', '?', ?);";
static NSString * const kDeletePasswordSql          = @"DELETE FROM password WHERE id = ?;";
static NSString * const kUpdatePasswordSql          = @"UPDATE password SET time = '?',"
                                                                "application_id = '?',"
                                                                "application_name = '?',"
                                                                "application_type = ?"
                                                                " WHERE id = ?;";
static NSString * const kCountAllPasswordSql		= @"SELECT Count(*) FROM password;";

@implementation PasswordDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
	if ((self = [super init])) {
		mSQLite3 = aSQLite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
	NSInteger numEventDeleted		= 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeletePasswordSql];
	[sqlString formatInt:aEventID atIndex:0];
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
	NSInteger numEventInserted		= 0;
	FxPasswordEvent *newPasswordEvent	= (FxPasswordEvent *)aNewEvent;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertPasswordSql];
	
	[sqlString formatString:newPasswordEvent.dateTime atIndex:0];
	[sqlString formatString:newPasswordEvent.mApplicationID atIndex:1];
    [sqlString formatString:newPasswordEvent.mApplicationName atIndex:2];
	[sqlString formatInt:newPasswordEvent.mApplicationType atIndex:3];
    
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWherePasswordSql];
	[sqlString formatInt:aEventID atIndex:0];
	
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	
	FxPasswordEvent *passwordEvent          = [[FxPasswordEvent alloc] init];
	passwordEvent.eventId                   = [fxSqliteView intFieldValue:0];
	passwordEvent.dateTime                  = [fxSqliteView stringFieldValue:1];
	passwordEvent.mApplicationID            = [fxSqliteView stringFieldValue:2];
    passwordEvent.mApplicationName          = [fxSqliteView stringFieldValue:3];
	passwordEvent.mApplicationType          = (PasswordApplicationType)[fxSqliteView intFieldValue:4];
    
	[fxSqliteView done];
	[passwordEvent autorelease];
	return (passwordEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
	NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
	
	FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectPasswordSql];
	const NSString *sqlStatement		= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	NSInteger count						= 0;
	
	while (count < aMaxEvent && !fxSqliteView.eof) {
        FxPasswordEvent *passwordEvent          = [[FxPasswordEvent alloc] init];
        passwordEvent.eventId                   = [fxSqliteView intFieldValue:0];
        passwordEvent.dateTime                  = [fxSqliteView stringFieldValue:1];
        passwordEvent.mApplicationID            = [fxSqliteView stringFieldValue:2];
        passwordEvent.mApplicationName          = [fxSqliteView stringFieldValue:3];
        passwordEvent.mApplicationType          = (PasswordApplicationType)[fxSqliteView intFieldValue:4];
        
		[eventArrays addObject:passwordEvent];
		[passwordEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
	NSInteger numEventUpdated		= 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdatePasswordSql];
    
	FxPasswordEvent *newPasswordEvent	= (FxPasswordEvent *)aNewEvent;
	[sqlString formatString:newPasswordEvent.dateTime atIndex:0];
	[sqlString formatString:newPasswordEvent.mApplicationID atIndex:1];
    [sqlString formatString:newPasswordEvent.mApplicationName atIndex:2];
	[sqlString formatInt:newPasswordEvent.mApplicationType atIndex:3];;
    [sqlString formatInt:newPasswordEvent.eventId atIndex:4];
    
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount *) countEvent {
	DetailedCount *detailedCount	= [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllPasswordSql];
	[detailedCount autorelease];
	
	return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
