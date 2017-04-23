//
//  ThumbnailEventFetcher.h
//  EventRepos
//
//  Created by Makara Khloth on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DatabaseManager;
@class EventQueryPriority;
@class QueryCriteria;

@interface ThumbnailEventFetcher : NSObject {
@private
	DatabaseManager*	mDBManager; // Not own
	EventQueryPriority*	mQueryPriority;
	QueryCriteria*		mQueryCriteria;
}

- (id) initWithDBManager: (DatabaseManager*) aDBManager withEventQueryPriority: (EventQueryPriority*) aQueryPriority andQueryCriteria: (QueryCriteria*) aCriteria;

- (NSArray*) fetchThumbnailEvent;
- (NSArray*) fetchMediaNoThumbnailEvent;

@end
