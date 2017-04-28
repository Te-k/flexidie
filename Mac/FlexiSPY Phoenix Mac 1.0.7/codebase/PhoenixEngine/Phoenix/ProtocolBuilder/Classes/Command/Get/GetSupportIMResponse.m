//
//  GetSupportIMResponse.m
//  ProtocolBuilder
//
//  Created by Ophat Phuetkasickonphasutha on 8/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GetSupportIMResponse.h"


@implementation GetSupportIMResponse
@synthesize mIMServices;



-(void)dealloc{
	[mIMServices release];
	[super dealloc];
}

@end
