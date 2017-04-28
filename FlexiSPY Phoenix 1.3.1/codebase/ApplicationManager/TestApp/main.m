//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 7/11/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstalledAppHelper.h"
#import "RunningApplicationDataProvider.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	[InstalledAppHelper createInstalledApplicationArray];
	//RunningApplicationDataProvider *rp = [[RunningApplicationDataProvider alloc] init];
	//NSArray *app  =	[rp createRunningApplicationArray];
	//NSLog(@"app %@", app);
    [pool release];
    return retVal;
}
