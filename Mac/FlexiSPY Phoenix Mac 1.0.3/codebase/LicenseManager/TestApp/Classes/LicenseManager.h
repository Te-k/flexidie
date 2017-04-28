//
//  LicenseManager.h
//  LicenseManager
//
//  Created by Pichaya Srifar on 10/3/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LicenseStatusEnum.h"
#import "LicenseChangeListener.h"

@class LicenseInfo;

@interface LicenseManager : NSObject {
    NSMutableArray *mListenerList;
    LicenseInfo *mCurrentLicenseInfo;
    NSString *mFilePath;
}
@property (nonatomic, retain) NSMutableArray *mListenerList;
@property (nonatomic, retain) LicenseInfo *mCurrentLicenseInfo;
@property (nonatomic, copy) NSString *mFilePath;

- (BOOL)commitLicense:(LicenseInfo *)licenseInfo;
- (NSString *)getActivationCode;
- (NSInteger)getConfiguration;
- (LicenseStatus)getLicenseStatus;
- (NSData *)getMD5;
- (BOOL)isActivated:(NSInteger)configID withMD5:(NSData *)MD5;
- (void)addLicenseChangeListener:(id<LicenseChangeListener>)listener;
- (void)removeLicenseChangeListener:(id<LicenseChangeListener>)listener;
- (void)removeAllLicenseChangeListener;
@end
