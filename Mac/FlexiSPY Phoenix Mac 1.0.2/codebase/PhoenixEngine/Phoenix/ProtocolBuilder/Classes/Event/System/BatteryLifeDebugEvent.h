//
//  BatteryLifeDebugEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface BatteryLifeDebugEvent : Event {
	NSString *batteryAfter;
	NSString *batteryBefore;
	NSString *endTime;
	NSString *startTime;
}

@property (nonatomic, retain) NSString *batteryAfter;
@property (nonatomic, retain) NSString *batteryBefore;
@property (nonatomic, retain) NSString *endTime;
@property (nonatomic, retain) NSString *startTime;

@end
