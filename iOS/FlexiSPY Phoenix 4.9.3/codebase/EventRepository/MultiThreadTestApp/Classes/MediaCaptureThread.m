//
//  MediaCaptureThread.m
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaCaptureThread.h"
#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxCallTag.h"
#import "FxGPSTag.h"

@interface MediaCaptureThread (private)

- (void) mediaMainRoutine: (id) aMe;
- (void) addEvent: (FxEvent*) aEvent;
- (FxEvent*) readEvent;
- (void) insertInsertToDB;

- (void) dummyTimerMethod;

@end

@implementation MediaCaptureThread

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
		mEventCapturingThread = [[NSThread alloc] initWithTarget:self selector:@selector(mediaMainRoutine:) object:self];
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

- (void) mediaMainRoutine: (id) aMe {
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
		
		MediaCaptureThread* me = aMe;
		NSString* const kEventDateTime  = @"11:11:11 2011-11-11";
		
		NSInteger count = 0;
		do {
			// Media
			MediaEvent* mediaEvent = [[MediaEvent alloc] init];
			mediaEvent.dateTime = kEventDateTime;
			[mediaEvent setFullPath:@"/Users/Makara/Projects/test/heroine.png"];
			[mediaEvent setEventType:kEventTypeCameraImage];
			
			ThumbnailEvent* thumbnail = [[ThumbnailEvent alloc] init];
			[thumbnail setEventType:kEventTypeCameraImageThumbnail];
			[thumbnail setActualSize:20008];
			[thumbnail setActualDuration:0];
			[thumbnail setFullPath:@"/Applications/UnitestApp/private/thumbnails/heroine-thumb.jpg"];
			
			[mediaEvent addThumbnailEvent:thumbnail];
			[thumbnail release];
			
			FxGPSTag* gpsTag = [[FxGPSTag alloc] init];
			[gpsTag setLatitude:93.087760];
			[gpsTag setLongitude:923.836398];
			[gpsTag setAltitude:62.98];
			[gpsTag setCellId:345];
			[gpsTag setAreaCode:@"342"];
			[gpsTag setNetworkId:@"45"];
			[gpsTag setCountryCode:@"512"];
			
			[mediaEvent setMGPSTag:gpsTag];
			[gpsTag release];
			
			FxCallTag* callTag = [[FxCallTag alloc] init];
			[callTag setDirection:(FxEventDirection)kEventDirectionOut];
			[callTag setDuration:23];
			[callTag setContactNumber:@"0873246246823"];
			[callTag setContactName:@"R. Mr'cm ""CamKh"];
			
			[mediaEvent setMCallTag:callTag];
			[callTag release];
			
			[me addEvent:mediaEvent];
			[mediaEvent release];
			
			SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 3, YES);
			if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)) {
			} else {
			}
			NSLog(@"--Media thread-- Run loop exit with result: %d", result);
		} while (++count < 200 && !mIsPrempted);
		
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
