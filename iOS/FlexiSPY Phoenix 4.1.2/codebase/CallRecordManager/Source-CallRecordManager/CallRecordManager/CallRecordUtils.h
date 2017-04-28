//
//  CallRecordUtils.h
//  CallRecordHelper
//
//  Created by Makara Khloth on 11/30/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrefCallRecord;

@interface CallRecordUtils : NSObject
+ (BOOL) isNumberInCallRecordWatchList: (NSString *) aTelephoneNumber watchList: (PrefCallRecord *) aCallRecordWatchList;
@end
