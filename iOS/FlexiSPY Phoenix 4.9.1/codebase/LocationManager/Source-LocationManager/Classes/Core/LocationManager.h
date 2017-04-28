/**
 - Project name :  LocationManager Component
 - Class name   :  LocationManager
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 **/

#import "LocationManagerDelegate.h"

@protocol EventDelegate;

@protocol LocationManager <NSObject> 
@optional
- (void) setEventDelegate: (id <EventDelegate>) aDelegate;
- (void) setLocationManagerDelegate:(id <LocationManagerDelegate>) aDelegate;
- (void) startTracking;
- (void) stopTracking;
- (void) getCurrentLocationOnDemand;
@end
