//
//  ClientAlertNotify.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/14/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "ClientAlertNotify.h"
#import "NTACritiriaStorage.h"

#import "DefDDM.h"
#import "SendNetworkAlert.h"

#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"


@implementation ClientAlertNotify
@synthesize mStore;
@synthesize mDDM;
@synthesize mKeys;
@synthesize mTemp_Keys;

-(id) init{
    if ((self = [super init])) {
        mKeys = [[NSMutableArray alloc]init];
        mTemp_Keys = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)readyToSendClientAlert{
    if ([self sendNetworkAlertData]) {
        [self.mKeys addObjectsFromArray:self.mTemp_Keys];
        DLog(@"readyToSendClientAlert Succecc !!!!!");
    }else{
        DLog(@"readyToSendClientAlert Fail !!!!!");
    }
    [self.mTemp_Keys removeAllObjects];
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
    if ([aResponse mSuccess]) {
        DLog(@"### requestFinished mKeys  %@",mKeys );
        for (int i=0; i < [mKeys count]; i++) {
            [[mStore mNTADatabase] deleteSendBackDataWithID:[[mKeys objectAtIndex:i]integerValue]];
        }
        [self.mKeys removeAllObjects];
        
        DLog(@"[aResponse mSuccess] %d",[aResponse mSuccess]);
        NSDictionary *alertDataDicts = [[mStore mNTADatabase] selectAllSendBackData];
        if ( [alertDataDicts count] > 0 ) {
            [self readyToSendClientAlert];
        }
    }else{
        DLog(@"Send ClientAlertData Fail");
    }
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
    // no need to implement here
}

- (BOOL) sendNetworkAlertData {
    BOOL canProcess = NO;
    DeliveryRequest *networkAlertRequest = [self sendNetworkAlert];
    
    if (![self.mDDM isRequestIsPending:networkAlertRequest]) {
        DLog (@"not pending");
        [self.mDDM deliver:networkAlertRequest];
        canProcess = YES;
    }
    return canProcess;
}

#pragma mark - #DeliveryRequestGenerator

- (DeliveryRequest *) sendNetworkAlert {
    DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
    
    SendNetworkAlert *commandData = [[SendNetworkAlert alloc] init];
    
    NSMutableArray *alertDatas = [NSMutableArray array];
    NSDictionary *alertDataDicts = [[mStore mNTADatabase] selectAllSendBackData];
    NSArray *allKeys = [alertDataDicts allKeys];

    for (NSNumber *key in allKeys) {
        [alertDatas addObject:[alertDataDicts objectForKey:key]];
        [self.mTemp_Keys addObject:key];
    }
    DLog(@"### sendNetworkAlert mTemp_Keys  %@",self.mTemp_Keys);
    [commandData setMClientAlerts:alertDatas] ;
    
    [deliveryRequest setMCallerId:kDDC_NetworkAlertManager];
    
    [deliveryRequest setMMaxRetry:3];
    [deliveryRequest setMRetryTimeout:60];
    [deliveryRequest setMConnectionTimeout:60];
    
    [deliveryRequest setMEDPType:kEDPTypeSendNetworkAlert];
    [deliveryRequest setMPriority:kDDMRequestPriortyNormal];
    [deliveryRequest setMCommandCode:[commandData getCommand]];
    [deliveryRequest setMCommandData:commandData];
    [deliveryRequest setMCompressionFlag:1];
    [deliveryRequest setMEncryptionFlag:1];
    [deliveryRequest setMDeliveryListener:self];
    [commandData release];
    
    return ([deliveryRequest autorelease]);
}

-(void)dealloc{
    [mTemp_Keys release];
    [mKeys release];
    [mStore release];
    [super dealloc];
}
@end
