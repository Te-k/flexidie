//
//  SendCalendar.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@interface SendCalendar : NSObject <CommandData> {
@private
	NSArray *mCalendars; // Calendar2
}

@property (nonatomic, retain) NSArray *mCalendars;

@end
