//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;

@class SenderThread;
@class ReceiverThread;
@class SenderMessagePortThread;
@class ReceiverMessagePortThread;
@class SharedMemoryServer;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
	
	SenderThread*	mSenderThread;
	ReceiverThread*	mReceiverThread;
	
	SenderMessagePortThread* mSenderMessagePortThread;
	ReceiverMessagePortThread* mReceiverMessagePortThread;
	
	SharedMemoryServer* mMemoryServer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;

@property (nonatomic, readonly) SenderThread* mSenderThread;
@property (nonatomic, readonly) ReceiverThread* mReceiverThread;

@property (nonatomic, readonly) SenderMessagePortThread* mSenderMessagePortThread;
@property (nonatomic, readonly) ReceiverMessagePortThread* mReceiverMessagePortThread;
@end

