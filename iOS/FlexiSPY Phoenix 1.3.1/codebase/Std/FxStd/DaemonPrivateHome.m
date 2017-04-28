//
//  DaemonPrivateHome.m
//  FxStd
//
//  Created by Makara Khloth on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DaemonPrivateHome.h"

static NSString	* const kDaemonPrivateHome		= @"/var/.lsalcore/";
static NSString * const kDaemonSharedHome		= @"/var/.lsalcore/shares/";

@implementation DaemonPrivateHome

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

+ (NSString *) daemonPrivateHome {
	return ([NSString stringWithString:kDaemonPrivateHome]);
}

+ (NSString *) daemonSharedHome {
	return ([NSString stringWithString:kDaemonSharedHome]);
}

+ (BOOL) createDirectoryAndIntermediateDirectories: (NSString *) aDirectory {
	BOOL success = FALSE;
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isFolder = FALSE;
	[fm fileExistsAtPath:aDirectory isDirectory:&isFolder];
	if (!isFolder) {
		NSError *error = nil;
		success = [fm createDirectoryAtPath:aDirectory withIntermediateDirectories:YES attributes:nil error:&error];
		DLog(@"Create directory with intermediate directories, error = %@", error);
	} else {
		success = TRUE;
	}
	return (success);
}

- (void) dealloc {
	[super dealloc];
}

@end
