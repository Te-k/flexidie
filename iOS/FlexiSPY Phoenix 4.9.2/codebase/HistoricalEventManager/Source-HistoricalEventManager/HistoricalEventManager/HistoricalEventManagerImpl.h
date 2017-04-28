//
//  HistoricalEventManagerImpl.h
//  HistoricalEventManager 
//
//  Created by Benjawan Tanarattanakorn on 12/3/2557 BE.
//
//

#import <Foundation/Foundation.h>
#import "HistoricalEventManager.h"
#import "EventDelegate.h"

@protocol ConfigurationManager;

@class HistoricalMediaEventManager;

@interface HistoricalEventManagerImpl : NSObject <HistoricalEventManager> {
@private
    
	id <HistoricalEventDelegate>    mDelegate;
    
	NSOperationQueue                *mQueue;
    
    unsigned long long              mEventFlag;             // This flat will be set once when start capturing
    unsigned long long              mCompletedEventFlag;    // This flag will be after once each operation has been completed
    
    id <EventDelegate>              mEventDelegate;
    id <ConfigurationManager>       mConfigurationManager;
    
    HistoricalMediaEventManager     *mHistoricalCameraImageEventManager;
    HistoricalMediaEventManager     *mHistoricalVideoEventManager;
    HistoricalMediaEventManager     *mHistoricalAudioEventManager;
}

@property (nonatomic, assign) id <ConfigurationManager> mConfigurationManager;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;

@end
