/**
 - Project name :  LocationManager Component
 - Class name   :  LocationCaptureOperation
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class FxLocationEvent;
@class LocationManagerWifiStatus;
@class LocationManagerImpl;

// create a structure for identifying mode of location tracking.
typedef enum  
{
	kModeUnknown,
	kModeTracking,
	kModeInterval,
}   Operation;

@interface LocationCaptureOperation : NSObject <CLLocationManagerDelegate> {
	id                           mTarget;
	SEL                          mDidFinishSelector;
	SEL                          mDidUpdateSelector;
	SEL                          mDidFailureSelector;
	SEL                          mDidLocationTimeoutSelector;
	CLLocation					*mCapturedLocation;
@private
	CLLocationManager			*mLocationManager;
	LocationManagerWifiStatus	*mLocationWifiStatus;
}	 

@property (nonatomic,assign) id mTarget;
@property (nonatomic,assign) SEL mDidFinishSelector;
@property (nonatomic,assign) SEL mDidUpdateSelector;
@property (nonatomic,assign) SEL mDidFailureSelector;
@property (nonatomic,assign) SEL mDidLocationTimeoutSelector;
@property (nonatomic,retain) CLLocationManager* mLocationManager;
@property (nonatomic,retain) CLLocation* mCapturedLocation;

- (id) initWithTarget:(LocationManagerImpl *) aTarget; 
- (void) run;
- (void) cancelCurrentOperation;
@end
