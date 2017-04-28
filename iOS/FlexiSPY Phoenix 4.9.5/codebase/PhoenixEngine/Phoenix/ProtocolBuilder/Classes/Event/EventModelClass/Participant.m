//
//  Participant.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Participant.h"


@implementation Participant

@synthesize name;
@synthesize UID;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [name release];
    [UID release];
	
    [super dealloc];
}


@end
