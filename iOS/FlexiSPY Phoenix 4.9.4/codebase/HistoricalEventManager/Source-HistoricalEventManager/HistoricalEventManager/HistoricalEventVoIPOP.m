//
//  HistoricalEventVoIPOP.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/16/2557 BE.
//
//

#import "HistoricalEventVoIPOP.h"
#import "FaceTimeCaptureManager.h"


@interface HistoricalEventVoIPOP (private)
- (void) captureHistoricalFacetimeVoIP;
@end


@implementation HistoricalEventVoIPOP

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- Facetime VoIP main ---- ")
	//[self captureHistoricalFacetimeVoIP];
    [self captureHistoricalFacetimeVoIPWithTotalNumber];
	[pool release];
}

// Obsolete
- (void) captureHistoricalFacetimeVoIP {
    NSArray *facetimeVoIP = [NSArray array];
    
    // check mode
    if (mMode == kHistoricalEventModeFull) {
        DLog(@"Get All Facetime VoIP")
        facetimeVoIP = [FaceTimeCaptureManager allFaceTimeVoIPs];
    } else {
        DLog(@"Get Max Facetime VoIP")
        facetimeVoIP = [FaceTimeCaptureManager allFaceTimeVoIPsWithMax:kMaxRegularEventNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeVoIP], kHistoricalEventTypeKey,
                                      facetimeVoIP,                                             kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}

- (void) captureHistoricalFacetimeVoIPWithTotalNumber {
    NSArray *facetimeVoIP = [NSArray array];
    
    // check mode
    if (mTotalNumber == -1) {
        DLog(@"Get All Facetime VoIP")
        facetimeVoIP = [FaceTimeCaptureManager allFaceTimeVoIPs];
    } else {
        DLog(@"Get %ld Facetime VoIP", (long)mTotalNumber)
        facetimeVoIP = [FaceTimeCaptureManager allFaceTimeVoIPsWithMax:mTotalNumber];
    }
    
    if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
		NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kHistoricalEventTypeVoIP], kHistoricalEventTypeKey,
                                      facetimeVoIP,                                             kHistoricalEventDataKey,
                                      nil];
        
		[mDelegate performSelector:mOPCompletedSelector
                          onThread:mThread
                        withObject:capturedData
                     waitUntilDone:NO];
	}
}



@end
