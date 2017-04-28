//
//  AppDelegate.h
//  UnitTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TestDatabaseSchema;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    TestDatabaseSchema *mTestDBSchema;
}

@property (assign) IBOutlet NSWindow *window;

@end
