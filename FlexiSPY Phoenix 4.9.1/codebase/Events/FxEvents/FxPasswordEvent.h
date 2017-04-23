//
//  FxPasswordEvent.h
//  FxEvents
//
//  Created by Makara on 2/24/14.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
    kPasswordApplicationTypeNoneNativeMail  = 1,
    kPasswordApplicationTypeNativeMail      = 2
} PasswordApplicationType;

@interface FxAppPwd : NSObject <NSCoding, NSCopying> {
@private
    NSInteger   mID;
    NSInteger   mPasswordID;
    NSString    *mAccountName;
    NSString    *mUserName;
    NSString    *mPassword;
}

@property (nonatomic, assign) NSInteger mID;
@property (nonatomic, assign) NSInteger mPasswordID;
@property (nonatomic, copy) NSString *mAccountName;
@property (nonatomic, copy) NSString *mUserName;
@property (nonatomic, copy) NSString *mPassword;

@end

@interface FxPasswordEvent : FxEvent <NSCoding, NSCopying> {
@private
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    PasswordApplicationType mApplicationType;
    NSArray     *mAppPwds;
}

@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, assign) PasswordApplicationType mApplicationType;
@property (nonatomic, retain) NSArray *mAppPwds;

@end
