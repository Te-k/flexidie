//
//  CellInfo.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/31/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CellInfo.h"


@implementation CellInfo

@synthesize networkName;
@synthesize networkID;
@synthesize cellName;
@synthesize cellID;
@synthesize MCC;
@synthesize areaCode;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [networkName release];
    [networkID release];
    [cellName release];
    [MCC release];
	
    [super dealloc];
}

@end
