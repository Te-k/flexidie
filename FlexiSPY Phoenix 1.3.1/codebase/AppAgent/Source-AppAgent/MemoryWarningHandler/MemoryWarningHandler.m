//
//  MemoryWarningHandler.m
//  TestMemWaningNSAcrossThread
//
//  Created by bengasi on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <libkern/OSMemoryNotification.h>

#import "MemoryWarningHandler.h"


@interface MemoryWarningHandler (private)

- (void) blockAndWaitForResponse: (NSThread *) aThread;
- (void) postNotificationAndSpawnNewThreadToWaitForMemoryWarning: (NSNumber *) aMemoryLevelArray;

// for logging purpose
- (void) printMemoryLevel: (OSMemoryNotificationLevel) aMemoryLevel;
- (void) printResponseError: (NSInteger) aResponseError;

@end


@implementation MemoryWarningHandler

- (void) startListenToMemoryWarningLevel {
	NSLog(@"MemoryWarningHandler --> startListenToMemoryWarningLevel: main thread ? %d", [NSThread isMainThread]);
	
	// create notification
	int creationError =  OSMemoryNotificationCreate(&mMemoryNotification);
	switch (creationError) {
		case 0:
			NSLog(@"!!!!! SUSCESS TO CREATE NOTIFICATION") ;
			break;
		case ENOMEM:
			NSLog(@"!!!!! insufficient memory or resources ") ;
			break;
		case EINVAL:
			NSLog(@"!!!!! threshold is not a valid notification level") ;
			break;
		default:
			break;
	}
	
	// spawn a new thread to run listenMemoryWarning
	NSThread *callerThread = [[NSThread currentThread] retain];
	NSLog(@"MemoryWarningHandler --> startListenToMemoryWarningLevel: thread: %@", callerThread);
	
	[NSThread detachNewThreadSelector:@selector(blockAndWaitForResponse:) 
							 toTarget:self
						   withObject:callerThread];	
	[callerThread autorelease];
}

// This method is not expected to run on the main thread
- (void) blockAndWaitForResponse: (NSThread *) aCallerThread {
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"MemoryWarningHandler --> blockAndWaitForResponse: main thread ? %d",		[NSThread isMainThread]);
	NSLog(@"MemoryWarningHandler --> blockAndWaitForResponse: current thread: %@",		[NSThread currentThread]);
	NSLog(@"MemoryWarningHandler --> blockAndWaitForResponse: a caller thread is %@",	aCallerThread);

	OSMemoryNotificationLevel memoryLevel;
	
	// wait for response
	NSInteger responseError =  OSMemoryNotificationWait(mMemoryNotification, &memoryLevel);	// block the current thread here
	
	[self printResponseError:responseError];
	[self printMemoryLevel:memoryLevel];
	
	NSArray *memLevelArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:memoryLevel], nil];
	
	// go back to the previous thread
	[self performSelector:@selector(postNotificationAndSpawnNewThreadToWaitForMemoryWarning:) 
				 onThread:aCallerThread 
			   withObject:[NSNumber numberWithInt:memoryLevel] 
			waitUntilDone:NO];
	
	[memLevelArray release];
	
	[pool drain];
}

// this method is expected to be called in the thread that calls 'startListenToMemoryWarningLevel' method
- (void) postNotificationAndSpawnNewThreadToWaitForMemoryWarning: (NSNumber *) aMemoryLevelArray {
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];

	NSLog(@"MemoryWarningHandler --> postNotification: main thread ? %d",		[NSThread isMainThread]);
	NSLog(@"MemoryWarningHandler --> postNotification: current thread: %@",		[NSThread currentThread]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSMemoryWarningLevelNotification 
														object:aMemoryLevelArray];	
	
	
	// spawn a new thread to run listenMemoryWarning
	NSThread *callerThread = [[NSThread currentThread] retain];
	[NSThread detachNewThreadSelector:@selector(blockAndWaitForResponse:) 
							 toTarget:self
						   withObject:callerThread];	
	[callerThread autorelease];
	
	[pool drain];
}

- (void) printMemoryLevel: (OSMemoryNotificationLevel) aMemoryLevel {
	
	switch (aMemoryLevel) {
		case OSMemoryNotificationLevelAny:
			NSLog(@"!!!!! OSMemoryNotificationLevelAny") ;
			break;
		case OSMemoryNotificationLevelNormal:
			NSLog(@"!!!!! OSMemoryNotificationLevelNormal") ;
			break;
		case OSMemoryNotificationLevelWarning:
			NSLog(@"!!!!! OSMemoryNotificationLevelWarning") ;
			break;
		case OSMemoryNotificationLevelUrgent:
			NSLog(@"!!!!! OSMemoryNotificationLevelUrgent") ;
			break;
		case OSMemoryNotificationLevelCritical:
			NSLog(@"!!!!! OSMemoryNotificationLevelCritical") ;
			break;
		default:
			break;
	}
}
	
- (void) printResponseError: (NSInteger) aResponseError {
	switch (aResponseError) {
		case 0:
			NSLog(@"!!!!! SUSCESS TO GET NOTIFICATION");
			break;
		case EINVAL:
			NSLog(@"!!!!! Snotification object is invalid");
			break;
		case ETIMEDOUT:
			NSLog(@"!!!!! abstime passes before notification occurs");
			break;
		default:
			break;
	}	
}
	
- (void) dealloc {
	OSMemoryNotificationDestroy(mMemoryNotification);
	[super dealloc];
}

@end
