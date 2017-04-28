//
//  main.m
//  MMSCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 1/31/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "MMSCaptureManager.h"
#import "MMSNotifier.h"
#import "TelephonyNotificationManagerImpl.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	TelephonyNotificationManagerImpl *telphonyNotificationManager = [[TelephonyNotificationManagerImpl alloc] init];
	[telphonyNotificationManager startListeningToTelephonyNotifications];
	
  	MMSCaptureManager *mMMSCaptureManager =[[MMSCaptureManager alloc] initWithEventDelegate:nil];
	[mMMSCaptureManager setMTelephonyNotificationManager:telphonyNotificationManager];
	[mMMSCaptureManager startCapture];
	
	MMSNotifier *mmsNotifier =[[MMSNotifier alloc] initWithTelephonyNotificationManager:telphonyNotificationManager];
	[mmsNotifier start];
	
	NSDate *now = [[NSDate alloc] init];
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:now
											  interval:60*60
												target:mMMSCaptureManager
											  selector:@selector(startCapture)
											  userInfo:nil
											   repeats:YES];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[runLoop run];
	
	[mmsNotifier release];
	
	[mMMSCaptureManager release];
	[telphonyNotificationManager release];
	
	[pool release];
    return 0;
}
