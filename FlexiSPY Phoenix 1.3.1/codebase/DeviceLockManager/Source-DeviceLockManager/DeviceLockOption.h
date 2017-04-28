//
//  DeviceLockOption.h
//  DeviceLockManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceLockOption : NSObject {
@private
	BOOL			mEnableAlertSound;
	NSInteger		mLocationInterval;
	NSString		*mDeviceLockMessage;
}


@property (nonatomic, assign) BOOL mEnableAlertSound;
@property (nonatomic, assign) NSInteger mLocationInterval;
@property (nonatomic, retain) NSString *mDeviceLockMessage;

@end
