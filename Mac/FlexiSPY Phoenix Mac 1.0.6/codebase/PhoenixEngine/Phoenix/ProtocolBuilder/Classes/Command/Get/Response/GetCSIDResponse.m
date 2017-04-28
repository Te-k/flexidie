//
//  GetCSIDResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GetCSIDResponse.h"


@implementation GetCSIDResponse

@synthesize CSIDList;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [CSIDList release];
	
    [super dealloc];
}


@end
