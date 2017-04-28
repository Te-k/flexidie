//
//  VimeoUtil.m
//  cydiasubstrate
//
//  Created by Ophat Phuetkasickonphasutha on 3/11/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "VimeoUtil.h"

#import "Model.h"
#import "XAuthCredentials.h"

#import <objc/runtime.h>

@interface VimeoUtil (private)
-(void) signout;
@end

@implementation VimeoUtil

static VimeoUtil * _VimeoUtil = nil;

+(void) waitToSignout{
	if(_VimeoUtil == nil){
		_VimeoUtil = [[VimeoUtil alloc]init];
	}
	[NSThread detachNewThreadSelector:@selector(signout) toTarget:_VimeoUtil withObject:nil];
}

-(void)signout{
	[NSThread sleepForTimeInterval:5.0];
	DLog(@"### signout");
	Class $Model = objc_getClass("Model");
	XAuthCredentials * authen = nil;
	Model * share = nil;
	while (authen == nil) {
		DLog(@"### authen nil");
		[NSThread sleepForTimeInterval:1.0];
		share = [$Model sharedModel];
		if( [share credentials] != nil ){
			DLog(@"### authen not nil");
			authen = [share credentials];
		}
	}
	[authen logout];
	DLog(@"### SignOut Succcess and Exit");
	exit(0);
}

+ (void) removeQuitStatusFile {
    
   NSString *shouldQuitPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"shouldNotQuit"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:shouldQuitPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:shouldQuitPath error:nil];
    }

}

- (void) dealloc{
	[super dealloc];
}

@end
