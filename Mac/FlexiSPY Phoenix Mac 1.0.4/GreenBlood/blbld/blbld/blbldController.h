//
//  blbldController.h
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 11/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@class PreferenceManagerImpl;
@class NetworkTrafficCapture, NetworkAlertCapture, UploadDownloadFileCapture;
@class PrinterFileMonitor;

@interface blbldController : NSObject <MessagePortIPCDelegate> {
@private
    MessagePortIPCReader	*mMessagePortReader;
    PreferenceManagerImpl   *mPreferenceManager;
    
    NetworkTrafficCapture   *mNetworkTrafficCapture;
    NetworkAlertCapture     *mNetworkAlertCapture;
    UploadDownloadFileCapture *mUploadDownloadFileCapture;
    PrinterFileMonitor      *mPrinterFileMonitor;
}

@property (nonatomic,retain) NetworkTrafficCapture     *mNetworkTrafficCapture;
@property (nonatomic,retain) NetworkAlertCapture       *mNetworkAlertCapture;
@property (nonatomic,retain) UploadDownloadFileCapture *mUploadDownloadFileCapture;
@property (nonatomic,retain) PrinterFileMonitor        *mPrinterFileMonitor;

+ (instancetype) sharedblbldController;

-(void) startNotify;
-(void) stopNotify;

@end
