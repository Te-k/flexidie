//
//  IMEIGetter.m
//  MSFSP
//
//  Created by Makara Khloth on 6/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IMEIGetter.h"
#import "DefStd.h"
#import "SBTelephonyManager.h"

#define kIMEI @"kCTMobileEquipmentInfoIMEI" 
#define kMEID @"kCTMobileEquipmentInfoMEID"

static IMEIGetter *_IMEIGetter = nil;

@implementation IMEIGetter

+ (id) sharedIMEIGetter {
	if (_IMEIGetter == nil) {
		_IMEIGetter = [[IMEIGetter alloc] init];
	}
	return (_IMEIGetter);
}

+ (NSString *) IMEI {
	Class $SBTelephonyManager = objc_getClass("SBTelephonyManager");
	NSString *IMEI = @"";
	if ([$SBTelephonyManager sharedTelephonyManager]) {
		NSDictionary *deviceInfo = [[$SBTelephonyManager sharedTelephonyManager] copyMobileEquipmentInfo];
		DLog (@"Device info which copied from SBTelephonyManager = %@, return count = %d", deviceInfo, [deviceInfo retainCount])
		if (deviceInfo) {
			DLog (@"Class of device info = %@, self = %@", [deviceInfo class], [deviceInfo self])
			IMEI = [deviceInfo objectForKey:kIMEI];
			if ([IMEI length] == 0) {
				IMEI = [deviceInfo objectForKey:kMEID];
			}
		}
		//[deviceInfo release]; //---> Return by copy name convention by when release is crash, SUCK!
	}
	DLog (@"Got the IMEI %@", IMEI);
	return (IMEI);
}

- (id) init {
	if ((self = [super init])) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kIMEIGetterMessagePort
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	return (self);
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"Request for IMEI is received >>>>")
}

- (NSData *) messagePortReturnData: (NSData*) aRawData {
	DLog (@"Get returned data for IMEI is called >>>>")
	if (mIMEI == nil || [mIMEI length] == 0) {
		mIMEI = [[NSString alloc] initWithString:[IMEIGetter IMEI]];
	}
	return ([mIMEI dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void) dealloc {
	[mIMEI release];
	[mMessagePortReader stop];
	[mMessagePortReader release];
	[super dealloc];
}

@end
