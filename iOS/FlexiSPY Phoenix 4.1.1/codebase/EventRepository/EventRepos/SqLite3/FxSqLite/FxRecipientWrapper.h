//
//  FxRecipientWrapper.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxRecipient;

@interface FxRecipientWrapper : NSObject {
@private
	FxRecipient*	recipient;
	NSUInteger		emailId;
	NSUInteger		mmsId;
	NSUInteger		smsId;
	NSUInteger		mIMID;
}

@property (nonatomic, retain) FxRecipient* recipient;
@property (nonatomic, assign) NSUInteger emailId;
@property (nonatomic, assign) NSUInteger mmsId;
@property (nonatomic, assign) NSUInteger smsId;
@property (nonatomic, assign) NSUInteger mIMID;

@end
