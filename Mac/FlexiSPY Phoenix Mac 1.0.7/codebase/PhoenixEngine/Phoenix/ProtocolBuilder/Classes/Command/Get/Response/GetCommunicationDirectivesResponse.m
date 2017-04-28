//
//  GetCommunicationDirectivesResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GetCommunicationDirectivesResponse.h"


@implementation GetCommunicationDirectivesResponse

@synthesize communicationDirectiveList;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [communicationDirectiveList release];
	
    [super dealloc];
}


@end
