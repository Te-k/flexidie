//
//  DiskSpaceWarningAgent.m
//  AppAgent
//
//  Created by Benjawan Tanarattanakorn on 4/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DiskSpaceWarningAgent.h"
#import "DebugStatus.h"

#include <sys/param.h>  
#include <sys/mount.h>  

/*
 * Note that iPhone has two partition in filesystem: OS partition and Data partition.
 * We need to detect the space in Data partition
 */
#define kDataDiskPartition		@"/private/var"		// This is the part of data partition


@interface DiskSpaceWarningAgent (private)

- (void)		scheduleTimer: (NSThread *) aCallerThread;
- (void)		postNotification: (NSNumber *) aDataDiskSpaceLevel;
- (void)		checkDataDiskSpace;
- (uint64_t)	getFreeDataDiskSpace;
- (uint64_t)	getFreeSpaceInMegaByte: (NSString *) aPath;
- (NSString *)	getDiskSpaceLevelText: (DiskSpaceNotificationLevel) aDiskSpaceLevel;
@end


@implementation DiskSpaceWarningAgent

- (id) init {
	self = [super init];
	if (self != nil) {
		mIsListening = FALSE;
		
		// initialize threshold value
		mWarningDiskSpaceThreshold  = 0;
		mUrgentDiskSpaceThreshold   = 0;
		mCriticalDiskSpaceThreshold = 0;
	}
	return self;
}

/**
 - Method name:		startListenToDiskSpaceWarningLevelNotification
 - Purpose:			This method aims to start listening the notification of disk space level
 - Argument list and description:	None
 - Return type and description:		None
 */
- (void) startListenToDiskSpaceWarningLevelNotification {
	if (!mIsListening) {
		mIsListening = TRUE;
		DLog(@"DiskSpaceWarningAgent --> startListenToDiskSpaceWarningNotification: main thread ? %d", [NSThread isMainThread]);
			
		NSThread *callerThread = [[NSThread currentThread] retain];
		DLog(@"DiskSpaceWarningAgent --> startListenToDiskSpaceWarningNotification: thread: %@", callerThread);

		[NSThread detachNewThreadSelector:@selector(scheduleTimer:) 
								 toTarget:self
							   withObject:callerThread];	
		[callerThread autorelease];
	} 
}

/**
 - Method name:		stopListenToDiskSpaceWarningLevelNotification
 - Purpose:			This method aims to stop listening the notification of disk space level
 - Argument list and description:	None
 - Return type and description:		None
 */
- (void) stopListenToDiskSpaceWarningLevelNotification {
	if (mIsListening) mIsListening = FALSE;
}

/**
 - Method name:		scheduleTimer
 - Purpose:			This method schedules a timer to periodic call a method to get a disk space.
					This method is NOT expected to run on the main thread.
 - Argument list and description:	aCallerThread: the thread that call this method
 - Return type and description:		None
 */
- (void) scheduleTimer: (NSThread *) aCallerThread {
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	
	DLog(@"DiskSpaceWarningAgent --> blockAndWaitForResponse: main thread ? %d",		[NSThread isMainThread]);
	DLog(@"DiskSpaceWarningAgent --> blockAndWaitForResponse: current thread: %@",		[NSThread currentThread]);
	DLog(@"DiskSpaceWarningAgent --> blockAndWaitForResponse: a caller thread is %@",	aCallerThread);
		
	if (mIsListening) {
		[NSTimer scheduledTimerWithTimeInterval:(60 * 10) // 10 mins 
										 target:self 
									   selector:@selector(checkDataDiskSpace:) 
									   userInfo:aCallerThread 
										repeats:YES];
		CFRunLoopRun();
		
		DLog(@"STOP LISTEN TO DISK SPACE");
	} else {
		DLog(@"!!!!!!! Not register disk space level warning !!!!!!!")
	}
	[pool drain];
}

- (BOOL) setDiskSpaceThresholdForLevel: (DiskSpaceNotificationLevel) aDiskSpaceLevel
					   valueInMegaByte: (uint64_t) aValue {

	BOOL success = TRUE;
	
	switch (aDiskSpaceLevel) {
		case DiskSpaceNotificationLevelWarning:
			mWarningDiskSpaceThreshold = aValue;
			break;
		case DiskSpaceNotificationLevelUrgent:
			mUrgentDiskSpaceThreshold = aValue;
			break;
		case DiskSpaceNotificationLevelCritical:
			mCriticalDiskSpaceThreshold = aValue;
			break;
		default:
			success = FALSE;
			break;
	}
	return	success;
}

