//
//  AppDelegate.h
//  ConfigurationManagerTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TestConfigurationManager;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    TestConfigurationManager *testConfigMgr;
}

@property (assign) IBOutlet NSSegmentedControl *configurationSegmentedControl;

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSScrollView *featureTextView;
@property (assign) IBOutlet NSScrollView *remoteCommandTextView;

- (IBAction)configurationIDDidSelected:(id)sender;

@end
