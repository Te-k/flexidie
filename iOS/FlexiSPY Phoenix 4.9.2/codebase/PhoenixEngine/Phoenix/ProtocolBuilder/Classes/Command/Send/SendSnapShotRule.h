//
//  SendSnapShotRule.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@class SnapShotRule;

@interface SendSnapShotRule : NSObject <CommandData> {
@private
    SnapShotRule    *mSnapShotRule;
}

@property (nonatomic, retain) SnapShotRule *mSnapShotRule;

@end
