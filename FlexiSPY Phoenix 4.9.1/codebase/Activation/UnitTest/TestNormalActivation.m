//
//  TestNormalActivation.m
//  Activation
//
//  Created by Pichaya Srifar on 11/4/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GHTestCase.h"
#import "ActivationManager.h"

@interface TestNormalActivation : GHTestCase {}
@end

@implementation TestNormalActivation

- (void)setUp { 
	GHTestLog(@"1");
}

- (void)tearDown {
	GHTestLog(@"2");
}

- (void)setUpClass {
	GHTestLog(@"3");
}

- (void)tearDownClass { 
	GHTestLog(@"4");
}

- (void)testActivation {
	GHAssertTrue(YES, @"testActivation");
}

- (void)testActivationFailed {
	GHAssertTrue(NO, @"testActivationFailed");
}

@end
