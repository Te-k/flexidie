//
//  SessionInfo.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/31/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandCodeEnum.h"

@class CommandMetaData;

@interface SessionInfo : NSObject {
	BOOL payloadReadyFlag;
	uint32_t CSID;
	uint32_t payloadSize;
	uint32_t SSID;
	int32_t payloadCRC32;
	CommandCode commandCode;
	
	CommandMetaData *metaData;
	NSString *payloadPath;
	NSString *aesKey;
	NSData *serverPublicKey;
}

@property (nonatomic, assign) CommandCode commandCode;
@property (nonatomic, assign) uint32_t CSID;
@property (nonatomic, assign) int32_t payloadCRC32;
@property (nonatomic, assign) BOOL payloadReadyFlag;
@property (nonatomic, assign) uint32_t payloadSize;
@property (nonatomic, assign) uint32_t SSID;

@property (nonatomic, retain) NSString *aesKey;
@property (nonatomic, retain) CommandMetaData *metaData;
@property (nonatomic, retain) NSString *payloadPath;
@property (nonatomic, retain) NSData *serverPublicKey;

@end
