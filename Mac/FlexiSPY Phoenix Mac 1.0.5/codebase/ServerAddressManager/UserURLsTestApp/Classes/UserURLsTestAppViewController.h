//
//  UserURLsTestAppViewController.h
//  UserURLsTestApp
//
//  Created by Benjawan Tanarattanakorn on 12/20/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerAddressManagerImp;

@interface UserURLsTestAppViewController : UIViewController {
@private
	ServerAddressManagerImp *mServerAddrMgr;
	IBOutlet UILabel *mCurrentIndexLabel;
	IBOutlet UILabel *mStartIndexLabel;
}


@property (nonatomic, retain) IBOutlet UILabel *mCurrentIndexLabel;
@property (nonatomic, retain) IBOutlet UILabel *mStartIndexLabel;

- (IBAction) addUserURLsPressed: (UIButton *) aSender;
- (IBAction) clearUserURLsPressed: (UIButton *) aSender;
- (IBAction) getUserURLsPressed: (UIButton *) aSender;
- (IBAction) increaseCurrentIndexPressed: (UIButton *) aSender;

@end

