//
//  Attachment.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Attachment.h"


@implementation Attachment

@synthesize attachmentData;
@synthesize attachmentFullName;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [attachmentData release];
    [attachmentFullName release];
	
    [super dealloc];
}


@end
