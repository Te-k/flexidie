//
//  TestManager.m
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import "TestManager.h"
#import "Tester.h"
#import "UseCases.h"
#import "SentinelLogger.h"
#import "UseCaseFailureSender.h"

#import "LightActivationManager.h"
#import "LightEDM.h"

#import "DeliveryResponse.h"
#import "DateTimeFormat.h"

@interface TestManager (private)
- (void) testNext: (id) aObject;
- (void) prepareToTest;
- (BOOL) executeTest: (NSUInteger) aIndex;
@end

@implementation TestManager

@synthesize mUseCases;

@synthesize mEDM, mActivationManager;

@synthesize mDelegate, mSelector;

- (id) init {
    self = [super init];
    if (self) {
        mTesters = [[NSMutableArray alloc] init];
        mUseCaseDicts = [[NSMutableArray alloc] init];
    }
    return (self);
}

- (void) startTesting {
    NSLog(@"Start testing...");
    [self prepareToTest];
    
    NSLog(@"All use cases: %@", mUseCaseDicts);
    
    SentinelLogger *sentinelLogger = [SentinelLogger sharedSentinelLogger];
    [sentinelLogger deleteLogFile];
    
    [self executeTest:0];
}

- (void) stopTesting {
    NSLog(@"Stop testing all use cases");
    self.mUseCases = nil;
    [mUseCaseDicts removeAllObjects];
    [mTesters removeAllObjects];
    
    mActivationManager.mDelegate = nil;
    mActivationManager.mCompletedSelector = nil;
    mActivationManager.mUpdatingSelector = nil;
    
    mEDM.mDelegate = nil;
    mEDM.mCompletedSelector = nil;
    mEDM.mUpdatingSelector = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) testCompleted: (NSNumber *) aTestCaseIndex result: (id) aResult {
    DeliveryResponse *response = aResult;
    NSLog(@"Status code: %ld", (long)[response mStatusCode]);
    NSLog(@"Status message: %@", [response mStatusMessage]);
    
    NSDictionary *dict = [mUseCaseDicts objectAtIndex:[aTestCaseIndex unsignedIntegerValue]];
    NSNumber *ucAction = [dict objectForKey:@"usecaseAction"];
    NSString *ucActionName = [dict objectForKey:@"usecaseActionName"];
    NSString *ucName = [dict objectForKey:@"usecaseName"];
    
    NSString *date = [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString *result = [response mSuccess] ? @"success" : @"failed";
    NSString *statusMessage = [[response mStatusMessage] stringByReplacingOccurrencesOfString:@"," withString:@";"];
    
    // Inform UI
    [mDelegate performSelector:mSelector withObject:ucAction withObject:aResult];
    
    // Log to csv file
    SentinelLogger *sentinelLogger = [SentinelLogger sharedSentinelLogger];
    NSString *summary = [NSString stringWithFormat:@"%@,%@,%@,%@,%@\n", date, ucName, ucActionName, result, statusMessage];
    [sentinelLogger logSummary:summary];
    
    // Post to report server
    NSString *email = [mUseCases mEmail];
    if ([email length] && ![response mSuccess] && mUseCases.mPostFailedUseCase) {
        NSMutableDictionary *moreDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSNumber *errorCode = [NSNumber numberWithInteger:[response mStatusCode]];
        NSString *errorMessage = [response mStatusMessage];
        if (!errorMessage) errorMessage = @"";
        [moreDict setObject:errorCode forKey:@"errorCode"];
        [moreDict setObject:errorMessage forKey:@"errorMessage"];
        UseCaseFailureSender *ucFailureSender = [UseCaseFailureSender sharedUseCaseFailureSender];
        [ucFailureSender postFailedUseCase:moreDict to:email];
    }
    
    // Remove tester
    [mTesters removeObjectAtIndex:0];
    
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aTestCaseIndex, @"index", aResult, @"result", nil];
    [self performSelector:@selector(testNext:) withObject:userInfo afterDelay:mUseCases.mCycleTime*60];
}

