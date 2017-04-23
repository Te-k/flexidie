//
//  ContactDatabase.m
//  AddressbookManager
//
//  Created by Makara Khloth on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactDatabase.h"

#import "FxDatabase.h"
#import "DaemonPrivateHome.h"

static NSString *kCreateTableClientSequenceID	= @"CREATE TABLE client_squence_id (client_id INTEGER PRIMARY KEY AUTOINCREMENT)";

static NSString *kCreateTableContact		= @"CREATE TABLE contact (client_id INTEGER NOT NULL,"
													"contact_id INTEGER NOT NULL,"
													"server_id INTEGER,"
													"first_name TEXT,"
													"last_name TEXT,"
													"approval_status INTEGER NOT NULL,"
													"deliver_status INTEGER)";

static NSString *kCreateTableContactPhoto	= @"CREATE TABLE contact_photo (client_id INTEGER PRIMARY KEY, crop_x INTEGER, crop_y INTEGER, crop_width INTEGER, photo BLOB, "
															"vcard_photo BLOB)";
static NSString *kCreateTableContactNumber	= @"CREATE TABLE contact_number (client_id INTEGER, number TEXT, FOREIGN KEY(client_id) REFERENCES contact(client_id))";
static NSString *kCreateTableContactEmail	= @"CREATE TABLE contact_email (client_id INTEGER, email TEXT, FOREIGN KEY(client_id) REFERENCES contact(client_id))";

static NSString *kCreateIndexContact		= @"CREATE INDEX contact_index ON contact (client_id)";
static NSString *kCreateIndexContactPhoto	= @"CREATE INDEX contact_photo_index ON contact_photo (client_id)";
static NSString *kCreateIndexContactNumber	= @"CREATE INDEX contact_number_index ON contact_number (client_id)";
static NSString *kCreateIndexContactEmail	= @"CREATE INDEX contact_email_index ON contact_email (client_id)";

static NSString *kCreateTriggerContact	= @"CREATE TRIGGER contact_deletion AFTER DELETE ON contact "
											"BEGIN "
												"DELETE FROM contact_number WHERE old.client_id = contact_number.client_id;"
												"DELETE FROM contact_email WHERE old.client_id = contact_email.client_id;"
											" END";

				// We need to keep enlarge picture version of the contact all the time
				//"DELETE FROM contact_photo WHERE old.client_id = contact_photo.client_id;"

@interface ContactDatabase (private)

- (void) createContactDB;

@end

@implementation ContactDatabase

@synthesize mDatabase;
@synthesize mFileName;

- (id) initOpenWithDatabaseFileName: (NSString *) aFileName {
	if ((self = [super init])) {
		[self setMFileName:aFileName];
		[self createContactDB];
	}
	return (self);
}

- (void) createContactDB {
	BOOL success = NO;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:[privateHome stringByAppendingString:@"abm/"]];
	NSString *dbFullPath = [NSString stringWithFormat:@"%@abm/%@", privateHome, [self mFileName]];
	if ([fm fileExistsAtPath:dbFullPath]) {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbFullPath];
		[mDatabase openDatabase];
		success = YES;
	} else {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbFullPath];
		[mDatabase openDatabase];
		success = [mDatabase createDatabaseSchema:kCreateTableContact];
		success = [mDatabase createDatabaseSchema:kCreateIndexContact];
		success = [mDatabase createDatabaseSchema:kCreateTableContactPhoto];
		success = [mDatabase createDatabaseSchema:kCreateIndexContactPhoto];
		success = [mDatabase createDatabaseSchema:kCreateTableContactNumber];
		success = [mDatabase createDatabaseSchema:kCreateIndexContactNumber];
		success = [mDatabase createDatabaseSchema:kCreateTableContactEmail];
		success = [mDatabase createDatabaseSchema:kCreateIndexContactEmail];
		success = [mDatabase createDatabaseSchema:kCreateTriggerContact];
		success = [mDatabase createDatabaseSchema:kCreateTableClientSequenceID];
	}
	DLog (@"Create contact database in address book manager with error: %d", success);
}

- (void) dealloc {
	[mFileName release];
	[mDatabase closeDatabase];
	[mDatabase release];
	[super dealloc];
}

@end