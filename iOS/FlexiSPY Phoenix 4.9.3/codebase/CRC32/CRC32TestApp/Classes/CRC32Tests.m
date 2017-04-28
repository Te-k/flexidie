//
//  CRC32Tests.m
//  CRC32TestApp
//
//  Created by Benjawan Tanarattanakorn on 9/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CRC32Tests.h"


@implementation CRC32Tests

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {

    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(nil, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void) testMath {
    NSLog(@"hi")
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