- (void) testNext: (id) aObject {
    if (!self.mUseCases) { // Cancel
        [mUseCaseDicts removeAllObjects];
        [mTesters removeAllObjects];
        
        mActivationManager.mDelegate = nil;
        mActivationManager.mCompletedSelector = nil;
        mActivationManager.mUpdatingSelector = nil;
        
        mEDM.mDelegate = nil;
        mEDM.mCompletedSelector = nil;
        mEDM.mUpdatingSelector = nil;
        
        return;
    }
    
    NSDictionary *userInfo = aObject;
    
    NSUInteger lastIndex = [[userInfo objectForKey:@"index"] unsignedIntegerValue];
    id result = [userInfo objectForKey:@"result"];
    DeliveryResponse *response = result;
    
    NSUInteger nextIndex = lastIndex;
    if ([response mSuccess]) {
        // Decrease number of execute
        NSMutableDictionary *usecaseDict = [mUseCaseDicts objectAtIndex:lastIndex];
        NSNumber *usecaseID = [usecaseDict objectForKey:@"usecaseAction"];
        NSNumber *numberOfExecute = [usecaseDict objectForKey:@"numberOfExecute"];
        NSUInteger temp = [numberOfExecute unsignedIntegerValue];
        temp--;
        numberOfExecute = [NSNumber numberWithUnsignedInteger:temp];
        [usecaseDict setObject:numberOfExecute forKey:@"numberOfExecute"];
        
        NSLog(@"use case, no.exec: %@, %@", usecaseID, numberOfExecute);
        
        // Next use case
        nextIndex = lastIndex+1;
    } else {
        if (self.mUseCases.mSkipFailedUseCase) {
            // Next use case
            nextIndex = lastIndex+1;
        } else {
            // Repeat the same use case
        }
    }
    
    if (nextIndex >= [mUseCaseDicts count]) {
        [self executeTest:0];
    } else {
        NSLog(@"Start testing next use case");
        [self executeTest:nextIndex];
    }
}

- (void) prepareToTest {
    for (NSDictionary * dict in [mUseCases mUseCaseDicts]) {
        NSMutableDictionary *myDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [mUseCaseDicts addObject:myDict];
    }
}

- (BOOL) executeTest: (NSUInteger) aIndex {
    BOOL execute = NO;
    
    for (NSUInteger ucIndex = aIndex; ucIndex < [mUseCaseDicts count]; ucIndex++) {
        NSDictionary *dict = [mUseCaseDicts objectAtIndex:ucIndex];
        NSNumber *ucAction = [dict objectForKey:@"usecaseAction"];
        NSNumber *numberOfExecute = [dict objectForKey:@"numberOfExecute"];
        if ([numberOfExecute unsignedIntegerValue] > 0) {
            id delegate = nil;
            SEL selector = nil;
            if ([ucAction integerValue] == kSentinelUseCaseACT) {
                delegate = mActivationManager;
                selector = @selector(sendActivation);
            } else if ([ucAction integerValue] == kSentinelUseCaseSENDPIC) {
                delegate = mEDM;
                selector = @selector(sendThumbnail);
            } else if ([ucAction integerValue] == kSentinelUseCaseDEACT) {
                delegate = mActivationManager;
                selector = @selector(sendDeactivation);
            }
            
            Tester *tester = [[[Tester alloc] init] autorelease];
            tester.mDelegate = self;
            tester.mTarget = delegate;
            tester.mSelector = selector;
            tester.mTestCaseIndex = [NSNumber numberWithUnsignedInteger:ucIndex];
            
            mActivationManager.mDelegate = tester;
            mActivationManager.mCompletedSelector = @selector(didCompleteTest:);
            mActivationManager.mUpdatingSelector = @selector(didUpdateTest:);
            
            mEDM.mDelegate = tester;
            mEDM.mCompletedSelector = @selector(didCompleteTest:);
            mEDM.mUpdatingSelector = @selector(didUpdateTest:);
            
            [tester test];
            
            [mTesters addObject:tester];
            
            execute = YES;
            break;
        }
    }
    return (execute);
}

- (void) dealloc {
    [mUseCaseDicts release];
    self.mUseCases = nil;
    [mTesters release];
    [super dealloc];
}

@end
