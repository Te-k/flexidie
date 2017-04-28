//
//  LoggerTestAppAppDelegate.m
//  LoggerTestApp
//
//  Created by Syam Sasidharan on 11/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "LoggerTestAppViewController.h"

@implementation LoggerTestAppViewController

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 Implement viewDidLoad if you need to do additional setup after loading the view.*/
- (void)viewDidLoad {
    
    APPLOG("TestApp","viewDidLoad",1,kFXLogLevelDebug,@"Testing log..");
    APPLOGVERBOSE(@"Testing");
    APPLOGERROR(@"Testing");
    
	[super viewDidLoad];
}
 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

@end
