//
//  UseCases.m
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import "UseCases.h"

@implementation UseCases

@synthesize mUseCaseDicts, mCycleTime, mSkipFailedUseCase, mPostFailedUseCase, mEmail;

- (void) dealloc {
    self.mUseCaseDicts = nil;
    self.mEmail = nil;
    [super dealloc];
}

@end
