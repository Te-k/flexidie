//
//  ProductMetaData.h
//  AppEngine
//
//  Created by Makara Khloth on 12/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LicenseInfo;

@interface ProductMetaData : NSObject {
@private
	NSInteger	mConfigID;
	NSInteger	mProductID;
	NSInteger	mProtocolLanguage;
	NSInteger	mProtocolVersion;
	
	NSString	*mProductVersion;
	NSString	*mProductName;
	NSString	*mProductDescription;
	NSString	*mProductLanguage;
	NSString	*mLicenseHashTail;
	NSString	*mProductVersionDescription;
}

@property (nonatomic, assign) NSInteger mConfigID;
@property (nonatomic, assign) NSInteger mProductID;
@property (nonatomic, assign) NSInteger mProtocolLanguage;
@property (nonatomic, assign) NSInteger mProtocolVersion;
@property (nonatomic, copy) NSString *mProductVersion;
@property (nonatomic, copy) NSString *mProductName;
@property (nonatomic, copy) NSString *mProductDescription;
@property (nonatomic, copy) NSString *mProductLanguage;
@property (nonatomic, copy) NSString *mLicenseHashTail;
@property (nonatomic, copy) NSString *mProductVersionDescription;

- (id) init;
- (id) initWithData: (NSData *) aData;
- (NSData *) transformToData;

@end
