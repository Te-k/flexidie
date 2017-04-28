//
//  NTACritiriaStorage.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/6/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTADatabase.h"

@class NTAlertCriteria;

@interface NTACritiriaStorage : NSObject{
    NTADatabase * mNTADatabase;
}
@property(nonatomic,retain) NTADatabase * mNTADatabase;

- (void) storeCritiria: (NSArray *) aCritiria;
- (NSDictionary *) critirias;
- (NTAlertCriteria *) getCritiriaWithID: (NSInteger) aID;
- (void) clearCritiria;

@end
