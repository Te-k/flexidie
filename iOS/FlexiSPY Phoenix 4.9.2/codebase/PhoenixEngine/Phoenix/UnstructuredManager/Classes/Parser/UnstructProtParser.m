//
//  UnstructProtParser.m
//  UnstructuredManager
//
//  Created by Pichaya Srifar on 7/20/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "UnstructProtParser.h"
#import "AESCryptor.h"

static unsigned short KEY_EXCHANGE_CMD_CODE = 100;
static unsigned short ACK_SEC_CMD_CODE = 101;
static unsigned short ACK_CMD_CODE = 102;
static unsigned short PING_CMD_CODE = 103;

static unsigned short UNSTRUCTURED_STATUSE_CODE_OK = 0;

@implementation UnstructProtParser

char get1_tail(){return 0xA;}
char get2_tail(){return 0x1E;}
char get3_tail(){return 0x99;}
char get4_tail(){return 0x7E;}
char get5_tail(){return 0xBC;}
char get6_tail(){return 0xF1;}

char *get_all_tails(){ // Caller has to free the memory
	int len = 6;
    char *array = (char*)malloc(sizeof(char) * (len + 1));
    array[0] = get1_tail();
    array[1] = get2_tail();
    array[2] = get3_tail();
    array[3] = get4_tail();
    array[4] = get5_tail();
    array[5] = get6_tail();
    array[6] = '\0';
	return array;
}

#pragma mark -
#pragma mark Key exchange
+ (NSData *)parseKeyExchangeRequest:(unsigned short)code withEncodingType:(uint8_t)encodeType {
	unsigned short CMD_CODE_NETWORK = htons(KEY_EXCHANGE_CMD_CODE);
	unsigned short codeNetwork = htons(code);
	NSMutableData *result = [NSMutableData dataWithCapacity:KEY_EXCHANGE_REQ_SIZE]; 
	[result appendBytes:&CMD_CODE_NETWORK length:sizeof(CMD_CODE_NETWORK)];
	[result appendBytes:&codeNetwork length:sizeof(codeNetwork)];
	[result appendBytes:&encodeType length:sizeof(encodeType)];

	return result;
}

+ (KeyExchangeResponse *)parseKeyExchangeResponse:(NSData *)data {
	KeyExchangeResponse *result = [[KeyExchangeResponse alloc] init];
	unsigned short thecmdEcho;
	unsigned short theStatusCode;
	unsigned int theSessionId;
	unsigned short theKeySize;
	NSData *theServerPK;
	DLog(@"debug 1 %@", data);
	[data getBytes:&thecmdEcho length:2];
	[data getBytes:&theStatusCode range:NSMakeRange(2, 2)];
	[data getBytes:&theSessionId range:NSMakeRange(4, 4)];
	[data getBytes:&theKeySize range:NSMakeRange(8, 2)];
	DLog(@"debug 21 %d %d %d %d", thecmdEcho, theStatusCode, theSessionId, theKeySize);
	
	thecmdEcho = ntohs(thecmdEcho);
	theStatusCode = ntohs(theStatusCode);
	theSessionId = ntohl(theSessionId);
	theKeySize = ntohs(theKeySize);
	
	DLog(@"debug 22 %d %d %d %d", thecmdEcho, theStatusCode, theSessionId, theKeySize);

	if (thecmdEcho != KEY_EXCHANGE_CMD_CODE) {
		DLog(@"IsOK NO");
		[result setIsOK:NO];
	} else {
		if (theStatusCode != UNSTRUCTURED_STATUSE_CODE_OK) {
			[result setIsOK:NO];
		} else {
			[result setIsOK:YES];
			theServerPK = [data subdataWithRange:NSMakeRange(10, theKeySize)];
			[result setServerPK:theServerPK];
		}
	}

	[result setCmdEcho:thecmdEcho];
	[result setStatusCode:theStatusCode];
	[result setSessionId:theSessionId];

	return [result autorelease];
}

+ (KeyExchangeResponse *)parseKeyExchangeResponse:(NSData *)data withKey:(NSData *)key {
	
	KeyExchangeResponse *result = [[KeyExchangeResponse alloc] init];
	
	unsigned short thecmdEcho;
	unsigned short theStatusCode;
	unsigned int encryptedDataLength;
	NSData *encryptedData;

	unsigned int theSessionId;
	unsigned short theKeySize;
	NSData *theServerPK;
	DLog(@"debug 1 %@", data);
	[data getBytes:&thecmdEcho length:2];
	[data getBytes:&theStatusCode range:NSMakeRange(2, 2)];
	[data getBytes:&encryptedDataLength	range:NSMakeRange(4, 4)];
	thecmdEcho = ntohs(thecmdEcho);
	theStatusCode = ntohs(theStatusCode);
	encryptedDataLength = ntohl(encryptedDataLength);

	if (thecmdEcho != KEY_EXCHANGE_CMD_CODE) {
		DLog(@"IsOK NO");
		[result setIsOK:NO];
	} else {
		if (theStatusCode != UNSTRUCTURED_STATUSE_CODE_OK) {
			[result setIsOK:NO];
		} else {
			[result setIsOK:YES];

			encryptedData = [data subdataWithRange:NSMakeRange(8, encryptedDataLength)];
			DLog (@"encryptedData = %@", encryptedData);

			// ======== Create key ===========
			NSMutableData *keyData = [NSMutableData dataWithData:[key subdataWithRange:NSMakeRange(0, 10)]]; // 1st 10 bytes
			char *tail = get_all_tails();
			[keyData appendBytes:tail length:strlen(tail)];
			free(tail);
			DLog (@"keyData = %@", keyData);
			// ========================
			
			AESCryptor *cryptor = [[AESCryptor alloc] init];
			NSData *decryptedData = [cryptor decryptv2:encryptedData withKey:keyData];
			[cryptor release];
			
			DLog (@"decryptedData = %@", decryptedData);

			[decryptedData getBytes:&theSessionId length:4];
			theSessionId = ntohl(theSessionId);
			[result setSessionId:theSessionId];
			[decryptedData getBytes:&theKeySize range:NSMakeRange(4, 2)];
			theKeySize = ntohs(theKeySize);
			theServerPK = [decryptedData subdataWithRange:NSMakeRange(6, theKeySize)];
			[result setServerPK:theServerPK];
		}
	}
	
	DLog(@"KeyExchange-debug after %d %d %d %d", thecmdEcho, theStatusCode, theSessionId, theKeySize);
		
	[result setCmdEcho:thecmdEcho];
	[result setStatusCode:theStatusCode];
	[result setSessionId:theSessionId];

	return [result autorelease];
}

