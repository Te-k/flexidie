//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TestAppViewController.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = 0;
	if (argc <= 1) {
		retVal = UIApplicationMain(argc, argv, nil, nil);
	} else {
		NSString *telNumber = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
		NSString *smsMessage = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
		
		NSLog(@"telNumber = %@", telNumber);
		NSLog(@"smsMessage = %@", smsMessage);
		
		[TestAppViewController sendMessage000:telNumber toAddress:smsMessage];
	}
    [pool release];
    return retVal;
}
