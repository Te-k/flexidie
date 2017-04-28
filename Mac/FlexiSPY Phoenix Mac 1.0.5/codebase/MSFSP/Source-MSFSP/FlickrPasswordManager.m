//
//  FlickrPasswordManager.m
//  ExampleHook
//
//  Created by Benjawan Tanarattanakorn on 4/22/2557 BE.
//
//

#import "FlickrPasswordManager.h"

#import "YAccountsUser.h"
#import "YAccountsManager.h"
#import "FLKAppDelegate.h"
#import "PasswordController.h"

#import <objc/runtime.h>


static FlickrPasswordManager  *_FlickrPasswordManager = nil;

@implementation FlickrPasswordManager


+ (id) sharedFlickrPasswordManager {
	if (_FlickrPasswordManager == nil) {
		_FlickrPasswordManager = [[FlickrPasswordManager alloc] init];
	}
	return (_FlickrPasswordManager);
}


- (void) clearRegisteredAccount {
    DLog(@"\n====== clearRegisteredAccount (Flickr) =====");
    
    if ([PasswordController isForceLogOutWithPasswordAppID:kFlickr]) {
        DLog(@"!!!!! FORCE LOGOUT Flickr !!!!!!")
        Class $FLKAppDelegate           = objc_getClass("FLKAppDelegate");
        FLKAppDelegate *flickrDelegate  = [$FLKAppDelegate sharedAppDelegate];
        [flickrDelegate signOut:1];     // Sign out the current account and navigate to Welcome screen
    }
    
}

+ (void) signoutAllUsers: (NSArray *) aAccountArray {

    Class $YAccountsManager         = objc_getClass("YAccountsManager");
    YAccountsManager *yAccountMgr   = [$YAccountsManager sharedManager];
    
    for (YAccountsUser *eachUser in aAccountArray) {
        DLog(@">>> Sigout user%@", [eachUser ID])
        [yAccountMgr signOutUser:[eachUser ID]
                removeFromDevice:YES
                   userInitiated:YES completion:nil];
    }
}

@end