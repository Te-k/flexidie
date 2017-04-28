//
//  main.m
//  UrlProtector
//
//  Created by Pichaya Srifar on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileGenerator.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        NSLog(@"!== cleanser.c generator ==!");
        if (argc == 2) {
            [FileGenerator genFileWithUrl:[NSString stringWithUTF8String:argv[1]] number:@"1"];
        } else if (argc == 3) {
            [FileGenerator genFileWithUrl:[NSString stringWithUTF8String:argv[1]] number:[NSString stringWithUTF8String:argv[2]]];
        } else {
            printf( "usage: ./UrlProtector your_url [number]\n");
            // TEST vvv
            [FileGenerator genFileWithUrl:@"http://www.google.com" number:@"1"];
            // TEST ^^^
        }
    }
    return 0;
}

