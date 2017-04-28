//
//  LicenseInfo.m
//  LicenseManager
//
//  Created by Pichaya Srifar on 10/3/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "LicenseInfo.h"


@implementation LicenseInfo

@synthesize activationCode;
@synthesize configID;
@synthesize licenseStatus;
@synthesize md5;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [activationCode release];
    [md5 release];
    
    [super dealloc];
}


@end
