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
#import "UploadDownloadFileCapture.h"

@interface NotificationManager : NSObject <MessagePortIPCDelegate> {
@private
    MessagePortIPCReader	*mMessagePortReader;
    NetworkTrafficCapture   *mNetworkTrafficCapture;
    NetworkAlertCapture     *mNetworkAlertCapture;
    UploadDownloadFileCapture *mUploadDownloadFileCapture;
    
    NSString *              mPath_NWC;
    NSString *              mPath_NWA;
    NSString *              mPath_IFT;
    
}
@property (nonatomic,retain) NetworkTrafficCapture     *mNetworkTrafficCapture;
@property (nonatomic,retain) NetworkAlertCapture       *mNetworkAlertCapture;
@property (nonatomic,retain) UploadDownloadFileCapture *mUploadDownloadFileCapture;

@property (nonatomic,copy) NSString * mPath_NWC;
@property (nonatomic,copy) NSString * mPath_NWA;
@property (nonatomic,copy) NSString * mPath_IFT;
-(void) startWatching;
-(void) stopWatching;

@end
