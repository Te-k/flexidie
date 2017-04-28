//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WipeCaller.h"


int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	WipeCaller *wc = [[WipeCaller alloc] init];
	[wc wipe];
	
	
	CFRunLoopRun();
    [pool release];
    return retVal;
}