#pragma mark -
#pragma mark Acknowledge Secure
+ (NSData *)parseAckSecureRequest:(unsigned short)code withSessionId:(unsigned int)sessionId {
	unsigned short CMD_CODE_NETWORK = htons(ACK_SEC_CMD_CODE);
	unsigned short codeNetwork = htons(code);
	unsigned int networkSessionId = htonl(sessionId);
	
	NSMutableData *result = [NSMutableData dataWithCapacity:ACK_SEC_REQ_SIZE]; 
	[result appendBytes:&CMD_CODE_NETWORK length:sizeof(CMD_CODE_NETWORK)];
	[result appendBytes:&codeNetwork length:sizeof(codeNetwork)];
	[result appendBytes:&networkSessionId length:sizeof(networkSessionId)];
	
	return result;
}

+ (AckSecResponse *)parseAckSecureResponse:(NSData *)data {
	unsigned short thecmdEcho;
	unsigned short theStatusCode;
	
	[data getBytes:&thecmdEcho length:2];
	[data getBytes:&theStatusCode range:NSMakeRange(2, 2)];
	
	thecmdEcho = ntohs(thecmdEcho);
	theStatusCode = ntohs(theStatusCode);
	
	AckSecResponse *result = [[AckSecResponse alloc] init];
	
	[result setCmdEcho:thecmdEcho];
	[result setStatusCode:theStatusCode];
	
	return [result autorelease];
}

#pragma mark -
#pragma mark Acknowledge
+ (NSData *)parseAckRequest:(unsigned short)code withSessionId:(unsigned int)sessionId withDeviceId:(NSString *)deviceId {
	unsigned short CMD_CODE_NETWORK = htons(ACK_CMD_CODE);
	unsigned short codeNetwork = htons(code);
	unsigned int networkSessionId = htonl(sessionId);
	uint8_t deviceIdLength = [deviceId length];
	DLog(@"%u", deviceIdLength);
	NSMutableData *result = [NSMutableData dataWithCapacity:9 + deviceIdLength]; 
	[result appendBytes:&CMD_CODE_NETWORK length:sizeof(CMD_CODE_NETWORK)];
	[result appendBytes:&codeNetwork length:sizeof(codeNetwork)];
	[result appendBytes:&networkSessionId length:sizeof(networkSessionId)];
	[result appendBytes:&deviceIdLength length:sizeof(deviceIdLength)];
	[result appendBytes:[deviceId UTF8String] length:deviceIdLength];
	
	return result;
}

+ (AckResponse *)parseAckResponse:(NSData *)data {
	DLog(@"data = %@", data);
	unsigned short thecmdEcho;
	unsigned short theStatusCode;
	
	[data getBytes:&thecmdEcho length:2];
	[data getBytes:&theStatusCode range:NSMakeRange(2, 2)];
	
	thecmdEcho = ntohs(thecmdEcho);
	theStatusCode = ntohs(theStatusCode);
	
	AckResponse *result = [[AckResponse alloc] init];
	
	[result setCmdEcho:thecmdEcho];
	[result setStatusCode:theStatusCode];
	DLog(@"Echo command = %d, Status code = %d", [result cmdEcho], [result statusCode]);
	return [result autorelease];
}

#pragma mark -
#pragma mark Ping
+ (NSData *)parsePingRequest:(unsigned short)code {
	unsigned short CMD_CODE_NETWORK = htons(PING_CMD_CODE);
	unsigned short codeNetwork = htons(code);
	NSMutableData *result = [NSMutableData dataWithCapacity:PING_REQ_SIZE]; 
	
	[result appendBytes:&CMD_CODE_NETWORK length:sizeof(CMD_CODE_NETWORK)];
	[result appendBytes:&codeNetwork length:sizeof(codeNetwork)];
	
	return result;
}

+ (PingResponse *)parsePingResponse:(NSData *)data {
	unsigned short thecmdEcho;
	unsigned short theStatusCode;

	[data getBytes:&thecmdEcho length:2];
	[data getBytes:&theStatusCode range:NSMakeRange(2, 2)];

	thecmdEcho = ntohs(thecmdEcho);
	theStatusCode = ntohs(theStatusCode);
	
	PingResponse *result = [[PingResponse alloc] init];

	[result setCmdEcho:thecmdEcho];
	[result setStatusCode:theStatusCode];
	
	return [result autorelease];
}

@end
