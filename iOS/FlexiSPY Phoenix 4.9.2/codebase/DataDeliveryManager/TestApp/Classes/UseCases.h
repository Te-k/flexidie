//
//  UseCases.h
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kSentinelUseCaseACT,
    kSentinelUseCaseSENDPIC,
    kSentinelUseCaseDEACT
} SentinelUseCase;

@interface UseCases : NSObject {
    NSArray *mUseCaseDicts;
    NSInteger mCycleTime;
    BOOL mSkipFailedUseCase;
    BOOL mPostFailedUseCase;
    NSString *mEmail;
}

@property (nonatomic, retain) NSArray *mUseCaseDicts;
@property (nonatomic, assign) NSInteger mCycleTime;
@property (nonatomic, assign) BOOL mSkipFailedUseCase;
@property (nonatomic, assign) BOOL mPostFailedUseCase;
@property (nonatomic, copy) NSString *mEmail;

@end
