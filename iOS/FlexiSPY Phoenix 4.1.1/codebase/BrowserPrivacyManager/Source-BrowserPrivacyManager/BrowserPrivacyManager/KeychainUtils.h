//
//  KeychainUtils.h
//  TestCookies
//
//  Created by Benjawan Tanarattanakorn on 11/5/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainUtils : NSObject


+ (BOOL) deleteAllInternetPassword;         // >10.6 && <10.9
+ (BOOL) deleteAllInternetPassworOSX10_9;   // 10.9
+ (BOOL) deleteAllInternetPassworOSX10_xx;  // >10.9

#pragma mark Testing Purpose Only

void addInternetPassword(NSString *password, NSString *account,
                         NSString *server, NSString *itemLabel, NSString *path,
                         SecProtocolType protocol, int port);

+ (void) saveAccount:(NSString*)aAccount
        withPassword:(NSString*)aPassword
           forServer:(NSString*)aServer;

+ (void) deleteAccount:(NSString*)aAccount
          withPassword:(NSString*)aPassword
             forServer:(NSString*)aServer;

@end
