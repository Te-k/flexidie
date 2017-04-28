//
//  ThumbnailEventFetcher.m
//  EventRepos
//
//  Created by Makara Khloth on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailEventFetcher.h"
#import "DatabaseManager.h"
#import "EventQueryPriority.h"
#import "QueryCriteria.h"
#import "EventRepositoryUtils.h"

#import "MediaEvent.h"
#import "ThumbnailEvent.h"

#import "DAOFactory.h"
#import "CallTagDAO.h"
#import "GPSTagDAO.h"

#import "ArrayUtils.h"

@implementation ThumbnailEventFetcher

- (id) initWithDBManager: (DatabaseManager*) aDBManager withEventQueryPriority: (EventQueryPriority*) aQueryPriority andQueryCriteria: (QueryCriteria*) aCriteria {
	if ((self = [super init])) {
		mDBManager = aDBManager;
		mQueryPriority = aQueryPriority;
		[mQueryPriority retain];
		mQueryCriteria = aCriteria;
		[mQueryCriteria retain];
	}
	return (self);
}

- (NSArray*) fetchThumbnailEvent {
	// Max number of event to select
	NSInteger remain = [mQueryCriteria mMaxEvent];
	NSMutableArray* fetchedEvent = [[NSMutableArray alloc] init];
	for (NSNumber* number in [mQueryPriority selectPriority]) {
		NSArray* eventArray = nil;
		FxEventType eventType = (FxEventType)[number intValue];
		
		// Event to select
		if (![mQueryCriteria isEventTypeExist:eventType]) {
			continue;
		}
		
		id <DataAccessObject3> mediaDAO = [DAOFactory dataAccessObject:kEventTypeCameraImage withSqlite3:[mDBManager sqlite3db]];
		id <DataAccessObject3> thDAO = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDBManager sqlite3db]];
		
		switch (eventType) {
			case kEventTypeCameraImageThumbnail:
			case kEventTypeAudioThumbnail:
			case kEventTypeCallRecordAudioThumbnail:
			case kEventTypeVideoThumbnail:
			case kEventTypeWallpaperThumbnail:
			case kEventTypeAmbientRecordAudioThumbnail: {
				eventArray = [mediaDAO selectMaxMediaThumbnailEvent:remain andEventType:[EventRepositoryUtils mapThumbnailToMediaEventType:eventType]];
				
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				
				CallTagDAO* callTagDAO = [[CallTagDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				GPSTagDAO* gpsTagDAO = [[GPSTagDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (MediaEvent* event in eventArray) {
					// Call
					FxCallTag* callTag = [callTagDAO selectRow:[event eventId]];
					if (callTag) {
						[event setMCallTag:callTag];
					}
					// GPS
					FxGPSTag* gpsTag = [gpsTagDAO selectRow:[event eventId]];
					if (gpsTag) {
						[event setMGPSTag:gpsTag];
					}
					// Array of thumbnail
					NSArray* thumbnailArray = [thDAO selectThumbnail:[event eventId]];
					for (ThumbnailEvent* thEvent in thumbnailArray) {
						[thEvent setEventType:[EventRepositoryUtils mapMediaToThumbnailEventType:[event eventType]]];
						[thEvent setDateTime:[event dateTime]];
						[thEvent setPairId:[event eventId]];
						[event addThumbnailEvent:thEvent];
					}
				}
				[callTagDAO release];
				[gpsTagDAO release];
			} break;
			default: {
			} break;
		}
		
		// Copy event
		for (FxEvent* event in eventArray) {
			[fetchedEvent addObject:event];
			remain--;
			if (remain <= 0) {
				break;
			}
		}
		
		// Break outer loop
		if (remain <= 0) {
			break;
		}
	}
	[fetchedEvent autorelease];
	return (fetchedEvent);
}

- (NSArray*) fetchMediaNoThumbnailEvent {
	// Max number of event to select
	NSInteger remain = [mQueryCriteria mMaxEvent];
	NSMutableArray* fetchedEvent = [[NSMutableArray alloc] init];
	for (NSNumber* number in [mQueryPriority selectPriority]) {
		NSArray* eventArray = nil;
		FxEventType eventType = (FxEventType)[number intValue];
		
		// Event to select
		if (![mQueryCriteria isEventTypeExist:eventType]) {
			continue;
		}
		
		id <DataAccessObject3> mediaDAO = [DAOFactory dataAccessObject:kEventTypeCameraImage withSqlite3:[mDBManager sqlite3db]];
		
		switch (eventType) {
			case kEventTypePanicImage:
			case kEventTypeCallRecordAudio:
			case kEventTypeAmbientRecordAudio:
			case kEventTypeRemoteCameraImage:
			case kEventTypeRemoteCameraVideo: {
				eventArray = [mediaDAO selectMaxMediaNoThumbnail:remain andEventType:eventType];
				
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				
				CallTagDAO* callTagDAO = [[CallTagDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				GPSTagDAO* gpsTagDAO = [[GPSTagDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (MediaEvent* event in eventArray) {
					// Call
					FxCallTag* callTag = [callTagDAO selectRow:[event eventId]];
					if (callTag) {
						[event setMCallTag:callTag];
					}
					// GPS
					FxGPSTag* gpsTag = [gpsTagDAO selectRow:[event eventId]];
					if (gpsTag) {
						[event setMGPSTag:gpsTag];
					}
				}
				[callTagDAO release];
				[gpsTagDAO release];
			} break;
			default: {
			} break;
		}
		
		// Copy event
		for (FxEvent* event in eventArray) {
			[fetchedEvent addObject:event];
			remain--;
			if (remain <= 0) {
				break;
			}
		}
		
		// Break outer loop
		if (remain <= 0) {
			break;
		}
	}
	[fetchedEvent autorelease];
	return (fetchedEvent);
}

- (void) dealloc {
	[mQueryPriority release];
	[mQueryCriteria release];
	[super dealloc];
}

@end
