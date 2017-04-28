//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileDescriptorNotifier.h"
#import "DefStd.h"

int main(int argc, char *argv[]) {
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	FileDescriptorNotifier *fdn = [[FileDescriptorNotifier alloc] initWithFileDescriptorDelegate:nil filePath:@"/var/mobile/Media/DCIM/100APPLE/"];
	[fdn startMonitoringChange:kFDFileWrite|kFDFileRead];
	CFRunLoopRun();
	[fdn release];
	[pool release];
	return 0;
}
