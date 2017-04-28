//
//  TemporalControlManager.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/18/2558 BE.
//
//

#import <Foundation/Foundation.h>


#pragma mark - Delegate


@protocol TemporalControlDelegate <NSObject>

- (void) requestTemporalControlCompleted: (NSError *) aError;
- (void) syncTemporalControlCompleted: (NSError *) aError;

@end


#pragma mark - Manager


@protocol TemporalControlManager <NSObject>

- (BOOL) requestTemporalControl: (id <TemporalControlDelegate>) aDelegate;
- (BOOL) syncTemporalControl: (id <TemporalControlDelegate>) aDelegate;

@end
