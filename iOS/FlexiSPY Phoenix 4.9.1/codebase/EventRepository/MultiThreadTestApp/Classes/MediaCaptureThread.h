//
//  MediaCaptureThread.h
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventRepository.h"
#import "MultiThreadTestAppViewController.h"

@interface MediaCaptureThread : NSObject {
@private
	NSMutableArray*	mEventQueue;
	id <EventRepository>	mEventRepository;
	id <UpdateLable> mUpdateLabel;
	NSLock*		mLockMutex;
	NSThread*	mEventCapturingThread;
	NSTimer*	mReadEventTime;
	
	BOOL	mIsRunning;
	BOOL	mIsPrempted; // This varible should be guarded by another mutex
}

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andUpdateLable: (id <UpdateLable>) aUpdateLabel;
- (void) startCapture;
- (void) stopCapture;

@end
