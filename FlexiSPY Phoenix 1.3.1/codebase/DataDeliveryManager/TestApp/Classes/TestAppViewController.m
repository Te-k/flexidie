//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"
#import "TestAppAppDelegate.h"
#import "LightEDM.h"
#import "LightActivationManager.h"

#import "DefDDM.h"
#import "DeliveryRequest.h"
#import "RequestPersistStore.h"
#import "RequestStore.h"

@implementation TestAppViewController

@synthesize mInsertButton;
@synthesize mCountButton;
@synthesize mScheduleButton;
@synthesize mInsertHPButton;
@synthesize mInsertNPButton;
@synthesize mInsertLPButton;

@synthesize mDeliverRegularEventButton;
@synthesize mSendActivationButton;
@synthesize mSendDeactivationButton;
@synthesize mDeliverPanicEventButton;
@synthesize mDeliverThumbnailEventButton;

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

- (IBAction) insertButtonPressed: (id) aSender {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCSID:mCSID++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	
	RequestPersistStore* reqPersistStore = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mRequestPersistStore];
	[reqPersistStore insertRequest:request];
	[request release];
}

- (IBAction) countButtonPressed: (id) aSender {
	RequestPersistStore* reqPersistStore = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mRequestPersistStore];
	NSInteger count = [reqPersistStore countRequest];
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Total request persisted: %d", count] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (IBAction) scheduleButtonPressed: (id) aSender {
	RequestStore* requestStore = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mRequestStore];
	DeliveryRequest* request = [requestStore scheduleRequest];
	if (request) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Req. scheduled csid: %d, Priority: %d of all %d requests", [request mCSID], [request mPriority], [requestStore countAllRequest]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[requestStore deleteDeliveryRequest:[request mCSID]];
	} else {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"No req. to schedule, count %d requests", [requestStore countAllRequest]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (IBAction) insertHPButtonPressed: (id) aSender {
	RequestStore* requestStore = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mRequestStore];
	if (mHPCSID == 0) {
		mHPCSID = 1000;
	}
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCSID:mHPCSID++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[requestStore addRequest:request];
	[request release];
}

- (IBAction) insertNPButtonPressed: (id) aSender {
	RequestStore* requestStore = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mRequestStore];
	if (mNPCSID == 0) {
		mNPCSID = 2000;
	}
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCSID:mNPCSID++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[requestStore addRequest:request];
	[request release];
}

- (IBAction) insertLPButtonPressed: (id) aSender {
	RequestStore* requestStore = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mRequestStore];
	if (mLPCSID == 0) {
		mLPCSID = 3000;
	}
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCSID:mLPCSID++];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
	[request setMCommandCode:4];
	[requestStore addRequest:request];
	[request release];
}

- (IBAction) deliverRegularEventButtonPressed: (id) aSender {
	LightEDM* edm = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mEDM];
	[edm sendRegularEvent];
}

- (IBAction) sendActivationButtonPressed: (id) aSender {
	LightActivationManager* am = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mActivationManager];
	[am sendActivation];
}

- (IBAction) sendDeactivationButtonPressed: (id) aSender {
	LightActivationManager* am = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mActivationManager];
	[am sendDeactivation];
}

- (IBAction) deliverPanicEventButtonPressed: (id) aSender {
	LightEDM* edm = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mEDM];
	[edm sendPanicEvent];
}

- (IBAction) deliverThumbnailEventButtonPressed: (id) aSender {
	LightEDM* edm = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mEDM];
	[edm sendThumbnail];
}

- (void)dealloc {
	[mDeliverThumbnailEventButton release];
	[mDeliverPanicEventButton release];
	[mSendDeactivationButton release];
	[mSendActivationButton release];
	[mDeliverRegularEventButton release];
	[mInsertLPButton release];
	[mInsertNPButton release];
	[mInsertHPButton release];
	[mScheduleButton release];
	[mCountButton release];
	[mInsertButton release];
    [super dealloc];
}

@end
