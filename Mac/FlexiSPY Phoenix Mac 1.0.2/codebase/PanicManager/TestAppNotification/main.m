//
//  main.m
//  TestAppNotification
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanicManagerCreator.h"


int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	PanicManagerCreator *pmCreator = [[PanicManagerCreator alloc] init];
	[pmCreator registerSpringboardNotification];
//	[pmCreator performSelector:@selector(stopPanic) 
//					withObject:nil
//					afterDelay:60];
	
	CFRunLoopRun();
	
    [pool release];
    return retVal;
}
