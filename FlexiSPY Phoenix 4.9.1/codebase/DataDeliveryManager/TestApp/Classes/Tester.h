//
//  Tester.h
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import <Foundation/Foundation.h>

@protocol TesterDelegate <NSObject>

- (void) testCompleted: (NSNumber *) aTestCaseIndex result: (id) aResult;

@end

@interface Tester : NSObject {
    id mTarget;
    SEL mSelector;
    
    id <TesterDelegate> mDelegate;
    NSNumber *mTestCaseIndex;
}

@property (nonatomic, assign) id mTarget;
@property (nonatomic, assign) SEL mSelector;

@property (nonatomic, assign) id <TesterDelegate> mDelegate;
@property (nonatomic, retain) NSNumber *mTestCaseIndex;

- (void) test;

- (void) didCompleteTest: (id) aCompletedResult;
- (void) didUpdateTest: (id) aUpdatedResult;

@end
