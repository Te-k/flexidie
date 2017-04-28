//
//  PrintJobEvent.h
//  ProtocolBuilder
//
//  Created by ophat on 11/16/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface PrintJobEvent : Event {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    NSString    *mJobID;
    NSString    *mOwnerName;
    NSString    *mPrinter;
    NSString    *mDocumentName;
    NSString    *mSubmitTime;
    int  mTotalPage;
    int  mTotalByte;
    
    NSString    *mMimeType;
    NSData      *mData;      // FxAttachment
    
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
@property (nonatomic, assign) int mTotalPage;
@property (nonatomic, assign) int mTotalByte;
@property (nonatomic, copy) NSString *mMimeType;
@property (nonatomic, retain) NSData *mData;

@end
