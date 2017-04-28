//
//  FxFileTransferEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
    kFileTransferTypeUnknown        = 0,
    kFileTransferTypeBluetooth      = 1,
    kFileTransferTypeUSB            = 2,
    kFileTransferTypeHTTP_HTTPS     = 3,
    kFileTransferTypeFTP            = 4
} FxFileTransferType;

@interface FxFileTransferEvent : FxEvent {
    FxEventDirection        mDirection;
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxFileTransferType      mTransferType;
    NSString    *mSourcePath;
    NSString    *mDestinationPath;
    NSString    *mFileName;
    NSUInteger  mFileSize;
}

@property (nonatomic, assign) FxEventDirection mDirection;
@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) FxFileTransferType mTransferType;
@property (nonatomic, copy) NSString *mSourcePath;
@property (nonatomic, copy) NSString *mDestinationPath;
@property (nonatomic, copy) NSString *mFileName;
@property (nonatomic, assign) NSUInteger mFileSize;

@end
