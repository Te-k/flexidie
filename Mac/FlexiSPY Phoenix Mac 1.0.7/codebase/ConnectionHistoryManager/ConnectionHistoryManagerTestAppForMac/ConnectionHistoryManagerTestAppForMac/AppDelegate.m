//
//  AppDelegate.m
//  ConnectionHistoryManagerTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/9/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ConnectionHistoryManagerImp.h"
#import "ConnectionHistoryManager.h"
#import "ConnectionLog.h"

@implementation AppDelegate

@synthesize window = _window;

- (id)init {
    self = [super init];
    if (self) {
        mConnectionHistoryManager = [[ConnectionHistoryManagerImp alloc] init];
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (IBAction) insertButtonPressed: (id) aSender {
	NSLog(@"insertButtonPressed");
	id <ConnectionHistoryManager> connectionHistoryManager = mConnectionHistoryManager;
	ConnectionLog *connectionLog = [[ConnectionLog alloc] init];
	[connectionLog setMErrorCode:1];
	[connectionLog setMCommandCode:3];
	[connectionLog setMCommandAction:10];
	[connectionLog setMErrorCate:kConnectionLogHttpError];
	[connectionLog setMErrorMessage:@"This is not an error! fuck you!"];
	[connectionLog setMDateTime:@"2011-12-30 11:11:11"];
	[connectionLog setMAPNName:@"DTAC-Internet"];
	[connectionLog setMConnectionType:kConnectionTypeWifi];
	[connectionHistoryManager addConnectionHistory:connectionLog];
	[connectionLog release];
}

- (IBAction) selectButtonPressed: (id) aSender {
	NSLog(@"select");
	id <ConnectionHistoryManager> connectionHistoryManager = mConnectionHistoryManager;
    NSArray *connectionHistoryArray = [connectionHistoryManager selectAllConnectionHistory];
    
    for (ConnectionLog* connectionLog in connectionHistoryArray) {
        NSLog(@"mErrorMessage %@", [connectionLog mErrorMessage]);
        NSLog(@"mDateTime %@", [connectionLog mDateTime]);                      
        NSLog(@"mLogId %ld", [connectionLog mLogId]);   
        NSLog(@"mErrorCode %ld", [connectionLog mErrorCode]); 
        NSLog(@"mCommandCode %ld", [connectionLog mCommandCode]); 
        NSLog(@"mCommandAction %ld", [connectionLog mCommandAction]); 
        NSLog(@"mErrorCate %d", [connectionLog mErrorCate]); 
        NSLog(@"mAPNName %@", [connectionLog mAPNName]); 
        NSLog(@"mConnectionType %d", [connectionLog mConnectionType]);                    
    }    
}

- (IBAction) deleteButtonPressed: (id) aSender {
	NSLog(@"delete");
	id <ConnectionHistoryManager> connectionHistoryManager = mConnectionHistoryManager;
	[connectionHistoryManager clearAllConnectionHistory];
}



@end
