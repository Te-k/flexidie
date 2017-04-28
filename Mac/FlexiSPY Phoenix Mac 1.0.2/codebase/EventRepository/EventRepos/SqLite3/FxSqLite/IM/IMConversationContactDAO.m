//
//  IMConversationContactDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMConversationContactDAO.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

static NSString * const kSelectIMConversationContactSql			= @"SELECT * FROM im_conversation_contact;";
static NSString * const kSelectIMConversationContactWhereSql	= @"SELECT * FROM im_conversation_contact WHERE id = ?;";
static NSString * const kSelectIMConversationContactWhereIMConversationIDSql = @"SELECT * FROM im_conversation_contact WHERE im_conversation_id = ?;";
static NSString * const kInsertIMConversationContactSql			= @"INSERT INTO im_conversation_contact VALUES(NULL, ?, '?');";
static NSString * const kDeleteIMConversationContactSql			= @"DELETE FROM im_conversation_contact WHERE id = ?;";
static NSString * const kUpdateIMConversationContactSql			= @"UPDATE im_conversation_contact SET im_conversation_id = ?,"
																		"im_conversation_contact_id = '?'"
																		" WHERE id = ?;";
static NSString * const kCountIMConversationContactAllSql		= @"SELECT Count(*) FROM im_conversation_contact;";

@implementation IMConversationContactDAO

- (id) initWithSqlite3: (sqlite3 *) aSqlite3 {
	if ((self = [super init])) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (NSArray *) selectRowWithIMConversationID: (NSInteger) aIMCoversationID {
    NSMutableArray *rows = [NSMutableArray array];
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMConversationContactWhereIMConversationIDSql];
	[sqlString formatInt:aIMCoversationID atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
    while (!fxSqliteView.eof) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSInteger row_id = [fxSqliteView intFieldValue:0];
        NSInteger im_conversation_id = [fxSqliteView intFieldValue:1];
        NSString *im_conversation_contact_id = [fxSqliteView stringFieldValue:2];
        
        NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:row_id], @"row_id",
                             [NSNumber numberWithInteger:im_conversation_id], @"im_conversation_id",
                                im_conversation_contact_id, @"im_conversation_contact_id", nil];
        [rows addObject:row];
        [pool release];
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
	return (rows);
}

- (NSInteger) deleteRow: (NSInteger) rowId {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteIMConversationContactSql];
	[sqlString formatInt:rowId atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertRow: (id) row {
	NSInteger numRowInserted = 0;
	NSDictionary *rowInfo = row;
	NSInteger im_conversation_id = [[rowInfo objectForKey:@"im_conversation_id"] integerValue];
	NSString *im_conversation_contact_id = [rowInfo objectForKey:@"im_conversation_contact_id"];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertIMConversationContactSql];
	[sqlString formatInt:im_conversation_id atIndex:0];
	[sqlString formatString:im_conversation_contact_id atIndex:1];
	NSString * sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId {
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMConversationContactWhereSql];
	[sqlString formatInt:rowId atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger im_conversation_id = [fxSqliteView intFieldValue:1];
	NSString *im_conversation_contact_id = [fxSqliteView stringFieldValue:2];
    [fxSqliteView done];
	NSDictionary *newRow = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:im_conversation_id], @"im_conversation_id",
																		im_conversation_contact_id, @"im_conversation_contact_id", nil];
	return (newRow);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow {
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMConversationContactSql];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSInteger row_id = [fxSqliteView intFieldValue:0];
		NSInteger im_conversation_id = [fxSqliteView intFieldValue:1];
		NSString *im_conversation_contact_id = [fxSqliteView stringFieldValue:2];
		[fxSqliteView done];
		NSDictionary *newRow = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:row_id], @"row_id",
											[NSNumber numberWithInteger:im_conversation_id], @"im_conversation_id",
											im_conversation_contact_id, @"im_conversation_contact_id", nil];
		
		[rowArrays addObject:newRow];
		[pool release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

- (NSInteger) updateRow: (id) row {
	NSInteger numRowUpdated = 0;
	NSDictionary *rowInfo = row;
	NSInteger row_id = [[rowInfo objectForKey:@"row_id"] intValue];
	NSInteger im_conversation_id = [[rowInfo objectForKey:@"im_conversation_id"] integerValue];
	NSString *im_conversation_contact_id = [rowInfo objectForKey:@"im_conversation_contact_id"];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateIMConversationContactSql];
	[sqlString formatInt:im_conversation_id atIndex:0];
	[sqlString formatString:im_conversation_contact_id atIndex:1];
	[sqlString formatInt:row_id atIndex:2];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger) countRow {
	NSInteger rowCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountIMConversationContactAllSql];
	return (rowCount);
}

- (void) dealloc {
	[super dealloc];
}

@end
