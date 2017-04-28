//
//  CommunicationDirectiveEvents.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/2/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CommunicationDirectiveEvents.h"


@implementation CommunicationDirectiveEvents

@synthesize commuEventTypeList;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [commuEventTypeList release];
	
    [super dealloc];
}


@end
