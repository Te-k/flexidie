//
//  DatabaseOperationAssistant.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DatabaseManager;
@class EventKeys;
@class FxEvent;
@class EventCount;
@class EventResultSet;
@class QueryCriteria;
@class DbHealthInfo;
@class EventQueryPriority;

@interface DatabaseOperationAssistant : NSObject {
@private
	DatabaseManager*	mDatabaseManager; // Not own
	EventQueryPriority*	mEventQueryPriority; // Not own
	DbHealthInfo*	mDbHealthInfo;
}

@property (nonatomic, readonly) DbHealthInfo* mDbHealthInfo;

- (id) initWithDatabaseManager: (DatabaseManager*) aDBManager andEventQueryPriority: (EventQueryPriority*) aQueryPriority;

- (void) deleteEvent: (EventKeys*) aEventKeys;
- (FxEvent*) actualMedia: (NSInteger) aPairId;
- (EventCount*) eventCount;
- (EventResultSet*) mediaThumbnailEvents: (QueryCriteria*) aCriteria;
- (EventResultSet*) regularEvents: (QueryCriteria*) aCriteria;
- (EventResultSet*) mediaNoThumbnailEvents: (QueryCriteria*) aCriteria;
- (void) insert: (FxEvent*) aEvent;
- (void) updateMediaThumbnailStatus: (NSInteger) aPairId withStatus: (BOOL) aStatus;
- (NSInteger) countTotalEvent;

@end
