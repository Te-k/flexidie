//
//  main.m
//  FinderMenu
//
//  Created by Alexey Zhuchkov on 10/21/12.
//  Copyright (c) 2012 InfiniteLabs. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#import "mach_inject_bundle.h"

int main(int argc, const char * argv[])
{
  @autoreleasepool {
      
    NSArray *targets = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Safari"];

    if ([targets count] < 1) {
        return -1;
    }
     
    pid_t pid = [[targets objectAtIndex:0] processIdentifier];
   
//    NSLog(@"Target : %@", [targets objectAtIndex:0]);
// 
    NSString *bundlePath = [NSString stringWithFormat:@"%@/BrowserInjectorExt.bundle", [[NSBundle mainBundle] bundlePath] ];
      
    NSLog(@"Bundle path: %@", bundlePath);
//    NSLog(@"PID: %d", pid);
    
    mach_error_t err;
    err = mach_inject_bundle_pid([bundlePath fileSystemRepresentation], pid);
      
    if (err == err_none) {
//        NSLog(@"!!!!@@@@ Inject successful!");
    } else {
//        NSLog(@"!!!!@@@@ Inject error: %d", err);
    }
  }
  return 0;
}

