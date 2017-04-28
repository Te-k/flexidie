//
//  EventCount.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class DetailedCount;

@interface EventCount : NSObject {
@private
	NSMutableArray*		detailedEventCount;
	NSInteger			totalEventCount;
}

@property NSInteger totalEventCount;

- (id) init;
- (id) initWithData: (NSData *) aData;
- (NSData *) transformToData;
- (DetailedCount*) countEvent: (FxEventType) ofType;
- (void) addDetailedCount: (DetailedCount*) detailedCount; // Add event details count follow FxEventType enum sequence value
@end
