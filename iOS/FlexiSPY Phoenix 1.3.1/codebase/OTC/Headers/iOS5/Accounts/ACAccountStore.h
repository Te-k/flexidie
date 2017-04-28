//
//  ACAccountStore.h
//  Accounts
//
//  Copyright 2011 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Accounts/AccountsDefines.h>
//typedef void(^ACAccountStoreSaveCompletionHandler)(BOOL success, NSError *error);
//typedef void(^ACAccountStoreRequestAccessCompletionHandler)(BOOL granted, NSError *error);

@class ACAccount;
@class ACAccountType;

// The ACAccountStore class provides an interface for accessing and manipulating
// accounts. You must create an ACAccountStore object to retrieve, add and delete
// accounts from the Accounts database.

//ACCOUNTS_CLASS_AVAILABLE(5_0)
@interface ACAccountStore : NSObject

// An array of all the accounts in an account database
@property (nonatomic, readonly) NSArray *accounts;

// Returns the account matching the given account identifier
- (ACAccount *)accountWithIdentifier:(NSString *)identifier;

// Returns the account type object matching the account type identifier. See
// ACAccountType.h for well known account type identifiers
- (ACAccountType *)accountTypeWithAccountTypeIdentifier:(NSString *)typeIdentifier;

// Returns the accounts matching a given account type.
- (NSArray *)accountsWithAccountType:(ACAccountType *)accountType;

// Saves the account to the account database. If the account is unauthenticated and the associated account
// type supports authentication, the system will attempt to authenticate with the credentials provided.
// Assuming a successful authentication, the account will be saved to the account store. The completion handler
// for this method is called on an arbitrary queue.
//- (void)saveAccount:(ACAccount *)account withCompletionHandler:(ACAccountStoreSaveCompletionHandler)completionHandler;

// Obtains permission, if necessary, from the user to access protected properties, and utilize accounts
// of a particular type in protected operations, for example OAuth signing. The completion handler for 
// this method is called on an arbitrary queue.
//- (void)requestAccessToAccountsWithType:(ACAccountType *)accountType 
//                  withCompletionHandler:(ACAccountStoreRequestAccessCompletionHandler)handler;

@end

// Notification name sent out when the database is changed by an external process, another account store
// in the same process or by calling saveAccount: or removeAccount: on a store you are managing. When this
// notification is received, you should consider all ACAccount instances you have to be invalid. Purge current
// instances of ACAccount and obtain new instances using the account store. You may need to deal with accounts
// being removed by an external process while you are using them.
//ACCOUNTS_EXTERN NSString * const ACAccountStoreDidChangeNotification __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_5_0);