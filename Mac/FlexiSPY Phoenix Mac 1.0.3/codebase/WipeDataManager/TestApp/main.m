//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WipeCaller.h"
#import "WipeDataManager.h"
#import "WipeDataManagerImpl.h"
#import "WipeDelegate.h"

#import "AppleAccountTester.h"
#import "MediaPlayerTester.h"

int main(int argc, char *argv[]) {
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;
//    
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = 0;
//	WipeCaller *wc = [[[WipeCaller alloc] init] autorelease];
//	[wc wipe];
    
    WipeDelegate *delegate      = [[[WipeDelegate alloc] init] autorelease];
    WipeDataManagerImpl *wipe   = [[[WipeDataManagerImpl alloc] init] autorelease];
    [wipe wipeAllData:delegate];
    
//    [AppleAccountTester signoutAppleAccounts];
    
//    [MediaPlayerTester deleteAllSongs];
	
	CFRunLoopRun();
    
    [pool release];
    return retVal;
    
}
