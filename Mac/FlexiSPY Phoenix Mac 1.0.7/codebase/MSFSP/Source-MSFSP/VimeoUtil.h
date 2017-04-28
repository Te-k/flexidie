//
//  VimeoUtil.h
//  cydiasubstrate
//
//  Created by Ophat Phuetkasickonphasutha on 3/11/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@class _TtC5Vimeo29ObjC_AuthenticationController;

@interface VimeoUtil : NSObject {
	
}

+ (VimeoUtil *)sharedVimeoUtil;
+(void) waitToSignout;
+ (void) removeQuitStatusFile;

@end
