//
//  CalendarEventNotifier.h
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class EKEventStore;


@interface CalendarEventNotifier : NSObject {
	id					mCalendarChangeDelegate;
	SEL					mCalendarChangeSelector;	
}

@property (nonatomic, assign) id mCalendarChangeDelegate;
@property (nonatomic, assign) SEL mCalendarChangeSelector;

- (void) start;
- (void) stop;


@end
