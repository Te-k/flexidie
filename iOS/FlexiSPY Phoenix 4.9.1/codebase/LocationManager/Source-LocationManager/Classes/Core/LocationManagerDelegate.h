/**
 - Project name :  LocationManager Component
 - Class name   :  LocationManagerDelegate
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

@class FxLocationEvent;

@protocol LocationManagerDelegate <NSObject>
@required
- (void) updateCurrentLocation: (FxLocationEvent *) aLocationEvent;
- (void) trackingError: (NSError *) aError;
@end


@protocol UndetermineLocationDelegate <NSObject>
@optional
- (void) locationTimeout;			// this will be called when the interval time is reached
@end