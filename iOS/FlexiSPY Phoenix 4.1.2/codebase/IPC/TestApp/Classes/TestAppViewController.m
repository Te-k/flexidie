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


- (IBAction) sendDataFromThreadButtonPressed: (id) aSender {
	
	if( mSegmentedControl.selectedSegmentIndex == 0){ 
		NSLog(@"Socket mode");
		SenderThread* senderThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mSenderThread];
		[senderThread startSendingData];
	}
	if(mSegmentedControl.selectedSegmentIndex == 1){ 
		NSLog(@"MessagePort mode");
		SenderMessagePortThread* senderMessagePortThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mSenderMessagePortThread];
		[senderMessagePortThread startSendingData];
	}
}

- (IBAction) stopListenButtonPressed: (id) aSender {
	NSLog(@"stopListenButtonPressed");
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
	NSLog(@"startListenButtonPressed");
	if(mSegmentedControl.selectedSegmentIndex == 0){ 
		DLog (@"listen socket")
		ReceiverThread* receiverThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverThread];
		[receiverThread start];
	}
	if(mSegmentedControl.selectedSegmentIndex == 1){
		DLog (@"listen message port")
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
