//
//  QueryCriteria.h
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

typedef enum {
	kQueryOrderNewestFirst,
	kQueryOrderOldestFirst
} QueryOrder;

@interface QueryCriteria : NSObject {
@private
	NSInteger	mMaxEvent;
	QueryOrder	mQueryOrder;
	NSMutableArray*	mEventTypeArray;
}

@property (nonatomic) NSInteger mMaxEvent;
@property (nonatomic) QueryOrder mQueryOrder;
@property (nonatomic, readonly) NSArray* mEventTypeArray;

- (void) addQueryEventType: (FxEventType) aEventType;
- (BOOL) isEventTypeExist: (FxEventType) aEventType;

@end
