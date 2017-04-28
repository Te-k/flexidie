//
//  LabelCreator.h
//  DeviceLockManagerUtil
//
//  Created by Benjawan Tanarattanakorn on 8/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UICreator : NSObject {
@private
		UILabel		*mUserTextLabel;	// This is retained
	
	NSString		*mBundleName;
	NSString		*mBundleIdentifier;
}

@property (nonatomic, copy) NSString *mBundleName;
@property (nonatomic, copy) NSString *mBundleIdentifier;

+ (id) sharedUICreator;

- (UIView *) createLockScreenWithText: (NSString *) aUserText;
- (void) updateUserText: (NSString *) aUserText forView: (UIView *) aView;

@end
