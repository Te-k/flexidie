//
//  EventBaseWrapper.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@interface EventBaseWrapper : NSObject {
@private
    NSInteger   mId;
    NSInteger   mEventId;
    FxEventType   mEventType;
    FxEventDirection    mEventDirection;
}

@property (nonatomic) NSInteger mId;
@property (nonatomic) NSInteger mEventId;
@property (nonatomic) FxEventType mEventType;
@property (nonatomic) FxEventDirection mEventDirection;

@end
