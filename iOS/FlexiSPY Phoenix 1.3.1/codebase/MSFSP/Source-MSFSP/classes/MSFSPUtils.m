//
//  MSFSPUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MSFSPUtils.h"
#import <UIKit/UIKit.h>

@implementation MSFSPUtils

+ (NSInteger) systemOSVersion {
	NSInteger systemOSVersion = [[[UIDevice currentDevice] systemVersion] intValue];
	return (systemOSVersion);
}

@end
