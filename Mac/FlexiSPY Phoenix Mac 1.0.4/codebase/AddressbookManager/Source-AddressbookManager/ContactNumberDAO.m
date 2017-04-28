//
//  ContactNumberDAO.m
//  AddressbookManager
//
//  Created by Makara Khloth on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactNumberDAO.h"
#import "FxDatabase.h"
#import "FMDatabase.h"

static NSString * const kSelectFromContactNumber	= @"SELECT * FROM contact_number WHERE client_id = ?";
static NSString * const kInsertIntoContactNumber	= @"INSERT INTO contact_number VALUES(?, ?)";
static NSString * const kDeleteFromContactNumber	= @"DELETE FROM contact_number WHERE client_id = ?";

@implementation ContactNumberDAO

- (id) initWithDatabase: (FxDatabase *) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

- (void) insert: (NSArray *) aNumbers clientID: (NSInteger) aClientID {
	for (NSString *telNumber in aNumbers) {
		[[mDatabase mDatabase] executeUpdate:kInsertIntoContactNumber, [NSNumber numberWithInt:aClientID], telNumber];
	}
}

- (NSArray *) selectWithClientID: (NSInteger) aClientID {
	NSMutableArray *numbers = [NSMutableArray array];
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromContactNumber, [NSNumber numberWithInt:aClientID]];
	while ([rs next]) {
		[numbers addObject:[rs stringForColumnIndex:1]];
	}
	return (numbers);
}

- (void) deleteNumbers: (NSInteger) aClientID {
	[[mDatabase mDatabase] executeUpdate:kDeleteFromContactNumber, [NSNumber numberWithInt:aClientID]];
}

@end