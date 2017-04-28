/** 
 - Project name: AppAgent
 - Class name: MemoryWarningAgent
 - Version: 1.0
 - Purpose: 
 - Copy right: 27/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>


#define NSMemoryWarningLevelNotification			@"NSMemoryWarningLevelNotification"

#define MEMORY_LEVEL_NUMBER_KEY		@"memoryLevelNumber"
#define MEMORY_LEVEL_STRING_KEY		@"memoryLevelString"

typedef struct _OSMemoryNotification *OSMemoryNotificationRef;


@interface MemoryWarningAgent : NSObject {
@private
	OSMemoryNotificationRef		mMemoryNotification;
	BOOL						mIsListening;
}

- (void) startListenToMemoryWarningLevelNotification;
- (void) stopListenToMemoryWarningLevelNotification;

@end
