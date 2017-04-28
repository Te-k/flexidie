//
//  IPCTestAppForMacAppDelegate.m
//  IPCTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IPCTestAppForMacAppDelegate.h"

#import "SenderThread.h"
#import "ReceiverThread.h"
#import "ReceiverMessagePortThread.h"
#import "SenderMessagePortThread.h"


@implementation IPCTestAppForMacAppDelegate

@synthesize window;


@synthesize mSenderThread;
@synthesize mReceiverThread;
@synthesize ctl;
// UI
@synthesize mSendDataFromThreadButton;
@synthesize mStopListenButton;
@synthesize mStartListenButton;
@synthesize mDataReceivedLabel;
@synthesize mSegmentedControl;


@synthesize mSenderMessagePortThread, mReceiverMessagePortThread;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	DLog (@"launch")
	// Insert code here to initialize your application 
	
	

//	// start receiver
	mReceiverThread				= [[ReceiverThread alloc] init];
//	[mReceiverThread start];
//	
//	// start sender
	mSenderThread				= [[SenderThread alloc] init];
//	[mSenderThread startSendingData];
//	
//	
//	// start receiver
	mReceiverMessagePortThread	= [[ReceiverMessagePortThread alloc] init];
//	[mReceiverMessagePortThread start];
//	
//	// start sender
	mSenderMessagePortThread	= [[SenderMessagePortThread alloc] init];
//	[mSenderMessagePortThread startSendingData];
	
}

- (IBAction) sendDataFromThreadButtonPressed: (id) aSender {
	DLog (@"send data")
	if( [mSegmentedControl selectedSegment] == 0){ 
		NSLog(@"Socket mode");
//		SenderThread* senderThread = [(TestAppAppDelegate*)[[NSApplication sharedApplication] delegate] mSenderThread];
//		[senderThread startSendingData];
		[mSenderThread startSendingData];
	}
	if([mSegmentedControl selectedSegment] == 1){ 
		NSLog(@"MessagePort mode");
//		SenderMessagePortThread* senderMessagePortThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mSenderMessagePortThread];
//		[senderMessagePortThread startSendingData];
		[mSenderMessagePortThread startSendingData];
	}
}

- (IBAction) stopListenButtonPressed: (id) aSender {
	DLog(@"stopListenButtonPressed");
	if([mSegmentedControl selectedSegment] == 0){ 
//		ReceiverThread* receiverThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverThread];
//		[receiverThread stop];
		[mReceiverThread stop];
	}
	if([mSegmentedControl selectedSegment] == 1){
//		ReceiverMessagePortThread* receiverMessagePortThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverMessagePortThread];
//		[receiverMessagePortThread stop];		
		[mReceiverMessagePortThread stop];
	}
}

- (IBAction) startListenButtonPressed: (id) aSender {
	NSLog(@"startListenButtonPressed");
	if([mSegmentedControl selectedSegment] == 0){ 
		DLog (@"listen socket")
//		ReceiverThread* receiverThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverThread];
//		[receiverThread start];
		[mReceiverThread start];
	}
	if([mSegmentedControl selectedSegment] == 1){
		DLog (@"listen message port")
//		ReceiverMessagePortThread* receiverMessagePortThread = [(TestAppAppDelegate*)[[UIApplication sharedApplication] delegate] mReceiverMessagePortThread];
//		[receiverMessagePortThread start];		
		[mReceiverMessagePortThread start];
	}	
}


- (void)dealloc {
	// UI
	[mStartListenButton release];
	[mStopListenButton release];
	[mDataReceivedLabel release];
	[mSendDataFromThreadButton release];
	// Model
	[mReceiverThread release];
	[mSenderThread release];
	[mSenderMessagePortThread release];
	[mReceiverMessagePortThread release];
    [window release];
	//[ctl release];
    [super dealloc];
}

@end
