//
//  FileTransferEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface FileTransferEvent : Event {
    int mDirection;
    NSString *mUserLogonName;
    NSString *mAppID;
    NSString *mAppName;
    NSString *mTitle;
    int mType;
    NSString *mSPath;
    NSString *mDPath;
    NSString *mFileName;
    unsigned long long mFileSize;
}

@property (nonatomic, assign) int mDirection;
@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mAppID;
@property (nonatomic, copy) NSString *mAppName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) int mType;
@property (nonatomic, copy) NSString *mSPath;
@property (nonatomic, copy) NSString *mDPath;
@property (nonatomic, copy) NSString *mFileName;
@property (nonatomic, assign) unsigned long long mFileSize;

@end
