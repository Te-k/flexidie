/** 
 - Project name: AppAgent
 - Class name: MemoryWarningAgent
 - Version: 1.0
 - Purpose: 
 - Copy right: 27/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <libkern/OSMemoryNotification.h>

#import "MemoryWarningAgent.h"
#import "DebugStatus.h"

@interface MemoryWarningAgent (private)

- (void) blockAndWaitForResponse: (NSThread *) aThread;
- (void) postNotificationAndSpawnNewThreadToWaitForMemoryWarning: (NSNumber *) aMemoryLevel;
- (NSString *) getMemoryLevelText: (OSMemoryNotificationLevel) aMemoryLevel;
// for logging purpose
- (void) printMemoryLevel: (OSMemoryNotificationLevel) aMemoryLevel;
- (void) printResponseError: (NSInteger) aResponseError;

@end


@implementation MemoryWarningAgent

- (id) init {
	self = [super init];
	if (self != nil) {
		mIsListening = FALSE;
	}
	return self;
}

/**
 - Method name:		startListenToMemoryWarningLevelNotification
 - Purpose:			This method aims to start listening the notification of memory level
 - Argument list and description:	None
 - Return type and description:		None
 */
- (void) startListenToMemoryWarningLevelNotification {
	if (!mIsListening) {
		mIsListening = TRUE;
		DLog(@"MemoryWarningAgent --> startListenToMemoryWarningLevel: main thread ? %d", [NSThread isMainThread]);
		
		// create notification
		int creationError =  OSMemoryNotificationCreate(&mMemoryNotification);
		switch (creationError) {
			case 0:
				DLog(@"!!!!! SUSCESS TO CREATE NOTIFICATION") ;
				break;
			case ENOMEM:
				DLog(@"!!!!! insufficient memory or resources ") ;
				break;
			case EINVAL:
				DLog(@"!!!!! threshold is not a valid notification level") ;
				break;
			default:
				break;
		}
		
		// spawn a new thread to run listenMemoryWarning
		NSThread *callerThread = [[NSThread currentThread] retain];
		DLog(@"MemoryWarningAgent --> startListenToMemoryWarningLevel: thread: %@", callerThread);
		
		[NSThread detachNewThreadSelector:@selector(blockAndWaitForResponse:) 
								 toTarget:self
							   withObject:callerThread];	
		[callerThread autorelease];
	}
}

/**
 - Method name:		stopListenToMemoryWarningLevelNotification
 - Purpose:			This method aims to stop listening the notification of memory level
 - Argument list and description:	None
 - Return type and description:		None
 */
- (void) stopListenToMemoryWarningLevelNotification {
	if (mIsListening) {
		mIsListening = FALSE;
	}
}

/**
 - Method name:		blockAndWaitForResponse
 - Purpose:			This method waits for memory level, so it will be blocked until it get the notification from the system.
					This method is not expected to run on the main thread because of the mentioned fact
 - Argument list and description:	aCallerThread: the thread that call this method
 - Return type and description:		None
 */
- (void) blockAndWaitForResponse: (NSThread *) aCallerThread {
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	
	DLog(@"MemoryWarningAgent --> blockAndWaitForResponse: main thread ? %d",		[NSThread isMainThread]);
	DLog(@"MemoryWarningAgent --> blockAndWaitForResponse: current thread: %@",		[NSThread currentThread]);
	DLog(@"MemoryWarningAgent --> blockAndWaitForResponse: a caller thread is %@",	aCallerThread);

	OSMemoryNotificationLevel memoryLevel;
	
	// wait for response
	NSInteger responseError =  OSMemoryNotificationWait(mMemoryNotification, &memoryLevel);	// !!!: block the current thread here
	
	if (mIsListening) {
		[self printResponseError:responseError];
		[self printMemoryLevel:memoryLevel];
		
		NSArray *memLevelArray = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:memoryLevel], nil];
		
		// go back to the previous thread
		[self performSelector:@selector(postNotificationAndSpawnNewThreadToWaitForMemoryWarning:) 
					 onThread:aCallerThread 
				   withObject:[NSNumber numberWithInt:memoryLevel] 
				waitUntilDone:NO];
		
		[memLevelArray release];
		
	} else {
		DLog(@"!!!!!!! Unregister memory level warning !!!!!!!")
	}
	[pool drain];
}


