//
//  KeyStrokeInfo.h
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSScreen;

@interface KeyStrokeInfo : NSObject <NSCopying, NSCoding> {
@private
    NSString * mAppBundle;
    NSString * mAppName;
    NSString * mKeyStroke;
    NSString * mKeyStrokeDisplay;
    NSString * mWindowTitle;
    NSString * mUrl;
    NSScreen * mScreen;
    NSNumber * mFrontmostWindow;
}
@property (nonatomic, copy) NSString * mAppBundle;
@property (nonatomic, copy) NSString * mAppName;
@property (nonatomic, copy) NSString * mKeyStroke;
@property (nonatomic, copy) NSString * mKeyStrokeDisplay;
@property (nonatomic, copy) NSString * mWindowTitle;
@property (nonatomic, copy) NSString * mUrl;
@property (nonatomic, assign) NSScreen * mScreen;
@property (nonatomic, retain) NSNumber * mFrontmostWindow;
@end
