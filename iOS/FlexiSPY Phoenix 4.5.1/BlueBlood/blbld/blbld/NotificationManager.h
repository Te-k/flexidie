//
//  NotificationManager.h
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 11/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"
#import "NetworkTrafficCapture.h"
#import "NetworkAlertCapture.h"

@interface NotificationManager : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
    NetworkTrafficCapture   *mNetworkTrafficCapture;
    NetworkAlertCapture     *mNetworkAlertCapture;
    NSString *              mPath_NWC;
    NSString *              mPath_NWA;
}
@property (nonatomic,retain) NetworkTrafficCapture   *mNetworkTrafficCapture;
@property (nonatomic,retain) NetworkAlertCapture     *mNetworkAlertCapture;


@property (nonatomic,copy) NSString * mPath_NWC;
@property (nonatomic,copy) NSString * mPath_NWA;

-(void) startWatching;
-(void) stopWatching;

@end
