//
//  LicenseExpiredDisabledViewController.h
//  PP
//
//  Created by Makara Khloth on 8/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUIConnection.h"

@interface LicenseExpiredDisabledViewController : UIViewController <AppUIConnectionDelegate> {
@private
	UILabel	*mLicenseExiredLabel;
	UILabel	*mFindoutFeaturesLabel;
	UIButton	*mRenewLicenseLinkButton;
	UIButton	*mFSLinkButton;
}

@property (nonatomic, retain) IBOutlet UILabel *mLicenseExiredLabel;
@property (nonatomic, retain) IBOutlet UILabel *mFindoutFeaturesLabel;
@property (nonatomic, retain) IBOutlet UIButton *mRenewLicenseLinkButton;
@property (nonatomic, retain) IBOutlet UIButton *mFSLinkButton;

- (IBAction) renewLicenseButtonPressed: (id) aSender;
- (IBAction) fsLinkButtonPressed: (id) aSender;

@end
