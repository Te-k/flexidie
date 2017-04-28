//
//  GetTimeResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GetTimeResponse.h"


@implementation GetTimeResponse

@synthesize currentMobileTime;
@synthesize timeZone;
@synthesize representation;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [currentMobileTime release];
    [timeZone release];
	
    [super dealloc];
}


@end
