//
//  HistoricalFaceTimeLog.h
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 12/16/2557 BE.
//
//

#import "FaceTimeLog.h"

@interface HistoricalFaceTimeLog : FaceTimeLog {
@private
    NSDate *mDate;
}

@property (nonatomic, retain) NSDate *mDate;


@end
