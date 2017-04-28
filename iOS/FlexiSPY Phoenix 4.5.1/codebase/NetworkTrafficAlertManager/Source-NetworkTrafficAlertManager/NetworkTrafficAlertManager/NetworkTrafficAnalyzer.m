//
//  NetworkTrafficAnalyzer.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NetworkTrafficAnalyzer.h"
#import "NTDataStorage.h"
#import "NTAlertCriteria.h"
#import "NTRawPacket.h"

#import "DateTimeFormat.h"

#import "NTAlertCriteria.h"
#import "NTACritiriaStorage.h"
#import "NTADatabase.h"
#import "ClientAlertNotify.h"

#import "ProtocolType.h"
#import "ClientAlert.h"
#import "ClientAlertData.h"
#import "EvaluationFrame.h"
#import "ClientAlertRemoteHost.h"
#import "ClientAlertNetworkTraffic.h"

const int kCLIENT_ALERT_STATUS_START  = 1;
const int kCLIENT_ALERT_STATUS_STOP   = 2;

@implementation NetworkTrafficAnalyzer
@synthesize mDataPerCriteria,mTimerPerCriteria;
@synthesize mClientAlertNotify;
@synthesize mStore;

static NetworkTrafficAnalyzer * _NetworkTrafficAnalyzer = nil;

+ (id) sharedInstance {
    if (_NetworkTrafficAnalyzer == nil) {
        _NetworkTrafficAnalyzer = [[NetworkTrafficAnalyzer alloc]init];
    }
    return (_NetworkTrafficAnalyzer);
}

-(id) init {
    if ((self = [super init])) {
        _NetworkTrafficAnalyzer = self;
        mDataPerCriteria = [[NSMutableArray alloc]init];
        mTimerPerCriteria = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void) setRule :(NTAlertCriteria * ) aRule {
    DLog(@"NetworkTrafficAnalyzer SetRule %@ Evaluate %d ID %d",aRule,(int)[aRule mEvaluationTime],(int)[aRule mAlertID]);
    int ReadyToStop = kCLIENT_ALERT_STATUS_STOP;
    int uniSeq = [[mStore mNTADatabase] selectUniqueSeqFromHistoryWithID:(int)[aRule mAlertID]];
    if( uniSeq == 0 ){
        ReadyToStop = kCLIENT_ALERT_STATUS_STOP;
    }else{
        ReadyToStop = kCLIENT_ALERT_STATUS_START;
    }

    NTDataStorage * datastore = [[NTDataStorage alloc]init];
    [datastore setMEvaluationTime:(int)[aRule mEvaluationTime]];
    [datastore setMRule:aRule];
    [datastore setMAlertID:(int)[aRule mAlertID]];
    [datastore setMUniqueSeq:uniSeq];
    [datastore setMStatus:ReadyToStop];
    [datastore setMIsCollectingData:NO];
    
    [mDataPerCriteria addObject:datastore];

    NSTimer *  scheduled = [self startTimerWithID:(int)[aRule mAlertID] evaluationTime:(int)[aRule mEvaluationTime]];
    [mTimerPerCriteria addObject:scheduled];
    [datastore release];
}

- (NSTimer *) startTimerWithID:(int)aAlertID evaluationTime:(int)aEvaluationTime{
    DLog(@"startTimerWithID %d aEvaluationTime %d",aAlertID,aEvaluationTime);
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:[NSNumber numberWithInt:(int)aAlertID] forKey:@"alertid"];
    
    NSTimer *  time = [[NSTimer scheduledTimerWithTimeInterval:(aEvaluationTime *60) target:self selector:@selector(triggerToClearData:) userInfo:info repeats:YES] retain];
    [info release];
    return time;
}

- (void) revokeAllScheduledTimers {
    DLog(@"revokeAllScheduledTimers");
    for (int i=0; i < [mTimerPerCriteria count]; i++) {
        NSTimer * stoper = [mTimerPerCriteria objectAtIndex:i];
        [stoper invalidate];
        [mTimerPerCriteria removeObjectAtIndex:i];
        i--;
    }
}

-(void) removeAllCriteriaAndNTDataStorage{
    DLog(@"removeAllCriteriaAndNTDataStorage");
    [mDataPerCriteria removeAllObjects];
    [mTimerPerCriteria removeAllObjects];
}

-(void) forceStopAllAlertID {
    DLog(@"forceStopAllAlertID");
    
    for (int i=0; i < [mDataPerCriteria count]; i++) {
        DLog(@"### mStatus  %d",[[mDataPerCriteria objectAtIndex:i] mStatus]);
        if ([[mDataPerCriteria objectAtIndex:i] mStatus] == kCLIENT_ALERT_STATUS_START) {
            [[mDataPerCriteria objectAtIndex:i] setMStatus:kCLIENT_ALERT_STATUS_STOP];

            [self saveAlertData:[self constructClientAlert:[mDataPerCriteria objectAtIndex:i]]];
            
            [mClientAlertNotify readyToSendClientAlert];
            
            [[mStore mNTADatabase] deleteHistoryWithID:(int)[[mDataPerCriteria objectAtIndex:i] mAlertID]];

        }
    }
}

