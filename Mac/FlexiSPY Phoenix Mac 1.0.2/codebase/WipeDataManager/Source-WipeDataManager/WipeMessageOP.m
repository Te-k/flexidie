//
//  WipeMessageOP.m
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WipeMessageOP.h"
#import "DebugStatus.h"
#import "FMDatabase.h"
#import "WipeDataManager.h"
#import "DefStd.h"

#import <UIKit/UIKit.h>

static NSString* const kDeleteSMSGroupMemberHistory = @"DELETE from group_member";
static NSString* const kDeleteSMSHistory			= @"DELETE from message";
static NSString* const kDeleteSMSMsgGroupHistory	= @"DELETE from msg_group";
static NSString* const kDeleteSMSMsgPiecesHistory	= @"DELETE from msg_pieces";
static NSString* const kDeleteSMSMadridHistory		= @"DELETE from madrid_chat";				// exist in ios 5 only
static NSString* const kDeleteSMSMadridAttHistory	= @"DELETE from madrid_attachment";			// exist in ios 5 only

// for ios 5 only
static NSString* const kDeleteSMSSportlightHistory  = @"DELETE from Content";


@interface WipeMessageOP (private)
int callback_sms_sqlite_fn_read();
- (NSError *) wipeSMSDatabase;
- (NSError *) wipeSMSSportlightDatabase;
@end


@implementation WipeMessageOP
@synthesize mThread;

- (id) initWithDelegate: (id) aDelegate thread: (NSThread *) aThread {
	self = [super init];
	if (self != nil) {
		mDelegate = aDelegate;
		[self setMThread:aThread];
	}
	return self;
}

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- main ---- ")
	[self wipe];
	[pool release];
}

- (void) wipe {
	NSError *smsDeletionError = [self wipeSMSDatabase];
	NSError *smsSportlightDeletionError = [self wipeSMSSportlightDatabase];
	NSError *error = nil;
	if (!smsDeletionError && !smsSportlightDeletionError) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"success to delete sms data in the database"
															 forKey:NSLocalizedDescriptionKey];
		error = [[[NSError alloc] initWithDomain:kErrorDomain code:kWipeOperationOK userInfo:userInfo] autorelease];	// define error
	}
	else {
		if (!smsDeletionError && smsSportlightDeletionError) {
			error = smsSportlightDeletionError;			
		} else if (smsDeletionError && !smsSportlightDeletionError) {
			error = smsDeletionError;
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"fail to delete sms data and sms sportlight data in the database"
																 forKey:NSLocalizedDescriptionKey];
			error = [[[NSError alloc] initWithDomain:kErrorDomain code:kWipeOperationOK userInfo:userInfo] autorelease];	// define error
		}
	}
	if ([mDelegate respondsToSelector:@selector(operationCompleted:)]) {
		NSDictionary *wipeData = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithUnsignedInt:kWipeMessageType], kWipeDataTypeKey,
								  error, kWipeDataErrorKey, 
								  nil];		
		[mDelegate performSelector:@selector(operationCompleted:) onThread:mThread withObject:wipeData waitUntilDone:NO];
	}
	
}

// delete all rows in all tables in sms.db 
- (NSError *) wipeSMSDatabase {
	DLog(@"delete SMS Database")
	NSError *error = nil;
	FMDatabase*	db = [[FMDatabase alloc] initWithPath:kSMSHistoryDatabasePath];
	if ([db open]) {
		[db beginTransaction];
		const char *fn_name = "read"; 
		if (SQLITE_OK == sqlite3_create_function([db sqliteHandle], fn_name, 1, SQLITE_INTEGER, nil, (void *)callback_sms_sqlite_fn_read, nil, nil)) {
			[db executeUpdate:kDeleteSMSHistory];
			[db executeUpdate:kDeleteSMSMsgGroupHistory];
			[db executeUpdate:kDeleteSMSMsgPiecesHistory];
			[db executeUpdate:kDeleteSMSGroupMemberHistory];
			[db executeUpdate:kDeleteSMSMadridHistory];
			[db executeUpdate:kDeleteSMSMadridAttHistory];
			
			if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
				
				[db executeUpdate:@"delete from chat"];
				
			}
			
			[db commit];
			if ([db hadError]) {
				DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[db lastErrorMessage]
																	 forKey:NSLocalizedDescriptionKey];
				error = [[NSError alloc] initWithDomain:kErrorDomain code:[db lastErrorCode] userInfo:userInfo];	// define error
			} 
		} else {
			DLog(@"cannot create read function");
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"cannot create read function which is called by trigger for delete"
																 forKey:NSLocalizedDescriptionKey];
			error = [[NSError alloc] initWithDomain:kErrorDomain code:kWipeOperationCannotCreateCustomFunctionForTrigger userInfo:userInfo];	// define error
		}
		[db close];
	} else {
		DLog(@"Could not open db");
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot open sms database"
															 forKey:NSLocalizedDescriptionKey];
		error = [[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationCannotOpenDatabase 
									   userInfo:userInfo];														// define error
	}
	[db release];
	db = nil;
	return [error autorelease];
}

// delete all rows in table Contents in SMSSearchdb.sqlitedb
- (NSError *) wipeSMSSportlightDatabase {
	DLog(@"delete SMS Sportlight database")
	NSError *error = nil;
	
	NSString *sql = nil;
	NSString *spotlightPath = nil;
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
		spotlightPath = @"/var/mobile/Library/Spotlight/com.apple.MobileSMS/SMSSearchindex.sqlite";
		sql = @"delete from ZSPRECORD";
	} else {
		spotlightPath = kSMSSportlightDatabasePath;
		sql = kDeleteSMSSportlightHistory; // No such table in IOS 6.1.2
	}
	
	FMDatabase*	db = [[FMDatabase alloc] initWithPath:spotlightPath];
	if ([db open]) {
		[db beginTransaction];
		[db executeUpdate:sql];
		[db commit];
		if ([db hadError]) {
			DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[db lastErrorMessage]
																 forKey:NSLocalizedDescriptionKey];
			error = [[NSError alloc] initWithDomain:kErrorDomain code:[db lastErrorCode] userInfo:userInfo];	// define error
		}
    } else {
		DLog(@"Could not open db.");
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot open sms sportlight database"
															 forKey:NSLocalizedDescriptionKey];
		error = [[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationCannotOpenDatabase 
									   userInfo:userInfo];														// define error
	}
	[db release];
	db = nil;
	
	return [error autorelease];
}

// Required by 'deleteSMSContainingFromOriginalDatabase' for the delete trigger to work 
int callback_sms_sqlite_fn_read() {
	DLog(@"callback_sms_sqlite_fn_read");
	return 2; 
}

- (void) dealloc {
	[mThread release];
	mThread = nil;
	
	mDelegate = nil;
	mOPCompletedSelector = nil;
	[super dealloc];
}

@end
