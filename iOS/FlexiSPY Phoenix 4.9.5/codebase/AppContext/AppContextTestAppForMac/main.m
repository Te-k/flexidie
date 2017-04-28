//
//  main.m
//  AppContextTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AppContextImp.h"
#import "ProductInfoImp.h"
#import "MacInfoImp.h"



unsigned char kProductInfoCipher[] = {0xed,0x7a,0xb0,0x67,0xee,0xf,0xeb,0x59,0x71,0x1d,0x66,0xe0,0x99,
	0x65,0x6c,0xfd,0xa3,0xba,0x76,0xd8,0xa0,0xd,0x29,0x1c,0xc5,0xd6,0xc8,0x9d,0x5a,0x4c,0xbc,0x75,0x2c,
	0xc,0x72,0x5,0x3c,0x8d,0xab,0x41,0xb7,0x6f,0x5c,0x17,0xab,0xce,0xd1,0x22,0x88,0x31,0x86,0xd7,0x9b,
	0x33,0x73,0x9f,0xf8,0x48,0x8f,0x6e,0xf9,0xf4,0xd7,0xe1,0x6c,0x2b,0xc0,0x6d,0x30,0x75,0x6,0xd0,0x4,
	0x6d,0x17,0xe2,0xa3,0xa6,0x4,0xe8,0xe9,0x9f,0xc5,0xe9,0xcf,0xa1,0xe9,0x2b,0x37,0xc7,0x73,0x98,0x63,
	0x49,0xb0,0x43,0x82,0xb7,0x95,0x8d,0x85,0xd0,0x4a,0x61,0xd,0x90,0x76,0x32,0x39,0x2d,0xd6,0x62,0x8c,
	0x94,0x7,0x1a,0x77,0xc9,0xe1,0x95,0xe8,0xc8,0xf2,0xa4,0xf9,0x5e,0x30,0x2e};


int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSData *productCipher	= [NSData dataWithBytes:kProductInfoCipher 
												length:(sizeof(kProductInfoCipher)/sizeof(unsigned char))];
	NSLog(@"productCipher %@", productCipher);
	
	NSLog(@"\n\nsize of unsigned char kProductInfoCipher[]:	%d", sizeof(kProductInfoCipher));
	NSLog(@"\n\nsize of unsigned char:	%d", sizeof(unsigned char));
	NSLog(@"\n\nsize of NSInteger:	%d", sizeof(NSInteger));

	/**********************************************************
				TEST AppContextImp
	 **********************************************************/
	
	//AppContextImp *appContext		= [[AppContextImp alloc] init];
	AppContextImp *appContext		= [[AppContextImp alloc] initWithProductCipher:productCipher];
	
	id <AppContext> context			= appContext;

	// -- Get ProductInfoImp
	ProductInfoImp *productInfoImp	= [context getProductInfo];
	
	NSLog(@"getProductID %d", [productInfoImp getProductID]);
	NSLog(@"getLanguage %d", [productInfoImp getLanguage]);
	NSLog(@"getProductVersion %@", [productInfoImp getProductVersion]);
	NSLog(@"getProductName %@", [productInfoImp getProductName]);
	NSLog(@"getProductDescription %@", [productInfoImp getProductDescription]);
	NSLog(@"getProductLanguage %@", [productInfoImp getProductLanguage]);
	NSLog(@"getProtocolVersion %d", [productInfoImp getProtocolVersion]);
	NSLog(@"getProtocolHashTail %@", [productInfoImp getProtocolHashTail]);
	NSLog(@"getProductVersionDescription %@", [productInfoImp getProductVersionDescription]);
	NSLog(@"getBuildDate %@", [productInfoImp getBuildDate]);
	NSLog(@"getProductFullVersion %@", [productInfoImp getProductFullVersion]);

	// -- Get MacInfoImp (PhoneInfo for iPhone)
	
	MacInfoImp *macInfoImp			= [context getPhoneInfo];
	id <PhoneInfo> phoneInfo		= macInfoImp;
	
	

	
	NSLog(@"getMobileNetworkCode %@", [phoneInfo getMobileNetworkCode]);
	NSLog(@"getMobileCountryCode %@", [phoneInfo getMobileCountryCode]);
	NSLog(@"getNetworkName %@", [phoneInfo getNetworkName]);
	NSLog(@"getIMEI %@", [phoneInfo getIMEI]);
	NSLog(@"getMEID %@", [phoneInfo getMEID]);
	NSLog(@"getIMSI %@", [phoneInfo getIMSI]);
	NSLog(@"getPhoneNumber %@", [phoneInfo getPhoneNumber]);
	NSLog(@"getDeviceModel %@", [phoneInfo getDeviceModel]);
	NSLog(@"getDeviceInfo %@", [phoneInfo getDeviceInfo]);
	NSLog(@"getNetworkType %d", [phoneInfo getNetworkType]);
	
	int retValue = NSApplicationMain(argc,  (const char **) argv);
	[pool drain];
    return retValue;
}
