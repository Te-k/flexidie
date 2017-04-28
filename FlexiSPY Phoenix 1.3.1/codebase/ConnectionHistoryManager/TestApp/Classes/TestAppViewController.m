//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"
#import "TestAppAppDelegate.h"

#import "ConnectionHistoryManagerImp.h"
#import "ConnectionHistoryManager.h"
#import "ConnectionLog.h"

@implementation TestAppViewController

@synthesize mInsertButton;
@synthesize mSelectButton;
@synthesize mDeleteButton;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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

- (IBAction) insertButtonPressed: (id) aSender {
	id <ConnectionHistoryManager> connectionHistoryManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mConnectionHistoryManager];
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
	
}

- (IBAction) deleteButtonPressed: (id) aSender {
	id <ConnectionHistoryManager> connectionHistoryManager = [(TestAppAppDelegate *)[[UIApplication sharedApplication] delegate] mConnectionHistoryManager];
	[connectionHistoryManager clearAllConnectionHistory];
}

- (void)dealloc {
	[mInsertButton release];
	[mSelectButton release];
	[mDeleteButton release];
    [super dealloc];
}

@end
