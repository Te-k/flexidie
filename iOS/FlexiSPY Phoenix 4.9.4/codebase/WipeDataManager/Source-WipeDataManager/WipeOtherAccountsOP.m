//
//  WipeOtherAccountsOP.m
//  WipeDataManager
//
//  Created by Makara Khloth on 6/12/15.
//
//
#include <dlfcn.h>
#import <objc/runtime.h>

#import <Accounts/Accounts.h>

#import "WipeOtherAccountsOP.h"
#import "WipeDataManager.h"

#import "AAAccountManager.h"

#import "ACAccount+iOS8.h"
#import "ACAccountStore+iOS8.h"

#import "SSAccountStore.h"
#import "SSClientAccountStore.h"

#import "AccountsManager.h"
#import "BasicAccount.h"

@interface WipeOtherAccountsOP (private)
- (void) signoutAppleID;
- (void) wipeOtherAccounts;
@end

@implementation WipeOtherAccountsOP

@synthesize mThread;

- (id) initWithDelegate: (id) aDelegate thread: (NSThread *) aThread {
    self = [super init];
    if (self != nil) {
        mDelegate = aDelegate;
        [self setMThread:aThread];
    }
    return (self);
}

- (void) main {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    DLog(@"---- Operation wipe other accounts main ---- ");
    [self wipe];
    
    if ([mDelegate respondsToSelector:@selector(operationCompleted:)]) {
        NSNumber *opID = [NSNumber numberWithUnsignedInt:kWipeOtherAccountsType];
        NSDictionary *wipeOtherAccsInfo = [NSDictionary dictionaryWithObject:opID forKey:kWipeDataTypeKey];
        
        [mDelegate performSelector:@selector(operationCompleted:)
                          onThread:mThread
                        withObject:wipeOtherAccsInfo
                     waitUntilDone:NO];
    }
    
    [pool release];
}

- (void) wipe {
    [self wipeOtherAccounts];
    [self signoutAppleID];
}

- (void) wipeOtherAccounts {
    void *handle1 = dlopen("/System/Library/PrivateFrameworks/AppleAccount.framework/AppleAccount", RTLD_LAZY);
    void *handle2 = dlopen("/System/Library/PrivateFrameworks/StoreServices.framework/StoreServices", RTLD_LAZY);
    
    Class $AAAccountManager = objc_getClass("AAAccountManager");
    ACAccountStore * accountStore = nil;
    if ([[$AAAccountManager sharedManager] respondsToSelector:@selector(_accountStore)]) {
        accountStore = [[$AAAccountManager sharedManager] _accountStore];
        DLog(@"Store from existing");
    } else {
        accountStore = [[[ACAccountStore alloc] init] autorelease];
        DLog(@"Store from alloc new");
    }
    
    id allAccountTypes = [accountStore allAccountTypes];
    DLog(@"allAcountTypes: %@", allAccountTypes);
    
    for (ACAccountType *acType in allAccountTypes) {
        NSArray *accounts = [accountStore accountsWithAccountType:acType];
        DLog(@"accountType = %@, accounts = %@", acType, accounts);
    }
    
    /*
     <key>com.apple.private.accounts.allaccounts</key>
     <true/>
     */
    
    // To delete mail and other accounts for iOS 7,8
    for (ACAccount *account in [accountStore accounts]) {
        DLog(@"account to delete: %@", account);
        if ([accountStore respondsToSelector:@selector(removeAccount:withCompletionHandler:)]) {
            DLog(@"Deleting account type = %@", [[account accountType] performSelector:@selector(identifier)]);
            [accountStore performSelector:@selector(removeAccount:withCompletionHandler:) withObject:account withObject:^(void){DLog(@"Account is deleted!");}];
        }
    }
    
    // To delete mail and others accounts for iOS 6
    Class $AccountsManager = objc_getClass("AccountsManager");
    DLog(@"$AccountsManager = %@", $AccountsManager);
    AccountsManager *accsManager = [[$AccountsManager alloc] init];
    DLog(@"allBasicAccounts = %@", [accsManager allBasicAccounts]);
    DLog(@"allMailAccounts = %@", [accsManager allMailAccounts]);
    DLog(@"allBasicSyncableAccounts = %@", [accsManager allBasicSyncableAccounts]);
    
    NSArray *tmpBasicAccounts = [[accsManager allBasicAccounts] mutableCopy];
    
    for (BasicAccount *bAccount in tmpBasicAccounts) {
        DLog(@"shortTypeString, %@", [bAccount shortTypeString]);
        DLog(@"typeString, %@", [bAccount typeString]);
        DLog(@"type, %@", [bAccount type]);
        DLog(@"identifier, %@", [bAccount identifier]);
        DLog(@"displayName, %@", [bAccount displayName]);
        DLog(@"properties, %@", [bAccount properties]);
        DLog(@"propertiesToSave, %@", [bAccount propertiesToSave]);
        DLog(@"provisionedDataclasses, %@", [bAccount provisionedDataclasses]);
        
        [accsManager deleteAccount:bAccount];
    }
    // Need to save to make delete effect
    [accsManager saveAllAccounts];
    
    [tmpBasicAccounts release];
    [accsManager release];
    
    dlclose(handle2);
    dlclose(handle1);
}

- (void) signoutAppleID {
    void *handle1 = dlopen("/System/Library/PrivateFrameworks/AccountsManager.framework/AccountsManager", RTLD_LAZY);
    
    /*
     <key>com.apple.itunesstored.private</key>
     <true/>
     */
    
    // To signout apple ID
    Class $SSAccountStore = objc_getClass("SSAccountStore");
    SSAccountStore *ssAccountStore = [$SSAccountStore defaultStore];
    DLog(@"ssAccountStore, %@", ssAccountStore);
    DLog(@"accounts, %@", [ssAccountStore accounts]);
    
    //[(SSClientAccountStore *)ssAccountStore signOutAllAccounts];
    for (id account in [ssAccountStore accounts]) {
        [ssAccountStore signOutAccount:account];
    }
    
    dlclose(handle1);
}

- (void) dealloc {
    [self setMThread:nil];
    
    mDelegate = nil;
    mOPCompletedSelector = nil;
    [super dealloc];
}

@end
