//
//  CommandMetaData.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LanguageEnum.h"

@interface CommandMetaData : NSObject {
	uint8_t compressionCode;
	uint8_t encryptionCode;
	unsigned short confID;
	int32_t payloadCRC32;   //
	unsigned int payloadSize;   //
	unsigned short productID;
	unsigned short protocolVersion;
	Language language;
	
	NSString *activationCode;
	NSString *deviceID;
	NSString *IMSI;
	NSString *MCC;
	NSString *MNC;
	NSString *phoneNumber;
	NSString *productVersion;
	NSString *hostURL;
    
    uint8_t batteryLevel;
}

@property (nonatomic, assign) uint8_t compressionCode;
@property (nonatomic, assign) uint8_t encryptionCode;
@property (nonatomic, assign) unsigned short confID;
@property (nonatomic, assign) int32_t payloadCRC32;
@property (nonatomic, assign) unsigned int payloadSize;
@property (nonatomic, assign) unsigned short productID;
@property (nonatomic, assign) unsigned short protocolVersion;
@property (nonatomic, assign) Language language;

@property (nonatomic, copy) NSString *activationCode;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *IMSI;
@property (nonatomic, copy) NSString *MCC;
@property (nonatomic, copy) NSString *MNC;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *productVersion;
@property (nonatomic, copy) NSString *hostURL;

@property (nonatomic, assign) uint8_t batteryLevel;

@end
