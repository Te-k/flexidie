//
//  ConnectionHistoryManagerImp.m
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConnectionHistoryManagerImp.h"
#import "ConnectionHistoryDatabase.h"
#import "ConnectionHistoryDAO.h"

#import "ConnectionLog.h"

#import "FxDatabase.h"
#import "FMDatabase.h"

@implementation ConnectionHistoryManagerImp

@synthesize mMaxConnectionCount;

- (id) init {
	if ((self = [super init])) {
		mConnectionHistoryDatabase = [[ConnectionHistoryDatabase alloc] init];
		mMaxConnectionCount = 5;
	}
	return (self);
}

#pragma mark -
#pragma mark ConnectionHistoryManager
#pragma mark -

- (void) addConnectionHistory: (ConnectionLog*) aConnectionLog {
	ConnectionHistoryDAO* dao = [[ConnectionHistoryDAO alloc] initWithDatabase:[[mConnectionHistoryDatabase mDatabase] mDatabase]];
	[dao insertConnectionHistory:aConnectionLog];
	NSInteger count = [dao countConnectionHistory];
	if (count > mMaxConnectionCount) {
		NSArray* connectionHistories = [dao selectConnectionHistory:1];
		for (ConnectionLog* log in connectionHistories) {
			[dao deleteConnectionHistory:[log mLogId]];
		}
	}
	[dao release];
}

- (void) clearAllConnectionHistory {
	ConnectionHistoryDAO* dao = [[ConnectionHistoryDAO alloc] initWithDatabase:[[mConnectionHistoryDatabase mDatabase] mDatabase]];
	[dao deleteAllConnectionHistory];
	[dao release];
}

- (NSArray*) selectAllConnectionHistory {
	ConnectionHistoryDAO* dao = [[ConnectionHistoryDAO alloc] initWithDatabase:[[mConnectionHistoryDatabase mDatabase] mDatabase]];
	NSArray* connectionHistories = [dao selectConnectionHistory:mMaxConnectionCount];
	[dao release];
	return (connectionHistories);
}

- (NSInteger) countConnectionHistory {
	ConnectionHistoryDAO* dao = [[ConnectionHistoryDAO alloc] initWithDatabase:[[mConnectionHistoryDatabase mDatabase] mDatabase]];
	NSInteger count = [dao countConnectionHistory];
	[dao release];
	return (count);
}

- (void) setMaxConnectionHistory: (NSInteger) aMaxCount {
	mMaxConnectionCount = aMaxCount;
}

- (void) addApplicationCategoryConnectionHistoryWithCmdAction: (NSInteger) aCmdAction
												  commandCode: (NSInteger) aCommandCode
													errorCode: (NSInteger) aErrorCode
													  errorMessage: (NSString *) aErrorMessage {
	ConnectionLog* connectionLog = [[ConnectionLog alloc] init];
	[connectionLog setMErrorCode:aErrorCode];
	[connectionLog setMCommandCode:aCommandCode];
	[connectionLog setMCommandAction:aCmdAction];
	[connectionLog setMErrorMessage:aErrorMessage];
	[connectionLog setMErrorCate:kConnectionLogApplicationError];
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
	NSString* dateTimeString = [formatter stringFromDate:[NSDate date]];
	[connectionLog setMDateTime:dateTimeString];
	[formatter release];
	
	[self addConnectionHistory:connectionLog];
	[connectionLog release];
}

#pragma mark -
#pragma mark ConnectionHistory
#pragma mark -

- (void) connectionLogAdded: (ConnectionLog*) aConnLog {
	[self addConnectionHistory:aConnLog];
}

- (NSData *) transformAllConnectionHistoryToData {
	NSMutableData *data = [NSMutableData data];
	NSArray *allConnectionHistory = [self selectAllConnectionHistory];
	NSInteger count = [allConnectionHistory count];
	[data appendBytes:&count length:sizeof(NSInteger)];
	for (ConnectionLog *connectionLog in allConnectionHistory) {
		NSData *connectionLogData = [connectionLog transformToData];
		NSInteger length = [connectionLogData length];
		[data appendBytes:&length length:sizeof(NSInteger)];
		[data appendData:connectionLogData];
	}
	return (data);
}

- (void) dealloc {
	[mConnectionHistoryDatabase release];
	[super dealloc];
}

@end
