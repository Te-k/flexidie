//
//  UnstructProtParser.h
//  UnstructuredManager
//
//  Created by Pichaya Srifar on 7/20/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KeyExchangeResponse.h"
#import "AckSecResponse.h"
#import "AckResponse.h"
#import "PingResponse.h"

#define TAG UnstructParser

#define KEY_EXCHANGE_REQ_SIZE 6
#define ACK_SEC_REQ_SIZE 8
#define ACK_REQ_SIZE 45
#define PING_REQ_SIZE 4


@interface UnstructProtParser : NSObject {

}

+ (NSData *)parseKeyExchangeRequest:(unsigned short)code withEncodingType:(uint8_t)encodeType;
+ (KeyExchangeResponse *)parseKeyExchangeResponse:(NSData *)data;
+ (KeyExchangeResponse *)parseKeyExchangeResponse:(NSData *)data withKey:(NSData *)key;

+ (NSData *)parseAckSecureRequest:(unsigned short)code withSessionId:(unsigned int)sessionId;
+ (AckSecResponse *)parseAckSecureResponse:(NSData *)data;

+ (NSData *)parseAckRequest:(unsigned short)code withSessionId:(unsigned int)sessionId withDeviceId:(NSString *)deviceId;
+ (AckResponse *)parseAckResponse:(NSData *)data;

+ (NSData *)parsePingRequest:(unsigned short)code;
+ (PingResponse *)parsePingResponse:(NSData *)data;

@end
