//
//  AppPassword.h
//  ProtocolBuilder
//
//  Created by Makara on 2/25/14.
//
//

#import <Foundation/Foundation.h>

@interface AppPassword : NSObject {
@private
    NSString    *mAccountName;
    NSString    *mUserName;
    NSString    *mPassword;
}

@property (nonatomic, copy) NSString *mAccountName;
@property (nonatomic, copy) NSString *mUserName;
@property (nonatomic, copy) NSString *mPassword;

@end
