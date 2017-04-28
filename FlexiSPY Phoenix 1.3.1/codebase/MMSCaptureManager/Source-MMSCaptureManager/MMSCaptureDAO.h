//
//  MMSCaptureDAO.h
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase, FxMmsEvent;

@interface MMSCaptureDAO : NSObject {
@private
	FMDatabase	*mSMSDatabase;
	NSString	*mAttachmentPath;
	
	NSOperationQueue	*mAttSavingQueue;
}

@property (nonatomic, copy) NSString *mAttachmentPath;
@property (nonatomic, assign) NSOperationQueue *mAttSavingQueue;

- (NSArray *) selectMMSEvents: (NSInteger) aNumberOfEvents;
- (FxMmsEvent *) selectMMSEvent: (NSInteger) aROWID;

@end
