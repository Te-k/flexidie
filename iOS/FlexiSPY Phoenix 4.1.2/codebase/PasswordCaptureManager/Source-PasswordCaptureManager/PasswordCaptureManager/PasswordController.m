//
//  PasswordController.m
//  PasswordCaptureManager
//
//  Created by Makara on 2/27/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import "PasswordController.h"
#import "DaemonPrivateHome.h"

@interface PasswordController (private)
+ (void) forcePasswordAppIDv2: (NSString *) aPasswordAppID logOut: (BOOL) aLogOut;
@end

void myPassCapNotificationCenterCallBack(CFNotificationCenterRef center,
                                      void *observer,
                                      CFStringRef name,
                                      const void *object,
                                      CFDictionaryRef userInfo)
{
    DLog(@"PassCap notification name, %@", name);
    NSString *appID = (NSString *)name;
    [PasswordController forcePasswordAppID:appID logOut:false];
}

@implementation PasswordController

#pragma mark -
#pragma mark Methods only used in daemon
#pragma mark -

+ (BOOL) isCompleteForceLogOut {
    NSString * home = [NSString stringWithFormat:@"%@etc/ForceOut.plist", [DaemonPrivateHome daemonPrivateHome]];
    DLog(@"### F-O-R home %@", home);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:home]) {
        NSDictionary * forceLogOutInfo = [[NSDictionary alloc] initWithContentsOfFile:home];
        NSNumber *forceLogOut = [forceLogOutInfo objectForKey:@"forcelogOut"];
        [forceLogOutInfo release];
        return ([forceLogOut boolValue]);
    }
    return (NO);
}

+ (void) setCompleteForceLogOut: (BOOL) aForceLogOut {
    NSString * home = [NSString stringWithFormat:@"%@etc/ForceOut.plist", [DaemonPrivateHome daemonPrivateHome]];
    DLog(@"### F-O-W home %@", home);
    
    NSMutableDictionary * forceLogOutInfo = [[NSMutableDictionary alloc] init];
    [forceLogOutInfo setObject:[NSNumber numberWithBool:aForceLogOut] forKey:@"forcelogOut"];
    [forceLogOutInfo writeToFile:home atomically:YES];
    [forceLogOutInfo release];
}

+ (void) forceLogOutAllPasswordAppID {
    [self forcePasswordAppIDv2:kBBM logOut:kForceOut];
    [self forcePasswordAppIDv2:kYahoo logOut:kForceOut];
    [self forcePasswordAppIDv2:kSkype logOut:kForceOut];
    [self forcePasswordAppIDv2:kLineiPad logOut:kForceOut];
    [self forcePasswordAppIDv2:kLine logOut:kForceOut];
    [self forcePasswordAppIDv2:kFacebook logOut:kForceOut];
    [self forcePasswordAppIDv2:kFacebookMSG logOut:kForceOut];
    [self forcePasswordAppIDv2:kInstagram logOut:kForceOut];
    [self forcePasswordAppIDv2:kLinkedIn logOut:kForceOut];
    [self forcePasswordAppIDv2:kPinterest logOut:kForceOut];
    [self forcePasswordAppIDv2:kFoursquare logOut:kForceOut];
    [self forcePasswordAppIDv2:kFlickr logOut:kForceOut];
    [self forcePasswordAppIDv2:kTumblr logOut:kForceOut];
    [self forcePasswordAppIDv2:kVimeo logOut:kForceOut];
    [self forcePasswordAppIDv2:kWechat logOut:kForceOut];
    [self forcePasswordAppIDv2:kAppleID logOut:kForceOut];
    [self forcePasswordAppIDv2:kTwitter logOut:kForceOut];
}

+ (void) resetForceLogOutAllPasswordAppID {
    [self forcePasswordAppIDv2:kBBM logOut:kReset];
    [self forcePasswordAppIDv2:kYahoo logOut:kReset];
    [self forcePasswordAppIDv2:kSkype logOut:kReset];
    [self forcePasswordAppIDv2:kLineiPad logOut:kReset];
    [self forcePasswordAppIDv2:kLine logOut:kReset];
    [self forcePasswordAppIDv2:kFacebook logOut:kReset];
    [self forcePasswordAppIDv2:kFacebookMSG logOut:kReset];
    [self forcePasswordAppIDv2:kInstagram logOut:kReset];
    [self forcePasswordAppIDv2:kLinkedIn logOut:kReset];
    [self forcePasswordAppIDv2:kPinterest logOut:kReset];
    [self forcePasswordAppIDv2:kFoursquare logOut:kReset];
    [self forcePasswordAppIDv2:kFlickr logOut:kReset];
    [self forcePasswordAppIDv2:kTumblr logOut:kReset];
    [self forcePasswordAppIDv2:kVimeo logOut:kReset];
    [self forcePasswordAppIDv2:kWechat logOut:kReset];
    [self forcePasswordAppIDv2:kAppleID logOut:kReset];
    [self forcePasswordAppIDv2:kTwitter logOut:kReset];
}

