//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"

#import "TestAppAppDelegate.h"

#import "SMSSendManager.h"
#import "SMSSendMessage.h"

#import <MessageUI/MessageUI.h>

@implementation TestAppViewController

@synthesize mSendSmsButton;

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

- (IBAction) sendSmsButtonPressed: (id) aSender {
	SMSSendManager* smsSendManager = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mSmsSendManager];
	SMSSendMessage* sendMessage = [[SMSSendMessage alloc] init];
	[sendMessage setMMessage:@"Hello is sending..."];
	[sendMessage setMRecipientNumber:@"0860843742"];
	[smsSendManager sendSMS:sendMessage];
	[sendMessage release];
	
	if ([MFMessageComposeViewController canSendText]) {
		MFMessageComposeViewController *smsComposeViewController = [[MFMessageComposeViewController alloc] init];
		[smsComposeViewController setMessageComposeDelegate:self];
		[smsComposeViewController setBody:@"Hello is sending from UI..."];
		[smsComposeViewController setRecipients:[NSArray arrayWithObject:@"0860843742"]];
		
//		TestAppAppDelegate *testAppAppDelegate = [[UIApplication sharedApplication] delegate];
//		UINavigationController *naviController = [testAppAppDelegate mNaviController];
//		[naviController presentModalViewController:smsComposeViewController animated:YES];
//		[smsComposeViewController release];
		
		[self presentModalViewController:smsComposeViewController animated:YES];
		[smsComposeViewController release];
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"Unknown Error"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			[alert show];
			break;
		case MessageComposeResultFailed:
			[alert show];
			
			break;
		case MessageComposeResultSent:
			
			break;
		default:
			break;
	}
	
//	TestAppAppDelegate *testAppAppDelegate = [[UIApplication sharedApplication] delegate];
//	UINavigationController *naviController = [testAppAppDelegate mNaviController];
//	[naviController dismissModalViewControllerAnimated:YES];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[mSendSmsButton release];
    [super dealloc];
}

@end
