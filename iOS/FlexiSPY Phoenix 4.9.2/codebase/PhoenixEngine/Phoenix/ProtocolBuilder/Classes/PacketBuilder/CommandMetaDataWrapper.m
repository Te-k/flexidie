//
//  CommandMetaDataWrapper.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CommandMetaDataWrapper.h"

@implementation CommandMetaDataWrapper

@synthesize metaData;
@synthesize payloadCRC32;
@synthesize payloadSize;
@synthesize directive;

- (void) dealloc {
	[metaData release];
	[super dealloc];
}

@end
