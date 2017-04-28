//
//  CallLogCaptureThread.m
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CallLogCaptureThread.h"
#import "FxCallLogEvent.h"

@interface CallLogCaptureThread (private)

- (void) callLogMainRoutine: (id) aMe;
- (void) addEvent: (FxEvent*) aEvent;
- (FxEvent*) readEvent;
- (void) insertInsertToDB;

- (void) dummyTimerMethod;

@end

@implementation CallLogCaptureThread

@synthesize mParentThread;
@synthesize mEventRepository;

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andUpdateLable: (id <UpdateLable>) aUpdateLabel {
	if ((self = [super init])) {
		mEventRepository = aEventRepository;
		[mEventRepository retain];
		mUpdateLabel = aUpdateLabel;
		[mUpdateLabel retain];
		mEventQueue = [[NSMutableArray alloc] init];
		mLockMutex = [[NSLock alloc] init];
	}
	return (self);
}

- (void) startCapture {
	if (!mIsRunning) {
		mParentThread = [NSThread currentThread];
		mEventCapturingThread = [[NSThread alloc] initWithTarget:self selector:@selector(callLogMainRoutine:) object:self];
		[mEventCapturingThread start];
		mReadEventTime = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(insertInsertToDB) userInfo:nil repeats:YES];
		mIsRunning = TRUE;
		mIsPrempted = FALSE;
	}
}

- (void) stopCapture {
	mIsRunning = FALSE;
	mIsPrempted = TRUE;
	[mEventCapturingThread release];
	if ([mReadEventTime isValid]) {
		[mReadEventTime invalidate];
	}
}

- (void) eventAdded: (FxCallLogEvent*) aCallLogEvent {
	[mEventRepository insert:aCallLogEvent];
}

- (void) callLogMainRoutine: (id) aMe {
	@try {
		// Auto release pool
		NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
		
		// This thread's run loop
		NSRunLoop* thisRunLoop = [NSRunLoop currentRunLoop];
		
		// Create and schedule the first timer.
		NSDate* futureDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
		NSTimer* timerSource = [[NSTimer alloc] initWithFireDate:futureDate
													interval:0.1
													target:self
													selector:@selector(dummyTimerMethod)
													userInfo:nil
													repeats:YES];
		
		[thisRunLoop addTimer:timerSource forMode:NSDefaultRunLoopMode];
		
		CallLogCaptureThread* me = aMe;
		NSString* const kEventDateTime  = @"11:11:11 2011-11-11";
		NSString* const kContactName    = @"Mr. Makara KHLOTH";
		NSString* const kContactNumber  = @"+66860843742";
		
		NSInteger count = 0;
		do {
			// Call log event
			FxCallLogEvent* callLogEvent = [[FxCallLogEvent alloc] init];
			callLogEvent.dateTime = kEventDateTime;
			callLogEvent.contactName = kContactName;
			callLogEvent.contactNumber = kContactNumber;
			callLogEvent.direction = kEventDirectionIn;
			callLogEvent.duration = 399;
			[me addEvent:callLogEvent];
			[callLogEvent release];
			
			SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 3, YES);
			if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)) {
			} else {
			}
			NSLog(@"***Call log thread*** Run loop exit with result: %d", result);
		} while (++count < 100 && !mIsPrempted);
		
		[autoReleasePool release];
	}
	@catch (NSException * e) {
	}
	@finally {
	}
}

- (void) addEvent: (FxEvent*) aEvent {
	[mLockMutex lock];
	[mEventQueue addObject:aEvent];
	[mLockMutex unlock];
}

- (FxEvent*) readEvent {
	[mLockMutex lock];
	FxEvent* event = nil;
	if ([mEventQueue count]) {
		event = [mEventQueue objectAtIndex:0];
		[event retain];
		[event autorelease];
		[mEventQueue removeObjectAtIndex:0];
	}
	[mLockMutex unlock];
	return (event);
}

- (void) insertInsertToDB {
	FxEvent* event = [self readEvent];
	if (event) {
		[mEventRepository insert:event];
	}
	[mUpdateLabel eventAddedUpdateLabel];
}

- (void) dummyTimerMethod {
}

- (void) dealloc {
	[mEventRepository release];
	[mEventQueue release];
	[mLockMutex release];
	[mEventCapturingThread release];
	[mUpdateLabel release];
	[super dealloc];
}

@end
