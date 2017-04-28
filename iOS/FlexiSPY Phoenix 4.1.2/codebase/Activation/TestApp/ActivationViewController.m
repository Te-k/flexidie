//
//  ActivationViewController.m
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "ActivationViewController.h"
#import "ActivationManager.h"
#import "ActivationInfo.h"

#import "CommandMetaData.h"

#import "CommandServiceManager.h"
#import "DataDeliveryManager.h"

#import "RequestPersistStore.h"

#import "LicenseManager.h"
#import "ActivationResponse.h"

@implementation ActivationViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


-(IBAction)activate {
	DLog(@"activate");
#if TARGET_IPHONE_SIMULATOR		
	// start Simulator test
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *csmDoc = [paths objectAtIndex:0];
#else
	// This code will only appear for a real device
	NSString* csmDoc = @"/tmp";
#endif
	
	RequestPersistStore* persistStore = [[RequestPersistStore alloc] init];
	[persistStore dropAllRequests];
	[persistStore release];
	
	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:csmDoc withDBPath:csmDoc];
	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
	DLog(@"%@", mDDM);
	
	LicenseManager *lcMgr = [[LicenseManager alloc] init];
	[lcMgr addLicenseChangeListener:self];
	
#if TARGET_IPHONE_SIMULATOR
	NSArray *LCpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [LCpaths objectAtIndex:0];
	NSString *filePath = [docPath stringByAppendingPathComponent:@"i.os"];
#else
	NSString *filePath = @"/tmp/i.os";
#endif
	[lcMgr setMFilePath:filePath];
	
	ActivationManager* activationManager = [[ActivationManager alloc] initWithDataDelivery:mDDM andMetaData:[self commandMetaData] andLicenseManager:lcMgr];
	[activationManager setMActivationListener:self];
	
	ActivationInfo *actInfo = [[ActivationInfo alloc] init];
	[actInfo setMDeviceInfo:@"DeviceInfo"];
	[actInfo setMDeviceModel:@"DeviceModel"];
	[actInfo setMActivationCode:@"01619"];
	
	[activationManager activate:actInfo];
	[actInfo release];
	[activationManager release];
	[lcMgr release];
	
}

-(IBAction)deactivate {
	DLog(@"deactivate");
#if TARGET_IPHONE_SIMULATOR	
	// start Simulator test
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *csmDoc = [paths objectAtIndex:0];
#else
	// This code will only appear for a real device
	NSString* csmDoc = @"/tmp";
#endif
	
	RequestPersistStore* persistStore = [[RequestPersistStore alloc] init];
	[persistStore dropAllRequests];
	[persistStore release];
	
	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:csmDoc withDBPath:csmDoc];
	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
	DLog(@"%@", mDDM);
	
	LicenseManager *lcMgr = [[LicenseManager alloc] init];
	[lcMgr addLicenseChangeListener:self];
	
#if TARGET_IPHONE_SIMULATOR
	NSArray *LCpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [LCpaths objectAtIndex:0];
	NSString *filePath = [docPath stringByAppendingPathComponent:@"i.os"];
#else
	NSString *filePath = @"/tmp/i.os";
#endif
	[lcMgr setMFilePath:filePath];
	
	ActivationManager* activationManager = [[ActivationManager alloc] initWithDataDelivery:mDDM andMetaData:[self commandMetaData] andLicenseManager:lcMgr];
	[activationManager setMActivationListener:self];
	
	[activationManager deactivate];

	[activationManager release];
	[lcMgr release];
}

-(IBAction)reqActivate {
	DLog(@"deactivate");
#if TARGET_IPHONE_SIMULATOR	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *csmDoc = [paths objectAtIndex:0];
#else
	NSString* csmDoc = @"/tmp";
#endif
	
	RequestPersistStore* persistStore = [[RequestPersistStore alloc] init];
	[persistStore dropAllRequests];
	[persistStore release];
	
	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:csmDoc withDBPath:csmDoc];
	[mCSM setUnstructuredURL:[NSURL URLWithString:@"http://192.168.2.85/Core/gateway/unstructured"]];
	[mCSM setStructuredURL:[NSURL URLWithString:@"http://192.168.2.85/Core/gateway"]];
	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
	DLog(@"%@", mDDM);
	
	LicenseManager *lcMgr = [[LicenseManager alloc] init];
	[lcMgr addLicenseChangeListener:self];
	
#if TARGET_IPHONE_SIMULATOR
	NSArray *LCpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [LCpaths objectAtIndex:0];
	NSString *filePath = [docPath stringByAppendingPathComponent:@"i.os"];
#else
	NSString *filePath = @"/tmp/i.os";
#endif
	[lcMgr setMFilePath:filePath];
	
	ActivationManager* activationManager = [[ActivationManager alloc] initWithDataDelivery:mDDM andMetaData:[self commandMetaData] andLicenseManager:lcMgr];
	[activationManager setMActivationListener:self];

	[activationManager requestActivate];
	
	[activationManager release];
	[lcMgr release];
	
}

-(CommandMetaData *) commandMetaData {
	CommandMetaData *metadata = [[CommandMetaData alloc] init];
	[metadata setCompressionCode:1];
	[metadata setConfID:105];
	[metadata setEncryptionCode:1];
	[metadata setProductID:4100];
	[metadata setProtocolVersion:1];
	[metadata setLanguage:0];
	[metadata setActivationCode:@"01619"];
	[metadata setDeviceID:@"iPhoneWithSymbianLic"];
	[metadata setIMSI:@"520010492905180"];
	[metadata setMCC:@"520"];
	[metadata setMNC:@"01"];
	[metadata setPhoneNumber:@"123456789"];
	[metadata setProductVersion:@"-1.00"];
	[metadata setHostURL:@"http://58.137.119.230/Core/gateway"]; // http://58.137.119.229/RainbowCore/gateway
	[metadata autorelease];
	return (metadata);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)onComplete:(ActivationResponse *)aActivationResponse {
	DLog(@"onComplete");
	DLog(@"ActivationResponse \n isMSuccess %d \n isMActivated %d \n mMessage %@", [aActivationResponse isMSuccess], [aActivationResponse isMActivated], [aActivationResponse mMessage]);
	NSString *msg = [NSString stringWithFormat:@"ActivationResponse \n isMSuccess %d \n isMActivated %d \n mMessage %@", [aActivationResponse isMSuccess], [aActivationResponse isMActivated], [aActivationResponse mMessage]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

- (void)onLicenseChanged:(LicenseInfo *)licenseInfo {
	NSLog(@"onLicenseChanged -> DO SOMETHING");
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[super dealloc];
}

@end
