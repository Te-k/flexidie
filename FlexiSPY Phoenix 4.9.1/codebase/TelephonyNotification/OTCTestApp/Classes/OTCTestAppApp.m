//
//  OTCTestAppApp.m
//  OTCTestApp
//

#import "OTCTestAppApp.h"

@implementation OTCTestAppApp

@synthesize window;
@synthesize mainView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	// Create window
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
    
	// Set up content view
	mainView = [[UIView alloc] initWithFrame: [UIHardware fullScreenApplicationContentRect]];
	[window setContentView: mainView];
    
	// Show window
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[mainView release];
	[window release];
	[super dealloc];
}

@end
