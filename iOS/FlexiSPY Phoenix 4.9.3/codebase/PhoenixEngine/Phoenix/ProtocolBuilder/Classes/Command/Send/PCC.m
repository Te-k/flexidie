//
//  PCC.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "PCC.h"

@implementation PCC

@synthesize arguments;
@synthesize PCCID;

- (void) dealloc
{
	[arguments release];
	[super dealloc];
}


@end
