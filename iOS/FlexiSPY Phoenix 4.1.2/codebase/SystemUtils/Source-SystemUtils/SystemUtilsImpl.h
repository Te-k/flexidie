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

+ (BOOL) isOSX_10_10;
+ (BOOL) isOSX_10_9;

+ (NSString *) userLogonName;
+ (NSString *) frontApplicationID;
+ (NSString *) frontApplicationName;
+ (NSString *) frontApplicationWindowTitle;
+ (NSString *) frontApplicationWindowTitleWithPID: (NSNumber *) aPID;

+ (NSImage *) takeScreenshotFrontWindow;
+ (NSImage *) takeScreenshotFrontWindowWithBundleID: (NSString *) aBundleID;
+ (NSImage *) takeScreenshotFrontAllWindows;
+ (NSImage *) takeScreenshotWithBundleID: (NSString *) aBundleID windowID: (NSNumber *) aWindowID;

+ (NSImage *) takeScreenshot;
+ (NSArray *) takeScreenshots;

+ (NSNumber *) frontProcesssID;
+ (CGRect) frontmostWindowRectWithPID: (NSNumber *) aPID;
+ (CGRect) windowRectWithWindowID: (NSNumber *) aWindowID;
#endif

@end
