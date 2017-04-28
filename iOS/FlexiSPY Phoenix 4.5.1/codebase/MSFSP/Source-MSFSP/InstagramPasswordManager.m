//
//  InstagramPasswordManager.m
//  ExampleHook
//
//  Created by benjawan tanarattanakorn on 2/27/2557 BE.
//
//

#import "InstagramPasswordManager.h"

#import "IGAuthHelper.h"
#import "IGAuthHelper+7-0-1.h"
#import "IGAuthHelper+7-10-0.h"

#import <objc/runtime.h>


static InstagramPasswordManager  *_InstagramPasswordManager = nil;


@implementation InstagramPasswordManager


+ (id) sharedInstagramPasswordManager {
	if (_InstagramPasswordManager == nil) {
		_InstagramPasswordManager = [[InstagramPasswordManager alloc] init];
	}
	return (_InstagramPasswordManager);
}

- (void) clearRegisteredAccount {
    DLog(@"====== clearRegisteredAccount (Instagram) =====");
    
    Class $IGAuthHelper         = objc_getClass("IGAuthHelper");
    IGAuthHelper *igAuthHelper  = [$IGAuthHelper sharedAuthHelper];
    DLog(@"igAuthHelper = %@", igAuthHelper);
    
    if ([igAuthHelper respondsToSelector:@selector(logout)]) {                                  // Prior to 5.0.8
        //DLog(@"InstagramPasswordManager --> Logout With Handler (prior to version 5.0.8)")
        [igAuthHelper logout];
    } else if ([igAuthHelper respondsToSelector:@selector(logOutWithCompletionHandler:)]) {     // 5.0.8, 5.0.9
        //DLog(@"InstagramPasswordManager --> Logout With Handler (since version 5.0.8)")
        [igAuthHelper logOutWithCompletionHandler:nil];
    } else if ([igAuthHelper respondsToSelector:@selector(logOutWithSuccessHandler:failureHandler:)]) { // 7.0.1
        DLog(@"InstagramPasswordManager --> @selector(logOutWithSuccessHandler:failureHandler:)")
        [igAuthHelper logOutWithSuccessHandler:nil failureHandler:nil];
    } else if ([igAuthHelper respondsToSelector:@selector(logOutAllUsersWithCompletionHandler:)]) { // 7.10.0
        DLog(@"InstagramPasswordManager --> @selector(logOutAllUsersWithCompletionHandler:)");
        [igAuthHelper logOutAllUsersWithCompletionHandler:nil];
    }
}

@end
