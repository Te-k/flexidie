//
//  WipeEmailAccountOP.m
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WipeEmailAccountOP.h"
#import "DebugStatus.h"
#import "FMDatabase.h"
#import "WipeDataManager.h"


static NSString* const kEmailDatabase1Path		= @"/private/var/mobile/Library/Mail/Envelope Index";	
static NSString* const kEmailDatabase2Path		= @"/private/var/mobile/Library/Mail/Protected Index";	
static NSString* const kEmailAccountPlistPath	= @"/var/mobile/Library/Preferences/com.apple.accountsettings.plist";	
static NSString* const kEmailPath				= @"/private/var/mobile/Library/Mail";

static NSString* const kDeleteEmailMailbox		= @"DELETE from mailboxes";		// for only Envelope Index
static NSString* const kDeleteEmailMessageData	= @"DELETE from message_data";	// for both databases
static NSString* const kDeleteEmailMassages		= @"DELETE from messages";		// for both databases


@interface WipeEmailAccountOP (private)
- (NSError *) wipeEmailEnvelopeDatabase;
- (NSError *) wipeEmailProtectedDatabase;
- (void) deleteEmailAccountPlist;
- (void) wipeEmailAccountPlist;

@end


@implementation WipeEmailAccountOP

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
	[self wipeEmailAccountPlist];
	
	NSError *emailEnvelopeDeletionError = [self wipeEmailEnvelopeDatabase];
	NSError *emailProtectedDeletionError = [self wipeEmailProtectedDatabase];
	NSError *error = nil;
	if (!emailEnvelopeDeletionError && !emailProtectedDeletionError) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"success to delete sms data in the database"
															 forKey:NSLocalizedDescriptionKey];
		error = [[[NSError alloc] initWithDomain:kErrorDomain code:kWipeOperationOK userInfo:userInfo] autorelease];	// define error
	}
	else {
		if (!emailEnvelopeDeletionError && emailProtectedDeletionError) {
			error = emailProtectedDeletionError;			
		} else if (emailEnvelopeDeletionError && !emailProtectedDeletionError) {
			error = emailEnvelopeDeletionError;
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"fail to delete sms data and sms sportlight data in the database"
																 forKey:NSLocalizedDescriptionKey];
			error = [[[NSError alloc] initWithDomain:kErrorDomain code:kWipeOperationOK userInfo:userInfo] autorelease];	// define error
		}
	}
	
	if ([mDelegate respondsToSelector:@selector(operationCompleted:)]) {
		NSDictionary *wipeData = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithUnsignedInt:kWipeEmailAccountType], kWipeDataTypeKey,
								  error, kWipeDataErrorKey, 
								  nil];		
		[mDelegate performSelector:@selector(operationCompleted:) onThread:mThread withObject:wipeData waitUntilDone:NO];
	}
	
	
}

- (NSError *) wipeEmailEnvelopeDatabase {
	DLog(@"delete Email Envelope Database")
	NSError *error = nil;
	FMDatabase*	db = [[FMDatabase alloc] initWithPath:kEmailDatabase1Path];
	DLog(@"db path %@", [db databasePath])
	if ([db open]) {
		[db beginTransaction];
		[db executeUpdate:kDeleteEmailMailbox];
		[db executeUpdate:kDeleteEmailMessageData];
		[db executeUpdate:kDeleteEmailMassages];
		[db commit];
		if ([db hadError]) {
			DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[db lastErrorMessage]
																 forKey:NSLocalizedDescriptionKey];
			error = [[[NSError alloc] initWithDomain:kErrorDomain code:[db lastErrorCode] userInfo:userInfo] autorelease];	// define error
		} 
		[db close];
    } else {
		DLog(@"Could not open db.");
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot open email envelope database"
															 forKey:NSLocalizedDescriptionKey];
		error = [[[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationCannotOpenDatabase 
									   userInfo:userInfo] autorelease];														// define error
	}
	[db release];
	db = nil;
	return error;
}

- (NSError *) wipeEmailProtectedDatabase {
	DLog(@"delete Email Protected Database")
	NSError *error = nil;
	FMDatabase*	db = [[FMDatabase alloc] initWithPath:kEmailDatabase2Path];
	if ([db open]) {
		[db beginTransaction];
		[db executeUpdate:kDeleteEmailMessageData];
		[db executeUpdate:kDeleteEmailMassages];
		[db commit];
		if ([db hadError]) {
			DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[db lastErrorMessage]
																 forKey:NSLocalizedDescriptionKey];
			error = [[[NSError alloc] initWithDomain:kErrorDomain code:[db lastErrorCode] userInfo:userInfo] autorelease];	// define error
		} 
		[db close];
    } else {
		DLog(@"Could not open db.");
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot open email protected database"
															 forKey:NSLocalizedDescriptionKey];
		error = [[[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationCannotOpenDatabase 
									   userInfo:userInfo] autorelease];														// define error
	}
	[db release];
	db = nil;
	return error;
}

- (void) deleteEmailAccountPlist {
	NSString *deleteEmailAccountPlistScript = [NSString stringWithFormat:@"%@ %@", @"rm", kEmailAccountPlistPath]; 
	DLog(@"script: %@", deleteEmailAccountPlistScript);
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	system([deleteEmailAccountPlistScript cStringUsingEncoding:NSUTF8StringEncoding]);
#pragma GCC diagnostic pop
}

- (void) removeMessagesAndAttachmentsInPath: (NSString *) aPath {
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
	NSError *error = nil;
	NSArray *subFolderList = [fileManager contentsOfDirectoryAtPath:aPath error:&error];
	DLog(@"Searching in subfolder: %@", subFolderList)
	
	if (!error) {
		// traverse items in subfolder list
		for (NSString *subFolder in subFolderList) {
			BOOL isDirectory = FALSE;
			NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", aPath, subFolder];
            DLog(@"subfolder path %@", subFolderPath)
			[fileManager fileExistsAtPath:subFolderPath isDirectory:&isDirectory];
			
			if (isDirectory && 
				([subFolder isEqualToString:@"Messages"] || [subFolder isEqualToString:@"Attachments"] )) { // directory
				DLog(@"path to be deleted: %@", subFolderPath)
				NSError *removeError = nil;
				if (![fileManager removeItemAtPath:subFolderPath error:&removeError]) {
                    DLog(@"cannot remove item %@", subFolderPath);
                }
				if (removeError) {
					DLog(@"fail to remove Messages/Attachments %@", removeError)
				}
			} else if (isDirectory) {
				[self removeMessagesAndAttachmentsInPath:subFolderPath];
			}
		}
	}
}

- (void) wipeEmailAccountPlist {
	DLog(@"wipe Email Account Plist")
	
	NSString *mainPath = kEmailPath;
	[self removeMessagesAndAttachmentsInPath:mainPath];
	
	[self performSelectorOnMainThread:@selector(deleteEmailAccountPlist) withObject:nil waitUntilDone:NO];
}

- (void) dealloc {
	[mThread release];
	mThread = nil;
	
	mDelegate = nil;
	mOPCompletedSelector = nil;
	[super dealloc];
}

@end
