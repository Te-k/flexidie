//
//  CommandMetaData.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CommandMetaData.h"

@implementation CommandMetaData

@synthesize compressionCode;
@synthesize confID;
@synthesize encryptionCode;
@synthesize payloadCRC32;
@synthesize payloadSize;
@synthesize productID;
@synthesize protocolVersion;
@synthesize language;
@synthesize activationCode;
@synthesize deviceID;
@synthesize IMSI;
@synthesize MCC;
@synthesize MNC;
@synthesize phoneNumber;
@synthesize productVersion;
@synthesize hostURL;

- (NSString *) description {
	NSString *description = [NSString stringWithFormat:@"compressionCode -> %d\n"
							 "confID -> %d\n"
							 "encryptionCode -> %d\n"
							 "payloadCRC32 -> %d\n"
							 "payloadSize -> %d\n"
							 "productID -> %d\n"
							 "protocolVersion -> %d\n"
							 "language -> %d\n"
							 "activationCode -> %@\n"
							 "deviceID -> %@\n"
							 "IMSI -> %@\n"
							 "MCC -> %@\n"
							 "MNC -> %@\n"
							 "phoneNumber -> %@\n"
							 "productVersion -> %@\n"
							 "hostURL -> %@\n",
							 compressionCode,
							 confID,
							 encryptionCode,
							 payloadCRC32,
							 payloadSize,
							 productID,
							 protocolVersion,
							 language,
							 activationCode,
							 deviceID,
							 IMSI,
							 MCC,
							 MNC,
							 phoneNumber,
							 productVersion,
							 hostURL];
	return (description);
}

- (void) dealloc {
	[activationCode release];
	[deviceID release];
	[IMSI release];
	[MCC release];
	[MNC release];
	[phoneNumber release];
	[productVersion release];
	[hostURL release];
	[super dealloc];
}

@end
