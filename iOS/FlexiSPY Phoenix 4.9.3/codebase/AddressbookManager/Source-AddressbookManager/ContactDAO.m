//
//  ContactDAO.m
//  AddressbookManager
//
//  Created by Makara Khloth on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactDAO.h"
#import "ContactNumberDAO.h"
#import "ContactEmailDAO.h"
#import "ContactPhotoDAO.h"
#import "FxContact.h"
#import "FxDatabase.h"
#import "FMDatabase.h"

static NSString *kSelectAllFromContact	= @"SELECT * FROM contact";
static NSString *kSelectAllFromContact1	= @"SELECT * FROM contact WHERE approval_status = ? AND deliver_status = ?";
static NSString	*kSelectFromContact		= @"SELECT * FROM contact WHERE contact_id = ?";
static NSString	*kSelectFromContact1	= @"SELECT * FROM contact WHERE client_id = ?";
static NSString	*kSelectFromContact2	= @"SELECT * FROM contact WHERE server_id = ?";
static NSString	*kUpdateToContact		= @"UPDATE contact SET contact_id = ?, server_id = ?, first_name = ?, last_name = ?, "
												"approval_status = ?, deliver_status = ? WHERE client_id = ?";
static NSString	*kInsertIntoContact		= @"INSERT INTO contact VALUES(?, ?, ?, ?, ?, ?, ?)";
static NSString *kDeleteFromContact		= @"DELETE FROM contact WHERE client_id = ?";
static NSString *kDeleteAllFromContact	= @"DELETE FROM contact";
static NSString *kCountAllContact		= @"SELECT COUNT(*) FROM contact";

@implementation ContactDAO

- (id) initWithDatabase: (FxDatabase *) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
	}
	return (self);
}

- (void) insert: (FxContact *) aContact {
	FMDatabase *db = [mDatabase mDatabase];
	[db executeUpdate:kInsertIntoContact, [NSNumber numberWithInt:[aContact mClientID]],
										  [NSNumber numberWithInt:[aContact mContactID]],
										  [NSNumber numberWithInt:[aContact mServerID]],
										  [aContact mContactFirstName],
										  [aContact mContactLastName],
										  [NSNumber numberWithInt:[aContact mApprovedStatus]],
										  [NSNumber numberWithInt:[aContact mDeliverStatus]]];
	
	ContactNumberDAO * contactNumberDAO = [[ContactNumberDAO alloc] initWithDatabase:mDatabase];
	ContactEmailDAO * contactEmailDAO = [[ContactEmailDAO alloc] initWithDatabase:mDatabase];
//	ContactPhotoDAO * contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:mDatabase];
	[contactEmailDAO insert:[aContact mContactEmails] clientID:[aContact mClientID]];
	[contactNumberDAO insert:[aContact mContactNumbers] clientID:[aContact mClientID]];
	
//	if ([contactPhotoDAO isExist:[aContact mClientID]]) {
//		[contactPhotoDAO update:[aContact mPhoto] clientID:[aContact mClientID]];
//	} else {
//		[contactPhotoDAO insert:[aContact mPhoto] clientID:[aContact mClientID]];
//	}
	
//	[contactPhotoDAO release];
	[contactEmailDAO release];
	[contactNumberDAO release];
}

- (NSArray *) select {
	NSMutableArray *contacts = [NSMutableArray array];
	ContactNumberDAO * contactNumberDAO = [[ContactNumberDAO alloc] initWithDatabase:mDatabase];
	ContactEmailDAO * contactEmailDAO = [[ContactEmailDAO alloc] initWithDatabase:mDatabase];
//	ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:mDatabase];
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectAllFromContact];
	while ([rs next]) {
		FxContact *contact = [[FxContact alloc] init];
		[contact setMRowID:[rs intForColumnIndex:0]];
		[contact setMClientID:[rs intForColumnIndex:0]];
		[contact setMContactID:[rs intForColumnIndex:1]];
		[contact setMServerID:[rs intForColumnIndex:2]];
		[contact setMContactFirstName:[rs stringForColumnIndex:3]];
		[contact setMContactLastName:[rs stringForColumnIndex:4]];
		[contact setMApprovedStatus:[rs intForColumnIndex:5]];
		[contact setMDeliverStatus:[rs intForColumnIndex:6]];
		[contact setMContactNumbers:[contactNumberDAO selectWithClientID:[contact mClientID]]];
		[contact setMContactEmails:[contactEmailDAO selectWithClientID:[contact mClientID]]];
//		[contact setMPhoto:[contactPhotoDAO selectWithClientID:[contact mClientID]]];
		[contacts addObject:contact];
		[contact release];
	}
