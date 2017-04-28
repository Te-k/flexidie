//
//  ActivationResponseInfo.h
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActivationResponse : NSObject {
	BOOL mSuccess;
	BOOL mActivated;
	NSInteger mResponseCode;
	NSInteger mHTTPStatusCode;
	NSString *mMessage;
	NSString *mActivationCode;
	NSData *mMD5;
	NSInteger mConfigID;
	NSInteger mEchoCommand;
	NSInteger mErrorCategory;
}

@property (nonatomic, assign, getter=isMSuccess) BOOL mSuccess;
@property (nonatomic, assign, getter=isMActivated) BOOL mActivated;
@property (nonatomic, assign) NSInteger mResponseCode;
@property (nonatomic, assign) NSInteger mHTTPStatusCode;
@property (nonatomic, copy) NSString *mMessage;
@property (nonatomic, copy) NSString *mActivationCode;
@property (nonatomic, retain) NSData *mMD5;
@property (nonatomic, assign) NSInteger mConfigID;
@property (nonatomic, assign) NSInteger mEchoCommand;
@property (nonatomic, assign) NSInteger mErrorCategory;

@end
