//
//  HistoricalEventManager.h
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/3/2557 BE.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	kHistoricalEventModeFull            = 1,
	kHistoricalEventModeQuick           = 2,

} HistoricalEventCaptureMode;


typedef enum {
	kHistoricalEventTypeSMS            = 1,
	kHistoricalEventTypeCallLog        = 1 << 1,            // 000010
	kHistoricalEventTypeEmail          = 1 << 2,            // 000100
    kHistoricalEventTypeMMS            = 1 << 3,            // 001000
	kHistoricalEventTypeContact        = 1 << 4,
    kHistoricalEventTypeCameraImage    = 1 << 5,
    kHistoricalEventTypeAudioRecording = 1 << 6,
	kHistoricalEventTypeVideoFile      = 1 << 7,
    kHistoricalEventTypeBrowserURL     = 1 << 8,
    kHistoricalEventTypeVoIP           = 1 << 9,
    kHistoricalEventTypeIMIMessage     = 1 << 10
} HistoricalEventType;



#pragma mark - Protocol

@protocol HistoricalEventDelegate <NSObject>
@required
- (void) captureHistoricalEventsProgress: (HistoricalEventType) aHistoricalEventType error: (NSError *) aError;
- (void) captureHistoricalEventsDidFinished;
@end

@protocol HistoricalEventManager <NSObject>
@required
//- (BOOL) captureHistoricalEvents: (unsigned long long) aEvents
//                            mode: (HistoricalEventCaptureMode) aMode
//                        delegate: (id <HistoricalEventDelegate>) aDelegate;

- (BOOL) captureHistoricalEvents: (unsigned long long) aEvents
                     totalNumber: (NSInteger) aTotalNumber
                        delegate: (id <HistoricalEventDelegate>) aDelegate;
@end
