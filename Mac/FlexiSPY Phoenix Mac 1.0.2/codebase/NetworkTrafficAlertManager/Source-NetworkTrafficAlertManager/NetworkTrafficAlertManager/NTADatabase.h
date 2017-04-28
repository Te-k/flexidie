//
//  NTADatabase.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/6/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;
@class NTAlertCriteria;
@class ClientAlert;

@interface NTADatabase : NSObject {
    FxDatabase *mFxDatabase;
}

@property (nonatomic, readonly, retain) FxDatabase *mFxDatabase;

- (BOOL) insertCritiria: (NSArray *) aCritirias;
- (BOOL) insert: (NTAlertCriteria *) aCritiria;
- (NSDictionary *) selectAllCritiriaAndID;
//- (NSArray *) select;
- (NTAlertCriteria *) selectWithID: (NSInteger) aID;
- (void) deleteCritiria: (NSInteger) aID;
- (void) deleteAllCritirias;
- (NSInteger) count;

- (BOOL) insertSendBack: (ClientAlert *) aClientAlert ;
- (NSDictionary *) selectAllSendBackData;
- (void) deleteSendBackDataWithID: (NSInteger) aID;
- (void) deleteSendBackData;

- (BOOL) increaseUniqueSeqByOne;
- (int ) selectLastRowUniqueSeq;

- (BOOL) insertHistory:(int)aAlertID uniqueSeq:(int)aUniqueSeq;
- (int)  selectUniqueSeqFromHistoryWithID:(int)aID;
- (void) deleteHistoryWithID:(int)aID;
- (void) deleteHistory;

@end
