//
//  EventCenter.h
//  EventCenter
//
//  Created by Makara Khloth on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventDelegate.h"

@protocol EventRepository;

@interface EventCenter : NSObject <EventDelegate> {
@private
	id <EventRepository>	mEventRepository;
}

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository;

@end
