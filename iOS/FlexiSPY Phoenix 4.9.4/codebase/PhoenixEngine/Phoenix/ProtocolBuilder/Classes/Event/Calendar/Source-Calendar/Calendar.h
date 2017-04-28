//
//  Calendar.h
//  Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Calendar : NSObject {
	//NSInteger mCalendarId;
	NSString *mCalendarId;
	NSString * mCalendarName;
	NSArray * mCalendarEntries;
}
//@property (nonatomic,assign) NSInteger mCalendarId;
@property (nonatomic,copy) NSString *mCalendarId;
@property (nonatomic,copy) NSString * mCalendarName;
@property (nonatomic,retain) NSArray * mCalendarEntries; // Not use for sending data; the entries will get from Calendar2's data provider

@end
