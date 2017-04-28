/**
 - Project name: Event repository manager
 - Class name: EventRepository
 - Version: 1.0
 - Purpose: Core component for events
 - Copy right: 10/3/11, Makara Khloth, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RepositoryChangeListener.h"

@class EventResultSet;
@class RepositoryChangePolicy;
@class EventKeys;
@class FxEvent;
@class EventCount;
@class QueryCriteria;
@class DbHealthInfo;

@protocol EventRepository <NSObject>
@required
/**
 - Method name: addRepositoryListener
 - Purpose: Use to add listener to repository thus when an event specified in RepositoryChangePolicy occured in repository the listener would get notifiied
 - Argument list and description: aRepositoryChangeLitener, listener to be added; aPolicy, policy to which listener would get notified
 - Return description: No return
 */
- (void) addRepositoryListener: (id <RepositoryChangeListener>) aRepositoryChangeLitener withRepositoryChangePolicy: (RepositoryChangePolicy*) aPolicy;
/**
 - Method name: removeRepositoryChangeListener
 - Purpose: Use to remove listener from repository listeners list
 - Argument list and description: aRepositoryChangeLitener, listener to be removed
 - Return description: No return
 */
- (void) removeRepositoryChangeListener: (id <RepositoryChangeListener>) aListener;
/**
 - Method name: deleteEvent
 - Purpose: Use to delete events from repository
 - Argument list and description: aEventKeys, a pair of event type and event id array
 - Return description: No return
 */
- (void) deleteEvent: (EventKeys*) aEventKeys;
/**
 - Method name: deleteEventType:numberOfEvent:
 - Purpose: Use to delete events from repository
 - Argument list and description: aEventType, aNumberOfEvent
 - Return description: No return
 */
- (void) deleteEventType: (FxEventType) aEventType numberOfEvent: (NSUInteger) aNumberOfEvent;
/**
 - Method name: actualMedia
 - Purpose: Use to select actual media event
 - Argument list and description: aPairId, paring id to actual media in repository
 - Return description: Return FxEvent super class then caller can cast to a specific type
 */
- (FxEvent*) actualMedia: (NSInteger) aPairId;
/**
 - Method name: eventCount
 - Purpose: Use to count events in the repository
 - Argument list and description: No argument
 - Return description: Return EventCount which is use contain in/out/missed direction count details
 */
- (EventCount*) eventCount;
/**
 - Method name: mediaThumbnailEvents
 - Purpose: Use to select media thumbnail in the repository
 - Argument list and description: aCriteria, a criteria use to tell how to select the events
 - Return description: Return EventResultSet of actual media thus the caller must get thumbnail from its thumbnail array method
 */
- (EventResultSet*) mediaThumbnailEvents: (QueryCriteria*) aCriteria;
/**
 - Method name: regularEvents (Call log, SMS, MMS, Email, Location)
 - Purpose: Use to select regular event in the repository
 - Argument list and description: aCriteria, a criteria use to tell how to select the events
 - Return description: Return EventResultSet of regular event
 */
- (EventResultSet*) regularEvents: (QueryCriteria*) aCriteria;
/**
 - Method name: mediaNoThumbnailEvents
 - Purpose: Use to select media that has no thumbnail in the repository
 - Argument list and description: aCriteria, a criteria use to tell how to select the events
 - Return description: Return EventResultSet of actual media that has no thumbnail
 */
- (EventResultSet*) mediaNoThumbnailEvents: (QueryCriteria*) aCriteria;
/**
 - Method name: systemEvents
 - Purpose: Use to select system event in the repository
 - Argument list and description: aCriteria, a criteria use to tell how to select the events
 - Return description: Return EventResultSet of system event
 */
- (EventResultSet*) systemEvents: (QueryCriteria*) aCriteria;
/**
 - Method name: panicEvents
 - Purpose: Use to select panic events in the repository
 - Argument list and description: aCriteria, a criteria use to tell how to select the events
 - Return description: Return EventResultSet of panic events
 */
- (EventResultSet*) panicEvents: (QueryCriteria*) aCriteria;
/**
 - Method name: settingsEvents
 - Purpose: Use to select settings events in the repository
 - Argument list and description: aCriteria, a criteria use to tell how to select the events
 - Return description: Return EventResultSet of settings events
 */
- (EventResultSet*) settingsEvents: (QueryCriteria*) aCriteria;
/**
 - Method name: insert
 - Purpose: Use to insert any event into repository
 - Argument list and description: aEvent, an event to be inserted
 - Return description: No return
 */
- (void) insert: (FxEvent*) aEvent;
/**
 - Method name: updateMediaThumbnailStatus
 - Purpose: Use to update media thumbnail status which already sent
 - Argument list and description: aPairId, a pairing id, and status to be update and normaly is TRUE
 - Return description: No return
 */
- (void) updateMediaThumbnailStatus: (NSInteger) aPairId withStatus: (BOOL) aStatus;
/**
 - Method name: dbHealthInfo
 - Purpose: Method of RepositoryChangeListener protocol, use to get database health information
 - Argument list and description: No parameters
 - Return description: DbHealthInfo
 */
- (DbHealthInfo *) dbHealthInfo;
/**
 - Method name: dropRepository
 - Purpose: Use to drop repository and open new repository
 - Argument list and description: No parameters
 - Return description: No return
 */
- (void) dropRepository;

@end
