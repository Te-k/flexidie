//
//  AppDelegate.m
//  ConfigurationManagerTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "TestConfigurationManager.h"


#define LIGHT_VISIBLE		201
#define LIGHT_INVISIBLE		202
#define OMNI_INVISIBLE		206
#define OTHER_CONFIG		-1

@implementation AppDelegate

@synthesize configurationSegmentedControl = _configurationSegmentedControl;
@synthesize window = _window;
@synthesize featureTextView = _featureTextView;
@synthesize remoteCommandTextView = _remoteCommandTextView;

- (void)dealloc
{
    if (testConfigMgr)
        [testConfigMgr release];
    
    [self setWindow:nil];
    [self setFeatureTextView:nil];
    [self setRemoteCommandTextView:nil];
    
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(void) updateForConfiguration:(NSInteger) configID {
    if (!testConfigMgr) {
        testConfigMgr = [[TestConfigurationManager alloc] init];
    }
    [testConfigMgr updateForConfiguration:configID];
}

- (IBAction)configurationIDDidSelected:(id)sender {

    NSSegmentedControl *segmentedControl = (NSSegmentedControl *) sender;
    NSInteger config = [segmentedControl selectedSegment];
    switch (config) {
        case 0:
            [self updateForConfiguration:LIGHT_VISIBLE];
            break;
        case 1:
              [self updateForConfiguration:LIGHT_INVISIBLE];
            break;
        case 2:            
            [self updateForConfiguration:OMNI_INVISIBLE];
            break;
        default:
            [self updateForConfiguration:OTHER_CONFIG];
            break;
    }   
}
@end
