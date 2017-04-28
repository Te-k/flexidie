//
//  PayloadBuilderResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "PayloadBuilderResponse.h"


@implementation PayloadBuilderResponse

@synthesize aesKey;
@synthesize payloadPath;
@synthesize data;
@synthesize payloadSize;
@synthesize payloadCRC32;
@synthesize payloadType;

- (void) dealloc {
	[aesKey release];
	[payloadPath release];
	[data release];
	[super dealloc];
}

@end
