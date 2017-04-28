//
//  WipeCaller.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WipeCaller.h"
#import "DebugStatus.h"
#import "WipeDataManagerImpl.h"

@implementation WipeCaller

- (void) timeout {
	DLog(@"timeout");
}

- (void) wipeDataProgress: (WipeDataType) aWipeDataType error: (NSError *) aError {
	DLog(@"main thread? %d", [NSThread isMainThread])
	DLog(@"wipeDataProgress %d with error %@", aWipeDataType, aError)
}

- (void) wipeAllDataDidFinished {
	DLog(@"main thread? %d", [NSThread isMainThread])
	DLog(@"wipeAllDataDidFinished")
}

- (void) wipe {
	//[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeout) userInfo:nil repeats:YES];
	WipeDataManagerImpl *wdm = [[WipeDataManagerImpl alloc] init];
	[wdm wipeAllData:self];
}


@end
