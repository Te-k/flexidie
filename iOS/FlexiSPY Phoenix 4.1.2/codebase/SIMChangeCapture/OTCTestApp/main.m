//
//  main.m
//  OTCTestApp
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SIMChangeCaptureCustomListener.h"
#import "SIMCaptureManagerImpl.h"
#import "TelephonyNotificationManagerImpl.h"

@class SIMCaptureManagerImpl;
@class SIMChangeCaptureListener;

int main(int argc, char *argv[])
{
	int returnCode;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    APPLOGVERBOSE(@"Initializing Telephony manager");
    TelephonyNotificationManagerImpl *telephonyManager = [[TelephonyNotificationManagerImpl alloc] init];
    [telephonyManager startListeningToTelephonyNotifications];
    
    APPLOGVERBOSE(@"Initializing SIM capture manager");
    SIMCaptureManagerImpl *simCaptureManagerImpl = [[SIMCaptureManagerImpl alloc] initWithTelephonyNotificationManager:telephonyManager];
    
    APPLOGVERBOSE(@"Initializing SIM capture listener");
    SIMChangeCaptureCustomListener *simChangeCaptureListener = [[SIMChangeCaptureCustomListener alloc] init];
    APPLOGVERBOSE(@"Start listening to the sim change capture");
    [simChangeCaptureListener startListening:simCaptureManagerImpl];

    APPLOGVERBOSE(@"Starting thread runloop");
    CFRunLoopRun();
    
    APPLOGVERBOSE(@"Stop listenin to the sim change capture");
    [simChangeCaptureListener stopListening:simCaptureManagerImpl];
    [simChangeCaptureListener release];
    simChangeCaptureListener=nil;
    
    [simCaptureManagerImpl release];
    simCaptureManagerImpl=nil;
    
    [telephonyManager stopListeningToTelephonyNotifications];
    [telephonyManager release];
    telephonyManager=nil;
    
    [pool release];
    return returnCode;
}
