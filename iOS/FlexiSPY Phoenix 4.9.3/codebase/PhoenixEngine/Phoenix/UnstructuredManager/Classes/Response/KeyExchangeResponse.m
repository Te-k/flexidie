//
//  KeyExchangeResponse.m
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "KeyExchangeResponse.h"


@implementation KeyExchangeResponse

@synthesize sessionId;
@synthesize serverPK;

- (void) dealloc {
	[serverPK release];
	[super dealloc];
}

@end
