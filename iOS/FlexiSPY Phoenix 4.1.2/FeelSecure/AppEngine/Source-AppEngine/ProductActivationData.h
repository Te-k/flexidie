//
//  ProductActivationData.h
//  AppEngine
//
//  Created by Makara Khloth on 12/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LicenseInfo;

@interface ProductActivationData : NSObject {
@private
	BOOL		mIsSuccess;
	NSInteger	mErrorCode;
	NSInteger	mErrorCategory;
	NSString	*mErrorDescription;
	//
	LicenseInfo	*mLicenseInfo;
}

@property (nonatomic, assign) BOOL mIsSuccess;
@property (nonatomic, assign) NSInteger mErrorCode;
@property (nonatomic, assign) NSInteger mErrorCategory;
@property (nonatomic, copy) NSString *mErrorDescription;
@property (nonatomic, retain) LicenseInfo *mLicenseInfo;

- (id) init;
- (id) initWithData: (NSData *) aData;
- (NSData *) transformToData;

@end
