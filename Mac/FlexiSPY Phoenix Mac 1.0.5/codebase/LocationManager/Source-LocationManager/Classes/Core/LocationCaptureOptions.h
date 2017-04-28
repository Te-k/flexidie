/**
 - Project name :  LocationManager Component
 - Class name   :  LocationCaptureOptions
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

@protocol LocationCaptureOptions <NSObject> 
@optional
/*
 Note: Make sure that aIntervalTime is always greater than or equal aAtiveTime
 */
- (void) setIntervalTime: (NSUInteger) aIntervalTime; // In seconds
- (void) setLocationServicesActiveTime: (NSUInteger) aActiveTime; // In seconds
@end

