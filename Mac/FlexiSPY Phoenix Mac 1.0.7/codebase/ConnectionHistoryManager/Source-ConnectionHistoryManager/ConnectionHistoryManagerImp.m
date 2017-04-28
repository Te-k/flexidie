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
#import "ServerStatusCodeHistoryDAO.h"

#import "ConnectionLog.h"

#import "FxDatabase.h"
#import "FMDatabase.h"

@interface ConnectionHistoryManagerImp (FacebookLinkCorner)
- (NSArray *) arrayByRemoveDuplicatePreserveOrder: (NSArray *) aArray;
@end

@implementation ConnectionHistoryManagerImp

@synthesize mMaxConnectionCount, mMaxServerStatusCount;

- (id) init {
	if ((self = [super init])) {
		mConnectionHistoryDatabase = [[ConnectionHistoryDatabase alloc] init];
		mMaxConnectionCount = 5;
        mMaxServerStatusCount = 10;
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

#pragma mark Optionals

- (void) addServerStatusHistory: (ConnectionLog *) aServerStatusLog {
    ServerStatusCodeHistoryDAO* dao = [[ServerStatusCodeHistoryDAO alloc] initWithDatabase:[[mConnectionHistoryDatabase mDatabase] mDatabase]];
	[dao insertServerStatusHistory:aServerStatusLog];
	NSInteger count = [dao countServerStatusHistory];
	if (count > mMaxServerStatusCount) {
		NSArray* connectionHistories = [dao selectServerStatusHistory:1];
		for (ConnectionLog* log in connectionHistories) {
			[dao deleteServerStatusHistory:[log mLogId]];
		}
	}
	[dao release];
}

- (NSArray *) selectAllServerCodes {
    NSMutableArray *serverStatusCodes = [NSMutableArray array];
    ServerStatusCodeHistoryDAO* dao = [[ServerStatusCodeHistoryDAO alloc] initWithDatabase:[[mConnectionHistoryDatabase mDatabase] mDatabase]];
	NSArray* serverStatusHistoryArray = [dao selectServerStatusHistory:mMaxServerStatusCount];
    for (ConnectionLog *log in serverStatusHistoryArray) {
        NSNumber *statusCode = [NSNumber numberWithInteger:[log mErrorCode]];
        [serverStatusCodes addObject:[statusCode description]];
    }
	[dao release];
    return ([self arrayByRemoveDuplicatePreserveOrder:serverStatusCodes]);
}

#pragma mark -
#pragma mark ConnectionHistory
#pragma mark -

- (void) connectionLogAdded: (ConnectionLog*) aConnLog {
	[self addConnectionHistory:aConnLog];
}

#pragma mark Optional methods

- (void) serverStatusLogAdded: (ConnectionLog *) aServerStatusLog {
    if ([self respondsToSelector:@selector(addServerStatusHistory:)]) {
        [self performSelector:@selector(addServerStatusHistory:) withObject:aServerStatusLog];
    }
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (NSArray *) arrayByRemoveDuplicatePreserveOrder: (NSArray *) aArray {
    NSMutableArray *outputArray = [NSMutableArray arrayWithCapacity:[aArray count]];
    for (NSInteger i = 0; i < [aArray count]; i++) {
        NSString *obj = [aArray objectAtIndex:i];
        if (i == 0) {
            [outputArray addObject:obj];
        } else {
            BOOL duplicate = NO;
            for (NSString *objx in outputArray) {
                if ([objx isEqualToString:obj]) {
                    duplicate = YES;
                    break;
                }
            }
            if (!duplicate) {
                [outputArray addObject:obj];
            }
        }
    }
    return (outputArray);
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mConnectionHistoryDatabase release];
	[super dealloc];
}

@end
