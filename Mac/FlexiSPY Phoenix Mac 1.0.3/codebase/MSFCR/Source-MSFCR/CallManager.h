//
//  CallManager.h
//  MSFCR
//
//  Created by Makara Khloth on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Telephony.h"

@class TelephonyNotificationManagerImpl;

@interface CallManager : NSObject {
@private
	TelephonyNotificationManagerImpl	*mTelephonyNotificationManager;
	
	CTCall	*mCurrentCall;
}

@property (nonatomic, readonly) TelephonyNotificationManagerImpl *mTelephonyNotificationManager;

+ (id) sharedCallManager;

@end
