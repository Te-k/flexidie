//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    NSLog(@"main enter");
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"running loop enter");
    int retVal = UIApplicationMain(argc, argv, nil, nil);
	NSLog(@"running loop end");
    [pool release];
	NSLog(@"main end");
    return retVal;
}
