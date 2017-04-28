//
//  SessionInfo.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/31/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SessionInfo.h"

@implementation SessionInfo

@synthesize aesKey;
@synthesize metaData;
@synthesize payloadPath;
@synthesize serverPublicKey;
@synthesize commandCode;
@synthesize CSID;
@synthesize payloadCRC32;
@synthesize payloadReadyFlag;
@synthesize payloadSize;
@synthesize SSID;

- (NSString *)description {
	return [NSString stringWithFormat:@"SessionInfo \n -> CSID %d \n -> SSID %d \n -> aesKey %@ \n -> metaData: %@ \n "
			"-> payloadPath %@ \n -> serverPublicKey %@ \n -> payloadSize %d \n -> payloadCRC32 %d",
	CSID,
	SSID,
	aesKey,
	metaData,
	payloadPath,
	serverPublicKey,
	[metaData payloadSize],
	[metaData payloadCRC32]];
}

- (void) dealloc {
	[aesKey release];
	[metaData release];
	[payloadPath release];
	[serverPublicKey release];
	[super dealloc];
}

@end
