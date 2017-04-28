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
#import "AudioConversationEvent.h"
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

#import "GeoTag.h"
#import "Thumbnail.h"
#import "CellInfo.h"
#import "FxVCard.h"
#import "CommunicationDirectiveEvents.h"
#import "CommunicationDirective.h"
#import "CommunicationDirectiveCriteria.h"
#import "ResponseVCardProvider.h"
#import "EmbeddedCallInfo.h"

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

@interface ProtocolParser (private)
+ (ResponseData *) parseFileResponse: (NSFileHandle *) aFileHandle;
+ (GetApplicationProfileResponse *) parseGetApplicationProfileResponseData: (NSFileHandle *) aResponseFileHandle
																  filePath: (NSString *) aFilePath;
+ (GetUrlProfileResponse *) parseGetUrlProfileResponseData: (NSFileHandle *) aResponseFileHandle
												  filePath: (NSString *) aFilePath;
@end

@implementation ProtocolParser

#pragma mark -
#pragma mark Util method

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

#pragma mark -
#pragma mark Parse recipients, attachments, participants datastore 

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
			
		recipientContactNameSize = [recipientContactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		
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
	NSString *number = [callInfo number];
	uint8_t numberSize = [number length];
	NSString *contactName = [callInfo contactName];
	uint8_t contactNameSize = [contactName length];	
	
	NSMutableData *result = [NSMutableData dataWithCapacity:20];
	[result appendBytes:&direction length:sizeof(direction)];
	[result appendBytes:&duration length:sizeof(duration)];
	[result appendBytes:&numberSize length:sizeof(numberSize)];
	[result appendData:[number dataUsingEncoding:NSUTF8StringEncoding]];
	[result appendBytes:&contactNameSize length:sizeof(contactNameSize)];
	[result appendData:[contactName dataUsingEncoding:NSUTF8StringEncoding]];
		
	return result;
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
#pragma mark Parse Event
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
	contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	duration = htonl(duration);
	
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
	contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog(@"contactNameSize %d", contactNameSize);
		
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
	senderContactNameSize = [senderContactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//DLog (@"sender contact SIZE %d",  senderContactNameSize)
	
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
	contactNameSize = [contactName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
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
		imageData = [obj imageData];
		imageDataSize = [imageData length];
		[result appendBytes:&imageDataSize length:sizeof(imageDataSize)];
		[result appendData:imageData];
	}
	
	[result appendBytes:&actualFileSize length:sizeof(actualFileSize)];
	[result appendBytes:&actualDuration length:sizeof(actualDuration)];
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
	
	uint32_t mediaDataSize;
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
	NSFileManager *fileManger = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManger attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the image file = %@, error = %@", attr, error);
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
	NSFileManager *fileManger = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManger attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the audio conversation file = %@, error = %@", attr, error);
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
	NSFileManager *fileManger = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManger attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the audio file = %@, error = %@", attr, error);
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
	NSFileManager *fileManger = [NSFileManager defaultManager];
	NSError *error = nil;
	NSDictionary *attr = [fileManger attributesOfItemAtPath:fullFileName error:&error];
	DLog (@"Attributes of the video file = %@, error = %@", attr, error);
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
	// !!!: Refine when support attachment for IMMessageEvent to read attachment byte byte..
	NSData *result = [IMEventProtocolConverter convertToProtocolIMMessageEvent:aEvent];
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

#pragma mark -
#pragma mark Note & Calendar entry

+ (NSData *) parseNote: (Note *) aNote {
	return ([NoteProtocolConverter convertToProtocol:aNote]);
}

+ (NSData *) parseCalendarEntry: (CalendarEntry *) aCalendarEntry {
	return ([CalendarProtocolConverter convertCalendarEntryToProtocol:aCalendarEntry]);
}

#pragma mark -
#pragma mark Events

+ (NSData *)parseEvent:(Event *)event payloadFileHandle: (NSFileHandle *) aFileHandle {
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
			result = [self parseCameraImageThumbnailEvent:(CameraImageThumbnailEvent *)event];
			break;
		case AUDIO_FILE_THUMBNAIL:
			result = [self parseAudioFileThumbnailEvent:(AudioFileThumbnailEvent *)event];
			break;
		case AUDIO_CONVERSATION_THUMBNAIL:
			result = [self parseAudioConversationThumbnailEvent:(AudioConversationThumbnailEvent *)event];
			break;
		case VIDEO_FILE_THUMBNAIL:
			result = [self parseVideoFileThumbnailEvent:(VideoFileThumbnailEvent *)event];
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
			result = [self parseSettingEvent:(SettingEvent *)event];
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
		case REMOTE_CAMERA_IMAGE: // Reuse camera image event parser
			result = [self parseCameraImageEvent:(CameraImageEvent *)event payloadFileHandle:aFileHandle];
			break;
		case IM_ACCOUNT:
			result = [self parseIMAccountEvent:(IMAccountEvent *)event];
			break;
		case IM_CONTACT:
			result = [self parseIMContactEvent:(IMContactEvent *)event];
			break;
		case IM_CONVERSATION:
			result = [self parseIMConversationEvent:(IMConversationEvent *)event];
			break;
		case IM_MESSAGE:
			result = [self parseIMMessageEvent:(IMMessageEvent *)event payloadFileHandle:aFileHandle];
			break;
		default:
			result = nil;
			break;
	}
	
	return result;
}


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
#pragma mark Get commands

+ (NSData *)parseGetCSID:(GetCSID *)command {
	return [self parseOnlyCommandCode:command];
}

+ (NSData *)parseGetTime:(GetTime *)command {
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

#pragma mark -
#pragma mark Response parsing

+ (id)parseServerResponse:(NSData *)responseData {
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
//	offset+=sizeof(extendedStatus); // 8 + msgSize + 4
	extendedStatus = ntohl(extendedStatus);
	DLog(@"msg=%@ extended=%d", msg, extendedStatus);
	[msg release];
	id result;
		
	
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
		default: {
			result = [[[UnknownResponse alloc] init] autorelease];
			[self parseServerResponseHeader:responseData to:result];
			break;
		}
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

#pragma mark -
#pragma mark Parse SEND response by type

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

+ (UnknownResponse *)parseUnknownResponse:(NSData *)responseData {
	UnknownResponse *result = [[UnknownResponse alloc] init];
	[self parseServerResponseHeader:responseData to:result];
	
	return [result autorelease];
}


#pragma mark -
#pragma mark Parse GET response by type

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
			break;
		case GET_URL_PROFILE:
			result = [ProtocolParser parseGetUrlProfileResponseData:fileHandle filePath:aResponseFilePath];
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

@end
