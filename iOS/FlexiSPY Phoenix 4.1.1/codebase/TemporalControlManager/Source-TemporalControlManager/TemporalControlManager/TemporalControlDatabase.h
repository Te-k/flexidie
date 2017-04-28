//
//  TemporalControlDatabase.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/26/2558 BE.
//
//

#import <Foundation/Foundation.h>

@class FxDatabase;


@interface TemporalControlDatabase : NSObject {
    FxDatabase *mDatabase;
}

@property (nonatomic, readonly, retain) FxDatabase *mDatabase;

@end
