//
//  LicenseInfo.h
//  LicenseManager
//
//  Created by Pichaya Srifar on 10/3/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LicenseStatusEnum.h"

@interface LicenseInfo : NSObject {
    LicenseStatus licenseStatus;
    NSInteger configID;
    NSString *activationCode;
    NSData *md5;
}

@property (nonatomic, assign) LicenseStatus licenseStatus;
@property (nonatomic, assign) NSInteger configID;
@property (nonatomic, retain) NSString *activationCode;
@property (nonatomic, retain) NSData *md5;

- (id) initWithData: (NSData *) aData;
- (NSData *) transformToData;

@end
