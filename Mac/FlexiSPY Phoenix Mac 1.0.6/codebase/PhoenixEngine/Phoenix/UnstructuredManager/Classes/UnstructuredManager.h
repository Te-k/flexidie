//
//  UnstructuredManager.h
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "KeyExchangeResponse.h"
#import "AckResponse.h"
#import "AckSecResponse.h"
#import "PingResponse.h"

@interface UnstructuredManager : NSObject {
	NSURL *URL;
	NSString *HTTPErrorMsg;
}

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSString *HTTPErrorMsg;

- (UnstructuredManager *)init;
- (UnstructuredManager *)initWithURL:(NSURL *)url;
- (KeyExchangeResponse *)doKeyExchangev1:(unsigned short)code withEncodingType:(unsigned short)encodeType;
- (KeyExchangeResponse *)doKeyExchangev2:(unsigned short)code withEncodingType:(unsigned short)encodeType;
- (AckSecResponse *)doAckSecure:(unsigned short)code withSessionId:(unsigned int)sessionId;
- (AckResponse *)doAck:(unsigned short)code withSessionId:(unsigned int)sessionId withDeviceId:(NSString *)deviceId;
- (PingResponse *)doPing:(unsigned short)code;

@end
