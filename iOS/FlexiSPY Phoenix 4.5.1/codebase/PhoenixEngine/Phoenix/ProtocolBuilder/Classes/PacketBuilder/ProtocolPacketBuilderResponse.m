//
//  ProtocolPacketBuilderResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ProtocolPacketBuilderResponse.h"

@implementation ProtocolPacketBuilderResponse

@synthesize aesKey;
@synthesize metaDataWithHeader;
@synthesize payloadData;
@synthesize payloadPath;
@synthesize payloadSize;
@synthesize payloadCRC32;
@synthesize payloadType;

- (void) dealloc
{
	[aesKey release];
	[metaDataWithHeader release];
	[payloadData release];
	[payloadPath release];
	[super dealloc];
}


@end
