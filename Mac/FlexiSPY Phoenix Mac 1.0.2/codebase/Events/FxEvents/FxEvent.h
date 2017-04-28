//
//  FxEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@interface FxEvent : NSObject {
@protected
	NSString*	dateTime;
	NSUInteger	eventId;
	FxEventType	eventType;
}

@property (nonatomic, copy) NSString* dateTime;
@property (nonatomic) NSUInteger eventId;
@property (nonatomic) FxEventType eventType;

@end
