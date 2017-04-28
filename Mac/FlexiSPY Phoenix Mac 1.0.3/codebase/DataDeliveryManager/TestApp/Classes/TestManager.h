//
//  TestManager.h
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import <Foundation/Foundation.h>

#import "Tester.h"

@class UseCases;
@class LightActivationManager, LightEDM;

@interface TestManager : NSObject <TesterDelegate> {
    UseCases *mUseCases;
    
    LightActivationManager *mActivationManager;
    LightEDM *mEDM;
    
    NSMutableArray *mTesters;
    NSMutableArray *mUseCaseDicts;
    
    id mDelegate;
    SEL mSelector;
}

@property (nonatomic, retain) UseCases *mUseCases;

@property (nonatomic, assign) LightEDM *mEDM;
@property (nonatomic, assign) LightActivationManager *mActivationManager;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) startTesting;
- (void) stopTesting;

@end
