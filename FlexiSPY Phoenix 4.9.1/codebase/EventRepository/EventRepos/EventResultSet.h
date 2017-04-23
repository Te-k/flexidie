//
//  EventResultSet.h
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class EventKeys;

@interface EventResultSet : NSObject {
@private
	NSArray*	mEventArray;
	BOOL		mShrinked;
}

@property (nonatomic, retain) NSArray* mEventArray;

- (NSArray*) events: (FxEventType) aEventType;
- (EventKeys*) shrink;

@end
