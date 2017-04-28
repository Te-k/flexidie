/**
 - Project name: Event repository manager
 - Class name: EventRepositoryManager
 - Version: 1.0
 - Purpose: Core component for events
 - Copy right: 10/3/11, Makara Khloth, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "EventRepository.h"

@class DatabaseManager;
@class EventQueryPriority;
@class RepositoryChangePolicyMapPool;
@class DatabaseOperationAssistant;
@class DbHealthInfo;

@interface EventRepositoryManager : NSObject <EventRepository> {
@private
	DatabaseManager*	mDatabaseManager;
	EventQueryPriority*	mEventQueryPriority;
	RepositoryChangePolicyMapPool*	mChangePolicyMapPool;
	DatabaseOperationAssistant*	mDBOperationAssistant;
	NSMutableArray*	mEventQueue;
	NSTimer*	mDBTimeInsertionScheduler;
	DbHealthInfo *mDBHealthInfo;
	
	NSInteger	mInsertTryCount;
}

@property (nonatomic, retain) DbHealthInfo *mDBHealthInfo;

- (id) initWithEventQueryPriority: (EventQueryPriority*) aQueryPriority;

- (void) openRepository;
- (void) closeRepository;
- (void) deleteRepository;

@end
