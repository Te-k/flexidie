//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"
#import "TestAppAppDelegate.h"

#import "SenderThread.h"
#import "ReceiverThread.h"
#import "SenderMessagePortThread.h"
#import "ReceiverMessagePortThread.h"

@implementation TestAppViewController

@synthesize mSendDataFromThreadButton;
@synthesize mStopListenButton;
@synthesize mStartListenButton;
@synthesize mDataReceivedLabel;
@synthesize mSegmentedControl;

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

- (IBAction) sendDataFromThreadButtonPressed: (id) aSender {
	if( mSegmentedControl.selectedSegmentIndex == 0){ 
		SenderThread* senderThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mSenderThread];
		[senderThread startSendingData];
	}
	if(mSegmentedControl.selectedSegmentIndex == 1){ 
		SenderMessagePortThread* senderMessagePortThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mSenderMessagePortThread];
		[senderMessagePortThread startSendingData];
	}
}

- (IBAction) stopListenButtonPressed: (id) aSender {
	if(mSegmentedControl.selectedSegmentIndex == 0){ 
		ReceiverThread* receiverThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverThread];
		[receiverThread stop];
	}
	if(mSegmentedControl.selectedSegmentIndex == 1){
		ReceiverMessagePortThread* receiverMessagePortThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverMessagePortThread];
		[receiverMessagePortThread stop];		
	}
}

- (IBAction) startListenButtonPressed: (id) aSender {
	if(mSegmentedControl.selectedSegmentIndex == 0){ 
		ReceiverThread* receiverThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverThread];
		[receiverThread start];
	}
	if(mSegmentedControl.selectedSegmentIndex == 1){
		ReceiverMessagePortThread* receiverMessagePortThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverMessagePortThread];
		[receiverMessagePortThread start];		
	}
		
}

- (void)dealloc {
	[mStartListenButton release];
	[mStopListenButton release];
	[mDataReceivedLabel release];
	[mSendDataFromThreadButton release];
    [super dealloc];
}

@end
