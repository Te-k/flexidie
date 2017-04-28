//
//  AppDelegate.m
//  UnitTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "TestDatabaseSchema.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    mTestDBSchema = [[TestDatabaseSchema alloc] init];
    
    // start running test case  
    [mTestDBSchema testCreateDatabaseFile];
    [mTestDBSchema testDropDatabaseFile];
    [mTestDBSchema testDropTable];
}

@end
