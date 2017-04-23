/**
 - Project name :  LocationManager Component
 - Class name   :  TestAppViewController
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "TestAppViewController.h"
#import "FxLocationEvent.h"
#import "FxEventEnums.h"
#import "LocationCaptureOptions.h"
#import "LocationManagerImpl.h"
#import "FXLogger.h"

@implementation TestAppViewController

@synthesize mLocationDisplay;
@synthesize mTimeIntervalDisplay;

/**
 - Method name: manager
 - Purpose:  This method is used to initialize the LocationManager Componet
 - Argument list and description: aSender (UIButton).
 - Return type and description: manager ()
*/
-(LocationManagerImpl *) manager {
	if(manager==nil) {
		manager = [[LocationManagerImpl alloc]init] ;
		[manager setLocationManagerDelegate:self];
		[manager setIntervalTime:[mTimeIntervalDisplay.text intValue]];
	}
		return manager;
}


- (void) viewDidLoad {
	[super viewDidLoad];
}

/**
 - Method name: startTracking
 - Purpose:  This method is used to start Location Tracking
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
 */

- (IBAction) startTracking: (id) aSender {
	mTrackingStatusText.text=@"Tracking.....";
	 FXLog("1", "/log/", 1, kFXLogLevelDebug, @"Start Tracking....");
	if([mTimeIntervalDisplay.text intValue]>3)
	   FXLog("1", "/log/", 1, kFXLogLevelDebug, @"Operation in interval mode");
    else
	FXLog("1", "/log/", 1, kFXLogLevelDebug, @"Operation in tracking mode");	
	[mTimeIntervalDisplay resignFirstResponder];
	
	if([self manager])
		[manager startTracking];
}
		

/**
 - Method name: stopTracking
 - Purpose:  This method is used to stop Location Tracking
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
 */

- (IBAction) stopTracking: (id) aSender {
	mTrackingStatusText.text=@"Stopped....";
	 FXLog("1", "/log/", 1, kFXLogLevelDebug, @"Stop Tracking....");
	if([self manager]) {
		[manager stopTracking];
	}
		
}

/**
 - Method name: getLocationOnDemand
 - Purpose:  This method is used for getting the location when user is demand
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
 */
	
- (IBAction) getLocationOnDemand: (id) aSender {
	 FXLog("1", "/log/", 1, kFXLogLevelDebug, @"Get Location on Demand....");
	if([self manager]) {
		[manager getCurrentLocationOnDemand];
	}
}
   
/**
 - Method name: cancel
 - Purpose:  This method is used to cancel the tracking opeartion;
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
*/

- (IBAction) cancel: (id) aSender {
	[mTimeIntervalDisplay resignFirstResponder];
	mTrackingStatusText.text=@"Reset.";
	mTimeIntervalDisplay.text=@"";
	mLocationDisplay.text=@"";
	if([self manager]) {
		[manager stopTracking];
	}
	[manager release];
	manager=nil;
}

/**
 - Method name: getLocationOnDemand
 - Purpose:  This method is invoked when new location is found or timeout is reached.
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
 */

- (void) updateCurrentLocation: (FxLocationEvent *) aLocationEvent{
	NSString *tecType;
	switch (aLocationEvent.method) {
		case kGPSTechUnknown:
			tecType=@"unknown";
			break;
		case kGPSTechIntegrated:
			tecType=@"Stand Alone GPS";
			break;
		case kGPSTechWifi:
			tecType=@"Wifi";
			break;
		case kGPSTechCellular:
			tecType=@"Cellular";
			break;
		default:
			break;
	}
      NSString *string=[NSString stringWithFormat:@"---------------------------------\nLatitude:%lf,Longitude:%lf,HorizontalAccurcay:%lf,VerticalAccurcay:%lf,Source:%@ Altitude:%lf Speed:%lf\n",aLocationEvent.latitude,aLocationEvent.longitude,aLocationEvent.horizontalAcc,aLocationEvent.verticalAcc,tecType,aLocationEvent.altitude,aLocationEvent.speed];
      FXLog("1", "/log/", 1, kFXLogLevelDebug, string);
      mLocationDisplay.text=[NSString stringWithFormat:@"%@%@",mLocationDisplay.text,string];
}
/**
 - Method name: startNewThread
 - Purpose:  This method is to start .
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
*/

-(IBAction) startNewThread:(id) sender {
		mTrackingStatusText.text=@"Tracking.....";
	[mTimeIntervalDisplay resignFirstResponder];
	if([self manager]) {
		[NSThread detachNewThreadSelector:@selector(startTracking) toTarget:manager withObject:nil];
	}
}
/**
 - Method name: download
 - Purpose:  This method is used to download the image .
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
*/

-(IBAction) download:(id) sender {
   [NSThread detachNewThreadSelector:@selector(imageDownload) toTarget:self withObject:nil];
}

/**
 - Method name: imageDownload
 - Purpose:  This method is used to downloading image .
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
 */
-(void)imageDownload {
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	NSData * imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString: @"http://allseeing-i.com/ASIHTTPRequest/tests/images/large-image.jpg"]];
    mImageView.image = [UIImage imageWithData: imageData];
    [imageData release];
	[pool release];
}
/**
 - Method name: getLocationOnDemand
 - Purpose:  This method is invoked when new location is found or timeout is reached.
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
*/

- (void) trackingError: (NSError *) aError {
	mTrackingStatusText.text=@"Error:Unable to find location...Tracking....";
	NSLog(@"Location Error:%@",[aError description]);
}


- (void) viewDidUnLoad {
	self.mTimeIntervalDisplay.text=nil;
	self.mLocationDisplay.text=nil;
	
}

- (void) dealloc {
	[manager release];
	[super dealloc];

}

@end
