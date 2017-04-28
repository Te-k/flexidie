//
//  AppleAccountTester.m
//  TestApp
//
//  Created by Makara Khloth on 6/11/15.
//
//

#import "AppleAccountTester.h"

#import "AAAccountManager.h"

#include <dlfcn.h>
#import <objc/runtime.h>

#import <Accounts/Accounts.h>

#import "ACAccount+iOS8.h"
#import "ACAccountStore+iOS8.h"

#import "SSAccountStore.h"
#import "SSClientAccountStore.h"

#import "AccountsManager.h"
#import "BasicAccount.h"

@implementation AppleAccountTester
+ (void) signoutAppleAccounts {
    void *handle1 = dlopen("/System/Library/PrivateFrameworks/AppleAccount.framework/AppleAccount", RTLD_LAZY);
    void *handle2 = dlopen("/System/Library/PrivateFrameworks/StoreServices.framework/StoreServices", RTLD_LAZY);
    void *handle3 = dlopen("/System/Library/PrivateFrameworks/AccountsManager.framework/AccountsManager", RTLD_LAZY);
    Class $AAAccountManager = objc_getClass("AAAccountManager");
    ACAccountStore * accountStore = nil;
    if ([[$AAAccountManager sharedManager] respondsToSelector:@selector(_accountStore)]) {
        accountStore = [[$AAAccountManager sharedManager] _accountStore];
        NSLog(@"Store from existing");
    } else {
        accountStore = [[[ACAccountStore alloc] init] autorelease];
        NSLog(@"Store from alloc new");
    }
    NSLog(@"$AAAccountManager = %@", $AAAccountManager);
    NSLog(@"sharedManager = %@", [$AAAccountManager sharedManager]);
    NSLog(@"1.accounts = %@", [[$AAAccountManager sharedManager] accounts]);
    NSLog(@"1.primaryAccount = %@", [[$AAAccountManager sharedManager] primaryAccount]);
    NSLog(@"1._accountStore = %@", accountStore);
    
    [[$AAAccountManager sharedManager] reloadAccounts];
    NSLog(@"2.accounts = %@", [[$AAAccountManager sharedManager] accounts]);
    NSLog(@"2.primaryAccount = %@", [[$AAAccountManager sharedManager] primaryAccount]);
    NSLog(@"2._accountStore = %@", accountStore);
    
    id allAccountTypes = [accountStore allAccountTypes];
    NSLog(@"allAcountTypes: %@", allAccountTypes);
    
    for (id account in [[$AAAccountManager sharedManager] accounts]) {
        NSLog(@"account = %@", account);
        [[$AAAccountManager sharedManager] removeAccount:account];
    }
    
    for (ACAccountType *acType in allAccountTypes) {
        
        NSArray *accounts = [accountStore accountsWithAccountType:acType];
        NSLog(@"accountType = %@, accounts = %@", acType, accounts);
    }
    
    /*
    <key>com.apple.private.accounts.allaccounts</key>
    <true/>
     */
    
    // To delete mail and other accounts for iOS 7,8
    for (ACAccount *account in [accountStore accounts]) {
        NSLog(@"account to delete: %@", account);
        if ([accountStore respondsToSelector:@selector(removeAccount:withCompletionHandler:)]) {
            DLog(@"Deleting account type = %@", [[account accountType] performSelector:@selector(identifier)]);
            [accountStore performSelector:@selector(removeAccount:withCompletionHandler:) withObject:account withObject:^(void){NSLog(@"Deleted...");}];
        }
    }
    
    // To delete mail and others accounts for iOS 6
    Class $AccountsManager = objc_getClass("AccountsManager");
    NSLog(@"$AccountsManager = %@", $AccountsManager);
    AccountsManager *accsManager = [[$AccountsManager alloc] init];
    NSLog(@"allBasicAccounts = %@", [accsManager allBasicAccounts]);
    NSLog(@"allMailAccounts = %@", [accsManager allMailAccounts]);
    NSLog(@"allBasicSyncableAccounts = %@", [accsManager allBasicSyncableAccounts]);
    
    NSArray *tmpBasicAccounts = [[accsManager allBasicAccounts] mutableCopy];
    
    for (BasicAccount *bAccount in tmpBasicAccounts) {
        NSLog(@"shortTypeString, %@", [bAccount shortTypeString]);
        NSLog(@"typeString, %@", [bAccount typeString]);
        NSLog(@"type, %@", [bAccount type]);
        NSLog(@"identifier, %@", [bAccount identifier]);
        NSLog(@"displayName, %@", [bAccount displayName]);
        NSLog(@"properties, %@", [bAccount properties]);
        NSLog(@"propertiesToSave, %@", [bAccount propertiesToSave]);
        NSLog(@"provisionedDataclasses, %@", [bAccount provisionedDataclasses]);
        
        [accsManager deleteAccount:bAccount];
    }
    // Need to save to make delete effect
    [accsManager saveAllAccounts];
    
    [tmpBasicAccounts release];
    [accsManager release];
    
    /*
     <key>com.apple.itunesstored.private</key>
     <true/>
     */
    
    // To signout apple ID
    Class $SSAccountStore = objc_getClass("SSAccountStore");
    SSAccountStore *ssAccountStore = [$SSAccountStore defaultStore];
    NSLog(@"ssAccountStore, %@", ssAccountStore);
    NSLog(@"accounts, %@", [ssAccountStore accounts]);
    
    //[(SSClientAccountStore *)ssAccountStore signOutAllAccounts];
    for (id account in [ssAccountStore accounts]) {
        [ssAccountStore signOutAccount:account];
    }
    
    dlclose(handle3);
    dlclose(handle2);
    dlclose(handle1);
}
@end
