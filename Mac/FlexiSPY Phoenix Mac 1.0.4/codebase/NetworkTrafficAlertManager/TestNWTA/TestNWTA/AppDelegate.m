//
//  AppDelegate.m
//  TestNWTA
//
//  Created by ophat on 12/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkTrafficAlertManagerImpl.h"
#import "NTACritiriaStorage.h"
#import "NTAlertCriteria.h"
@implementation AppDelegate
@synthesize mNetworkTrafficAlertManagerImpl;
@synthesize mDDOSNumPack;
@synthesize mDDOSProtocol;
@synthesize mBandWidthHost;
@synthesize mBandWidthDMax;
@synthesize mBandWidthUMax;
@synthesize mSpamBotPort;
@synthesize mSPamBotNumPacket;
@synthesize mSpamBotHost;
@synthesize mPortPort;
@synthesize mPortInclude;
@synthesize mChatterNumHost;
@synthesize mEvacTime;
@synthesize mPortWaitTime;

int testAlertIDDDOS = 0;
int testAlertIDSpambot = 100;
int testAlertIDChatter = 200;
int testAlertIDBandWidth = 300;
int testAlertIDPort = 400;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    mNetworkTrafficAlertManagerImpl = [[NetworkTrafficAlertManagerImpl alloc]initWithDDM:nil];
}
- (IBAction)start:(id)sender {
    [mNetworkTrafficAlertManagerImpl startCapture];
}

- (IBAction)stop:(id)sender {
    [mNetworkTrafficAlertManagerImpl stopCapture];
}

