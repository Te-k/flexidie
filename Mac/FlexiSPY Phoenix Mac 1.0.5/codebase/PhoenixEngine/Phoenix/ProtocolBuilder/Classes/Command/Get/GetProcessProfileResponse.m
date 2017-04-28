//
//  GetProcessProfileResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GetProcessProfileResponse.h"


@implementation GetProcessProfileResponse

@synthesize processList;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [processList release];
	
    [super dealloc];
}


@end
