//
//  ScreenshotUtils.h
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSScreen;

@interface ScreenshotUtils : NSObject {
@private
    
}
+ (id) sharedInstance;
+ (NSImage *) takeFrontWindowShot;
+ (NSImage *) takeFrontAllWindowsShot;
+ (NSImage *) takeFrontWindowShotWithBundleID: (NSString *) aBundleID;
+ (NSImage *) takeFrontWindowShotWithBundleIDUsingAppleScript: (NSString *) aBundleID;
+ (NSImage *) takeFocusedWindowShotWithBundleID: (NSString *) aBundleID;

+ (NSImage *) takeWindowShotWithBundleID: (NSString *) aBundleID windowID: (NSNumber *) aWindowID;
+ (NSImage *) takeScreenShot;
+ (NSImage *) takeScreenShotWithScreen: (NSScreen *) aScreen;
+ (NSArray *) takeScreenShots;
+ (NSData *)scale:(NSImage *)aNSImage X:(float)aX Y:(float)aY;
+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize;

+ (NSString *) frontWindowTitleWithPID: (NSNumber *) aPID;
+ (CGRect) frontmostWindowRectWithPID: (NSNumber *) aPID;
+ (CGRect) windowRectWithWindowID: (NSNumber *) aWindowID;
@end
