//
//  PayloadBuilderResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayloadTypeEnum.h"

@interface PayloadBuilderResponse : NSObject {
	NSString *aesKey;
	NSData *data;
	NSString *payloadPath;
	uint32_t payloadSize;
	uint32_t payloadCRC32;
	PayloadType payloadType;
}

@property (nonatomic, retain) NSString *aesKey;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *payloadPath;
@property (nonatomic) uint32_t payloadSize;
@property (nonatomic) uint32_t payloadCRC32;
@property (nonatomic) PayloadType payloadType;
@end
