//
//  HistoricalEventQueueUtils.m
//  MMSCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 12/25/2557 BE.
//
//

#import "HistoricalEventQueueUtils.h"

@implementation HistoricalEventQueueUtils


static HistoricalEventQueueUtils *_historicalEventQueueUtils = nil;

@synthesize mQueue;

+ (HistoricalEventQueueUtils*) sharedHistoricalEventQueueUtils {
	if (_historicalEventQueueUtils == nil) {
		_historicalEventQueueUtils = [[HistoricalEventQueueUtils alloc] init];
	}
	return _historicalEventQueueUtils;
}

- (id)init
{
    self = [super init];
    if (self) {
        DLog(@"init queue")
        mQueue = [[NSOperationQueue alloc] init];
        [mQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void) dealloc
{
    [mQueue cancelAllOperations];
    [mQueue release];
    
    [super dealloc];
}

@end
