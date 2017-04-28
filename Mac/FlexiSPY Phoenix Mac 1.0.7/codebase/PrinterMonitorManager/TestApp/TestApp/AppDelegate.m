//
//  AppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 10/26/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import "AppDelegate.h"

#import "PrinterMonitorManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize printerMonitorManager = _printerMonitorManager;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _printerMonitorManager = [[PrinterMonitorManager alloc] init];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)start:(id)sender {
    [_printerMonitorManager startCapture];
}

- (IBAction)stop:(id)sender {
    [_printerMonitorManager stopCapture];
}

@end