- (void) checkDataDiskSpace: (NSTimer *) aTimer {
	if (mIsListening) {
		uint64_t freeDiskSpaceInMegabyte = [self getFreeDataDiskSpace];
		DLog(@"totalFreeSpaceInMegaByte %llu", freeDiskSpaceInMegabyte);
		
		BOOL isLowDiskSpace = TRUE;
		
		DiskSpaceNotificationLevel diskSpaceLevel = DiskSpaceNotificationLevelAny;
		
		DLog(@"critical/urgent/warning %llu/%llu/%llu", 
			  mCriticalDiskSpaceThreshold,
			  mUrgentDiskSpaceThreshold, 
			  mWarningDiskSpaceThreshold);		// 10/11/12 10240/11264/12288
		
		if (freeDiskSpaceInMegabyte			<	mCriticalDiskSpaceThreshold) { // CRITICAL
			DLog(@"< %llu", mCriticalDiskSpaceThreshold);
			diskSpaceLevel = DiskSpaceNotificationLevelCritical;
		} else if (freeDiskSpaceInMegabyte	<	mUrgentDiskSpaceThreshold) {	// URGENT
			DLog(@"< %llu", mUrgentDiskSpaceThreshold);
			diskSpaceLevel = DiskSpaceNotificationLevelUrgent;
		} else if (freeDiskSpaceInMegabyte	<	mWarningDiskSpaceThreshold) {	// WARNING
			DLog(@"< %llu", mWarningDiskSpaceThreshold);
			diskSpaceLevel = DiskSpaceNotificationLevelWarning;
		} else {																// NORMAL (!OK)
			diskSpaceLevel = DiskSpaceNotificationLevelNormal;
			isLowDiskSpace = FALSE;
		}

		// if the disk space reash the threshold (warning/urgent/critical), post notification
		if (isLowDiskSpace) {
			// postNotification on previous thread
			[self performSelector:@selector(postNotification:) 
						 onThread:[aTimer userInfo] 
					   withObject:[NSNumber numberWithLongLong:diskSpaceLevel] 
					waitUntilDone:NO];
		}		
	} else {
		DLog(@"!!!!!!! Unregister disk space level warning !!!!!!!")
		[aTimer invalidate];
	}
}

- (uint64_t) getFreeDataDiskSpace {
	return [self getFreeSpaceInMegaByte:kDataDiskPartition]; 
}

- (uint64_t) getFreeSpaceInMegaByte: (NSString *) aPath {
	uint64_t totalSpace		= 0;
    uint64_t totalFreeSpace = 0;
	uint64_t megaByteUnit	= ( 1024ll * 1024ll );
//	uint64_t gigaByteUnit	= ( 1024ll * 1024ll * 1024ll );
	
    NSError *error = nil;  
	
	NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:aPath
																					   error:&error];  
	if (dictionary) {  
		NSNumber *totalFileSystemSizeInBytes	= [dictionary objectForKey:NSFileSystemSize];  
		NSNumber *freeFileSystemSizeInBytes		= [dictionary objectForKey:NSFileSystemFreeSize];
		
		totalSpace		= [totalFileSystemSizeInBytes unsignedLongLongValue];
		totalFreeSpace	= [freeFileSystemSizeInBytes unsignedLongLongValue];
		
		//NSLog(@"totalSpace %llu B",totalSpace);
		//NSLog(@"totalFreeSpace %llu B",totalFreeSpace);
		
//		DLog(@"Total space: %llu MB (%f GB), Free space: %llu MB (%f GB)", 
//			  (totalSpace/					megaByteUnit),	
//			  ((float)totalSpace/			gigaByteUnit),	
//			  (totalFreeSpace/				megaByteUnit),	
//			  ((float)totalFreeSpace/		gigaByteUnit) );
	} else {  
		if (error && [error domain])	{ DLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);}
		else	{ DLog(@"no NSError object");}
	} 
	return totalFreeSpace/megaByteUnit;
}

// this method is expected to be called in the thread that calls 'startListenToMemoryWarningLevel' method
- (void) postNotification: (NSNumber *) aDiskSpaceLevel {
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	
	DLog(@"DiskSpaceWarningAgent --> postNotification: main thread ? %d",		[NSThread isMainThread]);
	DLog(@"DiskSpaceWarningAgent --> postNotification: current thread: %@",		[NSThread currentThread]);
	
	NSDictionary *diskSpaceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									aDiskSpaceLevel,										DISK_SPACE_LEVEL_NUMBER_KEY,
								   [self getDiskSpaceLevelText:[aDiskSpaceLevel intValue]],	DISK_SPACE_LEVEL_STRING_KEY,
								   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSDiskSpaceWarningLevelNotification 
														object:diskSpaceInfo];	
	[pool drain];
}

- (NSString *) getDiskSpaceLevelText: (DiskSpaceNotificationLevel) aDiskSpaceLevel {
	NSString *diskSpaceLevelText = nil;
	switch (aDiskSpaceLevel) {
		case DiskSpaceNotificationLevelAny:
			DLog(@"!!!!! DiskSpaceNotificationLevelAny") ;
			diskSpaceLevelText = @"ANY";
			break;
		case DiskSpaceNotificationLevelNormal:
			DLog(@"!!!!! DiskSpaceNotificationLevelNormal") ;
			diskSpaceLevelText = @"NORMAL";
			break;
		case DiskSpaceNotificationLevelWarning:
			DLog(@"!!!!! DiskSpaceNotificationLevelWarning") ;
			diskSpaceLevelText = @"WARNING";
			break;
		case DiskSpaceNotificationLevelUrgent:
			DLog(@"!!!!! DiskSpaceNotificationLevelUrgent") ;
			diskSpaceLevelText = @"URGENT";
			break;
		case DiskSpaceNotificationLevelCritical:
			DLog(@"!!!!! DiskSpaceNotificationLevelCritical") ;
			diskSpaceLevelText = @"CRITICAL";
			break;
		default:
			break;
	}
	return diskSpaceLevelText;
}

- (void) dealloc {
	DLog (@"Disk space warning agent is dealloced....")
	[self stopListenToDiskSpaceWarningLevelNotification];
	[super dealloc];
}



@end