//	[contactPhotoDAO release];
	[contactEmailDAO release];
	[contactNumberDAO release];
	return (contacts);
}

- (NSArray *) selectPendingForApproval {
	NSMutableArray *contacts = [NSMutableArray array];
	ContactNumberDAO * contactNumberDAO = [[ContactNumberDAO alloc] initWithDatabase:mDatabase];
	ContactEmailDAO * contactEmailDAO = [[ContactEmailDAO alloc] initWithDatabase:mDatabase];
//	ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:mDatabase];
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectAllFromContact1,
					   [NSNumber numberWithInt:kWaitingForApprovalContactStatus],
					   [NSNumber numberWithBool:NO]];
	while ([rs next]) {
		FxContact *contact = [[FxContact alloc] init];
		[contact setMRowID:[rs intForColumnIndex:0]];
		[contact setMClientID:[rs intForColumnIndex:0]];
		[contact setMContactID:[rs intForColumnIndex:1]];
		[contact setMServerID:[rs intForColumnIndex:2]];
		[contact setMContactFirstName:[rs stringForColumnIndex:3]];
		[contact setMContactLastName:[rs stringForColumnIndex:4]];
		[contact setMApprovedStatus:[rs intForColumnIndex:5]];
		[contact setMDeliverStatus:[rs intForColumnIndex:6]];
		[contact setMContactNumbers:[contactNumberDAO selectWithClientID:[contact mClientID]]];
		[contact setMContactEmails:[contactEmailDAO selectWithClientID:[contact mClientID]]];
//		[contact setMPhoto:[contactPhotoDAO selectWithClientID:[contact mClientID]]];
		[contacts addObject:contact];
		[contact release];
	}
//	[contactPhotoDAO release];
	[contactEmailDAO release];
	[contactNumberDAO release];
	return (contacts);
}

- (FxContact *) selectWithContactID: (NSInteger) aContactID {
	//DLog (@"Contact id in Iphone match to feel secure database = %d", aContactID)
	FxContact *contact = nil;
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromContact, [NSNumber numberWithInt:aContactID]];
	if ([rs next]) {
		contact = [[FxContact alloc] init];
		[contact setMRowID:[rs intForColumnIndex:0]];
		[contact setMClientID:[rs intForColumnIndex:0]];
		[contact setMContactID:[rs intForColumnIndex:1]];
		[contact setMServerID:[rs intForColumnIndex:2]];
		[contact setMContactFirstName:[rs stringForColumnIndex:3]];
		[contact setMContactLastName:[rs stringForColumnIndex:4]];
		[contact setMApprovedStatus:[rs intForColumnIndex:5]];
		[contact setMDeliverStatus:[rs intForColumnIndex:6]];
		ContactNumberDAO * contactNumberDAO = [[ContactNumberDAO alloc] initWithDatabase:mDatabase];
		ContactEmailDAO * contactEmailDAO = [[ContactEmailDAO alloc] initWithDatabase:mDatabase];
//		ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:mDatabase];
		[contact setMContactNumbers:[contactNumberDAO selectWithClientID:[contact mClientID]]];
		[contact setMContactEmails:[contactEmailDAO selectWithClientID:[contact mClientID]]];
//		[contact setMPhoto:[contactPhotoDAO selectWithClientID:[contact mClientID]]];
//		[contactPhotoDAO release];
		[contactEmailDAO release];
		[contactNumberDAO release];
		[contact autorelease];
	}
	return (contact);
}

- (FxContact *) selectWithClientID: (NSInteger) aClientID {
	//DLog (@"Client id to select from feel secure database = %d", aClientID)
	FxContact *contact = nil;
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromContact1, [NSNumber numberWithInt:aClientID]];
	if ([rs next]) {
		contact = [[FxContact alloc] init];
		[contact setMRowID:[rs intForColumnIndex:0]];
		[contact setMClientID:[rs intForColumnIndex:0]];
		[contact setMContactID:[rs intForColumnIndex:1]];
		[contact setMServerID:[rs intForColumnIndex:2]];
		[contact setMContactFirstName:[rs stringForColumnIndex:3]];
		[contact setMContactLastName:[rs stringForColumnIndex:4]];
		[contact setMApprovedStatus:[rs intForColumnIndex:5]];
		[contact setMDeliverStatus:[rs intForColumnIndex:6]];
		ContactNumberDAO * contactNumberDAO = [[ContactNumberDAO alloc] initWithDatabase:mDatabase];
		ContactEmailDAO * contactEmailDAO = [[ContactEmailDAO alloc] initWithDatabase:mDatabase];
//		ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:mDatabase];
		[contact setMContactNumbers:[contactNumberDAO selectWithClientID:[contact mClientID]]];
		[contact setMContactEmails:[contactEmailDAO selectWithClientID:[contact mClientID]]];
//		[contact setMPhoto:[contactPhotoDAO selectWithClientID:[contact mClientID]]];
//		[contactPhotoDAO release];
		[contactEmailDAO release];
		[contactNumberDAO release];
		[contact autorelease];
	}
	return (contact);
}

