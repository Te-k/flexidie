//
//  TelephonyNotificationListener.h
//  OTCTestApp
//
//  Created by Syam Sasidharan on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TelephonyNotificationManager.h"
#import "FXLoggerHelper.h"

@interface TelephonyNotificationListener : NSObject {
    
@private
    id <TelephonyNotificationManager> mManager;

}

- (void)addListeners:(id)aManager;
- (void)cleanUp;

@end
