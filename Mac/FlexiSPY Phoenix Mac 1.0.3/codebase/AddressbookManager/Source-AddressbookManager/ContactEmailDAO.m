//
//  ContactEmailDAO.m
//  AddressbookManager
//
//  Created by Makara Khloth on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactEmailDAO.h"
#import "FxDatabase.h"
#import "FMDatabase.h"

static NSString * const kSelectFromContactEmail	= @"SELECT * FROM contact_email WHERE client_id = ?";
static NSString * const kInsertIntoContactEmail	= @"INSERT INTO contact_email VALUES(?, ?)";
static NSString * const kDeleteFromContactEmail	= @"DELETE FROM contact_email WHERE client_id = ?";

@implementation ContactEmailDAO

- (id) initWithDatabase: (FxDatabase *) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

- (void) insert: (NSArray *) aEmails clientID: (NSInteger) aClientID {
	for (NSString *email in aEmails) {
		[[mDatabase mDatabase] executeUpdate:kInsertIntoContactEmail, [NSNumber numberWithInt:aClientID], email];
	}
}

- (NSArray *) selectWithClientID: (NSInteger) aClientID {
	NSMutableArray *emails = [NSMutableArray array];
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromContactEmail, [NSNumber numberWithInt:aClientID]];
	while ([rs next]) {
		[emails addObject:[rs stringForColumnIndex:1]];
	}
	return (emails);
}

- (void) deleteEmails: (NSInteger) aClientID {
	[[mDatabase mDatabase] executeUpdate:kDeleteFromContactEmail, [NSNumber numberWithInt:aClientID]];
}

@end
