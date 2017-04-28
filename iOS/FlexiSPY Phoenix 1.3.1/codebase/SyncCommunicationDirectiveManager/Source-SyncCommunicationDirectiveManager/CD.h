//
//  CD.h
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDCriteria;

enum {
	kCDBlockCall	= 1,
	kCDBlockSMS		= kCDBlockCall << 1,
	kCDBlockMMS		= kCDBlockCall << 2,
	kCDBlockEmail	= kCDBlockCall << 3,
	kCDBlockIM		= kCDBlockCall << 4
};

enum {
	kCDActionAllow		= 1,
	kCDActionDisAllow	= 2
};

enum {
    
	kRecurrenceDaily = 1,
	kRecurrenceWeekly = 2,
    kRecurrenceMonthly = 3,
    kRecurrenceYearly = 4
    
};

enum {
	kCDDirectionIN	= 1,
	kCDDirectionOUT	= 2,
	kCDDirectionALL	= 3
};

@interface CD : NSObject {
@private
	NSInteger	mRecurrence;
	CDCriteria	*mCDCriteria;
	NSUInteger	mBlockEvents;
	NSString	*mStartDate; // YYYY-MM-DD
	NSString	*mEndDate; // YYYY-MM-DD
	NSString	*mStartTime; // HH:mm, Server sent 24:00 instead of 00:00 thus we override the setter property to handle this case
	NSString	*mEndTime; // HH:mm, Server sent 24:00 instead of 00:00 thus we override the setter property to handle this case
	NSInteger	mAction;
	NSInteger	mDirection;
}

/*
 Note: the logic that we change date time can cause the issue in last day of CD,
 CD with end date as 24:mm:ss never applied
 */

@property (nonatomic, assign) NSInteger mRecurrence;
@property (nonatomic, retain) CDCriteria *mCDCriteria;
@property (nonatomic, assign) NSUInteger mBlockEvents;
@property (nonatomic, copy) NSString *mStartDate;
@property (nonatomic, copy) NSString *mEndDate;
@property (nonatomic, copy) NSString *mStartTime;
@property (nonatomic, copy) NSString *mEndTime;
@property (nonatomic, assign) NSInteger mAction;
@property (nonatomic, assign) NSInteger mDirection;

- (id) init;
- (id) initWithData: (NSData *) aData;

- (NSData *) toData;


- (NSDate *) clientStartDate: (NSString *) aTimeZone;
- (NSDate *) clientEndDate: (NSString *) aTimeZone;

@end
