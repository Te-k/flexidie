/** 
 - Project name: AppAgent
 - Class name: AppAgentManager
 - Version: 1.0
 - Purpose: 
 - Copy right: 27/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "AppAgentManager.h"

#import "EventDelegate.h"
#import "FxSystemEvent.h"
#import "FxEventEnums.h"
#import "DateTimeFormat.h"
#import "MemoryWarningAgent.h"
#import "MemoryWarningAgentV2.h"
#import "DiskSpaceWarningAgent.h"
#import "DebugStatus.h"
#import "ExceptionHandleAgent.h"
#import "SystemPowerHandleAgent.h"
#import "BatteryMonitor.h"

@interface AppAgentManager (PrivateAPI)

- (void)		sendSystemEventForLowMemory: (NSString *) aMemoryLevelText;
- (void)		sendSystemEventForLowDiskSpace: (NSString *) aDiskspaceLevelText;
- (void)		sendSystemEventForBatteryLevel: (NSString *) aBatteryStatusText;

- (void)		sendSystemEventFor: (FxSystemEventType) aEventType message: (NSString *) aMessage;

- (void)		memoryWarningDidReceived: (NSNotification *) aNotification;
- (void)		diskSpaceWarningDidReceived: (NSNotification *) aNotification;
- (void)		exceptionNotificationReceived: (NSNotification *) aNotification;

@end


@implementation AppAgentManager


/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the AppAgentManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
 */

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		// Memory
		mMemoryWarningAgent = [[MemoryWarningAgent alloc] init];
        //mMemoryWarningAgent = [[MemoryWarningAgentV2 alloc] init];
		mListeningMemoryWarning = FALSE;
		
		// Disk space
		mDiskSpaceWarningAgent = [[DiskSpaceWarningAgent alloc] init];
		mListeningDiskSpaceWarning = FALSE;
		
		// Signal/Exception
		// note that we need to register this notification before the init of mExceptionHandleAgent because
		// the init method of mExceptionHandleAgent will post notification to check if there is a previous crash or not
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(exceptionNotificationReceived:)
													 name:CRASH_REPORT_NOTIFICATION 
												   object:nil]; 
		mExceptionHandleAgent = [[ExceptionHandleAgent alloc] init];
		mListeningException = FALSE;

		
		// System power
		mSystemPowerHandleAgent = [[SystemPowerHandleAgent alloc] init];
		mListeningSystemPowerCallback = FALSE;
		mEventDelegate = aEventDelegate;
		
		// Battery
		mBatteryMonitor = [[BatteryMonitor alloc] init];
		mListeningBatteryLevelWarning = FALSE;
	}
	return self;
}


#pragma mark -
#pragma mark Memory



- (void) startListenMemoryWarningLevel {
	if (!mListeningMemoryWarning) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(memoryWarningDidReceived:) 
													 name:NSMemoryWarningLevelNotification 
												   object:nil];
		
		[mMemoryWarningAgent startListenToMemoryWarningLevelNotification];
		mListeningMemoryWarning = TRUE;
	}		
}

- (void) stopListenMemoryWarningLevel {
	if (mListeningMemoryWarning) {
		[mMemoryWarningAgent stopListenToMemoryWarningLevelNotification];
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:NSMemoryWarningLevelNotification 
													  object:nil];
		mListeningMemoryWarning = FALSE;
	}
}

- (void) memoryWarningDidReceived: (NSNotification *) aNotification {
	//DLog(@"AppAgentManager --> memoryWarningDidReceived: main thread ? %d", [NSThread isMainThread]);
	//DLog(@"AppAgentManager --> memoryWarningDidReceived: !!!!! MEMORY WARNNING LEVEL: %@ !!!!! ", [aNotification object]);
	
	NSDictionary *memoryInfo = (NSDictionary *)[aNotification object];
	NSString *memoryLevelText = [memoryInfo objectForKey:MEMORY_LEVEL_STRING_KEY];
	[self sendSystemEventForLowMemory:memoryLevelText];
}

