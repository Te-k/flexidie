//
//  UserURLsTestAppViewController.m
//  UserURLsTestApp
//
//  Created by Benjawan Tanarattanakorn on 12/20/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserURLsTestAppViewController.h"
#import "ServerAddressManagerImp.h"

@implementation UserURLsTestAppViewController

@synthesize mCurrentIndexLabel;
@synthesize mStartIndexLabel;

- (IBAction) addUserURLsPressed: (UIButton *) aSender {
	NSArray *urlArray = [NSArray arrayWithObjects:@"www.hello.com",
						 @"www.coffee.com",
						 @"www.food.com",
						 nil];
	[mServerAddrMgr addUserURLs:urlArray];
	[[self mStartIndexLabel] setText:[NSString stringWithFormat:@"%d",[mServerAddrMgr mStartIndex]]];
	[[self mCurrentIndexLabel] setText:[NSString stringWithFormat:@"%d",[mServerAddrMgr mCurrentIndex]]];
}

- (IBAction) clearUserURLsPressed: (UIButton *) aSender {
	[mServerAddrMgr clearUserURLs];
	[[self mStartIndexLabel] setText:[NSString stringWithFormat:@"%d",[mServerAddrMgr mStartIndex]]];
	[[self mCurrentIndexLabel] setText:[NSString stringWithFormat:@"%d",[mServerAddrMgr mCurrentIndex]]];

}

- (IBAction) getUserURLsPressed: (UIButton *) aSender {
	NSArray *urlArray = [NSArray arrayWithArray:[mServerAddrMgr userURLs]];
	NSLog(@"User url array is %@", urlArray);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User URLs"
													message:[urlArray description]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (IBAction) increaseCurrentIndexPressed: (UIButton *) aSender {
	[mServerAddrMgr hasNextURL];
	[[self mStartIndexLabel] setText:[NSString stringWithFormat:@"%d",[mServerAddrMgr mStartIndex]]];
	[[self mCurrentIndexLabel] setText:[NSString stringWithFormat:@"%d",[mServerAddrMgr mCurrentIndex]]];

}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	mServerAddrMgr = [[ServerAddressManagerImp alloc] init];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mServerAddrMgr release];
	[mCurrentIndexLabel release];
	[mStartIndexLabel release];
    [super dealloc];
}

@end
