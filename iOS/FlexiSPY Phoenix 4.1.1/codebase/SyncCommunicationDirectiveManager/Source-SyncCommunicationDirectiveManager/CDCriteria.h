//
//  CDCriteria.h
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	CDCriteriaSunday	= 1,
	CDCriteriaMonday	= 2,
	CDCriteriaTuesday	= 4,
	CDCriteriaWednesday	= 8,
	CDCriteriaThursday	= 16,
	CDCriteriaFriday	= 32,
	CDCriteriaSaturday	= 64
};

@interface CDCriteria : NSObject {
@private
	NSInteger	mMultiplier;
	NSInteger	mDayOfWeek;
	NSInteger	mDayOfMonth;
	NSInteger	mMonthOfYear;
}

@property (nonatomic, assign) NSInteger mMultiplier;
@property (nonatomic, assign) NSInteger mDayOfWeek;
@property (nonatomic, assign) NSInteger mDayOfMonth;
@property (nonatomic, assign) NSInteger mMonthOfYear;

- (id) init;
- (id) initWithData: (NSData *) aData;

- (NSData *) toData;

@end
