//
//  AppDelegate.m
//  ProtocolBuilderTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 10/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "AppDelegate.h"

#import "CommandMetaData.h"
#import "ProtocolPacketBuilder.h"
#import "SendActivate.h"
#import "CommandMetaData.h"
#import "TransportDirectiveEnum.h"


@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}
	
- (void) test1 {
    NSLog(@"test 1");
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
    NSLog(@"keyFile %@", keyFile);
    
	NSData *keyData = [NSData dataWithContentsOfFile:keyFile];
    NSLog(@"keyData %@", keyData);
	ProtocolPacketBuilder *packetBuilder = [[ProtocolPacketBuilder alloc] init];
    
    NSLog(@"... building package for command SendActivate");
	ProtocolPacketBuilderResponse *response = [packetBuilder buildPacketForCommand:command  
                                                                      withMetaData:metadata
                                                                   withPayloadPath:nil 
                                                                     withPublicKey:keyData
                                                                          withSSID:1234687 
                                                                     withDirective:NON_RESUMABLE];
    

    
    NSLog(@"... DONE building package for command SendActivate");
    NSLog(@"response %@", response);
    
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self test1];
}

@end
