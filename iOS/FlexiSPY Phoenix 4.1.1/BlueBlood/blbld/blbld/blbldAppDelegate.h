//
//  blbldAppDelegate.h
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NotificationManager, AppTerminateMonitor;

@interface blbldAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow    *window;
    
    NSArray     *mArgs;
    NSTimer     *mKeepLiveTimer;
    NotificationManager *mNotificationManager;
    AppTerminateMonitor *mAppTerminateMonitor;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) NSArray *mArgs;
@property (nonatomic, retain) NotificationManager *mNotificationManager;
@property (nonatomic, retain) AppTerminateMonitor *mAppTerminateMonitor;

@end
