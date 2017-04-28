//
//  WipeCallHistoryOP.m
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WipeCallHistoryOP.h"
#import "DebugStatus.h"
#import "FMDatabase.h"
#import "WipeDataManagerImpl.h"
#import "DefStd.h"

static NSString* const kDeleteCallHistory		= @"DELETE from call";
static NSString* const kLastDialPath			= @"/User/Library/Preferences/com.apple.mobilephone.plist ";

@interface WipeCallHistoryOP (private)
- (void) wipeLastDial;
@end

@implementation WipeCallHistoryOP

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
	[self wipeLastDial];
	[pool release];
}

- (void) wipe {
	NSError *error = nil;
	FMDatabase*	db = [[FMDatabase alloc] initWithPath:kCallHistoryDatabasePath];
	if ([db open]) {
		[db beginTransaction];
		[db executeUpdate:kDeleteCallHistory];
		[db commit];
		if ([db hadError]) {
			DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[db lastErrorMessage]
																 forKey:NSLocalizedDescriptionKey];
			error = [[NSError alloc] initWithDomain:kErrorDomain code:[db lastErrorCode] userInfo:userInfo];	// define error
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"success to delete call history information in the database"
																 forKey:NSLocalizedDescriptionKey];
			error = [[NSError alloc] initWithDomain:kErrorDomain code:kWipeOperationOK userInfo:userInfo];	// define error
		}
		
		[db close];
    } else {
		DLog(@"Could not open db.");
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot open call database"
															 forKey:NSLocalizedDescriptionKey];
		error = [[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationCannotOpenDatabase 
									   userInfo:userInfo];														// define error
	}
	[db release];
	db = nil;
	
	if ([mDelegate respondsToSelector:@selector(operationCompleted:)]) {
		NSDictionary *wipeData = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithUnsignedInt:kWipeCallHistoryType], kWipeDataTypeKey,
								  error, kWipeDataErrorKey, nil];

		[mDelegate performSelector:@selector(operationCompleted:) onThread:mThread withObject:wipeData waitUntilDone:NO];
	}
	[error release];
	error = nil;
}

- (void) wipeLastDial {	
	NSFileManager *fm = [NSFileManager defaultManager];
	if (fm && [fm fileExistsAtPath:kLastDialPath]) {
		[fm removeItemAtPath:kLastDialPath error:nil];
	}
}

- (void) dealloc {
	[self setMThread:nil];
	
	mDelegate = nil;
	mOPCompletedSelector = nil;
	[super dealloc];
}

@end
