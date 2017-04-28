//
//  FxPrintJobEvent.h
//  FxEvents
//
//  Created by ophat on 11/16/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

@interface FxPrintJobEvent : FxEvent {
    
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    NSString    *mJobID;
    NSString    *mOwnerName;
    NSString    *mPrinter;
    NSString    *mDocumentName;
    NSString    *mSubmitTime;
    NSUInteger  mTotalPage;
    NSUInteger  mTotalByte;
    NSString    *mPathToData;

}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mJobID;
@property (nonatomic, copy) NSString *mOwnerName;
@property (nonatomic, copy) NSString *mPrinter;
@property (nonatomic, copy) NSString *mDocumentName;
@property (nonatomic, copy) NSString *mSubmitTime;
@property (nonatomic, assign) NSUInteger mTotalPage;
@property (nonatomic, assign) NSUInteger mTotalByte;
@property (nonatomic, retain) NSString *mPathToData;

@end
