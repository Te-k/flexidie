//
//  ProtocolBuilderAppDelegate.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "ProtocolBuilderAppDelegate.h"
#import "CommandMetaData.h"
#import "ProtocolPacketBuilder.h"
#import "SendActivate.h"
#import "CommandMetaData.h"
#import "TransportDirectiveEnum.h"

@implementation ProtocolBuilderAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after application launch
    [window makeKeyAndVisible];
	SendActivate *command = [[SendActivate alloc] init]; 
	[command setDeviceInfo:@"CMDDeviceInfo"];
	[command setDeviceModel:@"CMDDeviceModel"];
	
	CommandMetaData *metadata = [[CommandMetaData alloc] init];
	[metadata setMCC:@"MCC"];
	[metadata setCompressionCode:1];
	[metadata setConfID:0];
	[metadata setEncryptionCode:1];
	[metadata setProductID:4200];
	[metadata setProtocolVersion:1];
	[metadata setLanguage:0];
	[metadata setActivationCode:@"012549"];
	[metadata setDeviceID:@"DeviceId"];
	[metadata setIMSI:@"IMSI"];
	[metadata setMCC:@"MCC"];
	[metadata setMNC:@"MNC"];
	[metadata setPhoneNumber:@"123456789"];
	[metadata setProductVersion:@"1.00"];
	[metadata setHostURL:@"http://58.137.119.229/RainbowCore"];	
	
	NSString *keyFile=[[NSBundle mainBundle] pathForResource:@"server" ofType:@"pub"];
	NSData *keyData = [NSData dataWithContentsOfFile:keyFile];

	ProtocolPacketBuilder *packetBuilder = [[ProtocolPacketBuilder alloc] init];
	[packetBuilder buildPacketForCommand:command withMetaData:metadata
						 withPayloadPath:nil 
						   withPublicKey:keyData
							withSSID:1234687 
						   withDirective:NON_RESUMABLE];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
