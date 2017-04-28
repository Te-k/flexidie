//
//  Recipient.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Recipient.h"


@implementation Recipient

@synthesize contactName;
@synthesize recipient;
@synthesize recipientType;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [contactName release];
    [recipient release];
	
    [super dealloc];
}


@end
