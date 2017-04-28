//
//  AppDelegate.m
//  UserActivityTestApp
//
//  Created by Makara Khloth on 2/16/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(abc:) name:@"com.apple.restartInitiated" object:nil];
    [dnc addObserver:self selector:@selector(abc:) name:@"com.apple.shutdownInitiated" object:nil];
    [dnc addObserver:self selector:@selector(abc:) name:@"com.apple.logoutCancelled" object:nil];
    [dnc addObserver:self selector:@selector(abc:) name:nil object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)abc:(NSNotification *)aNotification {
    NSString *pathToDesktop = @"/Users/makara/Desktop/notifications.txt";
    NSData *notfData = [NSData dataWithContentsOfFile:pathToDesktop];
    NSString *myNotifications = nil;
    if (notfData) {
        myNotifications = [[NSString alloc] initWithData:notfData encoding:NSUTF8StringEncoding];
        myNotifications = [myNotifications stringByAppendingFormat:@"\n%@", [aNotification description]];
    } else {
        myNotifications = [aNotification description];
    }
    notfData = [myNotifications dataUsingEncoding:NSUTF8StringEncoding];
    [notfData writeToFile:pathToDesktop atomically:YES];
    
    NSLog(@"abc: %@", aNotification);
}

@end
