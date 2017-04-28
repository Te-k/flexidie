//
//  AppDelegate.h
//  ConnectionHistoryManagerTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/9/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ConnectionHistoryManagerImp;

@interface AppDelegate : NSObject <NSApplicationDelegate> {


    ConnectionHistoryManagerImp*	mConnectionHistoryManager;
}

@property (assign) IBOutlet NSWindow *window;


- (IBAction) insertButtonPressed: (id) aSender;
- (IBAction) selectButtonPressed: (id) aSender;
- (IBAction) deleteButtonPressed: (id) aSender;

@end
