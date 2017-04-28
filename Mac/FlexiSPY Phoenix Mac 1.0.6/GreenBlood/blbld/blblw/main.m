//
//  main.m
//  blblw
//
//  Created by Makara Khloth on 10/12/16.
//
//

#import <Foundation/Foundation.h>

#import "blblwController.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        DLog(@"Hello, blblw!");
        
        [blblwController sharedblblwController];
        
        CFRunLoopRun();
    }
    return 0;
}
