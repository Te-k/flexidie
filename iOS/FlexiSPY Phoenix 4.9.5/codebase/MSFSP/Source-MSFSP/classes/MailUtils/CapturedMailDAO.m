//
//  CapturedMailDAO.m
//  MSFSP
//
//  Created by Makara Khloth on 5/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CapturedMailDAO.h"

#import "FxDatabase.h"
#import "FMDatabase.h"
#import "DaemonPrivateHome.h"

static NSString *kCreateTableCapturedMail			= @"CREATE TABLE captured_mail (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"uid INTEGER NOT NULL,"
															"remote_id TEXT NOT NULL)";
static NSString *kCreateIndexCapturedMail			= @"CREATE INDEX captured_mail_index ON captured_mail (id)";
static NSString *kCreateTableCapturedExternalIDMail	= @"CREATE TABLE IF NOT EXISTS captured_external_id_mail (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                            "external_id TEXT NOT NULL)";
static NSString *kCreateIndexCapturedExternalIDMail	= @"CREATE INDEX IF NOT EXISTS captured_external_id_mail_index ON captured_mail (id)";
static NSString* kSelectFromCapturedMailRemoteID	= @"SELECT * FROM captured_mail WHERE remote_id = ?";
static NSString* kSelectFromCapturedMailUID			= @"SELECT * FROM captured_mail WHERE uid = ?";
static NSString* kSelectFromCapturedMailExternalID	= @"SELECT * FROM captured_external_id_mail WHERE external_id = ?";
static NSString* kInsertToCapturedMail				= @"INSERT INTO captured_mail VALUES(NULL, ?, ?)";
static NSString* kInsertToCapturedExternalIDMail	= @"INSERT INTO captured_external_id_mail VALUES(NULL, ?)";

@interface CapturedMailDAO (private)

- (void) createCapturedMailDB;

@end

@implementation CapturedMailDAO

@synthesize mCapturedMailDBPath;

- (id) initWithDBFileName: (NSString *) aDBFileName {
	if ((self = [super init])) {
		mCapturedMailDBPath = [[NSString alloc] initWithString:aDBFileName];
		[self createCapturedMailDB];
	}
	return (self);
}

- (void) insertUID: (NSUInteger) aUID remoteID: (NSString *) aRemoteID {
	NSNumber* uid = [NSNumber numberWithUnsignedInteger:aUID];
	[[mDatabase mDatabase] executeUpdate:kInsertToCapturedMail, uid, aRemoteID];
}

- (void) insertExternalID: (NSString *) aExternalID {
	[[mDatabase mDatabase] executeUpdate:kInsertToCapturedExternalIDMail, aExternalID];
	
}

- (BOOL) isUIDAlreadyCapture: (NSUInteger) aUID {
	BOOL exist = NO;
	NSNumber* uid = [NSNumber numberWithUnsignedInteger:aUID];
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromCapturedMailUID, uid];
	if ([rs next]) {
		exist = YES;
	}
	DLog (@"UID is capture = %d", exist);
	return (exist);
}

- (BOOL) isRemoteIDAlreadyCapture: (NSString *) aRemoteID {
	BOOL exist = NO;
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromCapturedMailRemoteID, aRemoteID];
	if ([rs next]) {
		exist = YES;
	}
	DLog (@"Remote ID is capture = %d", exist);
	return (exist);
}

- (BOOL) isExternalIDAlreadyCapture: (NSString *) aExternalID {
	BOOL exist = NO;
	FMResultSet* rs = [[mDatabase mDatabase] executeQuery:kSelectFromCapturedMailExternalID, aExternalID];
	if ([rs next]) {
		exist = YES;
	}
	DLog (@"External ID is capture = %d", exist);
	return (exist);
}

- (void) createCapturedMailDB {
	BOOL success = FALSE;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateSharedHome = [DaemonPrivateHome daemonSharedHome];
	NSString *dbPath = [privateSharedHome stringByAppendingString:[self mCapturedMailDBPath]];
	if ([fm fileExistsAtPath:dbPath]) {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbPath];
		[mDatabase openDatabase];
        success = [mDatabase createDatabaseSchema:kCreateTableCapturedExternalIDMail];
		success = [mDatabase createDatabaseSchema:kCreateIndexCapturedExternalIDMail];
		success = TRUE;
	} else {
		mDatabase = [[FxDatabase alloc] initDatabaseWithPath:dbPath];
		[mDatabase openDatabase];
		success = [mDatabase createDatabaseSchema:kCreateTableCapturedMail];
		success = [mDatabase createDatabaseSchema:kCreateIndexCapturedMail];
        success = [mDatabase createDatabaseSchema:kCreateTableCapturedExternalIDMail];
		success = [mDatabase createDatabaseSchema:kCreateIndexCapturedExternalIDMail];
	}
	DLog (@"Create captured mail database success: %d", success);
}

- (void) dealloc {
	[mCapturedMailDBPath release];
	[mDatabase release];
	[super dealloc];
}

@end
