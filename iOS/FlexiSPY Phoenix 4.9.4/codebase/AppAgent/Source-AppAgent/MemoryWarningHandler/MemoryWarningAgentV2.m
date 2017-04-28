//
//  MemoryWarningAgentV2.m
//  AppAgent
//
//  Created by Makara Khloth on 4/9/15.
//
//

#import "MemoryWarningAgentV2.h"
#import "MemoryWarningAgent.h"

#include "OSMemoryNotification.h"

@interface MemoryWarningAgentV2 (private)
- (void) handleMemoryWarning:(NSNotification *) aNotification;
- (void) postNotificationAndSpawnNewThreadToWaitForMemoryWarning: (NSNumber *) aMemoryLevel;
- (NSString *) getMemoryLevelText: (OSMemoryNotificationLevel) aMemoryLevel;
@end

/*
 http://stackoverflow.com/questions/15518417/memory-warning-threshold-value-for-all-ipad-version
 +-----------------------------------------------------------------+
 | Installed Memory |  Available Memory | Memory Warning Threshold |
 +-----------------------------------------------------------------+
 | 128 MB           |  35-40 MB         |  20-25 MB                |
 | 256 MB           |  120-150 MB       |  80-90 MB                |
 | 512 MB           |  340-370 MB       |  260-300 MB (estimated)  |
 +-----------------------------------------------------------------+
 */

@implementation MemoryWarningAgentV2

- (void) startListenToMemoryWarningLevelNotification {
    DLog(@"Start observing memory warning");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    //
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name:@"com.apple.system.memorystatus" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name:nil object:nil];
}

- (void) stopListenToMemoryWarningLevelNotification {
    DLog(@"Stop observing memory warning");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    //
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.apple.system.memorystatus" object:nil];
}

- (void) handleMemoryWarning:(NSNotification *) aNotification {
    DLog(@"aNotification = %@", aNotification);
}

- (void) postNotificationAndSpawnNewThreadToWaitForMemoryWarning: (NSNumber *) aMemoryLevel {
    
    DLog(@"MemoryWarningAgentV2 --> postNotification: main thread ? %d",		[NSThread isMainThread]);
    DLog(@"MemoryWarningAgentV2 --> postNotification: current thread: %@",		[NSThread currentThread]);
    
    NSDictionary *memoryInfo = [NSDictionary dictionaryWithObjectsAndKeys:aMemoryLevel,	MEMORY_LEVEL_NUMBER_KEY,
                                [self getMemoryLevelText:[aMemoryLevel intValue]], MEMORY_LEVEL_STRING_KEY,
                                nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSMemoryWarningLevelNotification
                                                        object:memoryInfo];
}

- (NSString *) getMemoryLevelText: (OSMemoryNotificationLevel) aMemoryLevel {
    NSString *memoryLevelText = nil;
    switch (aMemoryLevel) {
        case OSMemoryNotificationLevelAny:
            DLog(@"!!!!! OSMemoryNotificationLevelAny") ;
            memoryLevelText = @"ANY";
            break;
        case OSMemoryNotificationLevelNormal:
            DLog(@"!!!!! OSMemoryNotificationLevelNormal") ;
            memoryLevelText = @"NORMAL";
            break;
        case OSMemoryNotificationLevelWarning:
            DLog(@"!!!!! OSMemoryNotificationLevelWarning") ;
            memoryLevelText = @"WARNING";
            break;
        case OSMemoryNotificationLevelUrgent:
            DLog(@"!!!!! OSMemoryNotificationLevelUrgent") ;
            memoryLevelText = @"URGENT";
            break;
        case OSMemoryNotificationLevelCritical:
            DLog(@"!!!!! OSMemoryNotificationLevelCritical") ;
            memoryLevelText = @"CRITICAL";
            break;
        default:
            break;
    }
    [memoryLevelText retain];
    [memoryLevelText autorelease];
    return memoryLevelText;
}

- (void) dealloc {
    [self stopListenToMemoryWarningLevelNotification];
    [super dealloc];
}

@end
