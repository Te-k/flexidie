//
//  IPCTestAppForMacAppDelegate.h
//  IPCTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IPCTestAppForMacAppDelegate.h"

@class TestAppViewController;

@class SenderThread;
@class ReceiverThread;
@class SenderMessagePortThread;
@class ReceiverMessagePortThread;
@class IPCViewController;

@interface IPCTestAppForMacAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IPCViewController *ctl;
	
	// Model
	SenderThread*	mSenderThread;
	ReceiverThread*	mReceiverThread;	
	SenderMessagePortThread* mSenderMessagePortThread;
	ReceiverMessagePortThread* mReceiverMessagePortThread;

	// View
	NSButton*	mSendDataFromThreadButton;
	NSButton*	mStopListenButton;
	NSButton*	mStartListenButton;
	NSTextField*	mDataReceivedLabel;
	NSSegmentedControl* mSegmentedControl;
	
}
// View
@property (nonatomic, retain) IBOutlet NSButton* mSendDataFromThreadButton;
@property (nonatomic, retain) IBOutlet NSButton* mStopListenButton;
@property (nonatomic, retain) IBOutlet NSButton* mStartListenButton;
@property (nonatomic, retain) IBOutlet NSTextField* mDataReceivedLabel;
@property (nonatomic, retain) IBOutlet NSSegmentedControl* mSegmentedControl;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet IPCViewController *ctl;

// Model
@property (nonatomic, readonly) SenderThread* mSenderThread;
@property (nonatomic, readonly) ReceiverThread* mReceiverThread;
@property (nonatomic, readonly) SenderMessagePortThread* mSenderMessagePortThread;
@property (nonatomic, readonly) ReceiverMessagePortThread* mReceiverMessagePortThread;


- (IBAction) sendDataFromThreadButtonPressed: (id) aSender;
- (IBAction) stopListenButtonPressed: (id) aSender;
- (IBAction) startListenButtonPressed: (id) aSender;



@end