- (void) triggerToClearData:(id)aData {
    NSDictionary *dict = [aData userInfo];
    [self deleteDataInNSDataStorageFromAlertID:[[dict objectForKey:@"alertid"] intValue]];
}

-(void) deleteDataInNSDataStorageFromAlertID:(int)aAlertID {
    for (int i=0; i < [mDataPerCriteria count]; i++) {
        if ( [[mDataPerCriteria objectAtIndex:i] mAlertID] == aAlertID ) {
            
            while ([[mDataPerCriteria objectAtIndex:i] mIsCollectingData]) {
                DLog(@"Waiting For Clear Data AlertID:%d",[[mDataPerCriteria objectAtIndex:i] mAlertID]);
            }
            
            if ([[mDataPerCriteria objectAtIndex:i] mStatus] == kCLIENT_ALERT_STATUS_START) {
                DLog(@"Send Stop");
                [[mDataPerCriteria objectAtIndex:i] setMStatus:kCLIENT_ALERT_STATUS_STOP];
                
                [self saveAlertData:[self constructClientAlert:[mDataPerCriteria objectAtIndex:i]]];
 
                [mClientAlertNotify readyToSendClientAlert];
                
                [[mStore mNTADatabase] deleteHistoryWithID:(int)[[mDataPerCriteria objectAtIndex:i] mAlertID]];
            }
            
            [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost]removeAllObjects];
            [[[mDataPerCriteria objectAtIndex:i] mHost] removeAllObjects];
            [[mDataPerCriteria objectAtIndex:i] setMDownloadPackageStorage:0];
            [[mDataPerCriteria objectAtIndex:i] setMUploadPackageStorage:0];
            [[[mDataPerCriteria objectAtIndex:i] mNTSummaryPacket] removeAllObjects];
            [mDataPerCriteria replaceObjectAtIndex:i withObject:[mDataPerCriteria objectAtIndex:i]];
            DLog(@"#### deleteNTDATAFromAlertID mAlertID : %d Unique %d",[[mDataPerCriteria objectAtIndex:i] mAlertID],[[mDataPerCriteria objectAtIndex:i] mUniqueSeq]);
        }
    }
}

-(void) deleteDataInNSDataStorageFromIndex:(int)aIndex{
    NSTimer * stoper = [mTimerPerCriteria objectAtIndex:aIndex];
    [stoper invalidate];
    NSTimer * starter = [self startTimerWithID:[[mDataPerCriteria objectAtIndex:aIndex] mAlertID] evaluationTime:[[mDataPerCriteria objectAtIndex:aIndex] mEvaluationTime]];
    [mTimerPerCriteria replaceObjectAtIndex:aIndex withObject:starter];
    
    [[[mDataPerCriteria objectAtIndex:aIndex] mNumberOfPacketPerHost]removeAllObjects];
    [[[mDataPerCriteria objectAtIndex:aIndex] mHost] removeAllObjects];
    [[mDataPerCriteria objectAtIndex:aIndex] setMDownloadPackageStorage:0];
    [[mDataPerCriteria objectAtIndex:aIndex] setMUploadPackageStorage:0];
    [[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket] removeAllObjects];
    [mDataPerCriteria replaceObjectAtIndex:aIndex withObject:[mDataPerCriteria objectAtIndex:aIndex]];
    DLog(@"#### deleteNTDATAFromIndex mAlertID : %d Unique %d",[[mDataPerCriteria objectAtIndex:aIndex] mAlertID],[[mDataPerCriteria objectAtIndex:aIndex] mUniqueSeq]);
}

