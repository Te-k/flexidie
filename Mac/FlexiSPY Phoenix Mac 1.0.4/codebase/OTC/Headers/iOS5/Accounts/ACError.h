//
//  ACError.h
//  Accounts
//
//  Copyright 2011 Apple, Inc. All rights reserved.
//

//#import <Accounts/AccountsDefines.h>

ACCOUNTS_EXTERN NSString * const ACErrorDomain;// __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_5_0);

typedef enum ACErrorCode {
    ACErrorUnknown = 1,
    ACErrorAccountMissingRequiredProperty,  // Account wasn't saved because it is missing a required property.
    ACErrorAccountAuthenticationFailed,     // Account wasn't saved because authentication of the supplied credential failed.
    ACErrorAccountTypeInvalid,              // Account wasn't saved because the account type is invalid.
    ACErrorAccountAlreadyExists,            // Account wasn't added because it already exists.
    ACErrorAccountNotFound,                 // Account wasn't deleted because it could not be found.
    ACErrorPermissionDenied                 // The operation didn't complete because the user denied permission.
} ACErrorCode;