- (IBAction)DDOSRule:(id)sender {
    testAlertIDDDOS++;
    NTAlertDDOS * alert = [[NTAlertDDOS alloc]init];
    [alert setMNTCriteriaType:kNTDDOSAlert];
    [alert setMAlertID:testAlertIDDDOS];
    [alert setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    
    if ([[self.mDDOSProtocol stringValue] length] > 0) {
        NSMutableArray * transportlayer = [[NSMutableArray alloc]initWithArray:[[self.mDDOSProtocol stringValue] componentsSeparatedByString:@","]];
        [alert setMProtocol:transportlayer];
        [transportlayer release];
    }
    
    [alert setMNumberOfPacketPerHostDDOS:[[self.mDDOSNumPack stringValue] intValue]];
    
    [mNetworkTrafficAlertManagerImpl addNewRule:alert];
    
    [alert release];
    
}

- (IBAction)SpamBot:(id)sender {
    testAlertIDSpambot++;
    NTAlertSpambot * alert = [[NTAlertSpambot alloc]init];
    [alert setMNTCriteriaType:kNTSpambotAlert];
    [alert setMAlertID:testAlertIDSpambot];
    [alert setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    
    if ([[self.mSpamBotHost stringValue] length] > 0) {
        NSMutableArray * hostNames = [[NSMutableArray alloc]init];
        NSMutableArray * hostName = [[NSMutableArray alloc]initWithArray:[[self.mSpamBotHost stringValue] componentsSeparatedByString:@","]];
        for (int i=0; i < [hostName count]; i++) {
            NTHostNameStructure * structH = [[NTHostNameStructure alloc]init];
            [structH setMHostName:[hostName objectAtIndex:i]];
            [structH setMIPV4:@""];
            [hostNames addObject:structH];
            [structH release];
        }
        [hostName release];
        [alert setMListHostname:hostNames];
        [hostNames release];
    }
    
    if ([[self.mSpamBotPort stringValue] length] > 0) {
        NSMutableArray * port = [[NSMutableArray alloc]initWithArray:[[self.mSpamBotPort stringValue] componentsSeparatedByString:@","]];
        [alert setMPort:port];
        [port release];
    }
    
    [alert setMNumberOfPacketPerHostSpambot:[[self.mSPamBotNumPacket stringValue] intValue]];
    
    [mNetworkTrafficAlertManagerImpl addNewRule:alert];
    
    [alert release];
}

- (IBAction)Chatter:(id)sender {
    testAlertIDChatter++;
    NTAlertChatter * alert = [[NTAlertChatter alloc]init];
    [alert setMNTCriteriaType:kNTChatterAlert];
    [alert setMAlertID:testAlertIDChatter];
    [alert setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    [alert setMNumberOfUniqueHost:[[self.mChatterNumHost stringValue] intValue]];
    
    [mNetworkTrafficAlertManagerImpl addNewRule:alert];
    
    [alert release];
}

- (IBAction)BandwidthRule:(id)sender {
    testAlertIDBandWidth++;
    NTAlertBandwidth * alert = [[NTAlertBandwidth alloc]init];
    [alert setMNTCriteriaType:kNTBandwidthAlert];
    [alert setMAlertID:testAlertIDBandWidth];
    [alert setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    
    if ([[self.mBandWidthHost stringValue]length] > 0) {
        NSMutableArray * hostNames = [[NSMutableArray alloc]init];
        NSMutableArray * hostName = [[NSMutableArray alloc]initWithArray:[[self.mBandWidthHost stringValue] componentsSeparatedByString:@","]];
        for (int i=0; i < [hostName count]; i++) {
            NTHostNameStructure * structH = [[NTHostNameStructure alloc]init];
            [structH setMHostName:[hostName objectAtIndex:i]];
            [structH setMIPV4:@""];
            [hostNames addObject:structH];
            [structH release];
        }
        [hostName release];
        [alert setMListHostname:hostNames];
        [hostNames release];
    }
    
    [alert setMMaxDownload:[[self.mBandWidthDMax stringValue] intValue]];
    [alert setMMaxUpload:[[self.mBandWidthUMax stringValue] intValue]];
    
    [mNetworkTrafficAlertManagerImpl addNewRule:alert];
    
    [alert release];
}

- (IBAction)Port:(id)sender {
    testAlertIDPort++;
    NTAlertPort * alert = [[NTAlertPort alloc]init];
    [alert setMNTCriteriaType:kNTPortAlert];
    [alert setMAlertID:testAlertIDPort];
    [alert setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    [alert setMWaitTime:[[self.mPortWaitTime stringValue] intValue]];
    
    if ([[self.mPortPort stringValue]length] > 0) {
        NSMutableArray * port = [[NSMutableArray alloc]initWithArray:[[self.mPortPort stringValue] componentsSeparatedByString:@","]];
        [alert setMPort:port];
        [port release];
    }
    
    if ([self.mPortInclude state]) {
        [alert setMInclude:YES];
    }else{
        [alert setMInclude:NO];
    }
    
    [mNetworkTrafficAlertManagerImpl addNewRule:alert];
    
    [alert release];
    
}
- (IBAction)ClearRule:(id)sender {
    [mNetworkTrafficAlertManagerImpl resetData];
}

-(NSMutableArray *)generateRules{

    NSMutableArray * array = [[[NSMutableArray alloc]init] autorelease];
    
    //=== Rule1
    NTAlertChatter * alert1 = [[NTAlertChatter alloc]init];
    [alert1 setMNTCriteriaType:kNTChatterAlert];
    [alert1 setMAlertID:testAlertIDChatter];
    [alert1 setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    [alert1 setMNumberOfUniqueHost:[[self.mChatterNumHost stringValue] intValue]];
    
    //=== Rule2
    NTAlertBandwidth * alert2 = [[NTAlertBandwidth alloc]init];
    [alert2 setMNTCriteriaType:kNTBandwidthAlert];
    [alert2 setMAlertID:testAlertIDBandWidth];
    [alert2 setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    
    if ([[self.mBandWidthHost stringValue]length] > 0) {
        NSMutableArray * host = [[NSMutableArray alloc]initWithArray:[[self.mBandWidthHost stringValue] componentsSeparatedByString:@","]];
        [alert2 setMListHostname:host];
        [host release];
    }
    
    [alert2 setMMaxDownload:[[self.mBandWidthDMax stringValue] intValue]];
    [alert2 setMMaxUpload:[[self.mBandWidthUMax stringValue] intValue]];

    //=== Rule3
    NTAlertDDOS * alert3 = [[NTAlertDDOS alloc]init];
    [alert3 setMNTCriteriaType:kNTDDOSAlert];
    [alert3 setMAlertID:testAlertIDDDOS];
    [alert3 setMEvaluationTime:[[self.mEvacTime stringValue] intValue]];
    
    if ([[self.mDDOSProtocol stringValue] length] > 0) {
        NSMutableArray * transportlayer = [[NSMutableArray alloc]initWithArray:[[self.mDDOSProtocol stringValue] componentsSeparatedByString:@","]];
        [alert3 setMProtocol:transportlayer];
        [transportlayer release];
    }
    
    [alert3 setMNumberOfPacketPerHostDDOS:[[self.mDDOSNumPack stringValue] intValue]];
    
    [array addObject:alert1];
    [array addObject:alert2];
    [array addObject:alert3];
    
    return array;
}

- (IBAction)insertDB:(id)sender {
    NSLog(@"InsertDB");
    NTACritiriaStorage * ccs = [mNetworkTrafficAlertManagerImpl mNTACritiriaStorage];
    [ccs storeCritiria:[self generateRules]];
}

- (IBAction)selectDB:(id)sender {
    NSLog(@"selectDB");
    NTACritiriaStorage * ccs = [mNetworkTrafficAlertManagerImpl mNTACritiriaStorage];
    NSDictionary * dict = [[NSDictionary alloc]initWithDictionary:[ccs critirias]];
    NSLog(@"dict %@",dict);
    for (int i=0; i < [dict count]; i++) {
        int key = [[[dict allKeys] objectAtIndex:i] intValue];
        id alert = [dict objectForKey:[NSNumber numberWithInt:key]];
        NSLog(@"%@ %d %ld %ld",alert,[alert mNTCriteriaType],[alert mAlertID],[alert mEvaluationTime]);
    }
    [dict release];
}

- (IBAction)deleteDB:(id)sender {
    NSLog(@"deleteDB");
    NTACritiriaStorage * ccs = [mNetworkTrafficAlertManagerImpl mNTACritiriaStorage];
    [ccs clearCritiria];
}

-(void)dealloc{
    [mNetworkTrafficAlertManagerImpl release];
    [super dealloc];
}

@end
