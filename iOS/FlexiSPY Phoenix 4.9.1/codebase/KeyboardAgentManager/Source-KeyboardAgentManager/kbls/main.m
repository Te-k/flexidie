//
//  main.m
//  kbls
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DebugStatus.h"

int main(int argc, const char * argv[]) {
    NSString *parameter1 = @"";
    if (argc > 1) {
        parameter1 = [NSString stringWithCString:argv[1]
                                        encoding:NSUTF8StringEncoding];
    }
    
    DLog(@"kbls launch parameter1 : %@", parameter1);
    
    int retValue = 0;
    if ([parameter1 isEqualToString:@"kbls-load-all"]) {
        retValue = NSApplicationMain(argc, argv);
    }
    
    return retValue;
}
