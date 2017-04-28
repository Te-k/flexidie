//
//  MultiThreadTestAppViewController.m
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MultiThreadTestAppViewController.h"

#import "EventRepositoryManager.h"
#import "EventQueryPriority.h"
#import "EventCount.h"

#import "CallLogCaptureThread.h"
#import "MediaCaptureThread.h"

#import "EventGenerator.h"

@implementation MultiThreadTestAppViewController

@synthesize mDBEventCountLable;
@synthesize mButtonStartCapture;
@synthesize mButtonStopCapture;
@synthesize mButtonHello;

@synthesize mGenerateEventButton;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	EventQueryPriority* eventQueryPriority = [[EventQueryPriority alloc] init];
	mEventReposManager = [[EventRepositoryManager alloc] initWithEventQueryPriority:eventQueryPriority];
	[mEventReposManager deleteRepository];
	[mEventReposManager openRepository];
	[eventQueryPriority release];
	
	mCallLogCapture = [[CallLogCaptureThread alloc] initWithEventRepository:mEventReposManager andUpdateLable:self];
	mMediaCapture = [[MediaCaptureThread alloc] initWithEventRepository:mEventReposManager andUpdateLable:self];
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

}

- (IBAction) buttonStartCapturePressed: (id) aSender {
	[mCallLogCapture startCapture];
	[mMediaCapture startCapture];
}

- (IBAction) buttonStopCapturePressed: (id) aSender {
	[mCallLogCapture stopCapture];
	[mMediaCapture stopCapture];
}

- (IBAction) buttonHelloPressed: (id) aSender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Hello, main thread is not blocked" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) eventAddedUpdateLabel {
	EventCount* eventCount = [mEventReposManager eventCount];
	[mButtonHello setTitle:[NSString stringWithFormat:@"Event count: %d", [eventCount totalEventCount]] forState:UIControlStateNormal];
	[mDBEventCountLable setText:[NSString stringWithFormat:@"Event count: %d", [eventCount totalEventCount]]];
	}

- (IBAction) buttonGenerateEventPressed: (id) aSender {
	[EventGenerator generateEventAndInsertInDB: mEventReposManager];
}

- (void)dealloc {
	[mButtonStartCapture release];
	[mButtonStopCapture release];
	[mDBEventCountLable release];
	[mCallLogCapture release];
	[mMediaCapture release];
	[mEventReposManager release];
    [super dealloc];
}

@end
