//
//  ScreenshotFIDStore.m
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ScreenshotFIDStore.h"

#import "FMDatabase.h"
#import "DaemonPrivateHome.h"

@interface ScreenshotFIDStore (private)
- (void) buildDatabase;
@end

@implementation ScreenshotFIDStore

- (id) init {
    self = [super init];
    if (self) {
        [self buildDatabase];
    }
    return (self);
}

- (NSUInteger) uniqueFrameID {
    [mFIDStore executeUpdate:@"INSERT INTO frame VALUES(NULL)"];
    return ((NSUInteger)[mFIDStore lastInsertRowId]);
}

- (void) buildDatabase {
    NSString *etcPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
    NSString *dbPath = [etcPath stringByAppendingString:@"storeframe.db"];
    mFIDStore = [[FMDatabase databaseWithPath:dbPath] retain];
    [mFIDStore open];
    [mFIDStore executeUpdate:@"CREATE TABLE IF NOT EXISTS frame (frame_id INTEGER PRIMARY KEY AUTOINCREMENT)"];
}

- (void) dealloc {
    [mFIDStore close];
    [mFIDStore release];
    [super dealloc];
}

@end
