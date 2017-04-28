//
//  FxAttachmentWrapper.h
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxAttachment;

@interface FxAttachmentWrapper : NSObject {
@private
	FxAttachment*	attachment;
	NSUInteger		emailId;
	NSUInteger		mmsId;
	NSUInteger		mIMID;
}

@property (nonatomic, retain) FxAttachment* attachment;
@property (nonatomic, assign) NSUInteger emailId;
@property (nonatomic, assign) NSUInteger mmsId;
@property (nonatomic, assign) NSUInteger mIMID;

@end
