//
//  HistoricalCallLog.h
//  CallLogCapture
//
//  Created by Benjawan Tanarattanakorn on 12/16/2557 BE.
//
//

#import "CallLog.h"

@interface HistoricalCallLog : CallLog {
@private
    NSDate *mDate;
}

@property (nonatomic, retain) NSDate *mDate;

@end
