/** 
 - Project name: AppAgent
 - Class name: AppAgentManager
 - Version: 1.0
 - Purpose: 
 - Copy right: 27/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

@protocol EventDelegate;

@class MemoryWarningAgent;
@class DiskSpaceWarningAgent;
@class ExceptionHandleAgent;
@class SystemPowerHandleAgent;
@class BatteryMonitor;

@interface AppAgentManager : NSObject {
	id <EventDelegate>		mEventDelegate;

	// -- MEMORY
	MemoryWarningAgent		*mMemoryWarningAgent;
	BOOL		             mListeningMemoryWarning;
	
	// -- DISK SPACE
	DiskSpaceWarningAgent	*mDiskSpaceWarningAgent;
	BOOL					mListeningDiskSpaceWarning;
	
	// -- EXCEPTION
	ExceptionHandleAgent	*mExceptionHandleAgent;
	BOOL					mListeningException;
	
	// -- SYSTEM POWER
	SystemPowerHandleAgent	*mSystemPowerHandleAgent;
	BOOL					mListeningSystemPowerCallback;
	
	// -- BATTERY
	BatteryMonitor			*mBatteryMonitor;
	BOOL					mListeningBatteryLevelWarning;
}


- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;

// -- MEMORY
- (void) startListenMemoryWarningLevel;
- (void) stopListenMemoryWarningLevel;

// -- DISK SPACE
- (void) startListenDiskSpaceWarningLevel;
- (void) stopListenDiskSpaceWarningLevel;
- (BOOL) setThresholdInMegabyteForDiskSpaceCriticalLevel: (uint64_t) aValue;
- (BOOL) setThresholdInMegabyteForDiskSpaceUrgentLevel: (uint64_t) aValue;
- (BOOL) setThresholdInMegabyteForDiskSpaceWarningLevel: (uint64_t) aValue;

// -- UNCAUGHT EXCEPTION
- (void) startHandleUncaughtException;
- (void) stopHandleUncaughtException;

// -- SYSTEM POWER
- (void) startListenSystemPowerAndWakeIphone;
- (void) stopListenSystemPowerAndWakeIphone;

// -- BATTERY
- (void) startListenBatteryWarningLevel;
- (void) stopListenBatteryWarningLevel;

@end