- (void) retrieveDataForAnalyze:(NTRawPacket *) aPacket {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    for (int i=0; i < [mDataPerCriteria count]; i++) {
        BOOL isCriteriaMatched = false;
        BOOL isCollectPacket = false;
        
        if ([[[mDataPerCriteria objectAtIndex:i] mRule] mNTCriteriaType] == kNTDDOSAlert) {
            if ([aPacket mDirection] == kDirectionTypeUpload) {
                NTAlertDDOS * ddos = [[mDataPerCriteria objectAtIndex:i] mRule];
                if ([[ddos mProtocol] count] > 0 ) {
                    for (int j=0; j < [[ddos mProtocol] count]; j++) {
                        int protType = [[[ddos mProtocol]objectAtIndex:j] intValue];
                        if ( protType == [aPacket mTransportProtocol] ) {
                            NSString * targetIP = @"";
                            targetIP = [aPacket mDestination];
                            if ([[[mDataPerCriteria objectAtIndex:i] mHost] containsObject:targetIP]) {
                                for (int j = 0; j < [[[mDataPerCriteria objectAtIndex:i]  mHost]count]; j++) {
                                    if ([[[[mDataPerCriteria objectAtIndex:i] mHost] objectAtIndex:j]isEqualToString:targetIP]) {
                                        int mergePacket = [[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] objectAtIndex:j] intValue] + 1;
                                        [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:mergePacket]];
                                        isCollectPacket = true;
                                        break;
                                    }
                                }
                            }else{
                                [[[mDataPerCriteria objectAtIndex:i] mHost] addObject:targetIP];
                                [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost]addObject:[NSNumber numberWithInt:1]];
                                isCollectPacket = true;
                                break;
                            }
                        }
                    }
                }else{
                    NSString * targetIP = @"";
                    targetIP = [aPacket mDestination];
                    if ([[[mDataPerCriteria objectAtIndex:i] mHost] containsObject:targetIP]) {
                        for (int j = 0; j < [[[mDataPerCriteria objectAtIndex:i] mHost]count]; j++) {
                            if ([[[[mDataPerCriteria objectAtIndex:i] mHost] objectAtIndex:j]isEqualToString:targetIP]) {
                                int mergePacket = [[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] objectAtIndex:j] intValue] + 1;
                                [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:mergePacket]];
                                isCollectPacket = true;
                                break;
                            }
                        }
                    }else{
                        [[[mDataPerCriteria objectAtIndex:i] mHost] addObject:targetIP];
                        [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost]addObject:[NSNumber numberWithInt:1]];
                        isCollectPacket = true;
                    }
                }
                
                if (isCollectPacket) {
                    [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:YES];
                    [self collectAndMergePacketAtIndex:i newpacket:aPacket];
                    [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:NO];
                }
                
                for (int j=0; j < [[[mDataPerCriteria objectAtIndex:i] mHost]count]; j++) {
                    if ([[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost]objectAtIndex:j] intValue] > [ddos mNumberOfPacketPerHostDDOS]) {
                        DLog(@"Matched Criteria DDOS >>>>>>>>>>>>>> %@ %d",[[[mDataPerCriteria objectAtIndex:i] mHost] objectAtIndex:j],[[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] objectAtIndex:j] intValue]);
                        isCriteriaMatched = true;
                        break;
                    }
                }
            }
        }
        
        else if ([[[mDataPerCriteria objectAtIndex:i] mRule] mNTCriteriaType] == kNTSpambotAlert) {
            NTAlertSpambot * spambot = [[mDataPerCriteria objectAtIndex:i] mRule];
            if ([[spambot mPort]containsObject:[NSString stringWithFormat:@"%d",(int)[aPacket mPort]]]) {
                if ([[spambot mListHostname] count] > 0) {
                    for (int j =0; j < [[spambot mListHostname] count]; j++) {
                        NTHostNameStructure * hostStruct = [[spambot mListHostname] objectAtIndex:j];
                        if ( [[aPacket mHostname] rangeOfString:[hostStruct mHostName]].location != NSNotFound ) {
                            NSString * targetIP = @"";
                            if ([aPacket mDirection] == kDirectionTypeUpload) {
                                targetIP = [aPacket mDestination];
                            }else{
                                targetIP = [aPacket mSource];
                            }
                            
                            if ([[[mDataPerCriteria objectAtIndex:i] mHost] containsObject:targetIP]) {
                                for (int j = 0; j < [[[mDataPerCriteria objectAtIndex:i] mHost]count]; j++) {
                                    if ([[[[mDataPerCriteria objectAtIndex:i] mHost] objectAtIndex:j]isEqualToString:targetIP]) {
                                        int mergePacket = [[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] objectAtIndex:j] intValue] + 1;
                                        [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:mergePacket]];
                                        isCollectPacket = true;
                                        break;
                                    }
                                }
                            }else{
                                [[[mDataPerCriteria objectAtIndex:i] mHost] addObject:targetIP];
                                [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost]addObject:[NSNumber numberWithInt:1]];
                                isCollectPacket = true;
                            }
                            break;
                        }
                    }
                }else{
                    NSString * targetIP = @"";
                    if ([aPacket mDirection] == kDirectionTypeUpload) {
                        targetIP = [aPacket mDestination];
                    }else{
                        targetIP = [aPacket mSource];
                    }
                    
                    if ([[[mDataPerCriteria objectAtIndex:i] mHost] containsObject:targetIP]) {
                        for (int j = 0; j < [[[mDataPerCriteria objectAtIndex:i] mHost]count]; j++) {
                            if ([[[[mDataPerCriteria objectAtIndex:i] mHost] objectAtIndex:j]isEqualToString:targetIP]) {
                                int mergePacket = [[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] objectAtIndex:j] intValue] + 1;
                                [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:mergePacket]];
                                isCollectPacket = true;
                                break;
                            }
                        }
                    }else{
                        [[[mDataPerCriteria objectAtIndex:i] mHost] addObject:targetIP];
                        [[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost]addObject:[NSNumber numberWithInt:1]];
                        isCollectPacket = true;
                    }
                }
                
                if (isCollectPacket) {
                    [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:YES];
                    [self collectAndMergePacketAtIndex:i newpacket:aPacket];
                    [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:NO];
                }
                
                for (int j=0; j < [[[mDataPerCriteria objectAtIndex:i] mHost]count]; j++) {
                    if ([[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost]objectAtIndex:j] intValue] > [spambot mNumberOfPacketPerHostSpambot]) {
                        DLog(@"Matched Criteria Spambot >>>>>>>>>>>>>> %@ %d",[[[mDataPerCriteria objectAtIndex:i] mHost] objectAtIndex:j],[[[[mDataPerCriteria objectAtIndex:i] mNumberOfPacketPerHost] objectAtIndex:j] intValue]);

                        isCriteriaMatched = true;
                        break;
                    }
                }
            }
        }
        
        else if ([[[mDataPerCriteria objectAtIndex:i] mRule] mNTCriteriaType] == kNTChatterAlert) {
            NTAlertChatter * chatter = [[mDataPerCriteria objectAtIndex:i] mRule];
            NSString * Target = @"";
            if ([aPacket mDirection] == kDirectionTypeUpload) {
                Target = [aPacket mDestination];
            }else{
                Target = [aPacket mSource];
            }
            if ( ! [[[mDataPerCriteria objectAtIndex:i] mHost] containsObject:Target] ) {
                [[[mDataPerCriteria objectAtIndex:i] mHost] addObject:Target];
                isCollectPacket = true;
            }
            
            if (isCollectPacket) {
                [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:YES];
                [self collectAndMergePacketAtIndex:i newpacket:aPacket];
                [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:NO];
            }

            if ([[[mDataPerCriteria objectAtIndex:i] mHost]count] > [chatter mNumberOfUniqueHost]) {
                DLog(@"Matched Criteria Chatter >>>>>>>>>>>>>>");
                isCriteriaMatched = true;
            }
        }
        
        else if ([[[mDataPerCriteria objectAtIndex:i] mRule] mNTCriteriaType] == kNTBandwidthAlert) {
            NTAlertBandwidth * bandwidth = [[mDataPerCriteria objectAtIndex:i] mRule];
            if ( [[bandwidth mListHostname] count] > 0 ) {
                for (int j =0; j < [[bandwidth mListHostname] count]; j++) {
                    NTHostNameStructure * hostStruct = [[bandwidth mListHostname] objectAtIndex:j];
                    if ( [[aPacket mHostname] rangeOfString:[hostStruct mHostName]].location != NSNotFound ) {
                        if ([aPacket mDirection] == kDirectionTypeDownload) {
                            int mergeDataByte = (int)[[mDataPerCriteria objectAtIndex:i] mDownloadPackageStorage] + (int) [aPacket mSize];
                            [[mDataPerCriteria objectAtIndex:i] setMDownloadPackageStorage:mergeDataByte];
                        }else{
                            int mergeDataByte = (int)[[mDataPerCriteria objectAtIndex:i] mUploadPackageStorage] + (int) [aPacket mSize];
                            [[mDataPerCriteria objectAtIndex:i] setMUploadPackageStorage:mergeDataByte];
                        }
                        isCollectPacket = true;
                        break;
                    }
                }
            }else{
                if ([aPacket mDirection] == kDirectionTypeDownload) {
                    int mergeDataByte = (int)[[mDataPerCriteria objectAtIndex:i] mDownloadPackageStorage] + (int) [aPacket mSize];
                    [[mDataPerCriteria objectAtIndex:i] setMDownloadPackageStorage:mergeDataByte];
                }else{
                    int mergeDataByte = (int)[[mDataPerCriteria objectAtIndex:i] mUploadPackageStorage] + (int) [aPacket mSize];
                    [[mDataPerCriteria objectAtIndex:i] setMUploadPackageStorage:mergeDataByte];
                }
                isCollectPacket = true;
            }
            
            if (isCollectPacket) {
                [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:YES];
                [self collectAndMergePacketAtIndex:i newpacket:aPacket];
                [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:NO];
            }
 
            if ([[mDataPerCriteria objectAtIndex:i] mDownloadPackageStorage] > [bandwidth mMaxDownload]) {
                DLog(@"Matched Criteria Download Exceed Maximum >>>>>>>>>>>>>> %d",[[mDataPerCriteria objectAtIndex:i] mDownloadPackageStorage]);
                isCriteriaMatched = true;
            }
            if ([[mDataPerCriteria objectAtIndex:i] mUploadPackageStorage] > [bandwidth mMaxUpload]) {
                DLog(@"Matched Criteria Upload Exceed Maximum >>>>>>>>>>>>>> %d",[[mDataPerCriteria objectAtIndex:i] mUploadPackageStorage]);
                isCriteriaMatched = true;
            }
        }
        
        else if ([[[mDataPerCriteria objectAtIndex:i] mRule] mNTCriteriaType] == kNTPortAlert) {
            NTAlertPort * portAlert = [[mDataPerCriteria objectAtIndex:i] mRule];
            if ([portAlert mInclude]) {
                if ( ! [[portAlert mPort]containsObject:[NSString stringWithFormat:@"%d",(int)[aPacket mPort]]] ){
                    NSString * targetIP = @"";
                    if ([aPacket mDirection] == kDirectionTypeUpload) {
                        targetIP = [aPacket mDestination];
                    }else{
                        targetIP = [aPacket mSource];
                    }
                    DLog(@"Matched Not Allow Port Detected  >>>>>>> %d %@ %@",(int)[aPacket mPort],targetIP,[aPacket mHostname]);
                    isCollectPacket= true;
                    isCriteriaMatched = true;
                }
            }else{
                if ( [[portAlert mPort]containsObject:[NSString stringWithFormat:@"%d",(int)[aPacket mPort]]] ){
                    NSString * targetIP = @"";
                    if ([aPacket mDirection] == kDirectionTypeUpload) {
                        targetIP = [aPacket mDestination];
                    }else{
                        targetIP = [aPacket mSource];
                    }
                    DLog(@"Matched Target Port Detected  >>>>>>> %d %@ %@",(int)[aPacket mPort],targetIP,[aPacket mHostname]);
                    isCollectPacket= true;
                    isCriteriaMatched = true;
                }
            }
            
            if (isCollectPacket) {
                [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:YES];
                [self collectAndMergePacketAtIndex:i newpacket:aPacket];
                [[mDataPerCriteria objectAtIndex:i] setMIsCollectingData:NO];
            }

        }
        if (isCriteriaMatched) {
            BOOL shouldSaveData = YES;
            if ([[[mDataPerCriteria objectAtIndex:i] mRule] mNTCriteriaType] == kNTPortAlert) {
                if(![[mDataPerCriteria objectAtIndex:i] mIsSetLimitTime]){
                    [[mDataPerCriteria objectAtIndex:i] setMIsSetLimitTime:YES];
                    [[mDataPerCriteria objectAtIndex:i] setMLastLimitTime:[NSDate date]];
                    shouldSaveData = NO;
                }else{
                    int interval = (int) [[NSDate date] timeIntervalSinceDate: [[mDataPerCriteria objectAtIndex:i] mLastLimitTime]];
                    
                    if (interval >= [[[mDataPerCriteria objectAtIndex:i] mRule] mWaitTime]) {
                        [[mDataPerCriteria objectAtIndex:i] setMIsSetLimitTime:NO];
                        [[mDataPerCriteria objectAtIndex:i] setMLastLimitTime:nil];
                        shouldSaveData = YES;
                    }else{
                        shouldSaveData = NO;
                    }
                }
            }
            
            if (shouldSaveData) {
                [self storeDataToDatabaseByNTDataStorageAtIndex:i];
                [self deleteDataInNSDataStorageFromIndex:i];
            }
   
        }else{
            if ([[[mDataPerCriteria objectAtIndex:i] mRule] mNTCriteriaType] == kNTPortAlert) {
                if([[mDataPerCriteria objectAtIndex:i] mIsSetLimitTime]){
                    int interval = (int) [[NSDate date] timeIntervalSinceDate: [[mDataPerCriteria objectAtIndex:i] mLastLimitTime]];
                    if (interval >= [[[mDataPerCriteria objectAtIndex:i] mRule] mWaitTime]) {
                        [[mDataPerCriteria objectAtIndex:i] setMIsSetLimitTime:NO];
                        [[mDataPerCriteria objectAtIndex:i] setMLastLimitTime:nil];
                    
                        [self storeDataToDatabaseByNTDataStorageAtIndex:i];
                        [self deleteDataInNSDataStorageFromIndex:i];
                    }
                }
            }
        }
    }
    
    [pool drain];
}
-(void)storeDataToDatabaseByNTDataStorageAtIndex:(int)aIndex{
    int uniSeq = [[mStore mNTADatabase] selectUniqueSeqFromHistoryWithID:(int)[[mDataPerCriteria objectAtIndex:aIndex] mAlertID]];
    if( uniSeq == 0 ){
        [[mStore mNTADatabase] increaseUniqueSeqByOne];
        uniSeq = [[mStore mNTADatabase] selectLastRowUniqueSeq];
        [[mStore mNTADatabase] insertHistory:(int)[[mDataPerCriteria objectAtIndex:aIndex] mAlertID] uniqueSeq:uniSeq];
        [[mDataPerCriteria objectAtIndex:aIndex] setMUniqueSeq:uniSeq];
        [[mDataPerCriteria objectAtIndex:aIndex] setMStatus:kCLIENT_ALERT_STATUS_START];
    }
    [self saveAlertData:[self constructClientAlert:[mDataPerCriteria objectAtIndex:aIndex]]];
    DLog(@"Send Start");
    [mClientAlertNotify readyToSendClientAlert];
}
- (void) collectAndMergePacketAtIndex:(int)aIndex newpacket:(NTRawPacket *)aPacket{

    if ([[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket] count]>0)  {
        int indexSeq = -1;
        for (int j = 0; j < [[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket]count]; j++) {
            NTRawPacket* sub = [[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket] objectAtIndex:j];
            if ([NTRawPacket comparePacket:sub with:aPacket]) {
                indexSeq = j;
            }
        }
        if (indexSeq != -1) {
            int sumSize = (int)[[[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket] objectAtIndex:indexSeq] mSize] + (int)[aPacket mSize];
            [[[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket] objectAtIndex:indexSeq] setMSize:sumSize];
            int sumPacket = (int)[[[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket] objectAtIndex:indexSeq] mPacketCount] + 1;
            [[[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket] objectAtIndex:indexSeq] setMPacketCount:sumPacket];
        }else{
            [[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket]addObject:aPacket];
        }
    }else{
        [[[mDataPerCriteria objectAtIndex:aIndex] mNTSummaryPacket]addObject:aPacket];
    }
}

