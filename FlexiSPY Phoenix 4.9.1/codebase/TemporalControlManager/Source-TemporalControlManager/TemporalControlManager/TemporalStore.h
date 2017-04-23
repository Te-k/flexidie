//
//  TemporalStore.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/18/2558 BE.
//
//

#import <Foundation/Foundation.h>
#import "TemporalControlDatabase.h"

@class TemporalControl;


@interface TemporalStore : NSObject{
    TemporalControlDatabase * mTempControlDatabase;
}
@property(nonatomic,assign) TemporalControlDatabase * mTempControlDatabase;

- (void) storeTemporals: (NSArray *) aTemporals;
- (NSDictionary *) temporals;
- (TemporalControl *) getTemporalControlWithID: (NSInteger) aControlID;

@end
