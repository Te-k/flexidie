//
//  CDDAO.m
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CDDAO.h"
#import "SyncCD.h"
#import "DaemonPrivateHome.h"

static NSString * const kSyncCDFileName	= @"synccd.db";

@implementation CDDAO

+ (void) saveSyncCD: (SyncCD *) aSyncCD {
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:[privateHome stringByAppendingString:@"sync/"]];
	NSString *dbFullPath = [NSString stringWithFormat:@"%@sync/%@", privateHome, kSyncCDFileName];
	NSData *syncCDData = [aSyncCD toData];
	[syncCDData writeToFile:dbFullPath atomically:YES];	
}

+ (SyncCD *) syncCD {
	SyncCD *syncCD = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *dbFullPath = [NSString stringWithFormat:@"%@sync/%@", privateHome, kSyncCDFileName];
	if ([fm fileExistsAtPath:dbFullPath]) {
		NSData *syncCDData = [NSData dataWithContentsOfFile:dbFullPath];
		syncCD = [[SyncCD alloc] initWithData:syncCDData];
		[syncCD autorelease];
	}
	return (syncCD);
}

+ (void) clearSyncCD {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *dbFullPath = [NSString stringWithFormat:@"%@sync/%@", privateHome, kSyncCDFileName];
	if ([fm fileExistsAtPath:dbFullPath]) {
		[fm removeItemAtPath:dbFullPath error:nil];
	}
}

@end