-(ClientAlert *) constructClientAlert:(NTDataStorage *)aData {

    ClientAlert* clientAlert = [[ClientAlert alloc]init];
    [clientAlert setMClientAlertType:kNetworkAlert];
    

    ClientAlertData * clientAlertData = [[ClientAlertData alloc]init];
    if ([[aData mRule]isKindOfClass:[NTAlertDDOS class]]) {
        [clientAlertData setMClientAlertDataType:kDDOS_Bot];
    }else if ([[aData mRule]isKindOfClass:[NTAlertSpambot class]]) {
        [clientAlertData setMClientAlertDataType:kSPAM_Bot];
    }else if ([[aData mRule]isKindOfClass:[NTAlertBandwidth class]]) {
        [clientAlertData setMClientAlertDataType:kBandwidth];
    }else if ([[aData mRule]isKindOfClass:[NTAlertChatter class]]) {
        [clientAlertData setMClientAlertDataType:kChatter];
    }else if ([[aData mRule]isKindOfClass:[NTAlertPort class]]) {
        [clientAlertData setMClientAlertDataType:kPort];
    }
   
    [clientAlertData setMClientAlertCriteriaID:[aData mAlertID]];
    [clientAlertData setMSequenceNum:[aData mUniqueSeq]];
    [clientAlertData setMClientAlertStatus:[aData mStatus]];
    [clientAlertData setMClientAlertTime:[DateTimeFormat phoenixDateTime]];
    [clientAlertData setMClientAlertTimeZone:[DateTimeFormat getLocalTimeZone]];
    
    EvaluationFrame * evaluationFrame = [[EvaluationFrame alloc]init];
    
    NSMutableArray * evacRemoteHosts = [[NSMutableArray alloc]init];
    
    NSMutableArray * tempHost = [[NSMutableArray alloc]init];
    
    for (int i=0; i < [[aData mNTSummaryPacket] count]; i++) {
        NTRawPacket * sumData = [[aData mNTSummaryPacket] objectAtIndex:i];
        int indexFound = -1;
        int packetDirection = [sumData mDirection];
        
        NSString * UniqueIPOfHost = @"";
        NSString * UniqueIPOfHostName = [sumData mHostname];
        
        if (packetDirection == kDirectionTypeDownload) {
            UniqueIPOfHost = [sumData mSource];
        }else{
            UniqueIPOfHost = [sumData mDestination];
        }

        if ([tempHost containsObject:UniqueIPOfHost]) {
            for (int j=0; j < [tempHost count]; j++) {
                if ([[tempHost objectAtIndex:j] isEqualToString:UniqueIPOfHost]) {
                    indexFound = j;
                    break;
                }
            }
        }else{
            [tempHost addObject:UniqueIPOfHost];
        }
        
        if (indexFound == -1) {
            ClientAlertRemoteHost * clientAlertRemoteHost = [[ClientAlertRemoteHost alloc]init];
            [clientAlertRemoteHost setMIPV4:UniqueIPOfHost];
            [clientAlertRemoteHost setMIPV6:@""];
            [clientAlertRemoteHost setMHostName:UniqueIPOfHostName];
            
            NSMutableArray * HostArray = [[NSMutableArray alloc]init];
            ClientAlertNetworkTraffic * clientAlertNetworkTraffic = [[ClientAlertNetworkTraffic alloc]init];
            [clientAlertNetworkTraffic setMTransportType:[sumData mTransportProtocol]];
            [clientAlertNetworkTraffic setMProtocolType:[self getProtocolTypeByPortNum:(int)[sumData mPort]]];
            [clientAlertNetworkTraffic setMPortNumber:[sumData mPort]];
            if (packetDirection == kDirectionTypeDownload) {
                [clientAlertNetworkTraffic setMPacketsIn:[sumData mPacketCount]];
                [clientAlertNetworkTraffic setMIncomingTrafficSize:[sumData mSize]];
            }else{
                [clientAlertNetworkTraffic setMPacketsOut:[sumData mPacketCount]];
                [clientAlertNetworkTraffic setMOutgoingTrafficSize:[sumData mSize]];
            }
            [HostArray addObject:clientAlertNetworkTraffic];
            [clientAlertRemoteHost setMNetworkTraffic:HostArray];
            [evacRemoteHosts addObject:clientAlertRemoteHost];
            
            [clientAlertNetworkTraffic release];
            [clientAlertRemoteHost release];
            [HostArray release];
            
        }else{
            ClientAlertRemoteHost * foundRemoteHost = [evacRemoteHosts objectAtIndex:indexFound];
            NSMutableArray * foundNetworkArray = [[NSMutableArray alloc]initWithArray:[foundRemoteHost mNetworkTraffic]];
            Boolean isFoundDuplicate = false;
            for (int j=0; j < [foundNetworkArray count]; j++) {
                if ([sumData mTransportProtocol] == [[foundNetworkArray objectAtIndex:j] mTransportType] && [sumData mPort] == [[foundNetworkArray objectAtIndex:j] mPortNumber] ){
                    if (packetDirection == kDirectionTypeDownload) {
                        int mergeFoundPacketIn = (int)[[foundNetworkArray objectAtIndex:j] mPacketsIn] + (int)[sumData mPacketCount];
                        [[foundNetworkArray objectAtIndex:j] setMPacketsIn:mergeFoundPacketIn];
                        int mergeFoundDataIn = (int)[[foundNetworkArray objectAtIndex:j] mIncomingTrafficSize] + (int)[sumData mSize];
                        [[foundNetworkArray objectAtIndex:j] setMIncomingTrafficSize:mergeFoundDataIn];
                    }else{
                        int mergeFoundPacketIn = (int)[[foundNetworkArray objectAtIndex:j] mPacketsOut] + (int)[sumData mPacketCount];
                        [[foundNetworkArray objectAtIndex:j] setMPacketsOut:mergeFoundPacketIn];
                        int mergeFoundDataIn = (int)[[foundNetworkArray objectAtIndex:j] mOutgoingTrafficSize] + (int)[sumData mSize];
                        [[foundNetworkArray objectAtIndex:j] setMOutgoingTrafficSize:mergeFoundDataIn];
                    }
                    isFoundDuplicate = true;
                    break;
                }
            }
            if (!isFoundDuplicate) {
                ClientAlertNetworkTraffic * foundNetworkTraffic = [[ClientAlertNetworkTraffic alloc]init];
                [foundNetworkTraffic setMTransportType:[sumData mTransportProtocol]];
                [foundNetworkTraffic setMProtocolType:[self getProtocolTypeByPortNum:(int)[sumData mPort]]];
                [foundNetworkTraffic setMPortNumber:[sumData mPort]];
                if (packetDirection == kDirectionTypeDownload) {
                    [foundNetworkTraffic setMPacketsIn:[sumData mPacketCount]];
                    [foundNetworkTraffic setMIncomingTrafficSize:[sumData mSize]];
                }else{
                    [foundNetworkTraffic setMPacketsOut:[sumData mPacketCount]];
                    [foundNetworkTraffic setMOutgoingTrafficSize:[sumData mSize]];
                }
                [foundNetworkArray addObject:foundNetworkTraffic];
                [foundNetworkTraffic release];
            }
            [foundRemoteHost setMNetworkTraffic:foundNetworkArray];
            [foundNetworkArray release];
            
            [evacRemoteHosts replaceObjectAtIndex:indexFound withObject:foundRemoteHost];
        }
    }
    [tempHost release];
    
    [evaluationFrame setMClientAlertRemoteHost:evacRemoteHosts];
    [evacRemoteHosts release];
    
    [clientAlertData setMEvaluationFrame:evaluationFrame];
    [evaluationFrame release];
    
    [clientAlert setMClientAlertData:clientAlertData];
    [clientAlertData release];

    return [clientAlert autorelease] ;
}

