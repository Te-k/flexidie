//
//  EmbededCallInfo.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "EmbeddedCallInfo.h"


@implementation EmbeddedCallInfo

@synthesize contactName;
@synthesize direction;
@synthesize duration;
@synthesize number;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [contactName release];
    [number release];
	
    [super dealloc];
}


@end