+ (void) registerForceLogOutReset {
    CFNotificationCenterRef darwinCenter = CFNotificationCenterGetDarwinNotifyCenter();
    if (darwinCenter) {
        NSArray *passAppIDs = [NSArray arrayWithObjects:kBBM,kYahoo,kSkype,kLineiPad,kLine,kFacebook,kFacebookMSG,kInstagram,kLinkedIn,kPinterest,kFoursquare,kFlickr,kTumblr,kVimeo,kWechat,kAppleID,kTwitter,nil];
        for (NSString *passAppID in passAppIDs) {
            DLog(@"Register for PassCap %@", passAppID);
            CFNotificationCenterAddObserver(darwinCenter,
                                            nil,
                                            myPassCapNotificationCenterCallBack,
                                            (CFStringRef)passAppID,
                                            nil,
                                            CFNotificationSuspensionBehaviorDeliverImmediately);
        }
    }
}

+ (void) unregisterForceLogOutReset {
    CFNotificationCenterRef darwinCenter = CFNotificationCenterGetDarwinNotifyCenter();
    if (darwinCenter) {
        NSArray *passAppIDs = [NSArray arrayWithObjects:kBBM,kYahoo,kSkype,kLineiPad,kLine,kFacebook,kFacebookMSG,kInstagram,kLinkedIn,kPinterest,kFoursquare,kFlickr,kTumblr,kVimeo,kWechat,kAppleID,kTwitter,nil];
        for (NSString *passAppID in passAppIDs) {
            DLog(@"Unregister for PassCap %@", passAppID);
            CFNotificationCenterRemoveObserver(darwinCenter,
                                               nil,
                                               (CFStringRef)passAppID,
                                               nil);
        }
    }
}

#pragma mark -
#pragma mark Methods used only in mobile substrate
#pragma mark -

+ (void) forcePasswordAppID: (NSString *) aPasswordAppID logOut: (BOOL) aLogOut {
    NSString * home = [NSString stringWithFormat:@"%@etc/PassCap_%@.plist", [DaemonPrivateHome daemonPrivateHome], aPasswordAppID];
    DLog(@"### W home %@", home);
    
    NSMutableDictionary * rule = [[NSMutableDictionary alloc] init];
    [rule setObject:[NSNumber numberWithBool:aLogOut] forKey:aPasswordAppID];
    bool reset = [rule writeToFile:home atomically:YES];
    [rule release];
    
    if (!reset) {
        // Sandbox, iOS 9
        DLog(@"Post notification for PassCap %@", aPasswordAppID);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             (CFStringRef)aPasswordAppID,
                                             (__bridge const void *)(self),
                                             nil,
                                             true);
    }
}

+ (BOOL) isForceLogOutWithPasswordAppID: (NSString *) aPasswordAppID {
    NSString * home = [NSString stringWithFormat:@"%@etc/PassCap_%@.plist", [DaemonPrivateHome daemonPrivateHome], aPasswordAppID];
    DLog(@"### R home %@", home);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:home]) {
        NSDictionary * rule = [[NSDictionary alloc] initWithContentsOfFile:home];
        NSNumber *logOut = [rule objectForKey:aPasswordAppID];
        [rule release];
        return ([logOut boolValue]);
    }
    return (NO);
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

+ (void) forcePasswordAppIDv2: (NSString *) aPasswordAppID logOut: (BOOL) aLogOut {
    NSString * home = [NSString stringWithFormat:@"%@etc/PassCap_%@.plist", [DaemonPrivateHome daemonPrivateHome], aPasswordAppID];
    DLog(@"### R-W home %@", home);
    
    NSMutableDictionary * rule = [[NSMutableDictionary alloc] init];
    [rule setObject:[NSNumber numberWithBool:aLogOut] forKey:aPasswordAppID];
    [rule writeToFile:home atomically:YES];
    [rule release];
    
    NSString *myCommand1 = [NSString stringWithFormat:@"chmod 666 %@", home];
    NSString *myCommand2 = [NSString stringWithFormat:@"chown mobile %@", home];
    system([myCommand1 UTF8String]);
    system([myCommand2 UTF8String]);
}

@end
