//
//  main.m
//  CleanserTester
//
//  Created by Pichaya Srifar on 10/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CleanserTester.h"
#import "CleanserRegexTester.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Cleanser tester");
        //CleanserTester *tester = [[CleanserTester alloc] init];
        // [tester testCleanser ];
        if (argc == 2) {
            [CleanserRegexTester testRegex:[NSString stringWithUTF8String:argv[1]]];
        } else {
            [CleanserRegexTester testRegex:@"http://www.google.com"];
        }
    }
    return 0;
}

