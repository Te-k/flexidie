//
//  TemporalControlValidator.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/27/2558 BE.
//
//

#import <Foundation/Foundation.h>


@class TemporalControl;

@interface TemporalControlValidator : NSObject

- (NSMutableDictionary *) validTemporalControls: (NSDictionary *) aTemporals;

/// !!!:TODO This is private function, and must be remove at the end. It's for testing purpose
//- (NSMutableDictionary *) validTemporalControls: (NSDictionary *) aTemporals comparedDate: (NSDate *) aComparedDate;

- (NSMutableDictionary *) validTemporalControlsWithTime: (NSDictionary *) aTemporals;

@end
