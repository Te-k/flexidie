/**
 - Project name :  LocationManager Component
 - Class name   :  LocationManagerWifiStatus
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 **/

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface LocationManagerWifiStatus : NSObject {
@private
	SCNetworkReachabilityRef reachabilityRef;
}

- (BOOL) getWifiStatus;
@end
