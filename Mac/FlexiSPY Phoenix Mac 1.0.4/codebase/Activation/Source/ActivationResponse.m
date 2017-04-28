//
//  ActivationResponseInfo.m
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ActivationResponse.h"


@implementation ActivationResponse

@synthesize mSuccess;
@synthesize mActivated;
@synthesize mResponseCode;
@synthesize mHTTPStatusCode;
@synthesize mMessage;
@synthesize mActivationCode;
@synthesize mMD5;
@synthesize mConfigID;
@synthesize mEchoCommand;
@synthesize mErrorCategory;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc {
	[mMD5 release];
	[mMessage release];
	[mActivationCode release];
	[super dealloc];
}


@end
