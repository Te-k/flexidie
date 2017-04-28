//
//  ActivationViewController.h
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivationListener.h"
#import "LicenseChangeListener.h"

@class CommandServiceManager, DataDeliveryManager, CommandMetaData;

@interface ActivationViewController : UIViewController <ActivationListener, LicenseChangeListener>{
	CommandServiceManager*	mCSM;
	DataDeliveryManager*		mDDM;
}

-(IBAction)activate;
-(IBAction)deactivate;
-(IBAction)reqActivate;
-(CommandMetaData *) commandMetaData;
@end

