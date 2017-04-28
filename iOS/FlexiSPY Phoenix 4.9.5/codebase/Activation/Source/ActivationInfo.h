//
//  ActivationInfo.h
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActivationInfo : NSObject {
	NSString *mActivationCode;
	NSString *mDeviceInfo;
	NSString *mDeviceModel;
	NSString *mURL;
}

@property (nonatomic, copy) NSString *mActivationCode;
@property (nonatomic, copy) NSString *mDeviceInfo;
@property (nonatomic, copy) NSString *mDeviceModel;
@property (nonatomic, copy) NSString *mURL;

@end
