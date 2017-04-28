//
//  MMSAttachmentUtils.h
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKDBMessage;

@interface MMSAttachmentUtils : NSObject {
@private
	NSString			*mAttachmentPath;
	NSOperationQueue	*mAttSavingQueue;
}

@property (nonatomic, copy) NSString *mAttachmentPath;
@property (nonatomic, assign) NSOperationQueue *mAttSavingQueue;

- (NSMutableArray *) getAttachments: (CKDBMessage *) aCKDBMessage;
- (NSMutableArray *) getAttachments8: (CKDBMessage *) aCKDBMessage; // iOS 8

@end
