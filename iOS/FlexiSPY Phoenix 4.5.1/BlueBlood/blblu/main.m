//
//  main.m
//  blblu
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *parameter1 = [NSString string];
    if (argc > 1) {
        parameter1 = [NSString stringWithCString:argv[1]
                                        encoding:NSUTF8StringEncoding];
    }
    DLog(@"Launching parameter at index 1 = %@", parameter1);
    
    int retValue = 0;
    if ([parameter1 isEqualToString:@"blblu-load-all"]) {
        retValue = NSApplicationMain(argc, (const char **)argv);
    }
    
    [pool release];
    
    return (retValue);
}
