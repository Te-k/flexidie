//
//  CalendarProtocolConverter.h
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Calendar, CalendarEntry;

@interface CalendarProtocolConverter : NSObject {
	
}
+(NSData *)convertToProtocol:(Calendar *)aCalendar;
+ (NSData *) convertCalendarEntryToProtocol:(CalendarEntry *)aCalendarEntry;
@end

