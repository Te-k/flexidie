//
//  LINEPasswordManager.m
//  MSFSP
//
//  Created by benjawan tanarattanakorn on 2/25/2557 BE.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "LINEPasswordManager.h"
#import "AccountService.h"


static LINEPasswordManager  *_LINEPasswordManager = nil;


@implementation LINEPasswordManager

+ (id) sharedLINEPasswordManager{
	if (_LINEPasswordManager == nil) {
		_LINEPasswordManager = [[LINEPasswordManager alloc] init];
	}
	return (_LINEPasswordManager);
}

- (void) clearRegisteredAccount {
    DLog (@"====== clearRegisteredAccount =====")
    
    @try {
        Class $AccountService = objc_getClass("AccountService");
        DLog(@"AccountService %@", $AccountService)
        [$AccountService clearIdentityCredentialWithCompletionBlock:^(){
            DLog(@"clear success")
        } errorBlock:^(){
            DLog(@"clear fail")
        }];
    }
    @catch (NSException *exception) {
        DLog(@"LINE force log out exception: %@", exception);
    }
    @finally {
        ;
    }
}
@end
