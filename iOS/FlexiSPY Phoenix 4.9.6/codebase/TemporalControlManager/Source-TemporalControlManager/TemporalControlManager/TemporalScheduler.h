//
//  TemporalScheduler.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/18/2558 BE.
//
//

#import <Foundation/Foundation.h>

@interface TemporalScheduler : NSObject {
    id mTarget;
    SEL mSelector;
}

@property (nonatomic, assign) id mTarget;
@property (nonatomic, assign) SEL mSelector;

- (void) startScheduling: (NSDictionary *) aTemporalControls;
- (void) stopScheduling;

- (void) loadMobileTimerApplication;
- (void) unloadMobileTimerApplication;
@end
