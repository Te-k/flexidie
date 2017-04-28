//
//  CommunicationDirectiveCriteria.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/2/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaysOfWeekEnum.h"

@interface CommunicationDirectiveCriteria : NSObject {
	int multiplier;
	DaysOfWeek dayOfWeek;
	int dayOfMonth;
	int monthOfYear;
}

- (id)initWithMultiplier:(int)multi daysOfWeek:(DaysOfWeek)dow dayOfMonth:(int)dom andMonth:(int)month;

@property (nonatomic, assign) DaysOfWeek dayOfWeek;
@property (nonatomic, assign) int dayOfMonth;
@property (nonatomic, assign) int monthOfYear;
@property (nonatomic, assign) int multiplier;

@end
