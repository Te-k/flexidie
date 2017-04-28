//
//  DiskSpaceWarningAgent.h
//  AppAgent
//
//  Created by Benjawan Tanarattanakorn on 4/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define NSDiskSpaceWarningLevelNotification				@"NSDiskSpaceWarningLevelNotification"

#define DISK_SPACE_LEVEL_NUMBER_KEY		@"DiskSpaceLevelNumber"
#define DISK_SPACE_LEVEL_STRING_KEY		@"DiskSpaceLevelString"

typedef enum {
	DiskSpaceNotificationLevelAny		= -1,
	DiskSpaceNotificationLevelNormal	=  0,		
	DiskSpaceNotificationLevelWarning	=  1,
	DiskSpaceNotificationLevelUrgent	=  2,
	DiskSpaceNotificationLevelCritical	=  3,
} DiskSpaceNotificationLevel;


@interface DiskSpaceWarningAgent : NSObject {
@private
	BOOL						mIsListening;
	
	// disk space threshold (in megabyte)
	uint64_t					mWarningDiskSpaceThreshold;
	uint64_t					mUrgentDiskSpaceThreshold;
	uint64_t					mCriticalDiskSpaceThreshold;
}


- (void) startListenToDiskSpaceWarningLevelNotification;
- (void) stopListenToDiskSpaceWarningLevelNotification;

- (BOOL) setDiskSpaceThresholdForLevel: (DiskSpaceNotificationLevel) aDiskSpaceLevel
					   valueInMegaByte: (uint64_t) aValue;

@end
