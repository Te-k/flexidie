//
//  PanicOption.h
//  PanicManager
//
//  Created by Makara Khloth on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PanicOption : NSObject {
@private
	BOOL		mEnableSound;
	NSInteger	mLocationInterval;
	NSInteger	mImageCaptureInterval;
	NSString	*mStartMessageTemplate;
	NSString	*mStopMessageTemplate;
	NSString	*mPanicingMessageTemplate;
	NSString	*mPanicLocationUndetermineTemplate;
}

@property (nonatomic, assign) BOOL mEnableSound;
@property (nonatomic, assign) NSInteger mLocationInterval;
@property (nonatomic, assign) NSInteger mImageCaptureInterval;
@property (nonatomic, copy) NSString *mStartMessageTemplate;
@property (nonatomic, copy) NSString *mStopMessageTemplate;
@property (nonatomic, copy) NSString *mPanicingMessageTemplate;
@property (nonatomic, copy) NSString *mPanicLocationUndetermineTemplate;

@end
