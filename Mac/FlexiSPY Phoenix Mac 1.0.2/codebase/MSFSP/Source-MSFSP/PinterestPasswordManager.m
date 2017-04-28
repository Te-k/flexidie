//
//  PinterestPasswordManager.m
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/4/2557 BE.
//
//

#import "PinterestPasswordManager.h"
#import "CBLActiveUserManager.h"
#import "PIUserSessionManager.h"
#import <objc/runtime.h>

static PinterestPasswordManager  *_PinterestPasswordManager = nil;

@implementation PinterestPasswordManager

+ (id) sharedPinterestPasswordManager {
	if (_PinterestPasswordManager == nil) {
		_PinterestPasswordManager = [[PinterestPasswordManager alloc] init];
	}
	return (_PinterestPasswordManager);
}

- (void) clearRegisteredAccount {
    DLog(@"====== clearRegisteredAccount (Pinterest) =====");
    
    Class $CBLActiveUserManager         = objc_getClass("CBLActiveUserManager");
    if ($CBLActiveUserManager != nil) {
        CBLActiveUserManager *CBLActiveUserMgr  = [$CBLActiveUserManager sharedManager];
        [CBLActiveUserMgr logout];
    }
    
    //6.4.1
    Class $PIUserSessionManager         = objc_getClass("PIUserSessionManager");
    if ($PIUserSessionManager != nil) {
        PIUserSessionManager *PIUserSessionMgr  = [$PIUserSessionManager sharedManager];
        [PIUserSessionMgr logout];
    }
}

@end
