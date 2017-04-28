//
//  AppContextTestAppForMacAppDelegate.h
//  AppContextTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppContextTestAppForMacAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