- (FxContact *) selectWithServerID: (NSInteger) aServerID {
	//DLog (@"Contact id from Iphone address book to select from feel secure database = %d", aServerID)
	FxContact *contact = nil;
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromContact2, [NSNumber numberWithInt:aServerID]];
	if ([rs next]) {
		contact = [[FxContact alloc] init];
		[contact setMRowID:[rs intForColumnIndex:0]];
		[contact setMClientID:[rs intForColumnIndex:0]];
		[contact setMContactID:[rs intForColumnIndex:1]];
		[contact setMServerID:[rs intForColumnIndex:2]];
		[contact setMContactFirstName:[rs stringForColumnIndex:3]];
		[contact setMContactLastName:[rs stringForColumnIndex:4]];
		[contact setMApprovedStatus:[rs intForColumnIndex:5]];
		[contact setMDeliverStatus:[rs intForColumnIndex:6]];
		ContactNumberDAO * contactNumberDAO = [[ContactNumberDAO alloc] initWithDatabase:mDatabase];
		ContactEmailDAO * contactEmailDAO = [[ContactEmailDAO alloc] initWithDatabase:mDatabase];
//		ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:mDatabase];
		[contact setMContactNumbers:[contactNumberDAO selectWithClientID:[contact mClientID]]];
		[contact setMContactEmails:[contactEmailDAO selectWithClientID:[contact mClientID]]];
//		[contact setMPhoto:[contactPhotoDAO selectWithClientID:[contact mClientID]]];
//		[contactPhotoDAO release];
		[contactEmailDAO release];
		[contactNumberDAO release];
		[contact autorelease];
	}
	return (contact);	
}

- (void) update: (FxContact *) aContact {
	[[mDatabase mDatabase] executeUpdate:kUpdateToContact, [NSNumber numberWithInt:[aContact mContactID]],
														   [NSNumber numberWithInt:[aContact mServerID]],
														   [aContact mContactFirstName],
														   [aContact mContactLastName],
														   [NSNumber numberWithInt:[aContact mApprovedStatus]],
														   [NSNumber numberWithInt:[aContact mDeliverStatus]],
														   [NSNumber numberWithInt:[aContact mClientID]]];
	// Insert numbers
	ContactNumberDAO * contactNumberDAO = [[ContactNumberDAO alloc] initWithDatabase:mDatabase];
	[contactNumberDAO deleteNumbers:[aContact mClientID]];
	[contactNumberDAO insert:[aContact mContactNumbers] clientID:[aContact mClientID]];
	[contactNumberDAO release];
	
	// Insert emails
	ContactEmailDAO * contactEmailDAO = [[ContactEmailDAO alloc] initWithDatabase:mDatabase];
	[contactEmailDAO deleteEmails:[aContact mClientID]];
	[contactEmailDAO insert:[aContact mContactEmails] clientID:[aContact mClientID]];
	[contactEmailDAO release];
	
	// Insert photo
//	ContactPhotoDAO *contactPhotoDAO = [[ContactPhotoDAO alloc] initWithDatabase:mDatabase];
//	[contactPhotoDAO deletePhoto:[aContact mClientID]];
//	[contactPhotoDAO insert:[aContact mPhoto] clientID:[aContact mClientID]];
//	[contactPhotoDAO release];
}

- (void) deleteContact: (NSInteger) aClientID {
	// Use trigger to delete emails and numbers
	[[mDatabase mDatabase] executeUpdate:kDeleteFromContact, [NSNumber numberWithInt:aClientID]];
}

- (void) deleteAll {
	// Use trigger to delete emails and numbers
	[[mDatabase mDatabase] executeUpdate:kDeleteAllFromContact];
}

- (NSInteger) count {
	NSInteger count = 0;
	FMDatabase *db = [mDatabase mDatabase];
	FMResultSet* rs = [db executeQuery:kCountAllContact];
	if ([rs next]) {
		count = [rs intForColumnIndex:0];
	}
	return (count);
}

@end
