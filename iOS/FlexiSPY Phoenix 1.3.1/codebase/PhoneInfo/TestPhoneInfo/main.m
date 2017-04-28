//
//  main.m
//  TestPhoneInfo3
//
//  Created by Dominique  Mayrand on 11/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneInfoImp.h"

int main(int argc, char *argv[]) {
	NSLog(@"in main");
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	
	PhoneInfoImp *phoneInfo = [[PhoneInfoImp alloc] init];
	NSLog(@"imsi %@", [phoneInfo getIMSI]);
	
	[pool release];
	return retVal;
}
