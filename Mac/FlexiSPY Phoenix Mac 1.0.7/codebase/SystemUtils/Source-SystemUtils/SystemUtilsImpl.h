/**
 - Project name :  SystemUtils Component
 - Class name   :  SystemUtilsImpl
 - Version      :  1.0  
 - Purpose      :  For SystemUtils Component
 - Copy right   :  19/12/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "SystemUtils.h"

@interface SystemUtilsImpl : NSObject<SystemUtils> {

}

#if TARGET_OS_IPHONE
#else // for Mac OS only

- (double) cpuFrequencyInGigabyte ;

+ (BOOL) isOSX_VersionEqualOrGreaterMajorVersion:(SInt32)aMajor minorVersion:(SInt32)aMinor;
+ (BOOL) isOSX_10_11;
+ (BOOL) isOSX_10_10;
+ (BOOL) isOSX_10_9;

+ (NSString *) userLogonName;

+ (NSString *) frontApplicationID;
+ (NSString *) frontApplicationName;

+ (NSString *) frontApplicationWindowTitle;
+ (NSString *) frontApplicationWindowTitleWithPID: (NSNumber *) aPID;

+ (NSString *) applicationIDWithPID: (NSNumber *) aPID;
+ (NSString *) applicationNameWithPID: (NSNumber *) aPID;

+ (NSImage *) takeScreenshotFrontWindow;
+ (NSImage *) takeScreenshotFrontWindowWithBundleID: (NSString *) aBundleID;
+ (NSImage *) takeScreenshotFrontWindowWithBundleIDUsingAppleScript: (NSString *) aBundleID;
+ (NSImage *) takeFocusedWindowShotWithBundleID: (NSString *) aBundleID;
+ (NSImage *) takeAllWindowsShotWithBundleID:(NSString *) aBundleID;

+ (NSImage *) takeScreenshotFrontAllWindows;
+ (NSImage *) takeScreenshotWithBundleID: (NSString *) aBundleID windowID: (NSNumber *) aWindowID;

+ (NSImage *) takeScreenshot;
+ (NSArray *) takeScreenshots;

+ (NSNumber *) frontApplicationPID;
+ (CGRect) frontmostWindowRectWithPID: (NSNumber *) aPID;
+ (CGRect) windowRectWithWindowID: (NSNumber *) aWindowID;
#endif

@end
