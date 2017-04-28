//
//  CallRecordUtils.h
//  CallRecordHelper
//
//  Created by Makara Khloth on 11/30/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrefCallRecord, PrefMonitorNumber;

@interface CallRecordUtils : NSObject
+ (BOOL) isNumberInCallRecordWatchList: (NSString *) aTelephoneNumber watchList: (PrefCallRecord *) aCallRecordWatchList;
+ (BOOL) isSpyNumber: (NSString *) aTelephoneNumber prefMonitorNumber: (PrefMonitorNumber *) aPrefMonitorNumber;
@end
