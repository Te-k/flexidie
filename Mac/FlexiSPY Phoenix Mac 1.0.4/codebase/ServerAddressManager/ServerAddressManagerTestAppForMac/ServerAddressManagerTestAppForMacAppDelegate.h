//
//  ServerAddressManagerTestAppForMacAppDelegate.h
//  ServerAddressManagerTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerAddressChangeDelegate.h"
@class ServerAddressManagerImp;

@interface ServerAddressManagerTestAppForMacAppDelegate : NSObject <NSApplicationDelegate, ServerAddressChangeDelegate> {
    NSWindow *window;
	
	IBOutlet NSTextField *inputUrl;
	IBOutlet NSTextField *serverUrlLabel;
	IBOutlet NSTextField *serverStructuredUrlLabel;
	IBOutlet NSTextField *serverUnstructuredUrlLabel;
	
		ServerAddressManagerImp* serv;
}

@property (nonatomic, retain) IBOutlet NSTextField* inputUrl;
@property (nonatomic, retain) IBOutlet NSTextField* serverUrlLabel;
@property (nonatomic, retain) IBOutlet NSTextField* serverStructuredUrlLabel;
@property (nonatomic, retain) IBOutlet NSTextField* serverUnstructuredUrlLabel;


- (IBAction) saveURL:(id)sender;
- (IBAction) loadURL:(id)sender;
@property (assign) IBOutlet NSWindow *window;

@end
