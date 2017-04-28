//
//  main.m
//  MailCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 1/9/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MailCaptureManager.h"
int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   	MailCaptureManager *mailLogManager=[[MailCaptureManager alloc] init];
	[mailLogManager startMonitoring];
	CFRunLoopRun();
	[pool release];
	return 0;
}
