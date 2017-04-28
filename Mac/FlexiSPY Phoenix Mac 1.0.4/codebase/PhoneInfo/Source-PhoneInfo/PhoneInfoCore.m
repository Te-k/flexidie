//
//  PhoneInfoCore.m
//  PhoneInfo
//
//  Created by Dominique  Mayrand on 10/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhoneInfoCore.h"
#import "UIDevice-IOKitExtensions.h"
//#import "PhoneInfoExtensions.h"
#import "GetCellInfo.h"
#import "CTTelephonyNetworkInfo.h"
#import "CTCarrier.h"
#import "CoreTelephonyS.h"

@implementation PhoneInfoCore

@synthesize mIMEI, mMEID;


/* To retreive IMSI, Phonenumber and IMEI*/
struct CTServerConnection *sc = NULL;
struct CTResult result;

extern NSString *CTSIMSupportCopyMobileSubscriberIdentity();
extern NSString *CTSettingCopyMyPhoneNumber();

void callback2() { NSLog(@"Callback2"); }
/* ****************************************/


-(NSString*) getIMEI
{
	// #1 First look if the IMEI is already in the persistent datababse
	
	// #2 ioreg method
	if(mIMEI == nil)
	{
		// If not use ioreg method
		NSLog(@"Allocating UIDevice");
		mIMEI = [[UIDevice currentDevice] imei];
		//self doLog:[[UIDevice currentDevice] imei]];
	}
	
	// #3 Telephony API
	if(mIMEI == nil)
	{
		// This has not been tested on iOS devices 
		NSLog(@"From deviceIdentidy");
		struct CTResult result = {0};
		NSString *deviceIdentity;
		
		NSLog(@"Copy deviceIdentity");
		_CTServerConnectionCopyMobileIdentity(&result, sc, &deviceIdentity);
		mIMEI = deviceIdentity;
		mMEID = deviceIdentity;
		
	}
	NSLog(@"getIMEI returned");
	return mIMEI;
}



-(void) dealloc
{
	NSLog(@"PhoneInfo core dealloc");
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
		NSLog(@"Freeing ServerConnection");
		//_CTServerConnectionDestroy(sc);
		//free(sc);
		NSLog(@"ServerConnection freed");
	}
	[super dealloc];
}

-(id) init
{
	NSLog(@"init PhoneInfoCore");
	self = [super init];
	if(self)
	{
		sc = _CTServerConnectionCreate(kCFAllocatorDefault, callback2, NULL);
		if(sc = NULL)
		{
			NSLog(@"sc not created");
		}
	}
	return self;
}

-(void) getPhoneInfo:(PhoneInfo*) phoneInfo
{
	NSLog(@"getPhoneInfo");
	NSLog(@"setIMEI");
	if(phoneInfo == nil)
	{
		NSLog(@"phoneInfo is nil");
		return;
	}
	
	// Imei is only set once
	if([phoneInfo mIMEI] == nil)
	{
		[phoneInfo setIMEI:[self getIMEI]];
	}
	if([phoneInfo mMEID] == nil)
	{
		
		[phoneInfo setMEID:[self mMEID]];
	}
	
	
	NSLog(@"TelephonyNetworkInfo");
	CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	if(netInfo)
	{
		NSLog(@"Subscriber cellular provider");
		CTCarrier *carrier = [netInfo subscriberCellularProvider];
		NSLog(@"setMCC");
		[phoneInfo setMCC:[carrier mobileCountryCode]];
		NSLog(@"setMNC");
		[phoneInfo setMNC:[carrier mobileNetworkCode]];
		NSLog(@"setCarrierName");
		[phoneInfo setNetworkName:[carrier carrierName]];
		[netInfo release];
	}
	
	NSLog(@"setPhoneNumber");
	NSString *phoneNumber = CTSettingCopyMyPhoneNumber();
	if(phoneNumber)
	{
		[phoneInfo setOwnerPhoneNumber: phoneNumber];
	}else{
		NSLog(@"Search in user default");
		phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
		[phoneInfo setOwnerPhoneNumber: phoneNumber];
	}
	NSLog(@"getPhoneInfo");
}

@end