- (void) sendSystemEventForLowMemory: (NSString *) aMemoryLevelText {
	// Specification is changed not create system event in case of create thumbnail fialed
//	[self sendSystemEventFor:kSystemEventTypeMemoryInfo
//					 message:[NSString stringWithFormat:@"%@%@", @"Memory level: ", aMemoryLevelText]];
}


#pragma mark -
#pragma mark Disk Space


- (void) startListenDiskSpaceWarningLevel {
	//DLog(@"startListenDiskSpaceWarningLevel")
	if (!mListeningDiskSpaceWarning) {		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(diskSpaceWarningDidReceived:) 
													 name:NSDiskSpaceWarningLevelNotification 
												   object:nil];
		[mDiskSpaceWarningAgent startListenToDiskSpaceWarningLevelNotification];
		mListeningDiskSpaceWarning = TRUE;
	}		
}

- (void) stopListenDiskSpaceWarningLevel {
	if (mListeningDiskSpaceWarning) {
		[mDiskSpaceWarningAgent stopListenToDiskSpaceWarningLevelNotification];
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:NSDiskSpaceWarningLevelNotification 
													  object:nil];
		mListeningDiskSpaceWarning = FALSE;
	}
}

- (void) diskSpaceWarningDidReceived: (NSNotification *) aNotification {
	//DLog(@"AppAgentManager --> diskSpaceWarningDidReceived: main thread ? %d", [NSThread isMainThread]);
	//DLog(@"AppAgentManager --> diskSpaceWarningDidReceived: !!!!! DISK SPACE WARNNING LEVEL: %@ !!!!! ", [aNotification object]);
	
	NSDictionary *diskspaceInfo = (NSDictionary *)[aNotification object];
	NSString *diskspaceLevelText = [diskspaceInfo objectForKey:DISK_SPACE_LEVEL_STRING_KEY];
	[self sendSystemEventForLowDiskSpace:diskspaceLevelText];
}

- (void) sendSystemEventForLowDiskSpace: (NSString *) aDiskspaceLevelText {	
	[self sendSystemEventFor:kSystemEventTypeDiskInfo
					 message:[NSString stringWithFormat:@"%@%@", @"Disk space level: ", aDiskspaceLevelText]];
}

- (BOOL) setThresholdInMegabyteForDiskSpaceCriticalLevel: (uint64_t) aValue {
	return [mDiskSpaceWarningAgent setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelCritical valueInMegaByte:aValue];
}

- (BOOL) setThresholdInMegabyteForDiskSpaceUrgentLevel: (uint64_t) aValue {
	return [mDiskSpaceWarningAgent setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelUrgent valueInMegaByte:aValue];
}

- (BOOL) setThresholdInMegabyteForDiskSpaceWarningLevel: (uint64_t) aValue {
	return [mDiskSpaceWarningAgent setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelWarning valueInMegaByte:aValue];
}


#pragma mark -
#pragma mark Exception handler

- (void) startHandleUncaughtException {
	if (!mListeningException) {
		[mExceptionHandleAgent installExceptionHandler];
	}

}

- (void) stopHandleUncaughtException {
	if (mListeningException) {
		[mExceptionHandleAgent uninstallExceptionHandler];
	}
}

- (void) exceptionNotificationReceived: (NSNotification *) aNotification {
	//DLog(@"AppAgentManager --> exceptionNotificationReceived: >>>>>>>>>>>>>>>>>> %@ <<<<<<<<<<<<<<<<<<<<< ", [aNotification object]);
	
	NSDictionary *crashInfo = (NSDictionary *)[aNotification object];
	NSNumber *crashType = [crashInfo objectForKey:CRASH_TYPE_KEY];
	NSString *log = [crashInfo objectForKey:CRASH_REPORT_KEY];
	
	if ([crashType integerValue] == CRASH_TYPE_EXCEPTION) {
		[self sendSystemEventFor:kSystemEventTypeAppCrash message:log];
	} else if ([crashType integerValue] == CRASH_TYPE_SIGNAL) {
		[self sendSystemEventFor:kSystemEventTypeAppCrash message:log];
	}
}


