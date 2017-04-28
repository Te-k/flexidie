//
//  ACAccountType.h
//  Accounts
//
//  Copyright 2011 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Accounts/AccountsDefines.h>

// The identifiers for supported system account types are listed here:
// Twitter account type identifier
ACCOUNTS_EXTERN NSString * const ACAccountTypeIdentifierTwitter;// __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_5_0);

// Each account has an associated account type, containing information relevant to all the accounts of that type.
// ACAccountType objects are obtained by using the [ACAccountStore accountTypeWithIdentifier:] method
// or accessing the accountType property for a particular account object. They may also be used to find
// all the accounts of a particular type using [ACAccountStore accountsWithAccountType:]

//ACCOUNTS_CLASS_AVAILABLE(5_0)
@interface ACAccountType : NSObject

// A human readable description of the account type.
@property (nonatomic, readonly) NSString *accountTypeDescription;

// A unique identifier for the account type. Well known system account type identifiers are listed above.
@property (nonatomic, readonly) NSString *identifier;

// A boolean indicating whether the user has granted access to accounts of this type for your application.
@property (nonatomic, readonly) BOOL     accessGranted;

@end
