//
//  SendActivateResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendActivateResponse.h"


@implementation SendActivateResponse

@synthesize configID;
@synthesize md5;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc {
	[md5 release];
	[super dealloc];
}


@end
