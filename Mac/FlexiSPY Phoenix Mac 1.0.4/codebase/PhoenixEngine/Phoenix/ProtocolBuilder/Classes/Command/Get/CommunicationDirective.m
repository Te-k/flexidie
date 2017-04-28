//
//  CommunicationDirective.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/2/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CommunicationDirective.h"

@implementation CommunicationDirective

@synthesize action;
@synthesize timeUnit;
@synthesize direction;
@synthesize commuEvent;
@synthesize criteria;
@synthesize dayEndTime;
@synthesize dayStartTime;
@synthesize endDate;
@synthesize startDate;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [commuEvent release];
    [criteria release];
    [dayEndTime release];
    [dayStartTime release];
    [endDate release];
    [startDate release];
	
    [super dealloc];
}


@end
