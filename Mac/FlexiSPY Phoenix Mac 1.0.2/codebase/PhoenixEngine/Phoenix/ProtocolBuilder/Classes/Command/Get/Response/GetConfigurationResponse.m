//
//  GetConfigurationResponse.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GetConfigurationResponse.h"


@implementation GetConfigurationResponse

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
