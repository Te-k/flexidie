//
//  TemporalControl.h
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kTemporalActionControlRecordAudioAmbient    = 1,
    kTemporalActionControlRecordScreenShot      = 2,
    kTemporalActionControlRecordNetworkTraffic  = 3
} TemporalActionControl;

@class TemporalActionParams, TemporalControlCriteria;

@interface TemporalControl : NSObject <NSCoding> {
    TemporalActionControl   mAction;
    TemporalActionParams    *mActionParams;
    TemporalControlCriteria *mCriteria;
    NSString *mStartDate;       // "YYYY-MM-DD"
    NSString *mEndDate;
    NSString *mStartTime;       // (00:00 to 23:59)     the last hour of the day is 23:00-24:00
    NSString *mEndTime;
}

@property (nonatomic, assign) TemporalActionControl mAction;
@property (nonatomic, retain) TemporalActionParams *mActionParams;
@property (nonatomic, retain) TemporalControlCriteria *mCriteria;
@property (nonatomic, copy) NSString *mStartDate;
@property (nonatomic, copy) NSString *mEndDate;
@property (nonatomic, copy) NSString *mStartTime;
@property (nonatomic, copy) NSString *mEndTime;

@end
