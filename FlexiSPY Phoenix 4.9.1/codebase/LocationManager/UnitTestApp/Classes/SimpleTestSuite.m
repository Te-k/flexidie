/**
 - Project name :  LocationManager Component
 - Class name   :  SimpleTestSuite
 - Version      :  1.0  
 - Purpose      :  For unit testing Location Tracking Component
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "GHUnit.h"
#import "LocationManagerImpl.h"
#import "LocationCaptureOptions.h"
#import "LocationManagerSettings.h"

@interface SimpleTestSuite : GHTestCase<LocationManagerDelegate,CLLocationManagerDelegate> {
	LocationManagerImpl *locImpl;
}
@end
@implementation SimpleTestSuite

/**
 - Method name: setUpClass
 - Purpose: This method is used for Initalizing the  testing component or Class
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void)setUpClass {
		locImpl = [[LocationManagerImpl alloc] init];
}
/**
 - Method name: tearDownClass
 - Purpose: This method is run at end of all tests in the class
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void)tearDownClass {
	// Run at end of all tests in the class
    [locImpl release];
}

/**
 - Method name: testLocationMangerSetter
 - Purpose: This method is for testing setter in LocationManager Component
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void) testLocationMangerSetter {
    [locImpl setLocationManagerDelegate:self]; 
	GHAssertEqualObjects([locImpl mLocationManagerDelegate], self, @"Successfully done");
	[locImpl setIntervalTime:10*60];
	GHAssertEquals([locImpl mIntervalTime], 10*60, @"Successfully done");
	[locImpl setLocationServicesActiveTime:kActiveTimeThreeMinutesBefore];
	GHAssertEquals([locImpl mLocationServicesActiveTime], kActiveTimeThreeMinutesBefore, @"Successfully done");
	[locImpl setMinimumTimeForIntervalMode:kMinTimeIntervalThreeMinutes];
	GHAssertEquals([locImpl mMinTimeForIntervalMode], kMinTimeIntervalThreeMinutes, @"Successfully done");
	[locImpl setDesiredAccuracy:kDesiredAccuracyBest];
	GHAssertEquals([locImpl mDesiredAccuracy], kDesiredAccuracyBest, @"Successfully done");
}

/**
- Method name: testOperationMode
- Purpose: This method is for testing operation mode in LocationManager Component
- Argument list and description: No argument.
- Return type and description:No return.
*/

-(void)testOperationMode {
	int mode=kModeUnknown;
	if([locImpl mIntervalTime] <[locImpl mMinTimeForIntervalMode])
		mode=kModeTracking;
	else
		mode=kModeInterval;
	GHAssertEquals(mode, kModeInterval, @"Successfully done");
}

/**
 - Method name: testRequestIntervalMode
 - Purpose: This method is for testing request time calculation in locationManager component
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

-(void)testRequestIntervalMode {
	[locImpl setIntervalTime:5*60];
    [locImpl setLocationServicesActiveTime:kActiveTimeThreeMinutesBefore];
	int retVal;
	int requestTime = (int)([locImpl mIntervalTime]-[locImpl mLocationServicesActiveTime]);
	if(requestTime <=0)  {
		retVal=1;
	}
	else if([locImpl mIntervalTime] <=requestTime) {
		retVal= 1;
	}
	else {

		retVal=requestTime;
	}
	GHAssertEquals(retVal, requestTime, @"Successfully done");
}

/**
 - Method name: testLocationMangerSettings
 - Purpose: This method is for testing the wifi status in locationManager component
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

-(void) testLocationMangerSettings {
	LocationManagerSettings *settings=[[LocationManagerSettings alloc]init];
	BOOL wifiStatus=[settings getWifiStatus];
	GHAssertEquals(wifiStatus, YES, @"Successfully done");
	[settings release];
}


/**
 - Method name: testIntervalMode
 - Purpose: This method is for testing the interval mode in locationManager component
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void) testIntervalMode  {
	int intervalTime=10;
	int requestTime=3;
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    NSDate* limitDate = [NSDate dateWithTimeIntervalSinceNow:3];
    while ([(NSDate*)[NSDate date] compare:limitDate] == NSOrderedAscending) {
   	//sleep for a small increment then check again
	NSDate* incrementDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
	[NSThread sleepUntilDate:incrementDate];
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval interval = now - startTime;
	int second = (int) interval;
	if(second==(intervalTime-requestTime)) {
		GHAssertEquals(second, YES, @"Start Updating");
	}
}
	
}

/**
 - Method name: testOperationQueue
 - Purpose: This method is for testing the operation queue in locationManager component
 - Argument list and description: No argument.
 - Return type and description:No return.
 */

- (void) testOperationQueue{  
	NSOperationQueue *queue=[[NSOperationQueue alloc]init];
	[queue setSuspended:YES];
	GHAssertEquals([queue isSuspended], YES, @"Successfully done");
	[queue setSuspended:NO];
	GHAssertEquals([queue isSuspended], NO, @"Successfully done");
}

- (void) run {
	
}

# pragma mark LocationManagerDelegate methods
- (void) updateCurrentLocation: (FxLocationEvent *) aLocationEvent {
	
}

- (void) trackingError: (NSError *) aError {
	
}

@end
