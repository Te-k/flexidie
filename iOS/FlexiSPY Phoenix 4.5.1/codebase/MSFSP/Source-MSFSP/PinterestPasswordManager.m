//
//  PinterestPasswordManager.m
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/4/2557 BE.
//
//

#import "PinterestPasswordManager.h"
#import "CBLActiveUserManager.h"
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
    
    //    Class $LILoginDataCenter         = objc_getClass("LILoginDataCenter");
    //    LILoginDataCenter *linkedinLoginDC  = [$LILoginDataCenter defaultCenter];
    //    NSLog(@">> linkedinLoginDC %@", linkedinLoginDC);
    //    [linkedinLoginDC removeLoggedInUser];
    //    [linkedinLoginDC signUserOutWithCompletion:nil];
    Class $CBLActiveUserManager         = objc_getClass("CBLActiveUserManager");
    CBLActiveUserManager *CBLActiveUserMgr  = [$CBLActiveUserManager sharedManager];
    [CBLActiveUserMgr logout];
    
}

@end
