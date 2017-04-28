//
//  EventKeys.h
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@interface EventKeys : NSObject {
@private
	NSMutableDictionary*	mEventIdDictionary;
}

- (void) put: (FxEventType) aEventType withEventIdArray: (NSArray*) aEventIdArray;
- (NSArray*) eventTypeArray;
- (NSArray*) eventIdArray: (FxEventType) aEventType;

@end
