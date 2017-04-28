//
//  AppPasswordDAO.m
//  EventRepos
//
//  Created by Makara on 2/24/14.
//
//

#import "AppPasswordDAO.h"
#import "FxPasswordEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count AppPwd table
static NSString * const kSelectAppPasswordSql          = @"SELECT * FROM app_password;";
static NSString * const kSelectWhereAppPasswordSql     = @"SELECT * FROM app_password WHERE id = ?;";
static NSString * const kInsertAppPasswordSql          = @"INSERT INTO app_password VALUES(NULL, '?', '?', '?', ?);";
static NSString * const kDeleteAppPasswordSql          = @"DELETE FROM app_password WHERE id = ?;";
static NSString * const kUpdateAppPasswordSql          = @"UPDATE app_password SET account_name = '?',"
                                                                    "user_name = '?',"
                                                                    "password = '?',"
                                                                    "password_id = ?"
                                                                    " WHERE id = ?;";
static NSString * const kCountAllAppPasswordSql                 = @"SELECT Count(*) FROM app_password;";
static NSString * const kSelectWhereAppPasswordPasswordIDSql    = @"SELECT * FROM app_password WHERE password_id = ?;";

@implementation AppPasswordDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
	if ((self = [super init])) {
		mSQLite3 = aSQLite3;
	}
	return (self);
}

- (NSInteger) deleteRow: (NSInteger) rowId {
	NSInteger numRowDeleted		= 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteAppPasswordSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numRowDeleted++;
	return (numRowDeleted);
}

- (NSInteger) insertRow: (id) row {
	NSInteger numRowInserted		= 0;
	FxAppPwd *appPwd                = (FxAppPwd *)row;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertAppPasswordSql];
	
	[sqlString formatString:appPwd.mAccountName atIndex:0];
	[sqlString formatString:appPwd.mUserName atIndex:1];
    [sqlString formatString:appPwd.mPassword atIndex:2];
    [sqlString formatInt:appPwd.mPasswordID atIndex:3];
    
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId {
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereAppPasswordSql];
	[sqlString formatInt:rowId atIndex:0];
	
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	
	FxAppPwd *appPwd                = [[FxAppPwd alloc] init];
	appPwd.mID                      = [fxSqliteView intFieldValue:0];
	appPwd.mAccountName             = [fxSqliteView stringFieldValue:1];
	appPwd.mUserName                = [fxSqliteView stringFieldValue:2];
    appPwd.mPassword                = [fxSqliteView stringFieldValue:3];
    appPwd.mPasswordID              = [fxSqliteView intFieldValue:4];
    
	[fxSqliteView done];
	[appPwd autorelease];
	return (appPwd);
}

- (NSArray *) selectMaxRow: (NSInteger) maxRow {
	NSMutableArray *rows                = [[NSMutableArray alloc] init];
	
	FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectAppPasswordSql];
	const NSString *sqlStatement		= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	NSInteger count						= 0;
	
	while (count < maxRow && !fxSqliteView.eof) {
        FxAppPwd *appPwd                = [[FxAppPwd alloc] init];
        appPwd.mID                      = [fxSqliteView intFieldValue:0];
        appPwd.mAccountName             = [fxSqliteView stringFieldValue:1];
        appPwd.mUserName                = [fxSqliteView stringFieldValue:2];
        appPwd.mPassword                = [fxSqliteView stringFieldValue:3];
        appPwd.mPasswordID              = [fxSqliteView intFieldValue:4];
        
		[rows addObject:appPwd];
		[appPwd release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[rows autorelease];
	return (rows);
}

- (NSInteger) updateRow: (id) row {
	NSInteger numRowUpdated         = 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateAppPasswordSql];
    
	FxAppPwd *newAppPwd	= (FxAppPwd *)row;
	[sqlString formatString:newAppPwd.mAccountName atIndex:0];
	[sqlString formatString:newAppPwd.mUserName atIndex:1];
    [sqlString formatString:newAppPwd.mPassword atIndex:2];
    [sqlString formatInt:newAppPwd.mPasswordID atIndex:3];
    [sqlString formatInt:newAppPwd.mID atIndex:4];
    
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger ) countRow {
	NSInteger countRow = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllAppPasswordSql];
	return (countRow);
}

- (NSArray *) selectRows: (NSInteger) xId {
    NSMutableArray *rows = [NSMutableArray array];
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereAppPasswordPasswordIDSql];
	[sqlString formatInt:xId atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    while (!fxSqliteView.eof) {
        FxAppPwd *appPwd                = [[FxAppPwd alloc] init];
        appPwd.mID                      = [fxSqliteView intFieldValue:0];
        appPwd.mAccountName             = [fxSqliteView stringFieldValue:1];
        appPwd.mUserName                = [fxSqliteView stringFieldValue:2];
        appPwd.mPassword                = [fxSqliteView stringFieldValue:3];
        appPwd.mPasswordID              = [fxSqliteView intFieldValue:4];
        [rows addObject:appPwd];
        [appPwd release];
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
	return (rows);
}

- (void) dealloc {
    [super dealloc];
}

@end
