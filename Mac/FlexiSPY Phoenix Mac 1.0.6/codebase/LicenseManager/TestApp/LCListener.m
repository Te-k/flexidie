//
//  LCListener.m
//  LicenseManager3
//
//  Created by Pichaya Srifar on 10/5/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "LCListener.h"


@implementation LCListener

- (void)onLicenseChanged:(LicenseInfo *)licenseInfo {
	
	[NSThread sleepForTimeInterval:3.0];
	NSLog(@"onLicenseChanged -> DO SOMETHING");
}

@end
