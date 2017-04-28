//
//  IMServiceInfo.m
//  ProtocolBuilder
//
//  Created by Ophat Phuetkasickonphasutha on 8/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMServiceInfo.h"


@implementation IMServiceInfo
@synthesize 	 mIMClientID,mLatestVersion,mExceptionVersions,mPolicy;



- (void) dealloc {
	[mLatestVersion release];
	[mExceptionVersions release];
	[super dealloc];
}

@end
