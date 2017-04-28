//
//  ACAccount.h
//  Accounts
//
//  Copyright 2011 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
//#import <Accounts/AccountsDefines.h>
@class ACAccountType, ACAccountCredential;

// The ACAccount class represents an account stored on the system.
// Accounts are created not bound to any store. Once an account is saved it belongs
// to the store it was saved into.

//ACCOUNTS_CLASS_AVAILABLE(5_0)
@interface ACAccount (Legacy_iOS_3) //: NSObject

// Creates a new account object with a specified account type.
- (id)initWithAccountType:(ACAccountType *)type;

// This identifier can be used to look up the account using [ACAccountStore accountWithIdentifier:].
@property (nonatomic, readonly) NSString            *identifier;

// Accounts are stored with a particular account type. All available accounts of a particular type 
// can be looked up using [ACAccountStore accountsWithAccountType:]. When creating new accounts
// this property is required.
@property (nonatomic, retain)   ACAccountType       *accountType;

// A human readable description of the account.
// This property is only available to applications that have been granted access to the account by the user.
@property (nonatomic, copy)     NSString            *accountDescription;

// The username for the account. This property can be set and saved during account creation. The username is
// only available to applications that have been granted access to the account by the user.
@property (nonatomic, copy)     NSString            *username;

// The credential for the account. This property can be set and saved during account creation. It is 
// inaccessible once the account has been saved.
@property (nonatomic, retain)   ACAccountCredential *credential;

@end
