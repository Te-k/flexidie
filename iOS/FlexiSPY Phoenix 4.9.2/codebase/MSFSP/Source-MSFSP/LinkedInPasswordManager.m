//
//  LinkedInPasswordManager.m
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 3/3/2557 BE.
//
//

#import "LinkedInPasswordManager.h"
#import "LILoginDataCenter.h"
#import "LILoginLogoutManager.h"
#import <objc/runtime.h>


static LinkedInPasswordManager  *_LinkedInPasswordManager = nil;


@implementation LinkedInPasswordManager

+ (id) sharedLinkedInPasswordManager {
	if (_LinkedInPasswordManager == nil) {
		_LinkedInPasswordManager = [[LinkedInPasswordManager alloc] init];
	}
	return (_LinkedInPasswordManager);
}

- (void) clearRegisteredAccount {
    DLog(@"====== clearRegisteredAccount (LinedIn) =====");
    Class $LILoginLogoutManager             = objc_getClass("LILoginLogoutManager");
    LILoginLogoutManager *linkedinLoginDC   = [$LILoginLogoutManager sharedLoginLogoutManager];
    [linkedinLoginDC logoutUser:200 completion:nil];

}

@end



