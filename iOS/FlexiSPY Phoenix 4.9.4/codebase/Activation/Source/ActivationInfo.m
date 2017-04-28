//
//  ActivationInfo.m
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ActivationInfo.h"


@implementation ActivationInfo

@synthesize mActivationCode;
@synthesize mDeviceInfo;
@synthesize mDeviceModel;
@synthesize mURL;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc {
	[mActivationCode release];
	[mDeviceInfo release];
	[mDeviceModel release];
	[mURL release];
	[super dealloc];
}

@end
