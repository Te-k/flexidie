/**
 - Project name :  LocationManager TestApp
 - Class name   :  TestAppViewController
 - Version      :  1.0  
 - Purpose      :  For Testing Location Tracking Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 **/

#import <UIKit/UIKit.h>
#import "LocationManagerImpl.h"
@interface TestAppViewController : UIViewController <LocationManagerDelegate>{

	LocationManagerImpl *manager;
	IBOutlet UITextView*   mLocationDisplay;
	IBOutlet UIButton *    mStartButton;
	IBOutlet UITextField*   mTimeIntervalDisplay;
	IBOutlet UILabel*   mTrackingStatusText;
	IBOutlet UIImageView* mImageView;

}

@property (nonatomic, retain) 	IBOutlet UITextView*  mLocationDisplay;
@property (nonatomic, retain) 	IBOutlet UITextField* mTimeIntervalDisplay;

- (LocationManagerImpl *) manager;
- (IBAction) startTracking: (id) aSender;
- (IBAction) stopTracking: (id) aSender;
- (IBAction) getLocationOnDemand: (id) aSender;
- (IBAction) cancel: (id) aSender;
-(IBAction) startNewThread:(id) sender;
-(IBAction) download:(id) sender;
@end