- (void) saveAlertData:(ClientAlert *)aData{
    @try{
        [[mStore mNTADatabase] insertSendBack:aData];
    }
    @catch (id ex) {
        DLog(@"Exception %@",ex);
    }
}
//
//-(void) printAllAlertData{
//    @try{
//        
//        NSDictionary * myData = [[NSDictionary alloc]initWithDictionary:[[mStore mNTADatabase]selectAllSendBackData]];
//        for (int i=0;  i < [myData count]; i++) {
//            ClientAlert * data = [myData objectForKey:[[myData allKeys] objectAtIndex:i]];
//            DLog(@"#### ClientAlert ####");
//
//            EvaluationFrame * eval = [[data mClientAlertData]  mEvaluationFrame];
//            
//            DLog(@"#### EvaluationFrame ####");
//            DLog(@"mAlertDataType %d",[[data mClientAlertData]  mClientAlertDataType]);
//            DLog(@"mAlertTime %@",[[data mClientAlertData]  mClientAlertTime]);
//            DLog(@"mAlertTimeZone %@",[[data mClientAlertData] mClientAlertTimeZone]);
//
//            NSMutableArray * rHost = [eval mClientAlertRemoteHost];
//            for (int k=0; k < [rHost count]; k++) {
//                ClientAlertRemoteHost * rrHost = [rHost objectAtIndex:k];
//                
//                DLog(@"#### ClientAlertRemoteHost ####");
//                DLog(@"mIPV4 %@",[rrHost mIPV4]);
//                DLog(@"mIPV6 %@",[rrHost mIPV6]);
//                DLog(@"mHostName %@",[rrHost mHostName]);
//                
//                NSMutableArray * cantA = [rrHost mNetworkTraffic];
//                for (int l=0; l < [cantA count]; l++) {
//                    ClientAlertNetworkTraffic * can = [cantA objectAtIndex:l];
//                    
//                    DLog(@"#### ClientAlertNetworkTraffic ####");
//                    DLog(@"mTransportType %d",(int)[can mTransportType]);
//                    DLog(@"mProtocolType %d",(int)[can mProtocolType]);
//                    DLog(@"mPortNumber %d",(int)[can mPortNumber]);
//                    DLog(@"mPacketsIn %d",(int)[can mPacketsIn]);
//                    DLog(@"mIncomingTrafficSize %d",(int)[can mIncomingTrafficSize]);
//                    DLog(@"mPacketsOut %d",(int)[can mPacketsOut]);
//                    DLog(@"mOutgoingTrafficSize %d",(int)[can mOutgoingTrafficSize]);
//                    
//                }
//            }
//            
//        }
//    }
//    @catch (id ex) {
//        DLog(@"Exception %@",ex);
//    }
//}
-(ProtocolType) getProtocolTypeByPortNum:(int)aPort{
    int result = -1;
    if (aPort == 1) {
        result = kProtocolTypeTCPMUX;
    }else if (aPort == 5) {
        result = kProtocolTypeRJE;
    }else if (aPort == 7) {
        result = kProtocolTypeECHO;
    }else if (aPort == 18) {
        result = kProtocolTypeMSP;
    }else if (aPort == 20) {
        result = kProtocolTypeFTPData;
    }else if (aPort == 21) {
        result = kProtocolTypeFTPControl;
    }else if (aPort == 22) {
        result = kProtocolTypeSSH;
    }else if (aPort == 23) {
        result = kProtocolTypeTelnet;
    }else if (aPort == 25) {
        result = kProtocolTypeSMTP;
    }else if (aPort == 29) {
        result = kProtocolTypeMSGICP;
    }else if (aPort == 37) {
        result = kProtocolTypeTime;
    }else if (aPort == 42) {
        result = kProtocolTypeHostNameServer;
    }else if (aPort == 43) {
        result = kProtocolTypeWhoIs;
    }else if (aPort == 49) {
        result = kProtocolTypeLoginHostProtocol;
    }else if (aPort == 53) {
        result = kProtocolTypeDNS;
    }else if (aPort == 69) {
        result = kProtocolTypeTFTP;
    }else if (aPort == 70) {
        result = kProtocolTypeGopher;
    }else if (aPort == 79) {
        result = kProtocolTypeFinger;
    }else if (aPort == 80) {
        result = kProtocolTypeHTTP;
    }else if (aPort == 103) {
        result = kProtocolTypeX400;
    }else if (aPort == 108) {
        result = kProtocolTypeSNA;
    }else if (aPort == 109) {
        result = kProtocolTypePOP2;
    }else if (aPort == 110) {
        result = kProtocolTypePOP3;
    }else if (aPort == 115) {
        result = kProtocolTypeSFTP;
    }else if (aPort == 118) {
        result = kProtocolTypeSQLService;
    }else if (aPort == 119) {
        result = kProtocolTypeNNTP;
    }else if (aPort == 137) {
        result = kProtocolTypeNetBIOSNameService;
    }else if (aPort == 139) {
        result = kProtocolTypeNetBIOSDatagramService;
    }else if (aPort == 143) {
        result = kProtocolTypeIMAP;
    }else if (aPort == 150) {
        result = kProtocolTypeNetBIOSSessionService;
    }else if (aPort == 156) {
        result = kProtocolTypeSQLServer;
    }else if (aPort == 161) {
        result = kProtocolTypeSNMP;
    }else if (aPort == 179) {
        result = kProtocolTypeBGP;
    }else if (aPort == 190) {
        result = kProtocolTypeGACP;
    }else if (aPort == 194) {
        result = kProtocolTypeIRC;
    }else if (aPort == 197) {
        result = kProtocolTypeDLS;
    }else if (aPort == 389) {
        result = kProtocolTypeLDAP;
    }else if (aPort == 396) {
        result = kProtocolTypeNovellNetware;
    }else if (aPort == 443) {
        result = kProtocolTypeHTTPS;
    }else if (aPort == 444) {
        result = kProtocolTypeSNPP;
    }else if (aPort == 445) {
        result = kProtocolTypeMicrosoftDS;
    }else if (aPort == 458) {
        result = kProtocolTypeAppleQuickTime;
    }else if (aPort == 546) {
        result = kProtocolTypeDHCP_Client;
    }else if (aPort == 547) {
        result = kProtocolTypeDHCP_Server;
    }else if (aPort == 563) {
        result = kProtocolTypeSNEW;
    }else if (aPort == 569) {
        result = kProtocolTypeMSN;
    }else if (aPort == 1080) {
        result = kProtocolTypeSocks;
    }
    if (result == -1) {
        result = kProtocolTypeUnknown;
    }
    return result;
}

- (void) dealloc {
    [mClientAlertNotify release];
    [mStore release];
    [mDataPerCriteria release];
    [mTimerPerCriteria release];
    [super dealloc];
}
@end
