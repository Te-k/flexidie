//
//  Thumbnail.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Thumbnail.h"


@implementation Thumbnail

@synthesize imageData;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [imageData release];
	
    [super dealloc];
}

@end
