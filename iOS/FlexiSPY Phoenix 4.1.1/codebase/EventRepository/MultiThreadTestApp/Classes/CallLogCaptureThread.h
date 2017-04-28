//
//  CallLogCaptureThread.h
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventRepository.h"
#import "MultiThreadTestAppViewController.h"

@class FxCallLogEvent;

@protocol CallLogCapture <NSObject>
@required
- (void) eventAdded: (FxCallLogEvent*) aCallLogEvent;

@end


@interface CallLogCaptureThread : NSObject <CallLogCapture> {
@private
	NSMutableArray*	mEventQueue;
	id <EventRepository>	mEventRepository;
	id <UpdateLable> mUpdateLabel;
	NSLock*		mLockMutex;
	NSThread*	mEventCapturingThread;
	NSTimer*	mReadEventTime;
	NSThread*	mParentThread;
	
	BOOL	mIsRunning;
	BOOL	mIsPrempted; // This varible should be guarded by another mutex
}

@property (readonly) NSThread* mParentThread;
@property (readonly) id <EventRepository> mEventRepository;

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andUpdateLable: (id <UpdateLable>) aUpdateLabel;
- (void) startCapture;
- (void) stopCapture;

@end