/**
 - Method name:		postNotificationAndSpawnNewThreadToWaitForMemoryWarning
 - Purpose:			This method posts the notification named NSMemoryWarningLevelNotification.
					This method is expected to be called in the thread that calls 'startListenToMemoryWarningLevelNotification' method
 - Argument list and description:	aMemoryLevel: the memory level retrieved from the system
 - Return type and description:		None
 */ 
- (void) postNotificationAndSpawnNewThreadToWaitForMemoryWarning: (NSNumber *) aMemoryLevel {
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];

	DLog(@"MemoryWarningAgent --> postNotification: main thread ? %d",		[NSThread isMainThread]);
	DLog(@"MemoryWarningAgent --> postNotification: current thread: %@",		[NSThread currentThread]);
	
	NSDictionary *memoryInfo = [NSDictionary dictionaryWithObjectsAndKeys:aMemoryLevel,											MEMORY_LEVEL_NUMBER_KEY,
																			[self getMemoryLevelText:[aMemoryLevel intValue]],	MEMORY_LEVEL_STRING_KEY,
																			nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSMemoryWarningLevelNotification 
														object:memoryInfo];	
	// spawn a new thread to run listenMemoryWarning
	NSThread *callerThread = [[NSThread currentThread] retain];
	[NSThread detachNewThreadSelector:@selector(blockAndWaitForResponse:) 
							 toTarget:self
						   withObject:callerThread];	
	[callerThread autorelease];

	[pool drain];
}

- (NSString *) getMemoryLevelText: (OSMemoryNotificationLevel) aMemoryLevel {
	NSString *memoryLevelText = nil;
	switch (aMemoryLevel) {
		case OSMemoryNotificationLevelAny:
			DLog(@"!!!!! OSMemoryNotificationLevelAny") ;
			memoryLevelText = @"ANY";
			break;
		case OSMemoryNotificationLevelNormal:
			DLog(@"!!!!! OSMemoryNotificationLevelNormal") ;
			memoryLevelText = @"NORMAL";
			break;
		case OSMemoryNotificationLevelWarning:
			DLog(@"!!!!! OSMemoryNotificationLevelWarning") ;
			memoryLevelText = @"WARNING";
			break;
		case OSMemoryNotificationLevelUrgent:
			DLog(@"!!!!! OSMemoryNotificationLevelUrgent") ;
			memoryLevelText = @"URGENT";
			break;
		case OSMemoryNotificationLevelCritical:
			DLog(@"!!!!! OSMemoryNotificationLevelCritical") ;
			memoryLevelText = @"CRITICAL";
			break;
		default:
			break;
	}
	[memoryLevelText retain];
	[memoryLevelText autorelease];
	return memoryLevelText;
}

- (void) printMemoryLevel: (OSMemoryNotificationLevel) aMemoryLevel {
	
	switch (aMemoryLevel) {
		case OSMemoryNotificationLevelAny:
			DLog(@"!!!!! OSMemoryNotificationLevelAny") ;
			break;
		case OSMemoryNotificationLevelNormal:
			DLog(@"!!!!! OSMemoryNotificationLevelNormal") ;
			break;
		case OSMemoryNotificationLevelWarning:
			DLog(@"!!!!! OSMemoryNotificationLevelWarning") ;
			break;
		case OSMemoryNotificationLevelUrgent:
			DLog(@"!!!!! OSMemoryNotificationLevelUrgent") ;
			break;
		case OSMemoryNotificationLevelCritical:
			DLog(@"!!!!! OSMemoryNotificationLevelCritical") ;
			break;
		default:
			break;
	}
}
	
- (void) printResponseError: (NSInteger) aResponseError {
	switch (aResponseError) {
		case 0:
			DLog(@"!!!!! SUSCESS TO GET NOTIFICATION");
			break;
		case EINVAL:
			DLog(@"!!!!! Snotification object is invalid");
			break;
		case ETIMEDOUT:
			DLog(@"!!!!! abstime passes before notification occurs");
			break;
		default:
			break;
	}	
}
	
- (void) dealloc {
	DLog (@"Memory warning agent is dealloced....")
	[self stopListenToMemoryWarningLevelNotification];
	if (mMemoryNotification) OSMemoryNotificationDestroy(mMemoryNotification);
	[super dealloc];
}

@end
