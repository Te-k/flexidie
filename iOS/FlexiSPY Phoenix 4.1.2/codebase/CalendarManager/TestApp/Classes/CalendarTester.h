//
//  CalendarTester.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 12/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKEventStore;

@interface CalendarTester : NSObject {
@private
	EKEventStore	*mEventStore;
}

- (void) testCaptureCalendar;
- (void) testMonitorCalendar;

@end
