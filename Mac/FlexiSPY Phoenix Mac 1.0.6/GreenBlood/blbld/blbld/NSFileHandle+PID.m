//
//  NSFileHandle+PID.m
//  blbld
//
//  Created by Makara Khloth on 11/15/16.
//
//

#import "NSFileHandle+PID.h"

#include <objc/runtime.h>

@implementation NSFileHandle (PID)

- (pid_t) pid {
    return objc_getAssociatedObject(self, @selector(pid));
}

- (void) setPid: (pid_t) pid {
    objc_setAssociatedObject(self, @selector(pid), pid, OBJC_ASSOCIATION_ASSIGN);
}

@end
