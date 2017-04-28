//
//  ProtocolPacketBuilderResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayloadTypeEnum.h"

@interface ProtocolPacketBuilderResponse : NSObject {
	NSString *aesKey;
	NSData *metaDataWithHeader;
	long payloadCRC32;
	NSData *payloadData;
	NSString *payloadPath;
	long payloadSize;
	PayloadType payloadType;
}

@property (nonatomic, retain) NSString *aesKey;
@property (nonatomic, retain) NSData *metaDataWithHeader;
@property (nonatomic, retain) NSData *payloadData;
@property (nonatomic, retain) NSString *payloadPath;
@property (nonatomic, assign) long payloadSize;
@property (nonatomic, assign) long payloadCRC32;
@property (nonatomic, assign) PayloadType payloadType;

@end
