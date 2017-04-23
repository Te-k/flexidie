//
//  GetActivationCodeResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GetActivationCodeResponse.h"

@implementation GetActivationCodeResponse

@synthesize activationCode;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc {
	[activationCode release];
	[super dealloc];
}


@end
