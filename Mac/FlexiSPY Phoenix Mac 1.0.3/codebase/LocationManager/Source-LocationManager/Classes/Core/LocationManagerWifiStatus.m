/**
 - Project name :  LocationManager Component
 - Class name   :  LocationManagerWifiStatus
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "LocationManagerWifiStatus.h"
#import <netinet/in.h>

@implementation LocationManagerWifiStatus
 
 /**
 - Method name: init
 - Purpose: This method is used for Initializing LocationManagerSettings Class
 - Argument list and description: No argument.
 - Return type and description:id(LocationManager object)
 */

- (id) init {
	self = [super init];
	if (self != nil) {
	 //Initializing class instances
	}
	return self;
}

 /**
 - Method name: getWifiStatus
 - Purpose:  This method is used to get the Wifi status.
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (BOOL) getWifiStatus {
	BOOL localWiFiRef=NO;
	struct sockaddr_in localWifiAddress;
	SCNetworkReachabilityFlags flags;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	//IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	 reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*) &localWifiAddress);
	if(reachabilityRef!=NULL) {
		if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))  {
			if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
				localWiFiRef=YES;
			}
		}			
	}
	return localWiFiRef;
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: aManager (CLLocationManager instance ),aNewLocation(CLLocation instance),aOldLocation(aOldLocation)
 - Return type and description: No Return
 */

- (void) dealloc {
	if(reachabilityRef!= NULL){
		CFRelease(reachabilityRef);
	}
	[super dealloc];
}

@end
