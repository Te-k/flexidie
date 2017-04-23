//
//  MacInfoTest.m
//  TestApp
//
//  Created by vervata on 9/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MacInfoTest.h"
#import "MacInfoImp.h"


@implementation MacInfoTest

- (void) testGetMacInfo {
	MacInfoImp *imp = [[MacInfoImp alloc] init];
	NSLog(@"getMobileNetworkCode %@",[imp getMobileNetworkCode]);
	NSLog(@"getMobileCountryCode %@",[imp getMobileCountryCode]);
	NSLog(@"getNetworkName %@",[imp getNetworkName]);
	NSLog(@"getIMEI %@",[imp getIMEI]);
	NSLog(@"getMEID %@",[imp getMEID]);
	NSLog(@"getIMSI %@",[imp getIMSI]);
	NSLog(@"getPhoneNumber %@",[imp getPhoneNumber]);
	NSLog(@"getDeviceModel %@",[imp getDeviceModel]);
	NSLog(@"getDeviceInfo %@",[imp getDeviceInfo]);
	NSLog(@"getNetworkType %d",[imp getNetworkType]);
	
	NSLog(@"getComputerName %@",[imp getComputerName]);
	NSLog(@"getLoginUsername %@",[imp getLoginUsername]);
	NSLog(@"getLocalHostName %@",[imp getLocalHostName]);
//	NSLog(@"getCurrentLocation %@",[imp getCurrentLocation]);
//	NSLog(@"getProxy %@",[imp getProxy]);

	
}

@end