#pragma mark -
#pragma mark System Power

- (void) startListenSystemPowerAndWakeIphone {
	//DLog(@"startListenSystemPowerAndWakeIphone")
	if (!mListeningSystemPowerCallback) {		
		[mSystemPowerHandleAgent start];
		mListeningDiskSpaceWarning = TRUE;
	}		
}

- (void) stopListenSystemPowerAndWakeIphone {
	if (mListeningSystemPowerCallback) {
		[mSystemPowerHandleAgent stop];
		mListeningSystemPowerCallback = FALSE;
	}
}


#pragma mark -
#pragma mark Battery 

- (void) startListenBatteryWarningLevel {
	if (!mListeningBatteryLevelWarning) {	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(batteryLevelWarningDidReceived:) 
													 name:BATTERY_LEVEL_NOTIFICATION 
												   object:nil];
		
		[mBatteryMonitor startMonotorBatteryLevelNotification];
		mListeningBatteryLevelWarning = TRUE;
	}		
	
}

- (void) stopListenBatteryWarningLevel {
	if (mListeningBatteryLevelWarning) {		
		[mBatteryMonitor stopMonotorBatteryLevelNotification];
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:BATTERY_LEVEL_NOTIFICATION 
													  object:nil];
		
		mListeningBatteryLevelWarning = FALSE;
	}	
}


- (void) batteryLevelWarningDidReceived: (NSNotification *) aNotification {
	DLog(@"AppAgentManager --> batteryLevelWarningDidReceived: main thread ? %d", [NSThread isMainThread]);
	DLog(@"AppAgentManager --> batteryLevelWarningDidReceived: !!!!! BATTERY LEVEL: %@ !!!!! ", aNotification);
	
	NSDictionary *batteryInfo = (NSDictionary *)[aNotification object];
	NSString *batteryStatusText = [batteryInfo objectForKey:BATTERY_MESSAGE];
	[self sendSystemEventForBatteryLevel:batteryStatusText];
}

- (void) sendSystemEventForBatteryLevel: (NSString *) aBatteryStatusText {	
	[self sendSystemEventFor:kSystemEventTypeBatteryInfo
					 message:aBatteryStatusText];
}


#pragma mark -
#pragma mark System Event


- (void) sendSystemEventFor: (FxSystemEventType) aEventType message: (NSString *) aMessage {
	DLog(@"sending system event")
	FxSystemEvent *systemEvent = [[FxSystemEvent alloc] init];
	[systemEvent setMessage:[NSString stringWithString:aMessage]];
	[systemEvent setDirection:kEventDirectionOut];
	[systemEvent setSystemEventType:aEventType];
	[systemEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:systemEvent withObject:self];
	}
	[systemEvent release];
}

- (void) dealloc {
	DLog (@"Application agent manager is dealloced...");
	[self stopListenSystemPowerAndWakeIphone]; // To set flag to system power thread to exit otherwise it won't call dealloc
	[mSystemPowerHandleAgent release];
	mSystemPowerHandleAgent = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:CRASH_REPORT_NOTIFICATION 
												  object:nil];
	[self stopHandleUncaughtException];
	[mExceptionHandleAgent release];
	mExceptionHandleAgent = nil;
	
	[self stopListenMemoryWarningLevel];	// To signal thread to exit otherwise it won't call dealloc (MemoryWarningAgent)
	[mMemoryWarningAgent release];
	mMemoryWarningAgent = nil;
	
	[self stopListenDiskSpaceWarningLevel]; // To invalidate timer otherwise it won't call dealloc
	[mDiskSpaceWarningAgent release];
	mDiskSpaceWarningAgent = nil;
	
	[self stopListenBatteryWarningLevel];
	[mBatteryMonitor release];
	mBatteryMonitor = nil;
	[super dealloc];
}

@end
