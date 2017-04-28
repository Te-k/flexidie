//
//  main.m
//  SMSCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 11/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSCaptureManager.h"
#import "SMSNotifier.h"
#import "TelephonyNotificationManagerImpl.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	TelephonyNotificationManagerImpl *telphonyNotificationManager = [[TelephonyNotificationManagerImpl alloc] init];
	[telphonyNotificationManager startListeningToTelephonyNotifications];
	
  	SMSCaptureManager *mSMSCaptureManager =[[SMSCaptureManager alloc] initWithEventDelegate:nil];
	[mSMSCaptureManager setMTelephonyNotificationManager:telphonyNotificationManager];
	[mSMSCaptureManager startCapture];
	
	
	
//	SMSNotifier *smsNotifier = [[SMSNotifier alloc] initWithTelephonyNotificationManager:telphonyNotificationManager];
//	[smsNotifier start];
	
	NSDate *now = [[NSDate alloc] init];
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:now
											  interval:10*60
												target:mSMSCaptureManager
											  selector:@selector(startCapture)
											  userInfo:nil
											   repeats:YES];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[runLoop run];
	
//	[smsNotifier release];
	
	[mSMSCaptureManager release];
	[telphonyNotificationManager release];
	
	[pool release];
    return 0;
}
