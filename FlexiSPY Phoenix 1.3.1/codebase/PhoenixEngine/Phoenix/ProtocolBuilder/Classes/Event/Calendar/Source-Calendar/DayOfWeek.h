//
//  DayOfWeek.h
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
	kDayOfWeekNone		=0,
	kDayOfWeekSunday	=1,
	kDayOfWeekMonday	=2,
	kDayOfWeekTuesday	=4,
	kDayOfWeekWednesday =8,
	kDayOfWeekThursday =16,
	kDayOfWeekFriday   =32,
	kDayOfWeekSaturday =64
}DayOfWeek;

