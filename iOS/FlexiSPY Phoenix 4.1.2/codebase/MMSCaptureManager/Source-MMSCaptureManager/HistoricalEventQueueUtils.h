//
//  HistoricalEventQueueUtils.h
//  MMSCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 12/25/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface HistoricalEventQueueUtils : NSObject {
@private
    NSOperationQueue *mQueue;
}

+ (HistoricalEventQueueUtils*) sharedHistoricalEventQueueUtils;

@property (nonatomic, retain) NSOperationQueue *mQueue;

@end
