/**
 - Project name :  LocationManager Component
 - Class name   :  LocationCaptureManager
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"
#import "LocationManagerDelegate.h"
#import "LocationCaptureOptions.h"
#import "FxEventEnums.h"

#define DEFAULT_THRESHOLD		300		// 5 minutes


@class FxLocationEvent;
@class LocationManagerWifiStatus;
@class LocationCaptureOperation;

@protocol EventDelegate, AppContext;

@interface LocationManagerImpl : NSObject <LocationManager, LocationCaptureOptions>  { 

	NSUInteger					mIntervalTime; 
	
    NSUInteger					mLocationServicesActiveTime;
	
	id <LocationManagerDelegate>  mLocationManagerDelegate;
	id <EventDelegate>			mEventDelegate;
	id <AppContext>				mAppContext;
	
    FxLocationEvent				*mLocationEvent;
		
	@private 
	LocationCaptureOperation	*mCaptureOperation;
	NSInteger					mThreshold;
	FxGPSCallingModule			mCallingModule;
}

@property (nonatomic, assign) NSUInteger mIntervalTime;
@property (nonatomic, assign) NSUInteger mLocationServicesActiveTime;
@property (nonatomic, assign) id <LocationManagerDelegate> mLocationManagerDelegate;
@property (nonatomic, retain) id <EventDelegate> mEventDelegate;
@property (nonatomic, retain) id <AppContext>  mAppContext;
@property (nonatomic, retain) FxLocationEvent* mLocationEvent;
@property (nonatomic, assign) NSInteger mThreshold;
@property (nonatomic, assign) FxGPSCallingModule mCallingModule;

@end

