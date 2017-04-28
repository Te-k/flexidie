//
//  GetSnapShotRuleResponse.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@class SnapShotRule;

@interface GetSnapShotRuleResponse : ResponseData {
@private
    SnapShotRule    *mSnapShotRule;
}

@property (nonatomic, retain) SnapShotRule *mSnapShotRule;

@end
