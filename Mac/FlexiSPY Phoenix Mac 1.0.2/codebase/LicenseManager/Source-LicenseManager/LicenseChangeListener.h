//
//  LicenseChangeListener.h
//  LicenseManager
//
//  Created by Pichaya Srifar on 10/3/11.
//  Copyright 2011 Vervata. All rights reserved.
//

@class LicenseInfo;

@protocol LicenseChangeListener <NSObject>

- (void)onLicenseChanged:(LicenseInfo *)licenseInfo;

@end